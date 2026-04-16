<script setup>
import { reactive, ref } from "vue";
import { useQuasar } from "quasar";
import axios from "axios";

const props = defineProps({
  defaults: {
    type: Object,
    default: () => ({}),
  },
});

const $q = useQuasar();
const loading = ref(false);
const output = ref("");
const lastStatus = ref(null);

const form = reactive({
  app_path: props.defaults.app_path || "/var/www/adv",
  backup_path: props.defaults.backup_path || "/root/deploy-backups",
  db_name: props.defaults.db_name || "",
  large_file_size_mb: Number(props.defaults.large_file_size_mb || 100),
  log_retention_days: Number(props.defaults.log_retention_days || 14),
  backup_retention_days: Number(props.defaults.backup_retention_days || 30),
  apply_cleanup: false,
});

async function runAction(type) {
  loading.value = true;
  output.value = "";
  lastStatus.value = null;

  try {
    let url = "";
    let payload = {};

    if (type === "audit-files") {
      url = route("admin.db.audit-files");
      payload = {
        app_path: form.app_path,
        backup_path: form.backup_path,
        large_file_size_mb: form.large_file_size_mb,
      };
    }

    if (type === "audit-db") {
      url = route("admin.db.audit-db");
      payload = { db_name: form.db_name };
    }

    if (type === "cleanup") {
      url = route("admin.db.cleanup");
      payload = {
        app_path: form.app_path,
        backup_path: form.backup_path,
        log_retention_days: form.log_retention_days,
        backup_retention_days: form.backup_retention_days,
        apply: form.apply_cleanup,
      };
    }

    const res = await axios.post(url, payload);
    lastStatus.value = !!res.data?.ok;
    output.value = res.data?.output || "Tidak ada output.";

    $q.notify({
      type: res.data?.ok ? "positive" : "negative",
      message: res.data?.message || "Perintah selesai dijalankan.",
    });
  } catch (error) {
    const message = error?.response?.data?.message || "Gagal menjalankan perintah.";
    output.value = error?.response?.data?.output || message;
    lastStatus.value = false;
    $q.notify({ type: "negative", message });
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <i-head title="DB Administration" />
  <authenticated-layout>
    <template #title>DB Administration</template>
    <div class="row q-col-gutter-md q-pa-sm">
      <q-card class="col-12 q-pa-xs" square flat bordered>
        <q-card-section>
          <div class="text-subtitle1 text-bold text-grey-8">Manage Data VPS</div>
          <div class="text-grey-8 q-mt-xs">
            Audit ukuran file deploy, upload foto, tabel database, dan jalankan cleanup aman.
          </div>
        </q-card-section>
      </q-card>

      <q-card class="col-12 col-md-6" flat bordered square>
        <q-card-section class="text-subtitle2 text-bold">Konfigurasi Path</q-card-section>
        <q-card-section class="q-gutter-sm">
          <q-input v-model="form.app_path" label="App Path" dense outlined />
          <q-input v-model="form.backup_path" label="Backup Path" dense outlined />
          <q-input v-model.number="form.large_file_size_mb" type="number" label="Minimum file besar (MB)" dense outlined />
        </q-card-section>
        <q-card-actions align="left" class="q-px-md q-pb-md">
          <q-btn
            color="primary"
            label="Audit File & Foto"
            :loading="loading"
            @click="runAction('audit-files')"
          />
        </q-card-actions>
      </q-card>

      <q-card class="col-12 col-md-6" flat bordered square>
        <q-card-section class="text-subtitle2 text-bold">Audit Database</q-card-section>
        <q-card-section class="q-gutter-sm">
          <q-input v-model="form.db_name" label="Nama Database" dense outlined />
        </q-card-section>
        <q-card-actions align="left" class="q-px-md q-pb-md">
          <q-btn
            color="secondary"
            label="Audit Tabel Database"
            :loading="loading"
            @click="runAction('audit-db')"
          />
        </q-card-actions>
      </q-card>

      <q-card class="col-12" flat bordered square>
        <q-card-section class="text-subtitle2 text-bold">Cleanup Data Lama</q-card-section>
        <q-card-section class="row q-col-gutter-sm items-end">
          <div class="col-12 col-md-3">
            <q-input v-model.number="form.log_retention_days" type="number" label="Retensi log (hari)" dense outlined />
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model.number="form.backup_retention_days" type="number" label="Retensi backup (hari)" dense outlined />
          </div>
          <div class="col-12 col-md-4">
            <q-checkbox
              v-model="form.apply_cleanup"
              label="Saya paham, aktifkan hapus nyata (--apply)"
            />
          </div>
          <div class="col-12 col-md-2">
            <q-btn
              class="full-width"
              :color="form.apply_cleanup ? 'negative' : 'orange'"
              :label="form.apply_cleanup ? 'Cleanup Sekarang' : 'Preview Cleanup'"
              :loading="loading"
              @click="runAction('cleanup')"
            />
          </div>
        </q-card-section>
      </q-card>

      <q-card class="col-12" flat bordered square>
        <q-card-section class="row items-center justify-between">
          <div class="text-subtitle2 text-bold">Output</div>
          <q-badge v-if="lastStatus === true" color="positive" label="Sukses" />
          <q-badge v-if="lastStatus === false" color="negative" label="Gagal" />
        </q-card-section>
        <q-separator />
        <q-card-section>
          <pre class="output-box bg-grey-2 q-pa-sm rounded-borders">{{ output || 'Belum ada output. Jalankan salah satu aksi di atas.' }}</pre>
        </q-card-section>
      </q-card>
    </div>
  </authenticated-layout>
</template>

<style scoped>
.output-box {
  white-space: pre-wrap;
  min-height: 180px;
  max-height: 460px;
  overflow: auto;
  font-size: 12px;
}
</style>
