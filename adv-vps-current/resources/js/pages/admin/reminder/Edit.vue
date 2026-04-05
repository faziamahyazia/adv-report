<script setup>
import { useForm, usePage } from "@inertiajs/vue3";
import { Notify } from "quasar";
import axios from "axios";
import { ref, computed } from "vue";

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

// Monthly reminders config for reusable component
const monthlyReminders = computed(() => [
  {
    key: 'plan',
    title: 'Input Plan Kegiatan',
    icon: 'assignment',
    color: 'teal',
    enabledField: 'plan_reminder_enabled',
    dayField: 'plan_reminder_day',
    timeField: 'plan_reminder_time',
    templateField: 'plan_reminder_template',
    sending: sendingPlan,
    triggerFn: triggerPlan,
  },
  {
    key: 'report',
    title: 'Bereskan Laporan',
    icon: 'description',
    color: 'amber-8',
    enabledField: 'report_reminder_enabled',
    dayField: 'report_reminder_day',
    timeField: 'report_reminder_time',
    templateField: 'report_reminder_template',
    sending: sendingReport,
    triggerFn: triggerReport,
  },
]);

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
      <q-form @submit.prevent="submit">
        <div class="page-container">
          <!-- Main Content Area -->
          <div class="content-grid">
            <!-- Notifikasi Dasar -->
            <q-card class="compact-card" flat bordered>
              <div class="card-header">
                <div class="header-content">
                  <q-icon name="notifications" size="18px" color="primary" />
                  <span class="card-title">Notifikasi Dasar</span>
                </div>
              </div>
              <q-separator />
              <div class="card-body">
                <q-input
                  v-model="form.fonte_owner_phone"
                  outlined
                  dense
                  label="Nomor Owner"
                  placeholder="08123456789"
                  class="q-mb-sm"
                  :error="!!form.errors.fonte_owner_phone"
                  :error-message="form.errors.fonte_owner_phone"
                >
                  <template v-slot:prepend>
                    <q-icon name="phone" size="sm" />
                  </template>
                </q-input>
                
                <div class="toggle-group">
                  <q-toggle
                    v-model="form.complaint_received_notification_enabled"
                    color="primary"
                    size="sm"
                    label="Notifikasi Keluhan"
                    dense
                  />
                  <q-toggle
                    v-model="form.activity_notification_enabled"
                    color="primary"
                    size="sm"
                    label="Notifikasi Realisasi"
                    dense
                  />
                </div>

                <q-input
                  v-if="form.activity_notification_enabled"
                  v-model="form.activity_notification_template"
                  type="textarea"
                  outlined
                  dense
                  rows="3"
                  label="Template Realisasi"
                  class="q-mt-sm"
                  @focus="setActiveTemplateField('activity_notification_template')"
                  :error="!!form.errors.activity_notification_template"
                  :error-message="form.errors.activity_notification_template"
                />
              </div>
            </q-card>

            <!-- Reminder Jumat -->
            <q-card class="compact-card" flat bordered>
              <div class="card-header">
                <div class="header-content">
                  <q-icon name="event_note" size="18px" color="indigo" />
                  <span class="card-title">Reminder Jumat</span>
                </div>
                <q-btn
                  color="indigo"
                  size="sm"
                  unelevated
                  dense
                  no-caps
                  icon="send"
                  :loading="sendingWeekly"
                  @click="triggerWeekly"
                />
              </div>
              <q-separator />
              <div class="card-body">
                <q-toggle
                  v-model="form.weekly_reminder_enabled"
                  color="indigo"
                  size="sm"
                  label="Aktifkan Reminder Mingguan"
                  dense
                  class="q-mb-sm"
                />

                <q-input
                  v-if="form.weekly_reminder_enabled"
                  v-model="form.weekly_reminder_template"
                  type="textarea"
                  outlined
                  dense
                  rows="3"
                  label="Template Pesan"
                  @focus="setActiveTemplateField('weekly_reminder_template')"
                  :error="!!form.errors.weekly_reminder_template"
                  :error-message="form.errors.weekly_reminder_template"
                />
              </div>
            </q-card>

            <!-- Reminder Bulanan (Reusable Component Loop) -->
            <q-card
              v-for="reminder in monthlyReminders"
              :key="reminder.key"
              class="compact-card"
              flat
              bordered
            >
              <div class="card-header">
                <div class="header-content">
                  <q-icon :name="reminder.icon" size="18px" :color="reminder.color" />
                  <span class="card-title">{{ reminder.title }}</span>
                </div>
                <q-btn
                  :color="reminder.color"
                  size="sm"
                  unelevated
                  dense
                  no-caps
                  icon="send"
                  :loading="reminder.sending.value"
                  @click="reminder.triggerFn"
                />
              </div>
              <q-separator />
              <div class="card-body">
                <q-toggle
                  v-model="form[reminder.enabledField]"
                  :color="reminder.color"
                  size="sm"
                  label="Aktifkan Reminder"
                  dense
                  class="q-mb-sm"
                />

                <div v-if="form[reminder.enabledField]">
                  <div class="inline-form q-mb-sm">
                    <q-input
                      v-model.number="form[reminder.dayField]"
                      type="number"
                      min="1"
                      max="31"
                      outlined
                      dense
                      label="Tgl"
                      style="flex: 1"
                      :error="!!form.errors[reminder.dayField]"
                    >
                      <template v-slot:prepend>
                        <q-icon name="event" size="xs" />
                      </template>
                    </q-input>
                    <q-input
                      v-model="form[reminder.timeField]"
                      type="time"
                      outlined
                      dense
                      label="Jam"
                      style="flex: 1"
                      :error="!!form.errors[reminder.timeField]"
                    >
                      <template v-slot:prepend>
                        <q-icon name="schedule" size="xs" />
                      </template>
                    </q-input>
                  </div>

                  <q-input
                    v-model="form[reminder.templateField]"
                    type="textarea"
                    outlined
                    dense
                    rows="3"
                    label="Template Pesan"
                    @focus="setActiveTemplateField(reminder.templateField)"
                    :error="!!form.errors[reminder.templateField]"
                    :error-message="form.errors[reminder.templateField]"
                  />
                </div>
              </div>
            </q-card>
          </div>

          <!-- Sticky Sidebar -->
          <aside class="sidebar-panel">
            <q-card class="compact-card sticky-card" flat bordered>
              <div class="card-header">
                <div class="header-content">
                  <q-icon name="local_offer" size="18px" color="primary" />
                  <span class="card-title">Tag Template</span>
                </div>
              </div>
              <q-separator />
              <div class="card-body">
                <div v-if="activeTemplateField" class="active-field-badge">
                  <q-icon name="info" size="14px" />
                  <span class="text-caption">{{ activeTemplateField.replace(/_/g, ' ') }}</span>
                </div>
                <div class="tags-grid">
                  <q-chip
                    v-for="tag in page.props.available_tags || []"
                    :key="tag"
                    clickable
                    size="sm"
                    color="grey-2"
                    text-color="grey-8"
                    @click="insertTagToActiveTemplate(tag)"
                  >
                    {{ tag }}
                  </q-chip>
                </div>
              </div>
              <q-separator />
              <div class="card-footer">
                <q-btn
                  color="primary"
                  unelevated
                  no-caps
                  icon="save"
                  label="Simpan"
                  type="submit"
                  :loading="form.processing"
                  class="full-width-btn"
                />
              </div>
            </q-card>
          </aside>
        </div>
      </q-form>
    </div>
  </authenticated-layout>
</template>

<style scoped>
/* Container & Layout */
.reminder-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 16px;
}

.page-container {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}

/* Grid System - Responsive */
.content-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 12px;
}

/* Cards */
.compact-card {
  border-radius: 8px;
  border: 1px solid #e0e0e0;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
  overflow: hidden;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  background: #fafafa;
  min-height: 48px;
}

.header-content {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  min-width: 0;
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  color: #2c3e50;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.card-body {
  padding: 16px;
}

.card-footer {
  padding: 12px 16px;
  background: #fafafa;
}

/* Toggle Group */
.toggle-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 8px;
}

/* Inline Form */
.inline-form {
  display: flex;
  gap: 8px;
}

/* Active Field Badge */
.active-field-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 10px;
  background: #e3f2fd;
  border-radius: 4px;
  margin-bottom: 12px;
  font-size: 12px;
  color: #1976d2;
}

/* Tags Grid */
.tags-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  max-height: 400px;
  overflow-y: auto;
}

/* Sidebar */
.sidebar-panel {
  display: flex;
  flex-direction: column;
}

.sticky-card {
  position: sticky;
  top: 70px;
}

.full-width-btn {
  width: 100%;
  height: 40px;
}

/* Scrollbar */
.tags-grid::-webkit-scrollbar {
  width: 5px;
}

.tags-grid::-webkit-scrollbar-track {
  background: #f5f5f5;
}

.tags-grid::-webkit-scrollbar-thumb {
  background: #bdbdbd;
  border-radius: 3px;
}

/* Responsive - Desktop */
@media (min-width: 1024px) {
  .page-container {
    grid-template-columns: 1fr 320px;
    gap: 20px;
  }

  .content-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }
}

/* Responsive - Large Desktop */
@media (min-width: 1400px) {
  .content-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .page-container {
    grid-template-columns: 1fr 340px;
  }
}

/* Responsive - Tablet */
@media (min-width: 768px) and (max-width: 1023px) {
  .content-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Responsive - Mobile */
@media (max-width: 767px) {
  .reminder-page {
    padding: 12px;
  }

  .page-container {
    gap: 12px;
  }

  .content-grid {
    gap: 12px;
  }

  .sticky-card {
    position: static;
  }

  .card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
    padding: 12px;
  }

  .card-header .q-btn {
    align-self: stretch;
  }

  .inline-form {
    flex-direction: column;
    gap: 10px;
  }
}

/* Utility */
.q-mb-sm {
  margin-bottom: 8px;
}

.q-mt-sm {
  margin-top: 8px;
}
</style>
