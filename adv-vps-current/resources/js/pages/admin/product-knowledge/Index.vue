<script setup>
import { ref, reactive, watch, onMounted, computed } from "vue";
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

const altitudeZoneOptions = [
  { value: "all", label: "Semua Zona" },
  { value: "lowland", label: "Lowland (0-400 mdpl)" },
  { value: "middleland", label: "Middleland (401-700 mdpl)" },
  { value: "highland", label: "Highland (>700 mdpl)" },
];

const harvestFilter = reactive({
  search: "",
  product_id: "all",
  altitude_zone: "all",
});

const harvestItems = ref([]);
const harvestLoading = ref(false);
const harvestViewMode = ref("card");
const harvestDetailDialog = ref(false);
const selectedHarvest = ref(null);
const editMode = ref(false);
const savingEdit = ref(false);
const deletingItem = ref(false);
const editPhotoFile = ref(null);

const editForm = reactive({
  product_id: null,
  demo_plot_id: null,
  farmer_name: "",
  harvest_date: "",
  harvest_age_days: null,
  harvest_quantity: null,
  is_multiple_harvest: false,
  land_area: null,
  altitude_mdpl: null,
  strengths: "",
  weaknesses: "",
  notes: "",
});

const productById = computed(() => {
  const map = new Map();
  (availableProducts || []).forEach((item) => {
    map.set(Number(item.id), item);
  });
  return map;
});

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

function formatNumber(value, digits = 2) {
  const number = Number(value);
  if (!Number.isFinite(number)) {
    return "0";
  }
  return number.toFixed(digits);
}

function formatCurrency(value) {
  const number = Number(value);
  if (!Number.isFinite(number)) {
    return "-";
  }
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 0,
  }).format(number);
}

function pickPriceByUom(product, keyword) {
  if (!product) return null;
  const k = String(keyword || "").toLowerCase();
  const uom1 = String(product.uom_1 || "").toLowerCase();
  const uom2 = String(product.uom_2 || "").toLowerCase();

  if (uom1.includes(k)) return Number(product.price_1 || 0) || null;
  if (uom2.includes(k)) return Number(product.price_2 || 0) || null;
  return null;
}

const selectedHarvestMetrics = computed(() => {
  const item = selectedHarvest.value;
  if (!item) {
    return null;
  }

  const qty = Number(item.harvest_quantity || 0);
  const landArea = Number(item.land_area || 0);
  const totalPcs = Number(item.total_pieces || 0);
  const population = Number(item.demo_plot?.population || 0);
  const perPieceYield = totalPcs > 0
    ? (qty / totalPcs)
    : (Number(item.per_piece_quantity || 0) || null);
  const perTreeYield = population > 0 ? (qty / population) : null;
  const productivity = landArea > 0 ? (qty / landArea) : null;

  const product = productById.value.get(Number(item.product_id || 0));
  const pricePerPcs = pickPriceByUom(product, "pcs");
  const pricePerKg = pickPriceByUom(product, "kg");

  const estimatedRevenueFromPcs = (pricePerPcs && totalPcs > 0)
    ? (pricePerPcs * totalPcs)
    : null;
  const estimatedRevenueFromKg = (pricePerKg && qty > 0)
    ? (pricePerKg * qty)
    : null;
  const estimatedRevenue = estimatedRevenueFromPcs ?? estimatedRevenueFromKg;

  return {
    qty,
    totalPcs,
    population,
    perPieceYield,
    perTreeYield,
    productivity,
    pricePerPcs,
    estimatedRevenue,
    estimatedRevenuePerPcs: (estimatedRevenue && totalPcs > 0) ? (estimatedRevenue / totalPcs) : null,
  };
});

function altitudeZone(value) {
  const altitude = Number(value);
  if (!Number.isFinite(altitude) || altitude < 0) {
    return "-";
  }
  if (altitude <= 400) {
    return "Lowland";
  }
  if (altitude <= 700) {
    return "Middleland";
  }
  return "Highland";
}

function toZoneKey(value) {
  const label = altitudeZone(value);
  if (label === "Lowland") return "lowland";
  if (label === "Middleland") return "middleland";
  if (label === "Highland") return "highland";
  return "unknown";
}

function collectTopPhrases(texts = [], maxItems = 5) {
  const counts = new Map();

  texts
    .filter(Boolean)
    .forEach((raw) => {
      String(raw)
        .split(/[,.;\n]+/g)
        .map((part) => part.trim())
        .filter((part) => part.length >= 4)
        .forEach((part) => {
          const key = part.toLowerCase();
          counts.set(key, (counts.get(key) || 0) + 1);
        });
    });

  return Array.from(counts.entries())
    .sort((a, b) => b[1] - a[1])
    .slice(0, maxItems)
    .map(([label, count]) => ({
      label: label.charAt(0).toUpperCase() + label.slice(1),
      count,
    }));
}

const harvestAnalysis = computed(() => {
  const items = harvestItems.value || [];
  const zoneStats = {
    lowland: { label: "Lowland", range: "0-400 mdpl", count: 0, totalHarvest: 0 },
    middleland: { label: "Middleland", range: "401-700 mdpl", count: 0, totalHarvest: 0 },
    highland: { label: "Highland", range: ">700 mdpl", count: 0, totalHarvest: 0 },
  };

  let totalHarvest = 0;

  items.forEach((item) => {
    const qty = Number(item?.harvest_quantity || 0);
    totalHarvest += qty;

    const zoneKey = toZoneKey(item?.altitude_mdpl);
    if (zoneStats[zoneKey]) {
      zoneStats[zoneKey].count += 1;
      zoneStats[zoneKey].totalHarvest += qty;
    }
  });

  const zoneCards = Object.values(zoneStats).map((zone) => ({
    ...zone,
    avgHarvest: zone.count > 0 ? zone.totalHarvest / zone.count : 0,
  }));

  const strengthInsights = collectTopPhrases(items.map((item) => item?.strengths));
  const weaknessInsights = collectTopPhrases(items.map((item) => item?.weaknesses));

  const dominantZone = [...zoneCards].sort((a, b) => b.totalHarvest - a.totalHarvest)[0] || null;

  return {
    totalRecords: items.length,
    totalHarvest,
    zoneCards,
    dominantZone,
    strengthInsights,
    weaknessInsights,
  };
});

function downloadCsv(filename, rows) {
  const csvContent = rows
    .map((row) =>
      row
        .map((cell) => {
          const text = String(cell ?? "").replace(/"/g, '""');
          return `"${text}"`;
        })
        .join(",")
    )
    .join("\n");

  const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.setAttribute("download", filename);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

function exportHarvestAnalysisCsv() {
  const rows = [];
  const now = new Date().toISOString();
  const analysis = harvestAnalysis.value;

  rows.push(["Laporan", "Summary Analisis Hasil Panen"]);
  rows.push(["Waktu Export", now]);
  rows.push([]);

  rows.push(["Ringkasan Umum"]);
  rows.push(["Total Data", analysis.totalRecords]);
  rows.push(["Total Hasil Panen (kg)", formatNumber(analysis.totalHarvest, 2)]);
  rows.push([
    "Zona Dominan",
    analysis.dominantZone ? `${analysis.dominantZone.label} (${formatNumber(analysis.dominantZone.totalHarvest, 2)} kg)` : "-",
  ]);
  rows.push([]);

  rows.push(["Analisis Per Zona"]);
  rows.push(["Zona", "Range", "Jumlah Data", "Total Hasil (kg)", "Rata-rata per Data (kg)"]);
  analysis.zoneCards.forEach((zone) => {
    rows.push([
      zone.label,
      zone.range,
      zone.count,
      formatNumber(zone.totalHarvest, 2),
      formatNumber(zone.avgHarvest, 2),
    ]);
  });
  rows.push([]);

  rows.push(["Top Kekuatan"]);
  rows.push(["Frasa", "Frekuensi"]);
  (analysis.strengthInsights.length ? analysis.strengthInsights : [{ label: "-", count: 0 }]).forEach((item) => {
    rows.push([item.label, item.count]);
  });
  rows.push([]);

  rows.push(["Top Kelemahan"]);
  rows.push(["Frasa", "Frekuensi"]);
  (analysis.weaknessInsights.length ? analysis.weaknessInsights : [{ label: "-", count: 0 }]).forEach((item) => {
    rows.push([item.label, item.count]);
  });

  downloadCsv("summary-analisis-hasil-panen.csv", rows);
  $q.notify({ type: "positive", message: "Summary analisis berhasil diexport.", position: "top" });
}

function exportHarvestDetailCsv() {
  const rows = [[
    "Tanggal Panen",
    "Varietas",
    "Petani",
    "Ketinggian (mdpl)",
    "Zona",
    "Hasil Panen (kg)",
    "Luas Lahan (m2)",
    "Produktivitas (kg/m2)",
    "Kekuatan",
    "Kelemahan",
    "Catatan",
  ]];

  harvestItems.value.forEach((item) => {
    const productivity = item.land_area && item.harvest_quantity
      ? Number(item.harvest_quantity) / Number(item.land_area)
      : null;

    rows.push([
      formatDate(item.harvest_date),
      item.product?.name || "-",
      item.farmer_name || "-",
      item.altitude_mdpl ?? "-",
      altitudeZone(item.altitude_mdpl),
      formatNumber(item.harvest_quantity, 2),
      item.land_area ?? "-",
      productivity !== null ? formatNumber(productivity, 2) : "-",
      item.strengths || "-",
      item.weaknesses || "-",
      item.notes || "-",
    ]);
  });

  downloadCsv("detail-hasil-panen.csv", rows);
  $q.notify({ type: "positive", message: "Detail hasil panen berhasil diexport.", position: "top" });
}

function openHarvestDetail(item) {
  selectedHarvest.value = item;
  resetEditForm(item);
  editMode.value = false;
  harvestDetailDialog.value = true;
}

function openHarvestEdit(item) {
  openHarvestDetail(item);
  editMode.value = true;
}

function resetEditForm(item) {
  editForm.product_id = item?.product_id ?? null;
  editForm.demo_plot_id = item?.demo_plot_id ?? null;
  editForm.farmer_name = item?.farmer_name || "";
  editForm.harvest_date = item?.harvest_date ? String(item.harvest_date).slice(0, 10) : "";
  editForm.harvest_age_days = item?.harvest_age_days ?? null;
  editForm.harvest_quantity = item?.harvest_quantity ?? null;
  editForm.is_multiple_harvest = Boolean(item?.is_multiple_harvest);
  editForm.land_area = item?.land_area ?? null;
  editForm.altitude_mdpl = item?.altitude_mdpl ?? null;
  editForm.strengths = item?.strengths || "";
  editForm.weaknesses = item?.weaknesses || "";
  editForm.notes = item?.notes || "";
  editPhotoFile.value = null;
}

async function saveHarvestEdit() {
  if (!selectedHarvest.value?.id) {
    return;
  }

  savingEdit.value = true;
  try {
    const formData = new FormData();
    formData.append("product_id", String(editForm.product_id || selectedHarvest.value.product_id || ""));
    formData.append("harvest_date", editForm.harvest_date || "");
    formData.append("harvest_quantity", String(editForm.harvest_quantity ?? 0));
    formData.append("is_multiple_harvest", editForm.is_multiple_harvest ? "1" : "0");

    if (editForm.demo_plot_id) formData.append("demo_plot_id", String(editForm.demo_plot_id));
    if (editForm.farmer_name) formData.append("farmer_name", editForm.farmer_name);
    if (editForm.harvest_age_days !== null && editForm.harvest_age_days !== "") formData.append("harvest_age_days", String(editForm.harvest_age_days));
    if (editForm.land_area !== null && editForm.land_area !== "") formData.append("land_area", String(editForm.land_area));
    if (editForm.altitude_mdpl !== null && editForm.altitude_mdpl !== "") formData.append("altitude_mdpl", String(editForm.altitude_mdpl));
    if (editForm.strengths) formData.append("strengths", editForm.strengths);
    if (editForm.weaknesses) formData.append("weaknesses", editForm.weaknesses);
    if (editForm.notes) formData.append("notes", editForm.notes);
    if (editPhotoFile.value) formData.append("photo", editPhotoFile.value);

    await axios.post(route("admin.harvest-result.update", selectedHarvest.value.id), formData, {
      headers: { "Content-Type": "multipart/form-data" },
    });

    await fetchHarvests();
    const updated = harvestItems.value.find((item) => Number(item.id) === Number(selectedHarvest.value.id));
    if (updated) {
      selectedHarvest.value = updated;
      resetEditForm(updated);
    }
    editMode.value = false;
    $q.notify({ type: "positive", message: "Data hasil panen berhasil diperbarui.", position: "top" });
  } catch (error) {
    const message = error?.response?.data?.message || "Gagal memperbarui data hasil panen.";
    $q.notify({ type: "negative", message, position: "top" });
  } finally {
    savingEdit.value = false;
  }
}

function confirmDeleteHarvest() {
  if (!selectedHarvest.value?.id) {
    return;
  }

  $q.dialog({
    title: "Hapus Data Hasil Panen",
    message: "Data yang dihapus tidak bisa dikembalikan. Lanjutkan?",
    cancel: true,
    persistent: true,
    ok: { color: "negative", label: "Hapus" },
  }).onOk(async () => {
    deletingItem.value = true;
    try {
      await axios.post(route("admin.harvest-result.delete", selectedHarvest.value.id));
      await fetchHarvests();
      harvestDetailDialog.value = false;
      selectedHarvest.value = null;
      $q.notify({ type: "positive", message: "Data hasil panen berhasil dihapus.", position: "top" });
    } catch (error) {
      const message = error?.response?.data?.message || "Gagal menghapus data hasil panen.";
      $q.notify({ type: "negative", message, position: "top" });
    } finally {
      deletingItem.value = false;
    }
  });
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

          <div v-if="activeTab === 'harvest'" class="col-12">
            <div class="row q-col-gutter-sm harvest-filter-grid">
              <div class="col-12 col-md-5 col-lg-6">
                <q-input
                  v-model="harvestFilter.search"
                  dense
                  outlined
                  placeholder="Cari petani, varietas, penginput..."
                  clearable
                  bg-color="white"
                >
                  <template #prepend><q-icon name="search" size="18px" /></template>
                </q-input>
              </div>
              <div class="col-12 col-md-3 col-lg-3">
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
                />
              </div>
              <div class="col-12 col-md-4 col-lg-3">
                <q-select
                  v-model="harvestFilter.altitude_zone"
                  :options="altitudeZoneOptions"
                  option-value="value"
                  option-label="label"
                  emit-value
                  map-options
                  dense
                  outlined
                  bg-color="white"
                />
              </div>
            </div>
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

    <div v-else class="harvest-page-wrap q-pa-sm q-pa-md-md">
      <div v-if="harvestLoading" class="row q-col-gutter-sm">
        <div v-for="n in 6" :key="n" class="col-12 col-md-6 col-lg-4">
          <q-skeleton height="160px" />
        </div>
      </div>

      <div v-else-if="harvestItems.length === 0" class="q-pa-xl text-center text-grey-5">
        <q-icon name="agriculture" size="56px" />
        <div class="text-subtitle2 q-mt-sm text-grey-6">Belum ada data hasil panen.</div>
      </div>

      <div v-else>
        <q-card flat bordered class="q-mb-md harvest-feed-shell">
          <q-card-section>
            <div class="row items-center justify-between q-col-gutter-sm">
              <div class="col-12 col-md-auto">
                <div class="text-subtitle1 text-weight-medium">Data Input Hasil Panen BS</div>
                <div class="text-caption text-grey-7 q-mt-xs">
                  Tampilan kartu dengan thumbnail dan data utama seperti galeri Product Knowledge.
                </div>
              </div>
              <div class="col-12 col-md-auto">
                <div class="row items-center q-gutter-sm justify-end">
                  <div class="text-caption text-grey-7">
                    Total data: <b>{{ harvestItems.length }}</b>
                  </div>
                  <q-btn-toggle
                    v-model="harvestViewMode"
                    dense
                    unelevated
                    toggle-color="primary"
                    color="grey-3"
                    text-color="grey-8"
                    :options="[
                      { label: 'Card', value: 'card', icon: 'view_module' },
                      { label: 'Table', value: 'table', icon: 'table_rows' },
                    ]"
                  />
                </div>
              </div>
            </div>

            <div v-if="harvestViewMode === 'card'" class="harvest-gallery-grid q-mt-md">
              <q-card
                v-for="item in harvestItems"
                :key="`card-${item.id}`"
                flat
                bordered
                class="harvest-entry-card"
              >
                <div class="harvest-entry-body">
                  <div class="harvest-thumb-wrap compact">
                    <q-img
                      v-if="item.photo_path"
                      :src="'/' + item.photo_path"
                      ratio="4/3"
                      class="harvest-thumb compact"
                    />
                    <div v-else class="harvest-no-thumb compact flex flex-center bg-grey-2">
                      <q-icon name="agriculture" size="22px" color="grey-6" />
                    </div>

                    <div class="harvest-tag-row compact">
                      <span class="harvest-tag zone-tag">
                        {{ item.altitude_mdpl !== null && item.altitude_mdpl !== undefined ? altitudeZone(item.altitude_mdpl) : 'Zona -' }}
                      </span>
                      <span v-if="item.is_multiple_harvest" class="harvest-tag cycle-tag">Multi Panen</span>
                    </div>
                  </div>

                  <q-card-section class="q-pt-sm harvest-content-section">
                    <div class="harvest-title">{{ item.product?.name || '-' }}</div>
                    <div class="harvest-subtitle">{{ item.farmer_name || '-' }}</div>

                    <div class="harvest-stat-grid compact q-mt-sm">
                      <div class="harvest-stat-item compact">
                        <div class="harvest-stat-label">Tanggal</div>
                        <div class="harvest-stat-value">{{ formatDate(item.harvest_date) }}</div>
                      </div>
                      <div class="harvest-stat-item compact text-right">
                        <div class="harvest-stat-label">Total Panen</div>
                        <div class="harvest-stat-value">{{ formatNumber(item.harvest_quantity, 2) }} {{ item.harvest_unit || 'kg' }}</div>
                      </div>
                      <div class="harvest-stat-item compact">
                        <div class="harvest-stat-label">Luas Lahan</div>
                        <div class="harvest-stat-value">{{ item.land_area ? `${formatNumber(item.land_area, 2)} m²` : '-' }}</div>
                      </div>
                      <div class="harvest-stat-item compact text-right">
                        <div class="harvest-stat-label">Produktivitas</div>
                        <div class="harvest-stat-value">
                          {{ item.land_area && item.harvest_quantity ? `${formatNumber(item.harvest_quantity / item.land_area, 2)} ${item.harvest_unit || 'kg'}/m²` : '-' }}
                        </div>
                      </div>
                    </div>

                    <div class="harvest-meta q-mt-sm">
                      <div class="meta-line">Input: <b>{{ item.created_by?.name || '-' }}</b></div>
                      <div class="meta-line">Waktu: {{ formatDateTime(item.created_datetime) }}</div>
                    </div>

                    <div class="row q-mt-sm justify-end q-gutter-sm">
                      <q-btn
                        dense
                        flat
                        color="primary"
                        icon="visibility"
                        label="Detail"
                        @click="openHarvestDetail(item)"
                      />
                      <q-btn
                        v-if="item.can_edit"
                        dense
                        unelevated
                        color="secondary"
                        icon="edit"
                        label="Edit"
                        @click="openHarvestEdit(item)"
                      />
                    </div>
                  </q-card-section>
                </div>
              </q-card>
            </div>

            <div v-else class="q-mt-md harvest-table-wrap">
              <q-markup-table flat bordered dense class="harvest-table">
                <thead>
                  <tr>
                    <th class="text-left">Tanggal</th>
                    <th class="text-left">Varietas / Petani</th>
                    <th class="text-right">Panen</th>
                    <th class="text-right">Lahan</th>
                    <th class="text-right">Produktivitas</th>
                    <th class="text-left">Zona</th>
                    <th class="text-left">Input</th>
                    <th class="text-right">Aksi</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="item in harvestItems" :key="`table-${item.id}`">
                    <td>{{ formatDate(item.harvest_date) }}</td>
                    <td>
                      <div class="text-weight-medium">{{ item.product?.name || '-' }}</div>
                      <div class="text-caption text-grey-7">{{ item.farmer_name || '-' }}</div>
                    </td>
                    <td class="text-right">{{ formatNumber(item.harvest_quantity, 2) }} {{ item.harvest_unit || 'kg' }}</td>
                    <td class="text-right">{{ item.land_area ? `${formatNumber(item.land_area, 2)} m²` : '-' }}</td>
                    <td class="text-right">
                      {{ item.land_area && item.harvest_quantity ? `${formatNumber(item.harvest_quantity / item.land_area, 2)} ${item.harvest_unit || 'kg'}/m²` : '-' }}
                    </td>
                    <td>
                      {{ item.altitude_mdpl !== null && item.altitude_mdpl !== undefined ? altitudeZone(item.altitude_mdpl) : '-' }}
                    </td>
                    <td>
                      <div>{{ item.created_by?.name || '-' }}</div>
                      <div class="text-caption text-grey-7">{{ formatDateTime(item.created_datetime) }}</div>
                    </td>
                    <td class="text-right">
                      <q-btn dense flat color="primary" icon="visibility" @click="openHarvestDetail(item)" />
                      <q-btn v-if="item.can_edit" dense flat color="secondary" icon="edit" @click="openHarvestEdit(item)" />
                    </td>
                  </tr>
                </tbody>
              </q-markup-table>
            </div>
          </q-card-section>
        </q-card>

        <q-card flat bordered class="q-mb-md analysis-card">
          <q-card-section>
            <div class="row items-center justify-between q-col-gutter-sm">
              <div class="col-12 col-md-auto">
                <div class="text-subtitle1 text-weight-medium">Summary Analisis Hasil Panen</div>
              </div>
              <div class="col-12 col-md-auto">
                <div class="row q-gutter-sm justify-end">
                  <q-btn
                    outline
                    color="primary"
                    icon="download"
                    label="Export Summary CSV"
                    @click="exportHarvestAnalysisCsv"
                  />
                  <q-btn
                    outline
                    color="secondary"
                    icon="table_view"
                    label="Export Detail CSV"
                    @click="exportHarvestDetailCsv"
                  />
                </div>
              </div>
            </div>
            <div class="text-caption text-grey-7 q-mt-xs">
              Klasifikasi zona: Lowland 0-400 mdpl, Middleland 401-700 mdpl, Highland &gt;700 mdpl.
            </div>

            <div class="row q-col-gutter-sm q-mt-sm">
              <div class="col-12 col-sm-6 col-lg-3">
                <div class="analysis-metric">
                  <div class="text-caption text-grey-7">Total Data</div>
                  <div class="text-h6 text-weight-bold">{{ harvestAnalysis.totalRecords }}</div>
                </div>
              </div>
              <div class="col-12 col-sm-6 col-lg-3">
                <div class="analysis-metric">
                  <div class="text-caption text-grey-7">Total Hasil Panen</div>
                  <div class="text-h6 text-weight-bold">{{ formatNumber(harvestAnalysis.totalHarvest, 2) }} kg</div>
                </div>
              </div>
              <div class="col-12 col-sm-6 col-lg-6">
                <div class="analysis-metric">
                  <div class="text-caption text-grey-7">Zona Dominan</div>
                  <div class="text-h6 text-weight-bold">
                    {{ harvestAnalysis.dominantZone?.label || '-' }}
                    <span class="text-body2 text-weight-regular" v-if="harvestAnalysis.dominantZone">
                      ({{ formatNumber(harvestAnalysis.dominantZone.totalHarvest, 2) }} kg)
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div class="row q-col-gutter-sm q-mt-sm">
              <div
                v-for="zone in harvestAnalysis.zoneCards"
                :key="zone.label"
                class="col-12 col-md-4"
              >
                <div class="zone-card">
                  <div class="text-subtitle2 text-weight-medium">{{ zone.label }}</div>
                  <div class="text-caption text-grey-7">{{ zone.range }}</div>
                  <div class="q-mt-xs text-body2">Data: <b>{{ zone.count }}</b></div>
                  <div class="text-body2">Total: <b>{{ formatNumber(zone.totalHarvest, 2) }} kg</b></div>
                  <div class="text-body2">Rata-rata: <b>{{ formatNumber(zone.avgHarvest, 2) }} kg/data</b></div>
                </div>
              </div>
            </div>

            <div class="row q-col-gutter-sm q-mt-sm">
              <div class="col-12 col-md-6">
                <div class="insight-box">
                  <div class="text-subtitle2 text-weight-medium">Top Kekuatan</div>
                  <div v-if="harvestAnalysis.strengthInsights.length" class="q-mt-xs">
                    <div
                      v-for="item in harvestAnalysis.strengthInsights"
                      :key="`strength-${item.label}`"
                      class="text-body2"
                    >
                      - {{ item.label }} <span class="text-grey-7">({{ item.count }}x)</span>
                    </div>
                  </div>
                  <div v-else class="text-caption text-grey-7 q-mt-xs">Belum ada data kekuatan untuk dianalisis.</div>
                </div>
              </div>
              <div class="col-12 col-md-6">
                <div class="insight-box">
                  <div class="text-subtitle2 text-weight-medium">Top Kelemahan</div>
                  <div v-if="harvestAnalysis.weaknessInsights.length" class="q-mt-xs">
                    <div
                      v-for="item in harvestAnalysis.weaknessInsights"
                      :key="`weakness-${item.label}`"
                      class="text-body2"
                    >
                      - {{ item.label }} <span class="text-grey-7">({{ item.count }}x)</span>
                    </div>
                  </div>
                  <div v-else class="text-caption text-grey-7 q-mt-xs">Belum ada data kelemahan untuk dianalisis.</div>
                </div>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>

      <q-dialog v-model="harvestDetailDialog" full-width>
        <q-card class="harvest-detail-card">
          <q-card-section class="row items-center q-pb-none detail-header">
            <div>
              <div class="text-h6">Detail Input Hasil Panen BS</div>
              <div class="text-caption text-grey-7">
                Data lapangan, ringkasan analisis, dan aksi edit/hapus.
              </div>
            </div>
            <q-space />
            <q-btn
              v-if="selectedHarvest?.can_edit"
              flat
              dense
              color="primary"
              :label="editMode ? 'Batal Edit' : 'Edit Data'"
              @click="editMode ? resetEditForm(selectedHarvest) : null; editMode = !editMode"
            />
            <q-btn
              v-if="selectedHarvest?.can_delete"
              flat
              dense
              color="negative"
              label="Hapus"
              :loading="deletingItem"
              @click="confirmDeleteHarvest"
            />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>

          <q-card-section v-if="selectedHarvest" class="q-pt-sm">
            <q-card v-if="editMode" flat bordered class="q-mb-md detail-summary-shell">
              <q-card-section>
                <div class="text-subtitle2 text-weight-medium">Edit Data Hasil Panen</div>
                <div class="text-caption text-grey-7 q-mt-xs">BS penginput, agronomis, dan admin dapat mengubah data termasuk menambah/mengganti foto.</div>
                <div class="row q-col-gutter-sm q-mt-sm">
                  <div class="col-12 col-md-4">
                    <q-select
                      v-model="editForm.product_id"
                      :options="productOptions.filter((x) => x.value !== 'all')"
                      option-value="value"
                      option-label="label"
                      emit-value
                      map-options
                      dense
                      outlined
                      label="Varietas"
                    />
                  </div>
                  <div class="col-12 col-md-4">
                    <q-input v-model="editForm.farmer_name" dense outlined label="Nama Petani" />
                  </div>
                  <div class="col-12 col-md-4">
                    <q-input v-model="editForm.harvest_date" type="date" dense outlined label="Tanggal Panen" />
                  </div>
                  <div class="col-12 col-md-3">
                    <q-input v-model.number="editForm.harvest_quantity" type="number" min="0" step="0.01" dense outlined label="Total Panen (kg)" />
                  </div>
                  <div class="col-12 col-md-3">
                    <q-input v-model.number="editForm.harvest_age_days" type="number" min="1" dense outlined label="Umur Panen (hari)" />
                  </div>
                  <div class="col-12 col-md-3">
                    <q-input v-model.number="editForm.land_area" type="number" min="0" step="0.01" dense outlined label="Luas Lahan (m²)" />
                  </div>
                  <div class="col-12 col-md-3">
                    <q-input v-model.number="editForm.altitude_mdpl" type="number" min="0" dense outlined label="Ketinggian (mdpl)" />
                  </div>
                  <div class="col-12 col-md-6">
                    <q-input v-model="editForm.strengths" type="textarea" autogrow dense outlined label="Kekuatan" />
                  </div>
                  <div class="col-12 col-md-6">
                    <q-input v-model="editForm.weaknesses" type="textarea" autogrow dense outlined label="Kelemahan" />
                  </div>
                  <div class="col-12">
                    <q-input v-model="editForm.notes" type="textarea" autogrow dense outlined label="Catatan" />
                  </div>
                  <div class="col-12 col-md-6">
                    <q-file
                      v-model="editPhotoFile"
                      dense
                      outlined
                      accept="image/*"
                      label="Tambah / ganti foto panen"
                      clearable
                    />
                  </div>
                </div>
                <div class="row justify-end q-gutter-sm q-mt-sm">
                  <q-btn flat color="grey-7" label="Batal" @click="resetEditForm(selectedHarvest); editMode = false" />
                  <q-btn color="primary" icon="save" label="Simpan Perubahan" :loading="savingEdit" @click="saveHarvestEdit" />
                </div>
              </q-card-section>
            </q-card>

            <q-card flat bordered class="q-mb-md detail-summary-shell">
              <q-card-section>
                <div class="text-subtitle2 text-weight-medium">Summary Analisis Detail</div>
                <div class="text-caption text-grey-7 q-mt-xs">
                  Nilai estimasi mengikuti data master harga produk (jika tersedia).
                </div>

                <div class="row q-col-gutter-sm q-mt-sm" v-if="selectedHarvestMetrics">
                  <div class="col-12 col-sm-6 col-md-4 col-lg-2">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Total Panen</div>
                      <div class="detail-metric-value">{{ formatNumber(selectedHarvestMetrics.qty, 2) }} {{ selectedHarvest.harvest_unit || 'kg' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4 col-lg-2">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Hasil per PCS</div>
                      <div class="detail-metric-value">{{ selectedHarvestMetrics.perPieceYield ? `${formatNumber(selectedHarvestMetrics.perPieceYield, 4)} ${selectedHarvest.harvest_unit || 'kg'}` : '-' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4 col-lg-2">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Hasil per Pohon</div>
                      <div class="detail-metric-value">{{ selectedHarvestMetrics.perTreeYield ? `${formatNumber(selectedHarvestMetrics.perTreeYield, 4)} ${selectedHarvest.harvest_unit || 'kg'}` : '-' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4 col-lg-2">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Produktivitas</div>
                      <div class="detail-metric-value">{{ selectedHarvestMetrics.productivity ? `${formatNumber(selectedHarvestMetrics.productivity, 2)} ${selectedHarvest.harvest_unit || 'kg'}/m²` : '-' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4 col-lg-2">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Pendapatan per PCS</div>
                      <div class="detail-metric-value">{{ formatCurrency(selectedHarvestMetrics.estimatedRevenuePerPcs) }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4 col-lg-2">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Estimasi Pendapatan</div>
                      <div class="detail-metric-value">{{ formatCurrency(selectedHarvestMetrics.estimatedRevenue) }}</div>
                    </div>
                  </div>
                </div>
              </q-card-section>
            </q-card>

            <div class="row q-col-gutter-md detail-body-grid">
              <div class="col-12" v-if="selectedHarvest.photo_path">
                <q-card flat bordered class="q-mb-sm">
                  <q-img :src="'/' + selectedHarvest.photo_path" ratio="21/7" class="detail-photo-banner" />
                </q-card>
              </div>
              <div class="col-12 col-md-6">
                <q-card flat bordered>
                  <q-card-section>
                    <div class="text-subtitle2 text-weight-medium q-mb-sm">Data Utama</div>
                    <div class="detail-grid">
                      <div class="detail-key">Varietas</div><div class="detail-val">{{ selectedHarvest.product?.name || '-' }}</div>
                      <div class="detail-key">Nama Petani</div><div class="detail-val">{{ selectedHarvest.farmer_name || '-' }}</div>
                      <div class="detail-key">Tanggal Panen</div><div class="detail-val">{{ formatDate(selectedHarvest.harvest_date) }}</div>
                      <div class="detail-key">Umur Panen</div><div class="detail-val">{{ selectedHarvest.harvest_age_days ? `${selectedHarvest.harvest_age_days} hari` : '-' }}</div>
                      <div class="detail-key">Total Hasil</div><div class="detail-val">{{ formatNumber(selectedHarvest.harvest_quantity, 2) }} {{ selectedHarvest.harvest_unit || 'kg' }}</div>
                      <div class="detail-key">Luas Lahan</div><div class="detail-val">{{ selectedHarvest.land_area ? `${formatNumber(selectedHarvest.land_area, 2)} m²` : '-' }}</div>
                      <div class="detail-key">Ketinggian</div>
                      <div class="detail-val">
                        <span v-if="selectedHarvest.altitude_mdpl !== null && selectedHarvest.altitude_mdpl !== undefined">
                          {{ formatNumber(selectedHarvest.altitude_mdpl, 0) }} mdpl ({{ altitudeZone(selectedHarvest.altitude_mdpl) }})
                        </span>
                        <span v-else>-</span>
                      </div>
                    </div>
                  </q-card-section>
                </q-card>
              </div>
              <div class="col-12 col-md-6">
                <q-card flat bordered>
                  <q-card-section>
                    <div class="text-subtitle2 text-weight-medium q-mb-sm">Data Tambahan</div>
                    <div class="detail-grid">
                      <div class="detail-key">Lokasi</div><div class="detail-val">{{ selectedHarvest.location || '-' }}</div>
                      <div class="detail-key">Populasi Demo Plot</div><div class="detail-val">{{ selectedHarvest.demo_plot?.population ? `${formatNumber(selectedHarvest.demo_plot.population, 0)} pohon` : '-' }}</div>
                      <div class="detail-key">Total PCS</div><div class="detail-val">{{ selectedHarvest.total_pieces ? formatNumber(selectedHarvest.total_pieces, 0) : '-' }}</div>
                      <div class="detail-key">Hasil per PCS</div><div class="detail-val">{{ selectedHarvest.per_piece_quantity ? `${formatNumber(selectedHarvest.per_piece_quantity, 4)} ${selectedHarvest.harvest_unit || 'kg'}` : '-' }}</div>
                      <div class="detail-key">Mode Panen</div><div class="detail-val">{{ selectedHarvest.is_multiple_harvest ? 'Beberapa Kali Panen' : 'Sekali Panen' }}</div>
                      <div class="detail-key">Penginput</div><div class="detail-val">{{ selectedHarvest.created_by?.name || '-' }}</div>
                      <div class="detail-key">Waktu Input</div><div class="detail-val">{{ formatDateTime(selectedHarvest.created_datetime) }}</div>
                    </div>
                  </q-card-section>
                </q-card>
              </div>

              <div
                class="col-12"
                v-if="selectedHarvest.is_multiple_harvest && selectedHarvest.harvest_cycles && selectedHarvest.harvest_cycles.length"
              >
                <q-card flat bordered>
                  <q-card-section>
                    <div class="text-subtitle2 text-weight-medium">Rincian Panen Bertahap</div>
                    <div class="text-caption text-grey-7 q-mt-xs">
                      Ringkasan K1/K2/dst ditata grid agar tidak menghabiskan ruang vertikal.
                    </div>
                    <div class="cycle-grid-compact q-mt-sm">
                      <div
                        v-for="(cycle, idx) in selectedHarvest.harvest_cycles"
                        :key="`dlg-cycle-${idx}`"
                        class="cycle-grid-item"
                      >
                        <div class="cycle-label">{{ cycle.label || `K${idx + 1}` }}</div>
                        <div class="cycle-value">{{ formatNumber(cycle.quantity, 2) }} {{ selectedHarvest.harvest_unit || 'kg' }}</div>
                        <div class="cycle-date" v-if="cycle.date">{{ formatDate(cycle.date) }}</div>
                      </div>
                    </div>
                  </q-card-section>
                </q-card>
              </div>

              <div class="col-12" v-if="selectedHarvest.strengths || selectedHarvest.weaknesses || selectedHarvest.notes">
                <q-card flat bordered>
                  <q-card-section>
                    <div v-if="selectedHarvest.strengths" class="q-mb-sm"><b>Kekuatan:</b> {{ selectedHarvest.strengths }}</div>
                    <div v-if="selectedHarvest.weaknesses" class="q-mb-sm"><b>Kelemahan:</b> {{ selectedHarvest.weaknesses }}</div>
                    <div v-if="selectedHarvest.notes"><b>Catatan:</b> {{ selectedHarvest.notes }}</div>
                  </q-card-section>
                </q-card>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </q-dialog>
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

.harvest-page-wrap {
  width: 100%;
  max-width: none;
}

.harvest-filter-grid {
  width: 100%;
}

.harvest-feed-shell {
  width: 100% !important;
  max-width: none !important;
  background: linear-gradient(180deg, #f9fcff 0%, #ffffff 100%);
  border-color: #dbe8f3;
}

.harvest-table-wrap {
  width: 100%;
  overflow-x: auto;
}

.harvest-table {
  min-width: 980px;
}

.harvest-table thead th {
  background: #f3f7fc;
  color: #3d5875;
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.harvest-table tbody td {
  border-color: #e6edf4;
}

.harvest-gallery-grid {
  display: grid;
  width: 100%;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 12px;
}

@media (min-width: 1400px) {
  .harvest-gallery-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

.harvest-entry-card {
  width: 100% !important;
  max-width: none !important;
  border-radius: 12px;
  overflow: hidden;
  border-color: #dce7ef;
  background: #ffffff;
  transition: transform 0.18s ease, box-shadow 0.18s ease;
}

.harvest-entry-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 22px rgba(18, 48, 84, 0.12);
}

.harvest-entry-body {
  display: grid;
  grid-template-columns: 150px minmax(0, 1fr);
  gap: 10px;
}

.harvest-thumb-wrap {
  position: relative;
}

.harvest-thumb-wrap.compact {
  margin: 8px;
  border-radius: 10px;
  overflow: hidden;
}

.harvest-thumb,
.harvest-no-thumb {
  width: 100%;
}

.harvest-thumb {
  max-height: 180px;
  object-fit: cover;
}

.harvest-thumb.compact {
  max-height: 110px;
}

.harvest-no-thumb {
  aspect-ratio: 16 / 9;
  min-height: 160px;
}

.harvest-no-thumb.compact {
  aspect-ratio: 4 / 3;
  min-height: 110px;
}

.harvest-tag-row {
  position: absolute;
  top: 10px;
  left: 10px;
  right: 10px;
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.harvest-tag-row.compact {
  top: 6px;
  left: 6px;
  right: 6px;
}

.harvest-tag {
  font-size: 11px;
  font-weight: 700;
  border-radius: 999px;
  padding: 4px 9px;
  color: #fff;
}

.zone-tag {
  background: rgba(27, 74, 130, 0.84);
}

.cycle-tag {
  background: rgba(13, 102, 64, 0.86);
}

.harvest-title {
  font-size: 16px;
  line-height: 1.2;
  font-weight: 800;
  color: #20354f;
}

.harvest-subtitle {
  margin-top: 2px;
  font-size: 13px;
  font-weight: 600;
  color: #4f6478;
}

.harvest-stat-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
}

.harvest-stat-grid.compact {
  gap: 6px;
}

.harvest-stat-item {
  padding: 8px;
  border-radius: 8px;
  background: #f6f9fd;
  border: 1px solid #e4edf5;
}

.harvest-stat-item.compact {
  padding: 6px;
}

.harvest-stat-label {
  font-size: 11px;
  color: #73879b;
}

.harvest-stat-value {
  margin-top: 2px;
  font-size: 13px;
  font-weight: 700;
  color: #173554;
}

.harvest-meta {
  border-top: 1px dashed #d9e5ef;
  padding-top: 8px;
}

.meta-line {
  font-size: 12px;
  color: #597086;
  line-height: 1.45;
}

.analysis-card {
  width: 100% !important;
  max-width: none !important;
  background: #f8fbff;
  border-color: #dce8f3;
}

.harvest-detail-card {
  width: min(1120px, 96vw);
  max-width: 1120px;
  border-radius: 14px;
}

.harvest-detail-card > .q-card__section {
  width: 100%;
}

.harvest-detail-card .q-card {
  width: 100% !important;
  max-width: none !important;
}

.detail-body-grid {
  align-items: stretch;
}

.detail-header {
  border-bottom: 1px solid #e8edf3;
}

.detail-photo-banner {
  max-height: 220px;
}

.detail-summary-shell {
  background: linear-gradient(180deg, #f8fbff 0%, #ffffff 100%);
  border-color: #dbe7f3;
}

.detail-metric-card {
  border: 1px solid #e3ebf4;
  border-radius: 10px;
  padding: 10px;
  background: #fff;
  height: 100%;
}

.detail-metric-label {
  font-size: 11px;
  color: #70849a;
}

.detail-metric-value {
  margin-top: 4px;
  font-size: 13px;
  font-weight: 700;
  color: #1f3f60;
  line-height: 1.3;
  word-break: break-word;
}

.detail-grid {
  display: grid;
  grid-template-columns: 160px minmax(0, 1fr);
  gap: 8px 10px;
}

@media (min-width: 1024px) {
  .detail-body-grid > .col-12.col-md-6 {
    display: flex;
  }

  .detail-body-grid > .col-12.col-md-6 > .q-card {
    height: 100%;
  }
}

.detail-key {
  font-size: 12px;
  color: #66798e;
}

.detail-val {
  font-size: 13px;
  font-weight: 600;
  color: #223c57;
  word-break: break-word;
}

.cycle-grid-compact {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 8px;
}

.cycle-grid-item {
  border: 1px solid #e5edf4;
  border-radius: 8px;
  padding: 8px;
  background: #f8fbff;
}

.cycle-label {
  font-size: 12px;
  font-weight: 700;
  color: #29527c;
}

.cycle-value {
  margin-top: 2px;
  font-size: 13px;
  font-weight: 700;
  color: #1f3f60;
}

.cycle-date {
  margin-top: 2px;
  font-size: 11px;
  color: #70849a;
}

@media (max-width: 640px) {
  .harvest-gallery-grid {
    grid-template-columns: 1fr;
  }

  .harvest-entry-body {
    grid-template-columns: 1fr;
    gap: 0;
  }

  .harvest-thumb-wrap.compact {
    margin: 0;
    border-radius: 0;
  }

  .harvest-thumb {
    max-height: 160px;
  }

  .detail-grid {
    grid-template-columns: 1fr;
    gap: 2px;
  }

  .detail-key {
    margin-top: 6px;
    font-weight: 700;
  }

  .cycle-grid-compact {
    grid-template-columns: 1fr;
  }
}

.analysis-metric {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 10px;
  padding: 10px 12px;
  height: 100%;
}

.zone-card {
  background: #ffffff;
  border: 1px solid #dbeafe;
  border-radius: 10px;
  padding: 10px 12px;
  height: 100%;
}

.insight-box {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 10px;
  padding: 10px 12px;
  min-height: 120px;
}
</style>
