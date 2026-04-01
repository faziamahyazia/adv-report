<script setup>
import { useForm, usePage } from "@inertiajs/vue3";
import { Notify, useQuasar } from "quasar";
import axios from "axios";
import { ref } from "vue";

const page = usePage();
const $q = useQuasar();
const title = "Reminder WA";
const sendingPlan = ref(false);
const sendingReport = ref(false);

const form = useForm({
  fonte_owner_phone: page.props.data.fonte_owner_phone || "",
  complaint_received_notification_enabled: !!page.props.data.complaint_received_notification_enabled,
  activity_notification_enabled: !!page.props.data.activity_notification_enabled,
  activity_notification_template: page.props.data.activity_notification_template || "",
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
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>

    <div class="q-pa-sm">
      <div class="row q-col-gutter-md justify-center">
        <div class="col-12 col-lg-8">
          <q-form @submit.prevent="submit">
            <q-card flat bordered class="q-mb-md">
              <q-card-section>
                <div class="text-subtitle1 text-weight-bold">Nomor Owner Penerima Notifikasi WA</div>
                <div class="text-caption text-grey-7 q-mt-xs">
                  Nomor ini adalah tujuan notifikasi WA owner. Nomor pengirim WA ditentukan oleh device/token Fonte yang aktif.
                </div>
              </q-card-section>
              <q-separator />
              <q-card-section class="q-gutter-md">
                <q-input
                  v-model="form.fonte_owner_phone"
                  outlined
                  label="No Owner Penerima Notifikasi"
                  hint="Contoh: 081234567890 atau 6281234567890"
                  :error="!!form.errors.fonte_owner_phone"
                  :error-message="form.errors.fonte_owner_phone"
                />
              </q-card-section>
            </q-card>

            <q-card flat bordered class="q-mb-md">
              <q-card-section>
                <div class="text-subtitle1 text-weight-bold">Notifikasi Keluhan ke BS</div>
                <div class="text-caption text-grey-7 q-mt-xs">
                  BS akan menerima WA konfirmasi saat keluhan baru berhasil dibuat.
                </div>
              </q-card-section>
              <q-separator />
              <q-card-section class="q-gutter-md">
                <q-toggle v-model="form.complaint_received_notification_enabled" label="Aktifkan notifikasi keluhan diterima ke BS" />
              </q-card-section>
            </q-card>

            <q-card flat bordered class="q-mb-md">
              <q-card-section>
                <div class="text-subtitle1 text-weight-bold">Notifikasi Realisasi Kegiatan</div>
                <div class="text-caption text-grey-7 q-mt-xs">
                  Agronomis akan mendapat WA saat BS input atau update realisasi kegiatan.
                </div>
              </q-card-section>
              <q-separator />
              <q-card-section class="q-gutter-md">
                <q-toggle v-model="form.activity_notification_enabled" label="Aktifkan notifikasi realisasi kegiatan" />
                <q-input
                  v-model="form.activity_notification_template"
                  type="textarea"
                  autogrow
                  outlined
                  label="Template Pesan"
                  :error="!!form.errors.activity_notification_template"
                  :error-message="form.errors.activity_notification_template"
                />
              </q-card-section>
            </q-card>

            <q-card flat bordered class="q-mb-md">
              <q-card-section class="row items-center justify-between q-col-gutter-sm">
                <div class="col">
                  <div class="text-subtitle1 text-weight-bold">Reminder Input Plan Kegiatan</div>
                  <div class="text-caption text-grey-7 q-mt-xs">
                    Dikirim rutin tiap bulan ke BS sesuai pengaturan tanggal dan jam.
                  </div>
                </div>
                <div class="col-auto">
                  <q-btn color="primary" flat icon="send" label="Trigger Sekarang" :loading="sendingPlan" @click="triggerPlan" />
                </div>
              </q-card-section>
              <q-separator />
              <q-card-section class="q-gutter-md">
                <q-toggle v-model="form.plan_reminder_enabled" label="Aktifkan reminder plan bulanan" />
                <div class="row q-col-gutter-sm">
                  <div class="col-6 col-md-3">
                    <q-input
                      v-model.number="form.plan_reminder_day"
                      type="number"
                      min="1"
                      max="31"
                      outlined
                      label="Tanggal"
                      :error="!!form.errors.plan_reminder_day"
                      :error-message="form.errors.plan_reminder_day"
                    />
                  </div>
                  <div class="col-6 col-md-3">
                    <q-input
                      v-model="form.plan_reminder_time"
                      type="time"
                      outlined
                      label="Jam"
                      :error="!!form.errors.plan_reminder_time"
                      :error-message="form.errors.plan_reminder_time"
                    />
                  </div>
                </div>
                <q-input
                  v-model="form.plan_reminder_template"
                  type="textarea"
                  autogrow
                  outlined
                  label="Template Pesan"
                  :error="!!form.errors.plan_reminder_template"
                  :error-message="form.errors.plan_reminder_template"
                />
              </q-card-section>
            </q-card>

            <q-card flat bordered class="q-mb-md">
              <q-card-section class="row items-center justify-between q-col-gutter-sm">
                <div class="col">
                  <div class="text-subtitle1 text-weight-bold">Reminder Bereskan Laporan</div>
                  <div class="text-caption text-grey-7 q-mt-xs">
                    Reminder ke BS agar laporan rapi di tanggal 23 supaya tanggal 25 bisa dikirim ke agronomis.
                  </div>
                </div>
                <div class="col-auto">
                  <q-btn color="primary" flat icon="send" label="Trigger Sekarang" :loading="sendingReport" @click="triggerReport" />
                </div>
              </q-card-section>
              <q-separator />
              <q-card-section class="q-gutter-md">
                <q-toggle v-model="form.report_reminder_enabled" label="Aktifkan reminder laporan bulanan" />
                <div class="row q-col-gutter-sm">
                  <div class="col-6 col-md-3">
                    <q-input
                      v-model.number="form.report_reminder_day"
                      type="number"
                      min="1"
                      max="31"
                      outlined
                      label="Tanggal"
                      :error="!!form.errors.report_reminder_day"
                      :error-message="form.errors.report_reminder_day"
                    />
                  </div>
                  <div class="col-6 col-md-3">
                    <q-input
                      v-model="form.report_reminder_time"
                      type="time"
                      outlined
                      label="Jam"
                      :error="!!form.errors.report_reminder_time"
                      :error-message="form.errors.report_reminder_time"
                    />
                  </div>
                </div>
                <q-input
                  v-model="form.report_reminder_template"
                  type="textarea"
                  autogrow
                  outlined
                  label="Template Pesan"
                  :error="!!form.errors.report_reminder_template"
                  :error-message="form.errors.report_reminder_template"
                />
              </q-card-section>
            </q-card>

            <q-card flat bordered>
              <q-card-section>
                <div class="text-subtitle2 text-weight-bold">Tag yang bisa dipakai</div>
                <div class="text-caption text-grey-7 q-mt-xs">
                  Gunakan tag berikut di template pesan agar isi otomatis terganti.
                </div>
                <div class="q-mt-sm row q-col-gutter-sm">
                  <div v-for="tag in page.props.available_tags || []" :key="tag" class="col-auto">
                    <q-chip color="grey-3" text-color="dark">{{ tag }}</q-chip>
                  </div>
                </div>
              </q-card-section>
              <q-separator />
              <q-card-actions align="right">
                <q-btn color="primary" label="Simpan Pengaturan" type="submit" :loading="form.processing" />
              </q-card-actions>
            </q-card>
          </q-form>
        </div>
      </div>
    </div>
  </authenticated-layout>
</template>
