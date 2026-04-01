<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use App\Models\User;
use App\Services\FonteWhatsAppService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReminderSettingController extends Controller
{
    private function ensureAccess(): void
    {
        $role = Auth::user()?->role;
        if (!in_array($role, [User::Role_Admin, User::Role_Agronomist], true)) {
            abort(403, 'Hanya Admin/Agronomis yang dapat mengelola reminder WA.');
        }
    }

    private function defaultSettings(): array
    {
        return [
            'fonte_owner_phone' => '',
            'complaint_received_notification_enabled' => true,
            'activity_notification_enabled' => true,
            'activity_notification_template' => "Halo {agronomist_name},\nBS {bs_name} baru input/update realisasi kegiatan.\nTanggal: {activity_date}\nJenis: {activity_type}\nLokasi: {location}\nCatatan: {notes}\nStatus: {status}",
            'plan_reminder_enabled' => true,
            'plan_reminder_day' => 20,
            'plan_reminder_time' => '08:00',
            'plan_reminder_template' => "Halo {bs_name},\nReminder untuk input plan kegiatan bulan {month_label}.\nMohon lakukan input/update plan kegiatan paling lambat tanggal {day}.\nAgronomis PIC: {agronomist_name}.",
            'report_reminder_enabled' => true,
            'report_reminder_day' => 23,
            'report_reminder_time' => '08:00',
            'report_reminder_template' => "Halo {bs_name},\nMohon bereskan laporan kegiatan dan penjualan bulan {month_label}.\nReminder dikirim tanggal {day} agar tanggal 25 laporan bisa dikirim ke agronomis {agronomist_name}.",
        ];
    }

    private function settingsPayload(): array
    {
        $defaults = $this->defaultSettings();

        return [
            'fonte_owner_phone' => (string) Setting::value('wa_fonte_owner_phone', config('services.fonte.owner_phone', $defaults['fonte_owner_phone'])),
            'complaint_received_notification_enabled' => filter_var(Setting::value('wa_complaint_received_notification_enabled', $defaults['complaint_received_notification_enabled']), FILTER_VALIDATE_BOOLEAN),
            'activity_notification_enabled' => filter_var(Setting::value('wa_activity_notification_enabled', $defaults['activity_notification_enabled']), FILTER_VALIDATE_BOOLEAN),
            'activity_notification_template' => (string) Setting::value('wa_activity_notification_template', $defaults['activity_notification_template']),
            'plan_reminder_enabled' => filter_var(Setting::value('wa_plan_reminder_enabled', $defaults['plan_reminder_enabled']), FILTER_VALIDATE_BOOLEAN),
            'plan_reminder_day' => (int) Setting::value('wa_plan_reminder_day', $defaults['plan_reminder_day']),
            'plan_reminder_time' => (string) Setting::value('wa_plan_reminder_time', $defaults['plan_reminder_time']),
            'plan_reminder_template' => (string) Setting::value('wa_plan_reminder_template', $defaults['plan_reminder_template']),
            'report_reminder_enabled' => filter_var(Setting::value('wa_report_reminder_enabled', $defaults['report_reminder_enabled']), FILTER_VALIDATE_BOOLEAN),
            'report_reminder_day' => (int) Setting::value('wa_report_reminder_day', $defaults['report_reminder_day']),
            'report_reminder_time' => (string) Setting::value('wa_report_reminder_time', $defaults['report_reminder_time']),
            'report_reminder_template' => (string) Setting::value('wa_report_reminder_template', $defaults['report_reminder_template']),
        ];
    }

    public function edit()
    {
        $this->ensureAccess();

        return inertia('admin/reminder/Edit', [
            'data' => $this->settingsPayload(),
            'available_tags' => [
                '{agronomist_name}',
                '{bs_name}',
                '{activity_date}',
                '{activity_type}',
                '{location}',
                '{notes}',
                '{status}',
                '{month_label}',
                '{day}',
                '{company_name}',
            ],
        ]);
    }

    public function update(Request $request)
    {
        $this->ensureAccess();

        $validated = $request->validate([
            'fonte_owner_phone' => ['nullable', 'string', 'max:20', 'regex:/^\+?[0-9\s\-()]+$/'],
            'complaint_received_notification_enabled' => 'required|boolean',
            'activity_notification_enabled' => 'required|boolean',
            'activity_notification_template' => 'required|string|max:2000',
            'plan_reminder_enabled' => 'required|boolean',
            'plan_reminder_day' => 'required|integer|min:1|max:31',
            'plan_reminder_time' => ['required', 'regex:/^([01]\d|2[0-3]):([0-5]\d)$/'],
            'plan_reminder_template' => 'required|string|max:2000',
            'report_reminder_enabled' => 'required|boolean',
            'report_reminder_day' => 'required|integer|min:1|max:31',
            'report_reminder_time' => ['required', 'regex:/^([01]\d|2[0-3]):([0-5]\d)$/'],
            'report_reminder_template' => 'required|string|max:2000',
        ]);

        Setting::setValue('wa_fonte_owner_phone', trim((string) ($validated['fonte_owner_phone'] ?? '')));
        Setting::setValue('wa_complaint_received_notification_enabled', $validated['complaint_received_notification_enabled'] ? '1' : '0');
        Setting::setValue('wa_activity_notification_enabled', $validated['activity_notification_enabled'] ? '1' : '0');
        Setting::setValue('wa_activity_notification_template', $validated['activity_notification_template']);
        Setting::setValue('wa_plan_reminder_enabled', $validated['plan_reminder_enabled'] ? '1' : '0');
        Setting::setValue('wa_plan_reminder_day', (string) $validated['plan_reminder_day']);
        Setting::setValue('wa_plan_reminder_time', $validated['plan_reminder_time']);
        Setting::setValue('wa_plan_reminder_template', $validated['plan_reminder_template']);
        Setting::setValue('wa_report_reminder_enabled', $validated['report_reminder_enabled'] ? '1' : '0');
        Setting::setValue('wa_report_reminder_day', (string) $validated['report_reminder_day']);
        Setting::setValue('wa_report_reminder_time', $validated['report_reminder_time']);
        Setting::setValue('wa_report_reminder_template', $validated['report_reminder_template']);

        return back()->with('success', 'Pengaturan reminder WA berhasil diperbarui.');
    }

    public function triggerPlan(FonteWhatsAppService $waService)
    {
        $this->ensureAccess();

        $result = $waService->sendMonthlyPlanReminderToBs(Auth::user(), true);

        return response()->json([
            'message' => 'Trigger reminder plan selesai.',
            'result' => $result,
        ]);
    }

    public function triggerReport(FonteWhatsAppService $waService)
    {
        $this->ensureAccess();

        $result = $waService->sendMonthlyReportReminderToBs(Auth::user(), true);

        return response()->json([
            'message' => 'Trigger reminder laporan selesai.',
            'result' => $result,
        ]);
    }
}
