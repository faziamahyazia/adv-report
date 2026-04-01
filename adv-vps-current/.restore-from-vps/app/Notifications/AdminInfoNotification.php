<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\BroadcastMessage;
use Illuminate\Notifications\Notification;
use NotificationChannels\WebPush\WebPushChannel;
use NotificationChannels\WebPush\WebPushMessage;

class AdminInfoNotification extends Notification
{
    use Queueable;

    /**
     * @param array<string, mixed> $payload
     */
    public function __construct(private readonly array $payload)
    {
    }

    /**
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['database', 'broadcast', WebPushChannel::class];
    }

    /**
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'title' => (string) ($this->payload['title'] ?? 'Informasi Baru'),
            'message' => (string) ($this->payload['message'] ?? ''),
            'url' => $this->payload['url'] ?? null,
            'sent_by_id' => $this->payload['sent_by_id'] ?? null,
            'sent_by_name' => $this->payload['sent_by_name'] ?? null,
            'sent_by_role' => $this->payload['sent_by_role'] ?? null,
            'target_mode' => $this->payload['target_mode'] ?? null,
            'target_role' => $this->payload['target_role'] ?? null,
            'context' => $this->payload['context'] ?? null,
            'context_action' => $this->payload['context_action'] ?? null,
            'context_id' => $this->payload['context_id'] ?? null,
        ];
    }

    public function toWebPush(object $notifiable, mixed $notification): WebPushMessage
    {
        $url = (string) ($this->payload['url'] ?? '/admin/dashboard');

        if (!str_starts_with($url, 'http://') && !str_starts_with($url, 'https://')) {
            $url = url($url);
        }

        return (new WebPushMessage)
            ->title((string) ($this->payload['title'] ?? 'Informasi Baru'))
            ->body((string) ($this->payload['message'] ?? 'Ada pemberitahuan baru.'))
            ->icon('/icons/icon-192x192.png')
            ->tag((string) ($this->payload['sent_by_id'] ?? 'admin-info'))
            ->action('Buka', 'open_url')
            ->data([
                'url' => $url,
            ]);
    }

    public function toBroadcast(object $notifiable): BroadcastMessage
    {
        return new BroadcastMessage($this->toArray($notifiable));
    }
}