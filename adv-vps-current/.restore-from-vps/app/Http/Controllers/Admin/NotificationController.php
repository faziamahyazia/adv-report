<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Notifications\AdminInfoNotification;
use App\Notifications\AdminInfoReadNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Notifications\DatabaseNotification;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Notification;
use Inertia\Response;

class NotificationController extends Controller
{
    /**
     * @return array<int, string>
     */
    private function senderRoles(): array
    {
        return [User::Role_Admin, User::Role_Agronomist];
    }

    private function ensureSenderAccess(): void
    {
        $role = Auth::user()?->role;

        if (!in_array($role, $this->senderRoles(), true)) {
            abort(403, 'Hanya Admin/Agronomis yang dapat mengirim notifikasi info.');
        }
    }

    /**
     * @return array<int, array{label: string, value: string}>
     */
    private function targetRoleOptions(): array
    {
        return collect(User::Roles)
            ->map(fn(string $label, string $value) => [
                'label' => $label,
                'value' => $value,
            ])
            ->values()
            ->all();
    }

    /**
     * @return array<int, array{label: string, value: int, role: string, caption: string}>
     */
    private function availableUserOptions(int $excludeUserId): array
    {
        return User::query()
            ->where('active', true)
            ->where('id', '!=', $excludeUserId)
            ->orderBy('name')
            ->get(['id', 'name', 'role'])
            ->map(fn(User $user) => [
                'label' => $user->name,
                'value' => (int) $user->id,
                'role' => $user->role,
                'caption' => User::Roles[$user->role] ?? $user->role,
            ])
            ->values()
            ->all();
    }

    public function index(Request $request): Response
    {
        $this->ensureSenderAccess();

        return inertia('admin/notification/Index', [
            'recipient_role_options' => $this->targetRoleOptions(),
            'recipient_user_options' => $this->availableUserOptions((int) $request->user()->id),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $this->ensureSenderAccess();

        $validated = $request->validate([
            'target_mode' => 'required|in:all,role,users',
            'target_role' => 'exclude_unless:target_mode,role|required|string|in:' . implode(',', array_keys(User::Roles)),
            'user_ids' => 'exclude_unless:target_mode,users|required|array|min:1',
            'user_ids.*' => 'exclude_unless:target_mode,users|integer|exists:users,id',
            'title' => 'required|string|max:120',
            'message' => 'required|string|max:2000',
            'url' => 'nullable|string|max:255',
        ]);

        $sender = $request->user();
        $recipients = $this->resolveRecipients($validated, $sender);

        if ($recipients->isEmpty()) {
            return back()->with('error', 'Tidak ada penerima aktif yang cocok untuk notifikasi ini.');
        }

        $payload = [
            'title' => $validated['title'],
            'message' => $validated['message'],
            'url' => $this->normalizeUrl($validated['url'] ?? null),
            'sent_by_id' => $sender->id,
            'sent_by_name' => $sender->name,
            'sent_by_role' => $sender->role,
            'target_mode' => $validated['target_mode'],
            'target_role' => $validated['target_role'] ?? null,
        ];

        [$sentCount, $failedCount] = $this->sendInfoNotificationToRecipients($recipients, $payload);

        if ($sentCount === 0) {
            return back()->with('error', 'Notifikasi gagal dikirim ke semua penerima target.');
        }

        if ($failedCount > 0) {
            return back()->with('success', 'Notifikasi terkirim ke ' . $sentCount . ' user. ' . $failedCount . ' user gagal diproses.');
        }

        return back()->with('success', 'Notifikasi berhasil dikirim ke ' . $sentCount . ' user aktif.');
    }

    public function inbox(Request $request): JsonResponse
    {
        $notifications = $request->user()
            ->notifications()
            ->latest()
            ->limit(20)
            ->get()
            ->map(fn(DatabaseNotification $notification) => $this->transformNotification($notification))
            ->values();

        return response()->json([
            'items' => $notifications,
            'unread_count' => $request->user()->unreadNotifications()->count(),
        ]);
    }

    public function pushSubscribe(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'endpoint' => 'required|string|max:500',
            'keys.p256dh' => 'required|string',
            'keys.auth' => 'required|string',
            'content_encoding' => 'nullable|string|max:32',
        ]);

        $request->user()->updatePushSubscription(
            $validated['endpoint'],
            $validated['keys']['p256dh'],
            $validated['keys']['auth'],
            $validated['content_encoding'] ?? 'aes128gcm'
        );

        return response()->json([
            'message' => 'Subscription web push tersimpan.',
        ]);
    }

    public function pushUnsubscribe(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'endpoint' => 'required|string|max:500',
        ]);

        $request->user()->deletePushSubscription($validated['endpoint']);

        return response()->json([
            'message' => 'Subscription web push dihapus.',
        ]);
    }

    public function markAsRead(Request $request, string $id): JsonResponse
    {
        /** @var DatabaseNotification $notification */
        $notification = $request->user()->notifications()->findOrFail($id);

        if ($notification->read_at === null) {
            $notification->markAsRead();
            $this->notifySenderAboutRead($notification, $request->user());
        }

        $notification->refresh();

        return response()->json([
            'item' => $this->transformNotification($notification),
        ]);
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        $unreadNotifications = $request->user()->unreadNotifications()->get();

        foreach ($unreadNotifications as $notification) {
            $this->notifySenderAboutRead($notification, $request->user());
        }

        $request->user()->unreadNotifications()->update([
            'read_at' => now(),
        ]);

        return response()->json([
            'message' => 'Semua notifikasi telah ditandai dibaca.',
        ]);
    }

    /**
     * @param array<string, mixed> $validated
     */
    private function resolveRecipients(array $validated, User $sender): Collection
    {
        $query = User::query()
            ->where('active', true)
            ->where('id', '!=', $sender->id);

        return match ($validated['target_mode']) {
            'all' => $query->orderBy('name')->get(),
            'role' => $query
                ->where('role', $validated['target_role'])
                ->orderBy('name')
                ->get(),
            'users' => $query
                ->whereIn('id', $validated['user_ids'] ?? [])
                ->orderBy('name')
                ->get(),
            default => collect(),
        };
    }

    /**
     * @param array<string, mixed> $payload
     * @return array{0: int, 1: int}
     */
    private function sendInfoNotificationToRecipients(Collection $recipients, array $payload): array
    {
        $sentCount = 0;
        $failedCount = 0;

        foreach ($recipients as $recipient) {
            try {
                Notification::send($recipient, new AdminInfoNotification($payload));
                $sentCount++;
            } catch (\Throwable $exception) {
                $failedCount++;

                Log::warning('Gagal mengirim notifikasi info ke user.', [
                    'recipient_id' => $recipient->id ?? null,
                    'recipient_role' => $recipient->role ?? null,
                    'target_mode' => $payload['target_mode'] ?? null,
                    'error' => $exception->getMessage(),
                ]);
            }
        }

        return [$sentCount, $failedCount];
    }

    private function normalizeUrl(?string $url): ?string
    {
        if ($url === null) {
            return null;
        }

        $url = trim($url);

        if ($url === '') {
            return null;
        }

        if (str_starts_with($url, 'http://') || str_starts_with($url, 'https://')) {
            return $url;
        }

        return str_starts_with($url, '/') ? $url : '/' . $url;
    }

    private function notifySenderAboutRead(DatabaseNotification $notification, User $reader): void
    {
        if ($notification->type !== AdminInfoNotification::class) {
            return;
        }

        $data = is_array($notification->data) ? $notification->data : [];
        $senderId = isset($data['sent_by_id']) ? (int) $data['sent_by_id'] : null;

        if (!$senderId || $senderId === (int) $reader->id) {
            return;
        }

        $sender = User::query()->find($senderId);

        if (!$sender) {
            return;
        }

        Notification::send($sender, new AdminInfoReadNotification([
            'title' => (string) ($data['title'] ?? 'Informasi Baru'),
            'reader_id' => (int) $reader->id,
            'reader_name' => (string) $reader->name,
            'reader_role' => (string) $reader->role,
            'source_notification_id' => $notification->id,
            'url' => '/admin/notifications/info',
        ]));
    }

    /**
     * @return array<string, mixed>
     */
    private function transformNotification(DatabaseNotification $notification): array
    {
        $data = is_array($notification->data) ? $notification->data : [];

        return [
            'id' => $notification->id,
            'title' => (string) ($data['title'] ?? 'Informasi Baru'),
            'message' => (string) ($data['message'] ?? ''),
            'url' => $data['url'] ?? null,
            'sent_by_name' => $data['sent_by_name'] ?? null,
            'sent_by_role' => $data['sent_by_role'] ?? null,
            'context' => $data['context'] ?? null,
            'context_action' => $data['context_action'] ?? null,
            'created_at' => $notification->created_at?->toIso8601String(),
            'read_at' => $notification->read_at?->toIso8601String(),
        ];
    }
}