<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\BroadcastMessage;
use Illuminate\Notifications\Notification;

class AdminInfoReplyNotification extends Notification
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
        $replierName = (string) ($this->payload['replier_name'] ?? 'Pengguna');
        $replyMessage = (string) ($this->payload['reply_message'] ?? '');
        $contextAction = (string) ($this->payload['context_action'] ?? 'reply');
        $notificationTitle = (string) ($this->payload['notification_title'] ?? 'Balasan Pengumuman');
        $hasAttachment = !empty($this->payload['attachment_url']);

        $message = $contextAction === 'reply_sent'
            ? 'Anda membalas "' . $title . '"'
            : $replierName . ' membalas "' . $title . '"';

        if ($replyMessage !== '') {
            $message .= ': ' . $replyMessage;
        }

        if ($hasAttachment) {
            $message .= $replyMessage !== '' ? ' (dengan lampiran)' : ': mengirim lampiran';
        }

        return [
            'title' => $notificationTitle,
            'message' => $message,
            'reply_message' => $replyMessage,
            'url' => $this->payload['url'] ?? '/admin/settings/notifications/info',
            'sent_by_id' => $this->payload['replier_id'] ?? null,
            'sent_by_name' => $replierName,
            'sent_by_role' => $this->payload['replier_role'] ?? null,
            'context' => 'admin_info',
            'context_action' => $contextAction,
            'source_notification_id' => $this->payload['source_notification_id'] ?? null,
            'attachment_url' => $this->payload['attachment_url'] ?? null,
            'attachment_name' => $this->payload['attachment_name'] ?? null,
            'attachment_mime' => $this->payload['attachment_mime'] ?? null,
            'attachment_size' => $this->payload['attachment_size'] ?? null,
            'attachment_is_image' => (bool) ($this->payload['attachment_is_image'] ?? false),
        ];
    }

    public function toBroadcast(object $notifiable): BroadcastMessage
    {
        return new BroadcastMessage($this->toArray($notifiable));
    }
}
