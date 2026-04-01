<script setup>
import { ref, reactive, watch, onMounted } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import AuthenticatedLayout from "@/layouts/AuthenticatedLayout.vue";
import axios from "axios";
import { useQuasar } from "quasar";

const page = usePage();
const categories = page.props.categories ?? [];
const availableProducts = page.props.products ?? [];
const $q = useQuasar();

const activeTab = ref("gallery");

const filter = reactive({ search: "", category_id: "all" });
const products = ref([]);
const loading = ref(false);

const categoryOptions = [
  { value: "all", label: "Semua Kategori" },
  ...categories.map((c) => ({ value: c.id, label: c.name })),
];

const productOptions = [
  { value: "all", label: "Semua Varietas" },
  ...availableProducts.map((p) => ({ value: p.id, label: p.name })),
];

const harvestFilter = reactive({
  search: "",
  product_id: "all",
});

const todayIso = new Date(Date.now() - new Date().getTimezoneOffset() * 60000)
  .toISOString()
  .slice(0, 10);

const harvestForm = reactive({
  product_id: null,
  harvest_date: todayIso,
  harvest_age_days: null,
  harvest_quantity: null,
  harvest_unit: "kg/ha",
  location: "",
  strengths: "",
  weaknesses: "",
  notes: "",
  photo: null,
});

const harvestItems = ref([]);
const harvestLoading = ref(false);
const harvestSubmitting = ref(false);

async function fetchProducts() {
  loading.value = true;
  try {
    const res = await axios.get(route("admin.product-knowledge.data"), {
      params: { filter },
    });
    products.value = res.data;
  } finally {
    loading.value = false;
  }
}

async function fetchHarvests() {
  harvestLoading.value = true;
  try {
    const res = await axios.get(route("admin.product-knowledge.harvest-data"), {
      params: { filter: harvestFilter },
    });
    harvestItems.value = res.data;
  } finally {
    harvestLoading.value = false;
  }
}

function resetHarvestForm() {
  harvestForm.product_id = null;
  harvestForm.harvest_date = todayIso;
  harvestForm.harvest_age_days = null;
  harvestForm.harvest_quantity = null;
  harvestForm.harvest_unit = "kg/ha";
  harvestForm.location = "";
  harvestForm.strengths = "";
  harvestForm.weaknesses = "";
  harvestForm.notes = "";
  harvestForm.photo = null;
}

async function submitHarvest() {
  if (harvestSubmitting.value) {
    return;
  }

  harvestSubmitting.value = true;
  try {
    const formData = new FormData();
    formData.append("product_id", harvestForm.product_id ?? "");
    formData.append("harvest_date", harvestForm.harvest_date ?? "");
    formData.append("harvest_age_days", harvestForm.harvest_age_days ?? "");
    formData.append("harvest_quantity", harvestForm.harvest_quantity ?? "");
    formData.append("harvest_unit", harvestForm.harvest_unit ?? "");
    formData.append("location", harvestForm.location ?? "");
    formData.append("strengths", harvestForm.strengths ?? "");
    formData.append("weaknesses", harvestForm.weaknesses ?? "");
    formData.append("notes", harvestForm.notes ?? "");
    if (harvestForm.photo) {
      formData.append("photo", harvestForm.photo);
    }

    const res = await axios.post(route("admin.product-knowledge.harvest-store"), formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });

    $q.notify({
      type: "positive",
      message: res?.data?.message ?? "Data hasil panen berhasil disimpan.",
      position: "top",
    });

    resetHarvestForm();
    await fetchHarvests();
  } catch (error) {
    const msg = error?.response?.data?.message ?? "Gagal menyimpan data hasil panen.";
    $q.notify({ type: "negative", message: msg, position: "top" });
  } finally {
    harvestSubmitting.value = false;
  }
}

function formatDate(value) {
  if (!value) {
    return "-";
  }
  return new Intl.DateTimeFormat("id-ID", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(new Date(value));
}

function formatDateTime(value) {
  if (!value) {
    return "-";
  }
  return new Intl.DateTimeFormat("id-ID", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(value));
}

onMounted(async () => {
  await Promise.all([fetchProducts(), fetchHarvests()]);
});

let debounceTimer;
watch(filter, () => {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(fetchProducts, 300);
});

let harvestDebounceTimer;
watch(harvestFilter, () => {
  clearTimeout(harvestDebounceTimer);
  harvestDebounceTimer = setTimeout(fetchHarvests, 300);
});

function goGallery(product) {
  router.get(route("admin.product-knowledge.gallery", product.id));
}
function goEditor(product, e) {
  e.stopPropagation();
  router.get(route("admin.product-knowledge.photo-editor", product.id));
}

const canEdit = page.props.auth?.user?.role === "admin";
const isBs = page.props.auth?.user?.role === "bs";
</script>

<template>
  <AuthenticatedLayout>
    <template #title>Product Knowledge</template>
    <template #header>
      <q-toolbar class="filter-bar">
        <div class="row q-col-gutter-xs items-center q-pa-sm full-width">
          <div class="col-12 col-md-auto">
            <q-tabs
              v-model="activeTab"
              dense
              active-color="primary"
              indicator-color="primary"
              class="bg-white rounded-borders q-pa-xs"
            >
              <q-tab name="gallery" icon="photo_library" label="Galeri Produk" />
              <q-tab name="harvest" icon="agriculture" label="Hasil Panen" />
            </q-tabs>
          </div>

          <div v-if="activeTab === 'gallery'" class="col-auto">
            <q-input
              v-model="filter.search"
              dense
              outlined
              placeholder="Cari varietas..."
              clearable
              bg-color="white"
              style="max-width:240px"
            >
              <template #prepend><q-icon name="search" size="18px" /></template>
            </q-input>
          </div>
          <div v-if="activeTab === 'gallery'" class="col-auto">
            <q-select
              v-model="filter.category_id"
              :options="categoryOptions"
              option-value="value"
              option-label="label"
              emit-value
              map-options
              dense
              outlined
              bg-color="white"
              style="min-width:130px; max-width:180px"
            />
          </div>

          <div v-if="activeTab === 'harvest'" class="col-auto">
            <q-input
              v-model="harvestFilter.search"
              dense
              outlined
              placeholder="Cari lokasi, varietas, penginput..."
              clearable
              bg-color="white"
              style="max-width:280px"
            >
              <template #prepend><q-icon name="search" size="18px" /></template>
            </q-input>
          </div>
          <div v-if="activeTab === 'harvest'" class="col-auto">
            <q-select
              v-model="harvestFilter.product_id"
              :options="productOptions"
              option-value="value"
              option-label="label"
              emit-value
              map-options
              dense
              outlined
              bg-color="white"
              style="min-width:160px; max-width:220px"
            />
          </div>
        </div>
      </q-toolbar>
    </template>

    <div v-if="activeTab === 'gallery'">
      <div v-if="loading" class="pk-grid">
        <div v-for="n in 12" :key="n" class="pk-skeleton">
          <q-skeleton square style="aspect-ratio:1/1; width:100%" />
          <q-skeleton type="text" width="70%" class="q-mt-xs q-mx-xs" />
        </div>
      </div>

      <div v-else-if="products.length === 0" class="q-pa-xl text-center text-grey-5">
        <q-icon name="photo_library" size="56px" />
        <div class="text-subtitle2 q-mt-sm text-grey-6">Tidak ada varietas ditemukan.</div>
      </div>

      <div v-else class="pk-grid">
        <div
          v-for="product in products"
          :key="product.id"
          class="pk-item cursor-pointer"
          @click="goGallery(product)"
        >
          <div class="pk-thumb">
            <q-img
              v-if="product.photos && product.photos.length > 0"
              :src="'/' + product.photos[0].image_path"
              ratio="1"
              loading="lazy"
              class="pk-img"
            >
              <template #error>
                <div class="absolute-full flex flex-center bg-grey-2">
                  <q-icon name="image_not_supported" size="28px" color="grey-5" />
                </div>
              </template>
            </q-img>
            <div v-else class="pk-no-photo flex flex-center bg-grey-2">
              <q-icon name="add_photo_alternate" size="28px" color="grey-5" />
            </div>

            <span v-if="product.photos_count > 0" class="pk-badge">
              {{ product.photos_count }}
            </span>

            <button
              v-if="canEdit"
              class="pk-edit-btn"
              title="Kelola Foto"
              @click="goEditor(product, $event)"
            >
              <q-icon name="edit" size="14px" />
            </button>
          </div>

          <div class="pk-label">{{ product.name }}</div>
        </div>
      </div>
    </div>

    <div v-else class="q-pa-sm">
      <q-card v-if="isBs" flat bordered class="q-mb-md">
        <q-card-section class="text-subtitle1 text-weight-medium">
          Input Data Hasil Panen
        </q-card-section>
        <q-card-section>
          <div class="row q-col-gutter-sm">
            <div class="col-12 col-md-4">
              <q-select
                v-model="harvestForm.product_id"
                :options="availableProducts.map((p) => ({ value: p.id, label: p.name }))"
                option-value="value"
                option-label="label"
                emit-value
                map-options
                outlined
                dense
                label="Varietas Produk *"
              />
            </div>
            <div class="col-12 col-md-4">
              <q-input
                v-model="harvestForm.harvest_date"
                type="date"
                outlined
                dense
                label="Tanggal Panen *"
              />
            </div>
            <div class="col-12 col-md-4">
              <q-input
                v-model.number="harvestForm.harvest_age_days"
                type="number"
                outlined
                dense
                label="Umur Panen (hari)"
                min="1"
              />
            </div>

            <div class="col-12 col-md-4">
              <q-input
                v-model.number="harvestForm.harvest_quantity"
                type="number"
                step="0.01"
                outlined
                dense
                label="Hasil Panen"
                min="0"
              />
            </div>
            <div class="col-12 col-md-4">
              <q-input
                v-model="harvestForm.harvest_unit"
                outlined
                dense
                label="Satuan (contoh: kg/ha)"
              />
            </div>
            <div class="col-12 col-md-4">
              <q-input
                v-model="harvestForm.location"
                outlined
                dense
                label="Lokasi"
              />
            </div>

            <div class="col-12 col-md-6">
              <q-input
                v-model="harvestForm.strengths"
                outlined
                dense
                type="textarea"
                autogrow
                label="Kekuatan Produk"
              />
            </div>
            <div class="col-12 col-md-6">
              <q-input
                v-model="harvestForm.weaknesses"
                outlined
                dense
                type="textarea"
                autogrow
                label="Kelemahan Produk"
              />
            </div>

            <div class="col-12 col-md-6">
              <q-input
                v-model="harvestForm.notes"
                outlined
                dense
                type="textarea"
                autogrow
                label="Catatan Tambahan"
              />
            </div>
            <div class="col-12 col-md-6">
              <q-file
                v-model="harvestForm.photo"
                outlined
                dense
                label="Foto Hasil Panen"
                accept="image/*"
                clearable
              />
            </div>
          </div>
        </q-card-section>
        <q-card-actions align="right" class="q-px-md q-pb-md">
          <q-btn flat color="grey-7" label="Reset" @click="resetHarvestForm" />
          <q-btn
            color="primary"
            label="Simpan Data"
            :loading="harvestSubmitting"
            :disable="!harvestForm.product_id || !harvestForm.harvest_date"
            @click="submitHarvest"
          />
        </q-card-actions>
      </q-card>

      <div v-if="harvestLoading" class="row q-col-gutter-sm">
        <div v-for="n in 6" :key="n" class="col-12 col-md-6 col-lg-4">
          <q-skeleton height="160px" />
        </div>
      </div>

      <div v-else-if="harvestItems.length === 0" class="q-pa-xl text-center text-grey-5">
        <q-icon name="agriculture" size="56px" />
        <div class="text-subtitle2 q-mt-sm text-grey-6">Belum ada data hasil panen.</div>
      </div>

      <div v-else class="row q-col-gutter-sm">
        <div v-for="item in harvestItems" :key="item.id" class="col-12 col-md-6 col-lg-4">
          <q-card flat bordered class="harvest-card">
            <q-img
              v-if="item.photo_path"
              :src="'/' + item.photo_path"
              ratio="16/9"
              class="harvest-photo"
            />
            <q-card-section>
              <div class="text-subtitle2 text-weight-medium">{{ item.product?.name || '-' }}</div>
              <div class="text-caption text-grey-7 q-mt-xs">
                Diinput oleh: <b>{{ item.created_by?.name || '-' }}</b>
              </div>
              <div class="text-caption text-grey-7">
                Waktu input: {{ formatDateTime(item.created_datetime) }}
              </div>

              <div class="q-mt-sm text-body2">
                <div><b>Tanggal Panen:</b> {{ formatDate(item.harvest_date) }}</div>
                <div><b>Umur Panen:</b> {{ item.harvest_age_days ? item.harvest_age_days + ' hari' : '-' }}</div>
                <div>
                  <b>Hasil Panen:</b>
                  {{ item.harvest_quantity !== null ? item.harvest_quantity + ' ' + (item.harvest_unit || '') : '-' }}
                </div>
                <div><b>Lokasi:</b> {{ item.location || '-' }}</div>
              </div>

              <q-separator class="q-my-sm" />

              <div class="text-body2"><b>Kekuatan:</b> {{ item.strengths || '-' }}</div>
              <div class="text-body2 q-mt-xs"><b>Kelemahan:</b> {{ item.weaknesses || '-' }}</div>
              <div class="text-body2 q-mt-xs"><b>Catatan:</b> {{ item.notes || '-' }}</div>
            </q-card-section>
          </q-card>
        </div>
      </div>
    </div>
  </AuthenticatedLayout>
</template>

<style scoped>
.pk-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 6px;
  padding: 8px;
  box-sizing: border-box;
}
@media (min-width: 600px) {
  .pk-grid { grid-template-columns: repeat(4, 1fr); gap: 8px; }
}
@media (min-width: 960px) {
  .pk-grid { grid-template-columns: repeat(6, 1fr); gap: 10px; }
}

.pk-skeleton {
  display: flex;
  flex-direction: column;
}

.pk-item {
  display: flex;
  flex-direction: column;
}
.pk-item:hover .pk-img {
  opacity: 0.88;
}

.pk-thumb {
  position: relative;
  overflow: hidden;
  border-radius: 6px;
  background: #f0f0f0;
}
.pk-img {
  display: block;
  width: 100%;
  border-radius: 6px;
  transition: opacity 0.15s;
}
.pk-no-photo {
  aspect-ratio: 1 / 1;
  border-radius: 6px;
}

.pk-badge {
  position: absolute;
  bottom: 4px;
  left: 4px;
  background: rgba(0, 0, 0, 0.5);
  color: #fff;
  font-size: 10px;
  padding: 1px 5px;
  border-radius: 8px;
  line-height: 1.6;
  pointer-events: none;
}
.pk-edit-btn {
  position: absolute;
  top: 4px;
  right: 4px;
  width: 24px;
  height: 24px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.85);
  color: #444;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  padding: 0;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
}
.pk-edit-btn:hover {
  background: #fff;
}

.pk-label {
  font-size: 11px;
  color: #333;
  padding: 3px 2px 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.3;
}

.harvest-card {
  height: 100%;
}

.harvest-photo {
  background: #f5f5f5;
}
</style>
