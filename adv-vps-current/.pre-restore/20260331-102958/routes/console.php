<?php

use App\Services\FonteWhatsAppService;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote')->hourly();

Artisan::command('wa:remind-bs-weekly', function (FonteWhatsAppService $waService) {
    $result = $waService->sendWeeklyReminderToAllBs();

    $this->info('WA reminder BS selesai.');
    $this->line('Total BS : ' . $result['total_bs']);
    $this->line('Terkirim : ' . $result['sent']);
    $this->line('Dilewati : ' . $result['skipped']);
})->purpose('Kirim reminder update data ke semua BS via WhatsApp (Fonte).');

Artisan::command('wa:run-reminders', function (FonteWhatsAppService $waService) {
    $result = $waService->runScheduledReminders();

    $this->info('Scheduler reminder WA selesai.');
    $this->line('Plan ran   : ' . ($result['plan']['ran'] ? 'yes' : 'no'));
    $this->line('Plan sent  : ' . ($result['plan']['sent'] ?? 0));
    $this->line('Report ran : ' . ($result['report']['ran'] ? 'yes' : 'no'));
    $this->line('Report sent: ' . ($result['report']['sent'] ?? 0));
})->purpose('Jalankan reminder WA bulanan berdasarkan pengaturan aplikasi.');

Schedule::command('wa:remind-bs-weekly')
    ->fridays()
    ->at(config('services.fonte.bs_weekly_reminder_time', '08:00'))
    ->timezone(config('app.timezone', 'Asia/Jakarta'));

Schedule::command('wa:run-reminders')
    ->everyTenMinutes()
    ->timezone(config('app.timezone', 'Asia/Jakarta'));
