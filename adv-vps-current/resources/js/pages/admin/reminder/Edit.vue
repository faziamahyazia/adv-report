<script setup>
import { useForm, usePage } from "@inertiajs/vue3";
import { Notify } from "quasar";
import axios from "axios";
import { ref } from "vue";

const page = usePage();
const title = "Reminder WA";
const sendingWeekly = ref(false);
const sendingPlan = ref(false);
const sendingReport = ref(false);
const activeTemplateField = ref("");

const form = useForm({
  fonte_owner_phone: page.props.data.fonte_owner_phone || "",
  complaint_received_notification_enabled: !!page.props.data.complaint_received_notification_enabled,
  activity_notification_enabled: !!page.props.data.activity_notification_enabled,
  activity_notification_template: page.props.data.activity_notification_template || "",
  weekly_reminder_enabled: !!page.props.data.weekly_reminder_enabled,
  weekly_reminder_template: page.props.data.weekly_reminder_template || "",
  plan_reminder_enabled: !!page.props.data.plan_reminder_enabled,
  plan_reminder_day: Number(page.props.data.plan_reminder_day || 20),
  plan_reminder_time: page.props.data.plan_reminder_time || "08:00",
  plan_reminder_template: page.props.data.plan_reminder_template || "",
  report_reminder_enabled: !!page.props.data.report_reminder_enabled,
  report_reminder_day: Number(page.props.data.report_reminder_day || 23),
  report_reminder_time: page.props.data.report_reminder_time || "08:00",
  report_reminder_template: page.props.data.report_reminder_template || "",
});

const submit = () => {
  form.post(route("admin.reminder.update"), {
    preserveScroll: true,
  });
};

const triggerWeekly = async () => {
  sendingWeekly.value = true;
  try {
    const response = await axios.post(route("admin.reminder.trigger-weekly"));
    const result = response.data?.result || {};
    Notify.create({
      color: "positive",
      message: `${response.data?.message || "Trigger reminder Jumat selesai."} Terkirim ${result.sent || 0}, dilewati ${result.skipped || 0}.`,
    });
  } catch (error) {
    Notify.create({
      color: "negative",
      message: error?.response?.data?.message || "Gagal menjalankan reminder Jumat.",
    });
  } finally {
    sendingWeekly.value = false;
  }
};

const triggerPlan = async () => {
  sendingPlan.value = true;
  try {
    const response = await axios.post(route("admin.reminder.trigger-plan"));
    const result = response.data?.result || {};
    Notify.create({
      color: "positive",
      message: `${response.data?.message || "Trigger reminder plan selesai."} Terkirim ${result.sent || 0}, dilewati ${result.skipped || 0}.`,
    });
  } catch (error) {
    Notify.create({
      color: "negative",
      message: error?.response?.data?.message || "Gagal menjalankan reminder plan.",
    });
  } finally {
    sendingPlan.value = false;
  }
};

const triggerReport = async () => {
  sendingReport.value = true;
  try {
    const response = await axios.post(route("admin.reminder.trigger-report"));
    const result = response.data?.result || {};
    Notify.create({
      color: "positive",
      message: `${response.data?.message || "Trigger reminder laporan selesai."} Terkirim ${result.sent || 0}, dilewati ${result.skipped || 0}.`,
    });
  } catch (error) {
    Notify.create({
      color: "negative",
      message: error?.response?.data?.message || "Gagal menjalankan reminder laporan.",
    });
  } finally {
    sendingReport.value = false;
  }
};

const setActiveTemplateField = (field) => {
  activeTemplateField.value = field;
};

const insertTagToActiveTemplate = (tag) => {
  const field = activeTemplateField.value;
  if (!field || typeof form[field] !== "string") {
    Notify.create({
      color: "warning",
      message: "Pilih dulu salah satu kolom template, lalu klik tag.",
    });
    return;
  }

  const current = form[field] || "";
  form[field] = current.endsWith(" ") || current === "" ? `${current}${tag}` : `${current} ${tag}`;
};
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>

    <div class="reminder-page">
      <!-- Header Section -->
      <div class="page-header">
        <div class="header-content">
          <div class="header-icon">
            <q-icon name="mail" size="32px" color="primary" />
          </div>
          <div class="header-text">
            <div class="text-overline text-primary">Pengaturan WhatsApp</div>
            <h1 class="page-title">Reminder WA</h1>
            <p class="page-subtitle">Tampilan dengan agar alur pengaturan lebih jelas dan tidak berantakan</p>
          </div>
        </div>
      </div>

      <q-form @submit.prevent="submit">
        <div class="content-layout">
          <!-- Main Content -->
          <div class="main-content">
            <!-- Notifikasi Dasar Card -->
            <q-card class="settings-card" flat bordered>
              <q-card-section class="card-header">
                <div class="header-left">
                  <q-icon name="notifications" size="24px" color="primary" class="q-mr-sm" />
                  <div>
                    <div class="card-title">Notifikasi Dasar</div>
                    <div class="card-desc">Atur notifikasi owner, keluhan, dan realisasi kegiatan</div>
                  </div>
                </div>
              </q-card-section>
              <q-separator />
              <q-card-section class="card-body">
                <div class="form-group">
                  <q-input
                    v-model="form.fonte_owner_phone"
                    outlined
                    dense
                    label="Nomor Owner"
                    placeholder="081234567890"
                    prefix="+62"
                    :error="!!form.errors.fonte_owner_phone"
                    :error-message="form.errors.fonte_owner_phone"
                  >
                    <template v-slot:prepend>
                      <q-icon name="phone" />
                    </template>
                  </q-input>
                </div>
                <div class="toggle-list">
                  <div class="toggle-item">
                    <q-toggle v-model="form.complaint_received_notification_enabled" color="primary" />
                    <div class="toggle-label">
                      <div class="toggle-title">Notifikasi Keluhan</div>
                      <div class="toggle-desc">Terima notifikasi saat ada keluhan baru</div>
                    </div>
                  </div>
                  <div class="toggle-item">
                    <q-toggle v-model="form.activity_notification_enabled" color="primary" />
                    <div class="toggle-label">
                      <div class="toggle-title">Notifikasi Realisasi</div>
                      <div class="toggle-desc">Terima notifikasi saat ada realisasi kegiatan</div>
                    </div>
                  </div>
                </div>
                <div class="form-group" v-if="form.activity_notification_enabled">
                  <label class="field-label">Template Notifikasi Realisasi</label>
                  <q-input
                    v-model="form.activity_notification_template"
                    type="textarea"
                    outlined
                    dense
                    rows="4"
                    @focus="setActiveTemplateField('activity_notification_template')"
                    :error="!!form.errors.activity_notification_template"
                    :error-message="form.errors.activity_notification_template"
                    placeholder="Masukkan template pesan..."
                  />
                </div>
              </q-card-section>
            </q-card>

            <!-- Reminder Jumat Card -->
            <q-card class="settings-card" flat bordered>
              <q-card-section class="card-header">
                <div class="header-left">
                  <q-icon name="event_note" size="24px" color="indigo" class="q-mr-sm" />
                  <div>
                    <div class="card-title">Reminder Update Data Jumat</div>
                    <div class="card-desc">Otomatis setiap Jumat, bisa trigger manual kapan saja</div>
                  </div>
                </div>
                <q-btn
                  color="indigo"
                  unelevated
                  dense
                  no-caps
                  icon="send"
                  label="Trigger Jumat"
                  :loading="sendingWeekly"
                  @click="triggerWeekly"
                  class="action-btn"
                />
              </q-card-section>
              <q-separator />
              <q-card-section class="card-body">
                <div class="toggle-list">
                  <div class="toggle-item">
                    <q-toggle v-model="form.weekly_reminder_enabled" color="indigo" />
                    <div class="toggle-label">
                      <div class="toggle-title">Aktifkan Reminder Jumat</div>
                      <div class="toggle-desc">Kirim reminder otomatis setiap hari Jumat</div>
                    </div>
                  </div>
                </div>
                <div class="form-group" v-if="form.weekly_reminder_enabled">
                  <label class="field-label">Template Reminder Jumat</label>
                  <q-input
                    v-model="form.weekly_reminder_template"
                    type="textarea"
                    outlined
                    dense
                    rows="4"
                    @focus="setActiveTemplateField('weekly_reminder_template')"
                    :error="!!form.errors.weekly_reminder_template"
                    :error-message="form.errors.weekly_reminder_template"
                    placeholder="Masukkan template pesan..."
                  />
                </div>
              </q-card-section>
            </q-card>

            <!-- Reminder Bulanan Section -->
            <div class="monthly-section">
              <div class="section-title">
                <q-icon name="calendar_month" size="20px" color="teal" class="q-mr-xs" />
                Reminder Bulanan
              </div>
              
              <div class="monthly-grid">
                <!-- Reminder Plan Card -->
                <q-card class="settings-card" flat bordered>
                  <q-card-section class="card-header compact-header">
                    <div class="header-left">
                      <q-icon name="assignment" size="20px" color="teal" class="q-mr-sm" />
                      <div>
                        <div class="card-title small">Input Plan Kegiatan</div>
                        <div class="card-desc">Pengingat bulanan untuk input plan</div>
                      </div>
                    </div>
                    <q-btn
                      color="teal"
                      unelevated
                      dense
                      size="sm"
                      no-caps
                      icon="send"
                      :loading="sendingPlan"
                      @click="triggerPlan"
                      class="compact-btn"
                    />
                  </q-card-section>
                  <q-separator />
                  <q-card-section class="card-body compact-body">
                    <div class="toggle-list">
                      <div class="toggle-item compact">
                        <q-toggle v-model="form.plan_reminder_enabled" color="teal" size="sm" />
                        <div class="toggle-label">
                          <div class="toggle-title small">Aktifkan Reminder</div>
                        </div>
                      </div>
                    </div>
                    <div class="form-group" v-if="form.plan_reminder_enabled">
                      <div class="datetime-row">
                        <div class="datetime-field">
                          <label class="field-label small">Tanggal</label>
                          <q-input
                            v-model.number="form.plan_reminder_day"
                            type="number"
                            min="1"
                            max="31"
                            outlined
                            dense
                            :error="!!form.errors.plan_reminder_day"
                            :error-message="form.errors.plan_reminder_day"
                          >
                            <template v-slot:prepend>
                              <q-icon name="event" size="xs" />
                            </template>
                          </q-input>
                        </div>
                        <div class="datetime-field">
                          <label class="field-label small">Jam</label>
                          <q-input
                            v-model="form.plan_reminder_time"
                            type="time"
                            outlined
                            dense
                            :error="!!form.errors.plan_reminder_time"
                            :error-message="form.errors.plan_reminder_time"
                          >
                            <template v-slot:prepend>
                              <q-icon name="schedule" size="xs" />
                            </template>
                          </q-input>
                        </div>
                      </div>
                      <label class="field-label small">Template Pesan</label>
                      <q-input
                        v-model="form.plan_reminder_template"
                        type="textarea"
                        outlined
                        dense
                        rows="3"
                        @focus="setActiveTemplateField('plan_reminder_template')"
                        :error="!!form.errors.plan_reminder_template"
                        :error-message="form.errors.plan_reminder_template"
                        placeholder="Masukkan template pesan..."
                      />
                    </div>
                  </q-card-section>
                </q-card>

                <!-- Reminder Laporan Card -->
                <q-card class="settings-card" flat bordered>
                  <q-card-section class="card-header compact-header">
                    <div class="header-left">
                      <q-icon name="description" size="20px" color="teal" class="q-mr-sm" />
                      <div>
                        <div class="card-title small">Bereskan Laporan</div>
                        <div class="card-desc">Pengingat agar laporan siap dikirim</div>
                      </div>
                    </div>
                    <q-btn
                      color="teal"
                      unelevated
                      dense
                      size="sm"
                      no-caps
                      icon="send"
                      :loading="sendingReport"
                      @click="triggerReport"
                      class="compact-btn"
                    />
                  </q-card-section>
                  <q-separator />
                  <q-card-section class="card-body compact-body">
                    <div class="toggle-list">
                      <div class="toggle-item compact">
                        <q-toggle v-model="form.report_reminder_enabled" color="teal" size="sm" />
                        <div class="toggle-label">
                          <div class="toggle-title small">Aktifkan Reminder</div>
                        </div>
                      </div>
                    </div>
                    <div class="form-group" v-if="form.report_reminder_enabled">
                      <div class="datetime-row">
                        <div class="datetime-field">
                          <label class="field-label small">Tanggal</label>
                          <q-input
                            v-model.number="form.report_reminder_day"
                            type="number"
                            min="1"
                            max="31"
                            outlined
                            dense
                            :error="!!form.errors.report_reminder_day"
                            :error-message="form.errors.report_reminder_day"
                          >
                            <template v-slot:prepend>
                              <q-icon name="event" size="xs" />
                            </template>
                          </q-input>
                        </div>
                        <div class="datetime-field">
                          <label class="field-label small">Jam</label>
                          <q-input
                            v-model="form.report_reminder_time"
                            type="time"
                            outlined
                            dense
                            :error="!!form.errors.report_reminder_time"
                            :error-message="form.errors.report_reminder_time"
                          >
                            <template v-slot:prepend>
                              <q-icon name="schedule" size="xs" />
                            </template>
                          </q-input>
                        </div>
                      </div>
                      <label class="field-label small">Template Pesan</label>
                      <q-input
                        v-model="form.report_reminder_template"
                        type="textarea"
                        outlined
                        dense
                        rows="3"
                        @focus="setActiveTemplateField('report_reminder_template')"
                        :error="!!form.errors.report_reminder_template"
                        :error-message="form.errors.report_reminder_template"
                        placeholder="Masukkan template pesan..."
                      />
                    </div>
                  </q-card-section>
                </q-card>
              </div>
            </div>
          </div>

          <!-- Sidebar -->
          <aside class="sidebar">
            <div class="sidebar-sticky">
              <q-card class="settings-card sidebar-card" flat bordered>
                <q-card-section class="card-header">
                  <div class="header-left">
                    <q-icon name="local_offer" size="20px" color="amber-8" class="q-mr-sm" />
                    <div>
                      <div class="card-title small">Tag Template</div>
                      <div class="card-desc">Klik tag untuk insert ke template</div>
                    </div>
                  </div>
                </q-card-section>
                <q-separator />
                <q-card-section class="card-body">
                  <div v-if="activeTemplateField" class="active-template-info">
                    <q-icon name="info" size="16px" color="primary" />
                    <span>{{ activeTemplateField.replace(/_/g, ' ') }}</span>
                  </div>
                  <div class="tags-container">
                    <q-chip
                      v-for="tag in page.props.available_tags || []"
                      :key="tag"
                      clickable
                      color="grey-2"
                      text-color="grey-9"
                      size="sm"
                      @click="insertTagToActiveTemplate(tag)"
                      class="tag-chip"
                    >
                      {{ tag }}
                    </q-chip>
                  </div>
                </q-card-section>
                <q-separator />
                <q-card-section class="card-footer">
                  <q-btn
                    color="primary"
                    unelevated
                    no-caps
                    icon="save"
                    label="Simpan Pengaturan"
                    type="submit"
                    :loading="form.processing"
                    class="full-width"
                    size="md"
                  />
                </q-card-section>
              </q-card>
            </div>
          </aside>
        </div>
      </q-form>
    </div>
  </authenticated-layout>
</template>

<style scoped>
/* Base Styles */
.reminder-page {
  max-width: 1600px;
  margin: 0 auto;
  padding: 20px;
}

/* Header */
.page-header {
  margin-bottom: 32px;
}

.header-content {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.header-icon {
  width: 56px;
  height: 56px;
  background: linear-gradient(135deg, #1976d2 0%, #42a5f5 100%);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(25, 118, 210, 0.25);
}

.header-icon .q-icon {
  color: white !important;
}

.header-text {
  flex: 1;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  margin: 4px 0 8px 0;
  color: #1a202c;
  line-height: 1.2;
}

.page-subtitle {
  font-size: 14px;
  color: #64748b;
  margin: 0;
  line-height: 1.5;
}

/* Layout */
.content-layout {
  display: grid;
  grid-template-columns: 1fr;
  gap: 24px;
}

.main-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.sidebar {
  display: flex;
  flex-direction: column;
}

.sidebar-sticky {
  position: sticky;
  top: 80px;
}

/* Cards */
.settings-card {
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  background: #ffffff;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  transition: all 0.2s ease;
  overflow: hidden;
}

.settings-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  border-color: #cbd5e1;
}

/* Card Header */
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 20px;
  background: #f8fafc;
}

.card-header.compact-header {
  padding: 16px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  min-width: 0;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #1e293b;
  margin: 0;
  line-height: 1.3;
}

.card-title.small {
  font-size: 15px;
}

.card-desc {
  font-size: 12px;
  color: #64748b;
  margin-top: 2px;
  line-height: 1.4;
}

/* Card Body */
.card-body {
  padding: 20px;
}

.card-body.compact-body {
  padding: 16px;
}

.card-footer {
  padding: 16px 20px;
  background: #f8fafc;
}

/* Form Elements */
.form-group {
  margin-bottom: 16px;
}

.form-group:last-child {
  margin-bottom: 0;
}

.field-label {
  display: block;
  font-size: 13px;
  font-weight: 500;
  color: #475569;
  margin-bottom: 8px;
}

.field-label.small {
  font-size: 12px;
  margin-bottom: 6px;
}

/* Toggle List */
.toggle-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 20px;
}

.toggle-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px;
  background: #f8fafc;
  border-radius: 10px;
  transition: background 0.2s ease;
}

.toggle-item:hover {
  background: #f1f5f9;
}

.toggle-item.compact {
  padding: 8px 12px;
  gap: 10px;
}

.toggle-label {
  flex: 1;
  min-width: 0;
}

.toggle-title {
  font-size: 14px;
  font-weight: 500;
  color: #334155;
  margin-bottom: 2px;
}

.toggle-title.small {
  font-size: 13px;
}

.toggle-desc {
  font-size: 12px;
  color: #64748b;
  line-height: 1.4;
}

/* Date/Time Row */
.datetime-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 16px;
}

.datetime-field {
  display: flex;
  flex-direction: column;
}

/* Monthly Section */
.monthly-section {
  margin-top: 12px;
}

.section-title {
  display: flex;
  align-items: center;
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 2px solid #e2e8f0;
}

.monthly-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}

/* Buttons */
.action-btn {
  min-width: 140px;
  height: 36px;
  font-size: 13px;
  font-weight: 500;
  border-radius: 8px;
}

.compact-btn {
  min-width: 80px;
  height: 32px;
  font-size: 12px;
  border-radius: 6px;
}

.full-width {
  width: 100%;
  height: 44px;
  font-size: 14px;
  font-weight: 600;
  border-radius: 10px;
}

/* Sidebar Card */
.sidebar-card {
  background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
  border-color: #fde68a;
}

.active-template-info {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 8px;
  margin-bottom: 16px;
  font-size: 12px;
  color: #1976d2;
  font-weight: 500;
  border: 1px solid rgba(25, 118, 210, 0.2);
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  max-height: 400px;
  overflow-y: auto;
  padding: 4px;
}

.tag-chip {
  margin: 0 !important;
  font-size: 11px !important;
  height: 28px !important;
  transition: all 0.2s ease;
}

.tag-chip:hover {
  background-color: #e0e7ff !important;
  color: #4338ca !important;
  transform: translateY(-1px);
}

/* Responsive Design */
@media (min-width: 1024px) {
  .content-layout {
    grid-template-columns: 1fr 340px;
  }

  .monthly-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;
  }
}

@media (min-width: 1400px) {
  .content-layout {
    grid-template-columns: 1fr 380px;
  }
}

@media (max-width: 1023px) {
  .sidebar-sticky {
    position: static;
  }

  .tags-container {
    max-height: 250px;
  }
}

@media (max-width: 768px) {
  .reminder-page {
    padding: 16px;
  }

  .page-title {
    font-size: 24px;
  }

  .header-icon {
    width: 48px;
    height: 48px;
  }

  .page-header {
    margin-bottom: 24px;
  }

  .card-header {
    flex-direction: column;
    align-items: flex-start;
    padding: 16px;
  }

  .action-btn {
    width: 100%;
    min-width: unset;
  }

  .compact-btn {
    width: 100%;
    min-width: unset;
  }

  .card-title {
    font-size: 15px;
  }

  .section-title {
    font-size: 16px;
  }

  .datetime-row {
    grid-template-columns: 1fr;
    gap: 12px;
  }
}

@media (max-width: 599px) {
  .reminder-page {
    padding: 12px;
  }

  .settings-card {
    border-radius: 12px;
  }

  .card-body {
    padding: 16px;
  }

  .header-content {
    gap: 12px;
  }

  .header-icon {
    width: 44px;
    height: 44px;
  }

  .page-title {
    font-size: 22px;
  }

  .page-subtitle {
    font-size: 13px;
  }
}

/* Smooth Scrolling */
.tags-container::-webkit-scrollbar {
  width: 6px;
}

.tags-container::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 3px;
}

.tags-container::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.tags-container::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}
</style>
