<script setup>
import { computed, onMounted, reactive, watch } from "vue";
import { useForm, router, usePage } from "@inertiajs/vue3";
import { Notify, useQuasar } from "quasar";

const page = usePage();
const $q = useQuasar();
const title = computed(() => (page.props.data?.id ? `Edit Keluhan #${page.props.data.id}` : "Tambah Keluhan"));
const draftKey = computed(() => `complaint-draft-${page.props.auth.user.id}`);
const isDesktop = computed(() => $q.screen.gt.md);

const categoryOptions = [
  { label: "Rebah Semai", value: "rebah_semai" },
  { label: "Pertumbuhan Lambat", value: "pertumbuhan_lambat" },
  { label: "Keseragaman Jelek", value: "keseragaman_jelek" },
  { label: "Vigor Jelek", value: "vigor_jelek" },
  { label: "Daya Tumbuh Rendah", value: "daya_tumbuh_rendah" },
  { label: "Bulai", value: "bulai" },
  { label: "Busuk Batang", value: "busuk_batang" },
  { label: "Lainnya", value: "other" },
];

const form = useForm({
  id: page.props.data?.id || null,
  title: page.props.data?.title || "",
  reporter_name: page.props.data?.reporter_name || "",
  category: page.props.data?.category || "rebah_semai",
  description: page.props.data?.description || "",
  product_id: page.props.data?.product_id || null,
  product_name: page.props.data?.product_name || "",
  batch_id: page.props.data?.batch_id || null,
  batch_number: page.props.data?.batch?.batch_number || "",
  bs_id: page.props.data?.bs_id || (page.props.auth.user.role === "bs" ? page.props.auth.user.id : null),
  location: page.props.data?.location || "",
  severity: page.props.data?.severity || "medium",
  status: "open",
  source: "online",
  images: [],
});

const productOptions = computed(() => (page.props.products || []).map((p) => ({ label: p.name, value: p.id })));
const bsOptions = computed(() => (page.props.bs_users || []).map((u) => ({ label: `${u.name} (${u.username})`, value: u.id })));

const batchOptions = computed(() => {
  const pid = Number(form.product_id || 0);
  const rows = page.props.batches || [];
  return rows
    .filter((b) => !pid || Number(b.product_id || 0) === pid)
    .map((b) => ({ label: `${b.batch_number} - ${b.product_name}`, value: b.id, batch_number: b.batch_number }));
});

const applyBatchMeta = () => {
  const selected = batchOptions.value.find((x) => Number(x.value) === Number(form.batch_id || 0));
  if (!selected) return;
  form.batch_number = selected.batch_number || "";
};

const saveDraft = () => {
  if (form.id) return;
  const payload = {
    title: form.title,
    reporter_name: form.reporter_name,
    category: form.category,
    description: form.description,
    product_id: form.product_id,
    product_name: form.product_name,
    batch_id: form.batch_id,
    batch_number: form.batch_number,
    bs_id: form.bs_id,
    location: form.location,
    severity: form.severity,
  };
  localStorage.setItem(draftKey.value, JSON.stringify(payload));
};

const restoreDraft = () => {
  if (form.id) return;
  const raw = localStorage.getItem(draftKey.value);
  if (!raw) return;

  try {
    const d = JSON.parse(raw);
    Object.assign(form, d);
    form.source = "offline_sync";
    Notify.create({ color: "info", message: "Draft offline dipulihkan" });
  } catch (_e) {
    // ignore invalid draft
  }
};

const submit = () => {
  form.post(route("admin.complaint.save"), {
    forceFormData: true,
    onSuccess: () => {
      localStorage.removeItem(draftKey.value);
    },
  });
};

onMounted(restoreDraft);
watch(form, saveDraft, { deep: true });
watch(() => form.batch_id, applyBatchMeta);
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>

    <div class="complaint-editor-page q-pa-sm q-pa-md-md">
      <q-card flat bordered class="complaint-editor-card">
        <q-card-section class="q-pb-none">
          <div class="text-h6 text-weight-bold">Form Input Complaint</div>
          <div class="text-caption text-grey-7 q-mt-xs">
            Layout desktop sudah dioptimasi full-width agar input lebih cepat dan rapi.
          </div>
        </q-card-section>

        <q-card-section>
          <q-form @submit.prevent="submit" class="q-gutter-md">
            <div class="text-subtitle2 text-weight-medium">Informasi Keluhan</div>
            <div class="row q-col-gutter-md">
              <q-input class="col-12 col-lg-8" v-model="form.title" outlined dense label="Subjek *" :error="!!form.errors.title" :error-message="form.errors.title" />
              <q-input class="col-12 col-lg-4" v-model="form.reporter_name" outlined dense label="Nama Petani / Bandar" :error="!!form.errors.reporter_name" :error-message="form.errors.reporter_name" />

              <q-select class="col-12 col-md-6 col-xl-4" v-model="form.category" outlined dense emit-value map-options label="Kategori *"
                :options="categoryOptions" :error="!!form.errors.category" :error-message="form.errors.category" />
              <q-select class="col-12 col-md-6 col-xl-4" v-model="form.severity" outlined dense emit-value map-options label="Severity"
                :options="[
                  { label: 'Low', value: 'low' },
                  { label: 'Medium', value: 'medium' },
                  { label: 'High', value: 'high' },
                ]" :error="!!form.errors.severity" :error-message="form.errors.severity" />
              <q-select v-if="$page.props.auth.user.role !== 'bs'" class="col-12 col-md-6 col-xl-4" v-model="form.bs_id" outlined dense emit-value map-options label="BS" :options="bsOptions" :error="!!form.errors.bs_id" :error-message="form.errors.bs_id" />
            </div>

            <q-separator class="q-my-sm" />

            <div class="text-subtitle2 text-weight-medium">Produk dan Batch</div>
            <div class="row q-col-gutter-md">
              <q-select class="col-12 col-md-6 col-xl-4" v-model="form.product_id" outlined dense emit-value map-options label="Produk" :options="productOptions" clearable />
              <q-select class="col-12 col-md-6 col-xl-4" v-model="form.batch_id" outlined dense emit-value map-options label="Pilih Lot/Batch (opsional)" :options="batchOptions" clearable />
              <q-input class="col-12 col-md-6 col-xl-4" v-model="form.batch_number" outlined dense label="No Lot / Batch Number" :error="!!form.errors.batch_number" :error-message="form.errors.batch_number" />
            </div>

            <q-separator class="q-my-sm" />

            <div class="text-subtitle2 text-weight-medium">Detail Lapangan</div>
            <div class="row q-col-gutter-md">
              <q-input class="col-12 col-lg-8" v-model="form.location" outlined dense label="Alamat" :error="!!form.errors.location" :error-message="form.errors.location" />
              <q-input class="col-12 col-lg-4" v-model="form.status" outlined dense disable label="Status" />

              <q-input class="col-12" v-model="form.description" outlined type="textarea" autogrow label="Deskripsi Keluhan" :error="!!form.errors.description" :error-message="form.errors.description" />

              <q-file class="col-12" v-model="form.images" label="Upload Foto (maks 5, akan dikompres)" outlined dense multiple accept="image/*" :error="!!form.errors.images || !!form.errors['images.0']" :error-message="form.errors.images || form.errors['images.0']" />
            </div>

            <div class="row justify-between items-center q-pt-sm">
              <div class="text-caption text-grey-7" :class="{ 'q-mb-sm': !isDesktop }">
                Mode offline draft aktif: form otomatis disimpan di perangkat Anda.
              </div>
              <div>
                <q-btn flat color="grey-7" label="Batal" @click="router.get(route('admin.complaint.index'))" />
                <q-btn class="q-ml-sm" color="primary" label="Simpan Keluhan" type="submit" :loading="form.processing" />
              </div>
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </div>
  </authenticated-layout>
</template>

<style scoped>
.complaint-editor-page {
  width: 100%;
}

.complaint-editor-card {
  width: 100%;
  border-radius: 14px;
}

@media (min-width: 1280px) {
  .complaint-editor-page {
    padding-left: 20px;
    padding-right: 20px;
  }
}
</style>
