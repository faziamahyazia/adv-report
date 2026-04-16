<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\BroadcastMessage;
use Illuminate\Notifications\Notification;

class AdminInfoReadNotification extends Notification
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
        return ['database', 'broadcast'];
    }

    /**
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        $title = (string) ($this->payload['title'] ?? 'Informasi');
        $readerName = (string) ($this->payload['reader_name'] ?? 'Penerima');

        return [
            'title' => 'Notifikasi Dibaca',
            'message' => $readerName . ' sudah membaca: "' . $title . '"',
            'url' => $this->payload['url'] ?? '/admin/notifications/info',
            'sent_by_id' => $this->payload['reader_id'] ?? null,
            'sent_by_name' => $readerName,
            'sent_by_role' => $this->payload['reader_role'] ?? null,
            'context' => 'admin_info',
            'context_action' => 'read',
            'context_id' => $this->payload['source_notification_id'] ?? null,
        ];
    }

    public function toBroadcast(object $notifiable): BroadcastMessage
    {
        return new BroadcastMessage($this->toArray($notifiable));
    }
}
