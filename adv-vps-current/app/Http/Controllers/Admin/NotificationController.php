<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Notifications\AdminInfoNotification;
use App\Notifications\AdminInfoReplyNotification;
use App\Notifications\AdminInfoReadNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Notifications\DatabaseNotification;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Notification;
use NotificationChannels\WebPush\PushSubscription;
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

    public function pushSubscribe(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'endpoint' => 'required|string|max:500',
            'keys' => 'required|array',
            'keys.p256dh' => 'required|string|max:255',
            'keys.auth' => 'required|string|max:255',
            'content_encoding' => 'nullable|string|max:50',
        ]);

        /** @var User $user */
        $user = $request->user();

        PushSubscription::query()
            ->where('endpoint', $validated['endpoint'])
            ->where(function ($query) use ($user) {
                $query
                    ->where('subscribable_id', '!=', $user->id)
                    ->orWhere('subscribable_type', '!=', User::class);
            })
            ->delete();

        $user->updatePushSubscription(
            $validated['endpoint'],
            $validated['keys']['p256dh'],
            $validated['keys']['auth'],
            $validated['content_encoding'] ?? 'aes128gcm'
        );

        return response()->json([
            'message' => 'Langganan notifikasi browser berhasil disimpan.',
        ]);
    }

    public function thread(Request $request, string $id): JsonResponse
    {
        /** @var DatabaseNotification $notification */
        $notification = $request->user()->notifications()->findOrFail($id);
        $threadKey = $this->resolveThreadKey($notification);

        $threadItems = $request->user()
            ->notifications()
            ->where(function ($query) use ($threadKey) {
                $query
                    ->where('id', $threadKey)
                    ->orWhere('data->source_notification_id', $threadKey);
            })
            ->latest()
            ->limit(50)
            ->get()
            ->sortBy('created_at')
            ->values()
            ->map(fn(DatabaseNotification $item) => $this->transformNotification($item))
            ->values();

        return response()->json([
            'thread_key' => $threadKey,
            'items' => $threadItems,
        ]);
    }

    public function reply(Request $request, string $id): JsonResponse
    {
        /** @var DatabaseNotification $notification */
        $notification = $request->user()->notifications()->findOrFail($id);

        $validated = $request->validate([
            'message' => 'nullable|string|max:2000|required_without:attachment',
            'attachment' => 'nullable|file|max:10240|mimes:jpg,jpeg,png,webp,gif,pdf,doc,docx,xls,xlsx,ppt,pptx,zip,rar,txt',
        ]);

        if ($notification->read_at === null) {
            $notification->markAsRead();
            $this->notifySenderAboutRead($notification, $request->user());
        }

        $data = is_array($notification->data) ? $notification->data : [];
        $senderId = isset($data['sent_by_id']) ? (int) $data['sent_by_id'] : null;

        if (!$senderId || $senderId === (int) $request->user()->id) {
            return response()->json([
                'message' => 'Notifikasi ini tidak memiliki tujuan balasan.',
            ], 422);
        }

        $sender = User::query()->find($senderId);

        if (!$sender) {
            return response()->json([
                'message' => 'Pengirim notifikasi tidak ditemukan.',
            ], 404);
        }

        $attachmentData = $this->storeReplyAttachment($request->file('attachment'));
        $threadKey = $this->resolveThreadKey($notification);

        $replyPayload = [
            'title' => (string) ($data['title'] ?? 'Informasi Baru'),
            'reply_message' => (string) ($validated['message'] ?? ''),
            'replier_id' => (int) $request->user()->id,
            'replier_name' => (string) $request->user()->name,
            'replier_role' => (string) $request->user()->role,
            'source_notification_id' => $threadKey,
            'url' => '/admin/settings/notifications/info',
            'attachment_url' => $attachmentData['attachment_url'] ?? null,
            'attachment_name' => $attachmentData['attachment_name'] ?? null,
            'attachment_mime' => $attachmentData['attachment_mime'] ?? null,
            'attachment_size' => $attachmentData['attachment_size'] ?? null,
            'attachment_is_image' => $attachmentData['attachment_is_image'] ?? false,
            'context_action' => 'reply',
        ];

        Notification::send($sender, new AdminInfoReplyNotification($replyPayload));

        Notification::send($request->user(), new AdminInfoReplyNotification([
            ...$replyPayload,
            'notification_title' => 'Balasan Terkirim',
            'context_action' => 'reply_sent',
        ]));

        return response()->json([
            'message' => 'Balasan berhasil dikirim.',
        ]);
    }

    /**
     * @return array<string, mixed>|null
     */
    private function storeReplyAttachment(?UploadedFile $file): ?array
    {
        if (!$file) {
            return null;
        }

        $directory = public_path('uploads/notification-replies');

        if (!is_dir($directory)) {
            mkdir($directory, 0775, true);
        }

        $storedName = now()->format('YmdHis') . '-' . uniqid('', true) . '.' . $file->getClientOriginalExtension();
        $file->move($directory, $storedName);

        return [
            'attachment_url' => '/uploads/notification-replies/' . $storedName,
            'attachment_name' => $file->getClientOriginalName(),
            'attachment_mime' => $file->getClientMimeType(),
            'attachment_size' => $file->getSize(),
            'attachment_is_image' => str_starts_with((string) $file->getClientMimeType(), 'image/'),
        ];
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

    private function resolveThreadKey(DatabaseNotification $notification): string
    {
        $data = is_array($notification->data) ? $notification->data : [];
        $sourceNotificationId = (string) ($data['source_notification_id'] ?? '');

        return $sourceNotificationId !== '' ? $sourceNotificationId : (string) $notification->id;
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
            'thread_key' => $this->resolveThreadKey($notification),
            'url' => '/admin/settings/notifications/info',
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
            'sent_by_id' => $data['sent_by_id'] ?? null,
            'sent_by_name' => $data['sent_by_name'] ?? null,
            'sent_by_role' => $data['sent_by_role'] ?? null,
            'context' => $data['context'] ?? null,
            'context_action' => $data['context_action'] ?? null,
            'context_id' => $data['context_id'] ?? null,
            'source_notification_id' => $data['source_notification_id'] ?? null,
            'reply_message' => $data['reply_message'] ?? null,
            'attachment_url' => $data['attachment_url'] ?? null,
            'attachment_name' => $data['attachment_name'] ?? null,
            'attachment_mime' => $data['attachment_mime'] ?? null,
            'attachment_size' => $data['attachment_size'] ?? null,
            'attachment_is_image' => (bool) ($data['attachment_is_image'] ?? false),
            'created_at' => $notification->created_at?->toIso8601String(),
            'read_at' => $notification->read_at?->toIso8601String(),
        ];
    }
}
