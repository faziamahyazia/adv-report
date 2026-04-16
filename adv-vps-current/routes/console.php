<?php

use App\Models\InventoryLog;
use App\Models\Product;
use App\Models\Sale;
use App\Services\FonteWhatsAppService;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
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

Artisan::command('inventory-log:backfill-sale-base-quantity {--dry-run}', function () {
    $dryRun = (bool) $this->option('dry-run');
    $updated = 0;
    $skipped = 0;

    InventoryLog::query()
        ->with(['product:id,uom_1,uom_2,weight', 'customer:id,name'])
        ->where(function ($query) {
            $query->whereNotNull('reference_sale_id')
                ->orWhere('notes', 'like', '[SALE_SYNC%');
        })
        ->orderBy('id')
        ->chunkById(200, function ($items) use (&$updated, &$skipped, $dryRun) {
            foreach ($items as $item) {
                $product = $item->product;
                $weightGram = (float) ($product?->weight ?? 0);
                $uom1 = strtolower(trim((string) ($product?->uom_1 ?? '')));
                $uom2 = strtolower(trim((string) ($product?->uom_2 ?? '')));
                $quantity = (float) ($item->quantity ?? 0);

                if (!$product || $weightGram <= 0 || $quantity <= 0) {
                    $skipped++;
                    continue;
                }

                if (!in_array($uom1, ['kg', 'pcs'], true) || !in_array($uom2, ['kg', 'pcs'], true)) {
                    $skipped++;
                    continue;
                }

                $expectedBaseQuantity = (int) round(($quantity * 1000) / $weightGram);
                if ((int) $item->base_quantity === $expectedBaseQuantity) {
                    $skipped++;
                    continue;
                }

                if (!$dryRun) {
                    $item->base_quantity = $expectedBaseQuantity;
                    $item->save();
                }

                $updated++;
            }
        });

    $this->info(($dryRun ? 'Dry-run' : 'Backfill') . ' selesai.');
    $this->line('Updated: ' . $updated);
    $this->line('Skipped: ' . $skipped);
})->purpose('Backfill base_quantity inventory log sale-sync berdasarkan quantity dan master product.');

Schedule::command('wa:remind-bs-weekly')
    ->fridays()
    ->at(config('services.fonte.bs_weekly_reminder_time', '08:00'))
    ->timezone(config('app.timezone', 'Asia/Jakarta'));

Schedule::command('wa:run-reminders')
    ->everyTenMinutes()
    ->timezone(config('app.timezone', 'Asia/Jakarta'));
