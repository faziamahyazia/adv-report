<?php

namespace App\Services;

use App\Models\Activity;
use App\Models\ActivityPlan;
use App\Models\Complaint;
use App\Models\Sale;
use App\Models\Setting;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FonteWhatsAppService
{
    public function sendComplaintNotificationToAgronomist(User $agronomistUser, User $bsUser, Complaint $complaint): bool
    {
        $agronomistPhone = $this->resolveUserPhone($agronomistUser);
        if (!$agronomistPhone) {
            return false;
        }

        $lines = [
            '📣 Keluhan Baru dari BS',
            'Agronomis: ' . ($agronomistUser->name ?? '-'),
            'BS: ' . ($bsUser->name ?? '-'),
            'Judul: ' . ($complaint->title ?? '-'),
            'Kategori: ' . (Complaint::Categories[$complaint->category ?? Complaint::Category_Other] ?? '-'),
            'Severity: ' . strtoupper((string) ($complaint->severity ?? '-')),
            'Lokasi: ' . ($complaint->location ?? '-'),
            'Region: ' . ($complaint->region ?? '-'),
            'ID Keluhan: #' . $complaint->id,
        ];

        return $this->sendMessage($agronomistPhone, implode("\n", $lines));
    }

    public function sendHighSeverityComplaintAlertToAdmins(Complaint $complaint, User $bsUser): array
    {
        if (($complaint->severity ?? '') !== Complaint::Severity_High) {
            return ['total_admin' => 0, 'sent' => 0, 'skipped' => 0];
        }

        $admins = User::query()
            ->where('role', User::Role_Admin)
            ->where('active', true)
            ->orderBy('name')
            ->get(['id', 'name', 'username', 'whatsapp_number']);

        $result = [
            'total_admin' => $admins->count(),
            'sent' => 0,
            'skipped' => 0,
        ];

        foreach ($admins as $admin) {
            $phone = $this->resolveUserPhone($admin);
            if (!$phone) {
                $result['skipped']++;
                continue;
            }

            $lines = [
                '🚨 High Severity Complaint',
                'Admin: ' . ($admin->name ?? '-'),
                'BS: ' . ($bsUser->name ?? '-'),
                'Judul: ' . ($complaint->title ?? '-'),
                'Kategori: ' . (Complaint::Categories[$complaint->category ?? Complaint::Category_Other] ?? '-'),
                'Lokasi: ' . ($complaint->location ?? '-'),
                'Region: ' . ($complaint->region ?? '-'),
                'ID Keluhan: #' . $complaint->id,
            ];

            if ($this->sendMessage($phone, implode("\n", $lines))) {
                $result['sent']++;
            } else {
                $result['skipped']++;
            }
        }

        return $result;
    }

    public function sendComplaintStatusUpdatedToBs(User $bsUser, Complaint $complaint): bool
    {
        $bsPhone = $this->resolveUserPhone($bsUser);
        if (!$bsPhone) {
            return false;
        }

        $lines = [
            '✅ Update Status Keluhan',
            'Halo ' . ($bsUser->name ?? 'BS') . ',',
            'Keluhan Anda telah diperbarui.',
            'ID Keluhan: #' . $complaint->id,
            'Judul: ' . ($complaint->title ?? '-'),
            'Status: ' . (Complaint::Statuses[$complaint->status ?? Complaint::Status_Open] ?? '-'),
            'Severity: ' . strtoupper((string) ($complaint->severity ?? '-')),
        ];

        return $this->sendMessage($bsPhone, implode("\n", $lines));
    }

    public function sendComplaintReceivedToBs(User $bsUser, Complaint $complaint): bool
    {
        if (!filter_var(Setting::value('wa_complaint_received_notification_enabled', '1'), FILTER_VALIDATE_BOOLEAN)) {
            return false;
        }

        $bsPhone = $this->resolveUserPhone($bsUser);
        if (!$bsPhone) {
            return false;
        }

        $lines = [
            '✅ Keluhan Diterima',
            'Halo ' . ($bsUser->name ?? 'BS') . ',',
            'Keluhan Anda sudah kami terima dan akan segera ditindaklanjuti.',
            'ID Keluhan: #' . $complaint->id,
            'Judul: ' . ($complaint->title ?? '-'),
            'Kategori: ' . (Complaint::Categories[$complaint->category ?? Complaint::Category_Other] ?? '-'),
            'Severity: ' . strtoupper((string) ($complaint->severity ?? '-')),
            'Status: ' . (Complaint::Statuses[$complaint->status ?? Complaint::Status_Open] ?? '-'),
        ];

        return $this->sendMessage($bsPhone, implode("\n", $lines));
    }

    public function sendActivityInputNotificationToAgronomist(User $agronomistUser, User $bsUser, Activity $activity): bool
    {
        if (!filter_var(Setting::value('wa_activity_notification_enabled', '1'), FILTER_VALIDATE_BOOLEAN)) {
            return false;
        }

        $agronomistPhone = $this->resolveUserPhone($agronomistUser);
        if (!$agronomistPhone) {
            Log::warning('WA Fonte: nomor agronomis tidak valid untuk notifikasi realisasi kegiatan.', [
                'user_id' => $agronomistUser->id,
                'username' => $agronomistUser->username,
            ]);
            return false;
        }

        $activity->loadMissing(['type:id,name']);

        $template = (string) Setting::value(
            'wa_activity_notification_template',
            "Halo {agronomist_name},\nBS {bs_name} baru input/update realisasi kegiatan.\nTanggal: {activity_date}\nJenis: {activity_type}\nLokasi: {location}\nCatatan: {notes}\nStatus: {status}"
        );

        $message = $this->renderTemplate($template, [
            'agronomist_name' => $agronomistUser->name ?? '-',
            'bs_name' => $bsUser->name ?? '-',
            'activity_date' => optional($activity->date)->format('d-m-Y') ?: '-',
            'activity_type' => $activity->type?->name ?? '-',
            'location' => $activity->location ?: '-',
            'notes' => $activity->notes ?: '-',
            'status' => Activity::Statuses[$activity->status ?? Activity::Status_NotResponded] ?? '-',
            'company_name' => Setting::value('company_name', 'My Company'),
        ]);

        return $this->sendMessage($agronomistPhone, $message);
    }

    public function sendActivityApprovedToBs(User $bsUser, Activity $activity, User $approvedBy): bool
    {
        $bsPhone = $this->resolveUserPhone($bsUser);
        if (!$bsPhone) {
            Log::warning('WA Fonte: nomor BS tidak valid untuk notifikasi approval kegiatan.', [
                'user_id' => $bsUser->id,
                'username' => $bsUser->username,
            ]);
            return false;
        }

        $activity->loadMissing(['type:id,name', 'product:id,name']);

        $lines = [
            '✅ Realisasi Kegiatan Disetujui',
            'Halo ' . ($bsUser->name ?? 'BS') . ',',
            'Realisasi kegiatan Anda telah disetujui.',
            'Tanggal: ' . optional($activity->date)->format('d-m-Y'),
            'Jenis: ' . ($activity->type?->name ?? '-'),
            'Varietas: ' . ($activity->product?->name ?? '-'),
            'Lokasi: ' . ($activity->location ?: '-'),
            'Disetujui oleh: ' . ($approvedBy->name ?? '-'),
            'ID Aktivitas: #' . $activity->id,
        ];

        return $this->sendMessage($bsPhone, implode("\n", $lines));
    }

    public function sendActivityPlanApprovedToBs(User $bsUser, ActivityPlan $plan, User $approvedBy): bool
    {
        $bsPhone = $this->resolveUserPhone($bsUser);
        if (!$bsPhone) {
            Log::warning('WA Fonte: nomor BS tidak valid untuk notifikasi approval plan kegiatan.', [
                'user_id' => $bsUser->id,
                'username' => $bsUser->username,
            ]);
            return false;
        }

        $plan->loadMissing(['details.type:id,name', 'details.product:id,name']);

        $detailCount = $plan->details?->count() ?? 0;
        $monthLabel = Carbon::parse($plan->date)->translatedFormat('F Y');

        $lines = [
            '✅ Plan Kegiatan Disetujui',
            'Halo ' . ($bsUser->name ?? 'BS') . ',',
            'Plan kegiatan Anda untuk ' . $monthLabel . ' telah disetujui.',
            'Jumlah detail: ' . $detailCount,
            'Disetujui oleh: ' . ($approvedBy->name ?? '-'),
            'ID Plan: #' . $plan->id,
        ];

        return $this->sendMessage($bsPhone, implode("\n", $lines));
    }

    public function sendSaleInputNotificationToAgronomist(User $agronomistUser, User $bsUser, Sale $sale): bool
    {
        $agronomistPhone = $this->resolveUserPhone($agronomistUser);
        if (!$agronomistPhone) {
            Log::warning('WA Fonte: nomor agronomis tidak valid untuk notifikasi input sales.', [
                'user_id' => $agronomistUser->id,
                'username' => $agronomistUser->username,
            ]);
            return false;
        }

        $sale->loadMissing(['distributor:id,name', 'retailer:id,name', 'items.product:id,name']);

        $lines = [
            '📥 PO Baru dari BS',
            'Agronomis: ' . ($agronomistUser->name ?? '-'),
            'BS: ' . ($bsUser->name ?? '-'),
            'Tanggal: ' . optional($sale->date)->format('d-m-Y'),
            'Distributor: ' . ($sale->distributor?->name ?? '-'),
            'Retailer: ' . ($sale->retailer?->name ?? '-'),
            'Item PO:',
            $this->buildSaleItemsSummary($sale),
            'Total: Rp ' . number_format((float) $sale->total_amount, 0, ',', '.'),
            'ID Sales: #' . $sale->id,
        ];

        return $this->sendMessage($agronomistPhone, implode("\n", $lines));
    }

    public function sendSaleInputNotificationToBs(User $bsUser, Sale $sale): bool
    {
        $bsPhone = $this->resolveUserPhone($bsUser);
        if (!$bsPhone) {
            Log::warning('WA Fonte: nomor BS tidak valid untuk notifikasi input sales.', [
                'user_id' => $bsUser->id,
                'username' => $bsUser->username,
            ]);
            return false;
        }

        $sale->loadMissing(['distributor:id,name', 'retailer:id,name', 'items.product:id,name']);

        $lines = [
            '✅ PO Penjualan Diterima',
            'Halo ' . ($bsUser->name ?? 'BS') . ',',
            'PO Anda sudah masuk dan akan segera diproses.',
            'Tanggal: ' . optional($sale->date)->format('d-m-Y'),
            'Distributor: ' . ($sale->distributor?->name ?? '-'),
            'Retailer: ' . ($sale->retailer?->name ?? '-'),
            'Item PO:',
            $this->buildSaleItemsSummary($sale),
            'Total: Rp ' . number_format((float) $sale->total_amount, 0, ',', '.'),
            'ID Sales: #' . $sale->id,
        ];

        return $this->sendMessage($bsPhone, implode("\n", $lines));
    }

    public function sendSaleInputNotificationToOwner(User $bsUser, Sale $sale): bool
    {
        $ownerPhone = $this->resolveOwnerPhone();

        if (!$ownerPhone) {
            Log::warning('WA Fonte owner phone belum diatur, notifikasi input sales dilewati.');
            return false;
        }

        $sale->loadMissing(['distributor:id,name', 'retailer:id,name', 'items.product:id,name']);

        $lines = [
            '🔔 Input Penjualan Baru',
            'BS: ' . ($bsUser->name ?? '-'),
            'Tanggal: ' . optional($sale->date)->format('d-m-Y'),
            'Distributor: ' . ($sale->distributor?->name ?? '-'),
            'Retailer: ' . ($sale->retailer?->name ?? '-'),
            'Item PO:',
            $this->buildSaleItemsSummary($sale),
            'Total: Rp ' . number_format((float) $sale->total_amount, 0, ',', '.'),
            'ID Sales: #' . $sale->id,
        ];

        return $this->sendMessage($ownerPhone, implode("\n", $lines));
    }

    public function sendSaleReleasedNotificationToOwner(Sale $sale, ?User $releasedBy = null): bool
    {
        $ownerPhone = $this->resolveOwnerPhone();
        if (!$ownerPhone) {
            Log::warning('WA Fonte owner phone belum diatur, notifikasi release sales dilewati.');
            return false;
        }

        $sale->loadMissing(['distributor:id,name', 'retailer:id,name', 'created_by_user:id,name', 'items.product:id,name']);

        $lines = [
            '📤 PO Penjualan Released',
            'BS: ' . ($sale->created_by_user?->name ?? '-'),
            'Tanggal: ' . optional($sale->date)->format('d-m-Y'),
            'Distributor: ' . ($sale->distributor?->name ?? '-'),
            'Retailer: ' . ($sale->retailer?->name ?? '-'),
            'Item PO:',
            $this->buildSaleItemsSummary($sale),
            'Total: Rp ' . number_format((float) $sale->total_amount, 0, ',', '.'),
            'ID Sales: #' . $sale->id,
            'Release by: ' . ($releasedBy?->name ?? '-'),
        ];

        return $this->sendMessage($ownerPhone, implode("\n", $lines));
    }

    public function sendSaleReleasedNotificationToBs(User $bsUser, Sale $sale): bool
    {
        $bsPhone = $this->resolveUserPhone($bsUser);
        if (!$bsPhone) {
            Log::warning('WA Fonte: nomor BS tidak valid untuk notifikasi release sales.', [
                'user_id' => $bsUser->id,
                'username' => $bsUser->username,
            ]);
            return false;
        }

        $sale->loadMissing(['distributor:id,name', 'retailer:id,name', 'items.product:id,name']);

        $lines = [
            '✅ PO Penjualan Sudah Release',
            'Halo ' . ($bsUser->name ?? 'BS') . ',',
            'PO Anda sudah diproses (release).',
            'Tanggal: ' . optional($sale->date)->format('d-m-Y'),
            'Distributor: ' . ($sale->distributor?->name ?? '-'),
            'Retailer: ' . ($sale->retailer?->name ?? '-'),
            'Item PO:',
            $this->buildSaleItemsSummary($sale),
            'Total: Rp ' . number_format((float) $sale->total_amount, 0, ',', '.'),
            'ID Sales: #' . $sale->id,
        ];

        return $this->sendMessage($bsPhone, implode("\n", $lines));
    }

    public function sendWeeklyReminderToAllBs(bool $force = false): array
    {
        if (!$force && !filter_var(Setting::value('wa_weekly_reminder_enabled', '1'), FILTER_VALIDATE_BOOLEAN)) {
            return ['total_bs' => 0, 'sent' => 0, 'skipped' => 0];
        }

        $targets = User::query()
            ->with('parent:id,name,username,whatsapp_number')
            ->where('role', User::Role_BS)
            ->where('active', true)
            ->orderBy('name')
            ->get(['id', 'name', 'username', 'whatsapp_number', 'parent_id']);

        $template = (string) Setting::value(
            'wa_weekly_reminder_template',
            "📌 Reminder Update Data\nHalo {bs_name}, mohon update data aktivitas dan penjualan minggu ini di aplikasi Advanta Report.\nTerima kasih 🙏"
        );

        $result = [
            'total_bs' => $targets->count(),
            'sent' => 0,
            'skipped' => 0,
        ];

        foreach ($targets as $user) {
            $phone = $this->resolveUserPhone($user);
            if (!$phone) {
                $result['skipped']++;
                Log::warning('WA Fonte: nomor BS tidak valid/empty.', [
                    'user_id' => $user->id,
                    'username' => $user->username,
                ]);
                continue;
            }

            $message = $this->renderTemplate($template, [
                'bs_name' => $user->name ?? '-',
                'agronomist_name' => $user->parent?->name ?? '-',
                'day_name' => 'Jumat',
                'time' => config('services.fonte.bs_weekly_reminder_time', '08:00'),
                'company_name' => Setting::value('company_name', 'My Company'),
            ]);

            if ($this->sendMessage($phone, $message)) {
                $result['sent']++;
            } else {
                $result['skipped']++;
            }
        }

        return $result;
    }

    public function triggerWeeklyReminderToAllBs(): array
    {
        return $this->sendWeeklyReminderToAllBs(true);
    }

    public function sendMonthlyPlanReminderToBs(?User $scopeUser = null, bool $force = false): array
    {
        return $this->sendMonthlyReminderToBs('plan', $scopeUser, $force);
    }

    public function sendMonthlyReportReminderToBs(?User $scopeUser = null, bool $force = false): array
    {
        return $this->sendMonthlyReminderToBs('report', $scopeUser, $force);
    }

    public function runScheduledReminders(): array
    {
        $result = [
            'plan' => ['sent' => 0, 'skipped' => 0, 'total_bs' => 0, 'ran' => false],
            'report' => ['sent' => 0, 'skipped' => 0, 'total_bs' => 0, 'ran' => false],
        ];

        if ($this->isReminderDue('plan')) {
            $result['plan'] = $this->sendMonthlyPlanReminderToBs(null, false);
            $result['plan']['ran'] = true;
        }

        if ($this->isReminderDue('report')) {
            $result['report'] = $this->sendMonthlyReportReminderToBs(null, false);
            $result['report']['ran'] = true;
        }

        return $result;
    }

    public function sendMessage(string $phone, string $message): bool
    {
        if (!config('services.fonte.enabled', false)) {
            Log::info('WA Fonte nonaktif (FONTE_ENABLED=false), pengiriman dilewati.');
            return false;
        }

        $token = trim((string) config('services.fonte.token'));
        $endpoint = trim((string) config('services.fonte.endpoint', 'https://api.fonnte.com/send'));

        if ($token === '') {
            Log::warning('WA Fonte token kosong, pengiriman dilewati.');
            return false;
        }

        // Guard idempotensi: jika cache bermasalah, jangan sampai blok proses simpan penjualan.
        $dedupeKey = 'fonte:dedupe:' . sha1($phone . '|' . $message);
        try {
            if (!Cache::add($dedupeKey, 1, now()->addSeconds(45))) {
                Log::info('WA Fonte skip duplicate message.', [
                    'target' => $phone,
                ]);
                return true;
            }
        } catch (\Throwable $e) {
            Log::warning('WA Fonte dedupe cache unavailable, lanjut tanpa dedupe.', [
                'target' => $phone,
                'message' => $e->getMessage(),
            ]);
        }

        try {
            $response = Http::timeout(20)
                ->asForm()
                ->withHeaders([
                    'Authorization' => $token,
                ])
                ->post($endpoint, [
                    'target' => $phone,
                    'message' => $message,
                ]);

            if (!$response->successful()) {
                Log::warning('WA Fonte gagal kirim.', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                    'target' => $phone,
                ]);
                return false;
            }

            return true;
        } catch (\Throwable $e) {
            Log::error('WA Fonte exception.', [
                'message' => $e->getMessage(),
                'target' => $phone,
            ]);
            return false;
        }
    }

    private function resolveUserPhone(User $user): ?string
    {
        $raw = $user->whatsapp_number ?: $user->username;
        return $this->normalizePhone((string) $raw);
    }

    private function sendMonthlyReminderToBs(string $type, ?User $scopeUser = null, bool $force = false): array
    {
        $enabledKey = $type === 'plan' ? 'wa_plan_reminder_enabled' : 'wa_report_reminder_enabled';
        if (!$force && !filter_var(Setting::value($enabledKey, '1'), FILTER_VALIDATE_BOOLEAN)) {
            return ['total_bs' => 0, 'sent' => 0, 'skipped' => 0];
        }

        $targets = $this->getBsReminderTargets($scopeUser);
        $result = [
            'total_bs' => $targets->count(),
            'sent' => 0,
            'skipped' => 0,
        ];

        $settingPrefix = $type === 'plan' ? 'wa_plan_reminder' : 'wa_report_reminder';
        $day = (int) Setting::value($settingPrefix . '_day', $type === 'plan' ? 20 : 23);
        $template = (string) Setting::value(
            $settingPrefix . '_template',
            $type === 'plan'
                ? "Halo {bs_name},\nReminder untuk input plan kegiatan bulan {month_label}.\nMohon lakukan input/update plan kegiatan paling lambat tanggal {day}.\nAgronomis PIC: {agronomist_name}."
                : "Halo {bs_name},\nMohon bereskan laporan kegiatan dan penjualan bulan {month_label}.\nReminder dikirim tanggal {day} agar tanggal 25 laporan bisa dikirim ke agronomis {agronomist_name}."
        );

        foreach ($targets as $bsUser) {
            $phone = $this->resolveUserPhone($bsUser);
            if (!$phone) {
                $result['skipped']++;
                continue;
            }

            $message = $this->renderTemplate($template, [
                'bs_name' => $bsUser->name ?? '-',
                'agronomist_name' => $bsUser->parent?->name ?? '-',
                'month_label' => Carbon::now()->locale('id')->translatedFormat('F Y'),
                'day' => $day,
                'company_name' => Setting::value('company_name', 'My Company'),
            ]);

            if ($this->sendMessage($phone, $message)) {
                $result['sent']++;
            } else {
                $result['skipped']++;
            }
        }

        if (!$force && $scopeUser === null) {
            Setting::setValue($settingPrefix . '_last_sent_period', now()->format('Y-m'));
        }

        return $result;
    }

    private function getBsReminderTargets(?User $scopeUser = null): Collection
    {
        $q = User::query()
            ->with('parent:id,name,username,whatsapp_number')
            ->where('role', User::Role_BS)
            ->where('active', true)
            ->orderBy('name');

        if ($scopeUser && $scopeUser->role === User::Role_Agronomist) {
            $q->where('parent_id', $scopeUser->id);
        }

        return $q->get(['id', 'name', 'username', 'whatsapp_number', 'parent_id']);
    }

    private function isReminderDue(string $type): bool
    {
        $prefix = $type === 'plan' ? 'wa_plan_reminder' : 'wa_report_reminder';
        $enabled = filter_var(Setting::value($prefix . '_enabled', '1'), FILTER_VALIDATE_BOOLEAN);
        if (!$enabled) {
            return false;
        }

        $day = (int) Setting::value($prefix . '_day', $type === 'plan' ? 20 : 23);
        $time = (string) Setting::value($prefix . '_time', '08:00');
        [$hour, $minute] = array_pad(explode(':', $time), 2, '00');
        $now = now();

        if ((int) $now->format('d') !== $day) {
            return false;
        }

        if ($now->lt($now->copy()->setTime((int) $hour, (int) $minute))) {
            return false;
        }

        return Setting::value($prefix . '_last_sent_period', '') !== $now->format('Y-m');
    }

    private function renderTemplate(string $template, array $data): string
    {
        $replacements = [];
        foreach ($data as $key => $value) {
            $replacements['{' . $key . '}'] = (string) $value;

            // Support placeholder variant with dashes, e.g. {bs-name}.
            $dashKey = str_replace('_', '-', (string) $key);
            if ($dashKey !== $key) {
                $replacements['{' . $dashKey . '}'] = (string) $value;
            }
        }

        return strtr($template, $replacements);
    }

    private function resolveOwnerPhone(): ?string
    {
        $ownerPhone = $this->normalizePhone((string) Setting::value('wa_fonte_owner_phone', ''));

        if (!$ownerPhone) {
            $ownerPhone = $this->normalizePhone(config('services.fonte.owner_phone'));
        }

        if (!$ownerPhone) {
            $ownerPhone = $this->normalizePhone((string) Setting::value('company_phone', ''));
        }

        return $ownerPhone;
    }

    private function buildSaleItemsSummary(Sale $sale): string
    {
        $items = $sale->items ?? collect();

        if ($items->isEmpty()) {
            return '-';
        }

        $lines = $items->map(function ($item) {
            $name = $item->product?->name ?? ('Produk #' . ($item->product_id ?? '-'));
            $qty = number_format((float) ($item->quantity ?? 0), 2, ',', '.');
            $qty = rtrim(rtrim($qty, '0'), ',');
            $unit = trim((string) ($item->unit ?? ''));

            return '- ' . $name . ': ' . $qty . ($unit !== '' ? ' ' . $unit : '');
        })->values()->all();

        return implode("\n", $lines);
    }

    private function normalizePhone(?string $raw): ?string
    {
        if (!$raw) {
            return null;
        }

        $phone = preg_replace('/[^0-9+]/', '', trim($raw));

        if (str_starts_with($phone, '+')) {
            $phone = substr($phone, 1);
        }

        if (str_starts_with($phone, '0')) {
            $phone = '62' . substr($phone, 1);
        }

        if (!preg_match('/^[0-9]{9,16}$/', $phone)) {
            return null;
        }

        return $phone;
    }
}
