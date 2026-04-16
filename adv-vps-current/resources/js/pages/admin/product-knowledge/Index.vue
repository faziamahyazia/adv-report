<script setup>
import { ref, reactive, watch, onMounted, computed } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import AuthenticatedLayout from "@/layouts/AuthenticatedLayout.vue";
import axios from "axios";
import { useQuasar } from "quasar";
import dayjs from "dayjs";
import ECharts from "vue-echarts";
import { formatNumber as formatLocaleNumber } from "@/helpers/utils";

const page = usePage();
const categories = page.props.categories ?? [];
const availableProducts = page.props.products ?? [];
const demoPlots = page.props.demoPlots ?? [];
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

const farmerSourceOptions = [
  { label: "Dropdown Demo Plot", value: "demo_plot" },
  { label: "Input Manual", value: "manual" },
];

const altitudeZoneOptions = [
  { value: "all", label: "Semua Zona" },
  { value: "lowland", label: "Lowland (0-400 mdpl)" },
  { value: "middleland", label: "Middleland (401-700 mdpl)" },
  { value: "highland", label: "Highland (>700 mdpl)" },
];

const harvestStatusOptions = [
  { value: "all", label: "Semua Status Panen" },
  { value: "completed", label: "Panen Selesai" },
  { value: "pending", label: "Belum Selesai" },
];

const harvestFilter = reactive({
  search: "",
  product_id: "all",
  altitude_zone: "all",
});
const harvestStatusFilter = ref("all");

const harvestItems = ref([]);
const harvestLoading = ref(false);
const harvestViewMode = ref("card");
const harvestPagination = reactive({
  page: 1,
  rowsPerPage: 12,
});
const harvestRowsPerPageOptions = [
  { label: "12 / halaman", value: 12 },
  { label: "24 / halaman", value: 24 },
  { label: "48 / halaman", value: 48 },
];
const harvestDetailDialog = ref(false);
const harvestPhotoViewerDialog = ref(false);
const selectedHarvestPhotoViewerUrl = ref(null);
const selectedHarvest = ref(null);
const detailMobileTab = ref("summary");
const editMode = ref(false);
const savingEdit = ref(false);
const deletingItem = ref(false);
const deletingPhotoKey = ref(null);
const editPhotoFiles = ref([]);
const editPhotoPreviews = ref([]);
const editWeaknessPhotoFiles = ref([]);
const editWeaknessPhotoPreviews = ref([]);
const editThumbnailSelection = ref("");
const editErrors = ref({});

const editForm = reactive({
  farmer_source: "demo_plot",
  product_id: null,
  demo_plot_id: null,
  farmer_name: "",
  harvest_date: "",
  harvest_age_days: null,
  harvest_quantity: null,
  putren_quantity: null,
  total_pieces: null,
  germination_percentage: null,
  is_multiple_harvest: false,
  is_completed: true,
  harvest_cycles: [
    { label: "K1", date: "", quantity: null },
  ],
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

const editDemoPlotOptions = computed(() => {
  const selectedProductId = Number(editForm.product_id || 0);
  return demoPlots
    .filter((item) => {
      if (!selectedProductId) {
        return true;
      }
      return Number(item.product_id) === selectedProductId;
    })
    .map((item) => ({
      value: item.id,
      label: `${item.owner_name || '-'} | ${item.product_name || '-'} | ${formatNumber(item.population, 0)} pohon`,
    }));
});

const editSelectedDemoPlot = computed(() => {
  return demoPlots.find((item) => Number(item.id) === Number(editForm.demo_plot_id || 0)) || null;
});

const selectedEditProduct = computed(() => {
  return productById.value.get(Number(editForm.product_id || 0)) || null;
});

const isFreshCornEdit = computed(() => {
  const categoryName = String(selectedEditProduct.value?.category_name || "").toLowerCase();
  if (categoryName) {
    return categoryName.includes("fresh corn");
  }
  const name = String(selectedEditProduct.value?.name || "").toLowerCase();
  return name.includes("fresh corn");
});

const editTotalHarvestQuantity = computed(() => {
  if (!editForm.is_multiple_harvest) {
    return Number(editForm.harvest_quantity || 0);
  }
  return editForm.harvest_cycles.reduce((sum, cycle) => sum + Number(cycle.quantity || 0), 0);
});

const editThumbnailChoices = computed(() => {
  const choices = [];
  const existingPhotos = (Array.isArray(selectedHarvest.value?.photos) ? selectedHarvest.value.photos : [])
    .filter((photo) => (String(photo?.photo_type || "general").toLowerCase() !== "weakness"));

  existingPhotos.forEach((photo, index) => {
    choices.push({
      value: `existing:${photo?.id ?? index}`,
      label: `Foto lama ${index + 1}`,
      src: getPhotoUrl({ photo_urls: [photo?.image_path] }) || null,
    });
  });

  editPhotoPreviews.value.forEach((src, index) => {
    choices.push({
      value: `new:${index}`,
      label: `Upload baru ${index + 1}`,
      src,
    });
  });

  return choices.filter((item) => item.src);
});

const editExistingPhotos = computed(() => {
  const existingPhotos = (Array.isArray(selectedHarvest.value?.photos) ? selectedHarvest.value.photos : [])
    .filter((photo) => (String(photo?.photo_type || "general").toLowerCase() !== "weakness"));
  const photosFromRelation = existingPhotos
    .map((photo, index) => ({
      key: `photo-${photo?.id}`,
      id: photo?.id,
      label: `Foto ${index + 1}`,
      src: getPhotoUrl({ photo_urls: [photo?.image_path] }) || null,
      source: "record",
      rawPath: photo?.image_path || null,
    }))
    .filter((photo) => photo.id !== undefined && photo.id !== null && photo.src);

  const currentPhotoPath = String(selectedHarvest.value?.photo_path || "").trim();
  if (!currentPhotoPath) {
    return photosFromRelation;
  }

  const normalizedCurrent = normalizePhotoReference(currentPhotoPath);
  const hasMatchedRecord = photosFromRelation.some((photo) => {
    return normalizePhotoReference(photo.rawPath) === normalizedCurrent;
  });

  if (!hasMatchedRecord) {
    photosFromRelation.unshift({
      key: "legacy-photo-path",
      id: null,
      label: "Foto Legacy (Thumbnail Lama)",
      src: getPhotoUrl({ photo_urls: [currentPhotoPath] }) || null,
      source: "legacy",
      rawPath: currentPhotoPath,
    });
  }

  return photosFromRelation.filter((photo) => photo.src);
});

function normalizePhotoReference(raw) {
  const value = String(raw || "").trim();
  if (!value) {
    return null;
  }

  if (value.startsWith("http://") || value.startsWith("https://")) {
    return value;
  }

  let normalized = value.replace(/\\/g, "/").replace(/^\/+/, "");
  if (normalized.startsWith("public/")) {
    normalized = normalized.slice(7);
  }

  return `${window.location.origin}/${normalized}`;
}

function resolveThumbnailSelection(item) {
  const currentThumbnail = normalizePhotoReference(item?.photo_path || item?.photo_url || getPhotoUrl(item));
  const existingPhotos = (Array.isArray(item?.photos) ? item.photos : [])
    .filter((photo) => (String(photo?.photo_type || "general").toLowerCase() !== "weakness"));

  if (currentThumbnail) {
    const matchedExisting = existingPhotos.find((photo) => normalizePhotoReference(photo?.image_path) === currentThumbnail);
    if (matchedExisting?.id !== undefined && matchedExisting?.id !== null) {
      return `existing:${matchedExisting.id}`;
    }
  }

  if (existingPhotos.length > 0) {
    const firstExisting = existingPhotos[0];
    if (firstExisting?.id !== undefined && firstExisting?.id !== null) {
      return `existing:${firstExisting.id}`;
    }
  }

  if (editPhotoPreviews.value.length > 0) {
    return "new:0";
  }

  return "";
}

function firstError(value) {
  if (Array.isArray(value)) {
    return value[0] || "";
  }
  return value || "";
}

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
    harvestPagination.page = 1;
  } finally {
    harvestLoading.value = false;
  }
}

const filteredHarvestItems = computed(() => {
  const mode = harvestStatusFilter.value;
  if (mode === "completed") {
    return harvestItems.value.filter((item) => Boolean(item?.is_completed));
  }
  if (mode === "pending") {
    return harvestItems.value.filter((item) => !Boolean(item?.is_completed));
  }
  return harvestItems.value;
});

const totalHarvestPages = computed(() => {
  const total = filteredHarvestItems.value.length;
  return Math.max(1, Math.ceil(total / harvestPagination.rowsPerPage));
});

const paginatedHarvestItems = computed(() => {
  const start = (harvestPagination.page - 1) * harvestPagination.rowsPerPage;
  const end = start + harvestPagination.rowsPerPage;
  return filteredHarvestItems.value.slice(start, end);
});

const harvestPageStart = computed(() => {
  if (!filteredHarvestItems.value.length) {
    return 0;
  }
  return (harvestPagination.page - 1) * harvestPagination.rowsPerPage + 1;
});

const harvestPageEnd = computed(() => {
  if (!filteredHarvestItems.value.length) {
    return 0;
  }
  return Math.min(
    harvestPagination.page * harvestPagination.rowsPerPage,
    filteredHarvestItems.value.length
  );
});



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

function formatNumber(value, digits = 1) {
  const number = Number(value);
  if (!Number.isFinite(number)) {
    return "0";
  }
  return number.toFixed(digits);
}

function formatPerTreeYield(value) {
  const number = Number(value);
  if (!Number.isFinite(number) || number <= 0) {
    return "0 kg (0 gram)";
  }

  const kilograms = formatLocaleNumber(number, "id-ID", 2);
  const grams = Math.round(number * 1000);
  return `${kilograms} kg (${formatLocaleNumber(grams, "id-ID", 0)} gram)`;
}

const selectedHarvestMetrics = computed(() => {
  const item = selectedHarvest.value;
  if (!item) {
    return null;
  }

  const qty = Number(item.harvest_quantity || 0);
  const totalPcs = Number(item.total_pieces || 0);
  const population = Number(item.demo_plot?.population || 0);

  const product = productById.value.get(Number(item.product_id || 0));
  const seedsPerPiece = Number(product?.jumlah_biji_per_pcs || 0);
  const germination = Number(item.germination_percentage || 0);
  const totalSeedCount = (seedsPerPiece > 0 && totalPcs > 0) ? (seedsPerPiece * totalPcs) : null;
  const estimatedGrownPlants = (totalSeedCount && germination > 0) ? (totalSeedCount * (germination / 100)) : null;
  const productivityPerGrownPlant = (estimatedGrownPlants && qty > 0) ? (qty / estimatedGrownPlants) : null;
  const perPieceYield = totalPcs > 0
    ? (qty / totalPcs)
    : (Number(item.per_piece_quantity || 0) || null);
  const perTreeYield = productivityPerGrownPlant;
  const putrenQty = Number(item.putren_quantity || 0) || null;
  const putrenPerPieceYield = putrenQty && totalPcs > 0
    ? (putrenQty / totalPcs)
    : (Number(item.putren_per_piece_quantity || 0) || null);
  const putrenPerTreeYield = putrenQty && estimatedGrownPlants
    ? (putrenQty / estimatedGrownPlants)
    : (Number(item.putren_per_tree_quantity || 0) || null);
  const isFreshCorn = String(item?.product?.name || product?.name || "").toLowerCase().includes("fresh corn");

  return {
    qty,
    putrenQty,
    totalPcs,
    population,
    perPieceYield,
    perTreeYield,
    putrenPerPieceYield,
    putrenPerTreeYield,
    isFreshCorn,
    seedsPerPiece,
    totalSeedCount,
    germination,
    estimatedGrownPlants,
    productivityPerGrownPlant,
  };
});

const selectedHarvestPhotoUrls = computed(() => getGalleryPhotoUrls(selectedHarvest.value));

const selectedHarvestCoverPhotoUrl = computed(() => selectedHarvestPhotoUrls.value[0] || null);

const selectedHarvestCycleData = computed(() => {
  const cycles = Array.isArray(selectedHarvest.value?.harvest_cycles) ? selectedHarvest.value.harvest_cycles : [];
  return cycles
    .map((cycle, index) => ({
      label: cycle?.label || `K${index + 1}`,
      quantity: Number(cycle?.quantity || 0),
      date: cycle?.date || null,
    }))
    .filter((cycle) => cycle.quantity > 0 || cycle.date);
});

const selectedHarvestCyclePeak = computed(() => {
  const cycles = selectedHarvestCycleData.value;
  if (!cycles.length) {
    return null;
  }

  return cycles.reduce((peak, cycle) => {
    if (!peak || Number(cycle.quantity) > Number(peak.quantity)) {
      return cycle;
    }
    return peak;
  }, null);
});

const selectedHarvestCycleChartOption = computed(() => {
  const cycles = selectedHarvestCycleData.value;
  if (!cycles.length) {
    return null;
  }

  const peakLabel = selectedHarvestCyclePeak.value?.label || null;
  const labels = cycles.map((cycle) => cycle.label);
  const quantities = cycles.map((cycle) => Number(cycle.quantity || 0));

  return {
    backgroundColor: "transparent",
    tooltip: {
      trigger: "axis",
      axisPointer: { type: "shadow" },
      formatter(params) {
        const point = Array.isArray(params) ? params[0] : params;
        const cycle = cycles[point.dataIndex] || null;
        return [
          `<div style="font-weight:700;margin-bottom:4px">${cycle?.label || '-'}</div>`,
          `<div>Total: <b>${formatNumber(cycle?.quantity || 0)} ${selectedHarvest.value?.harvest_unit || 'kg'}</b></div>`,
          cycle?.date ? `<div>Tanggal: ${formatDate(cycle.date)}</div>` : "",
        ].filter(Boolean).join("<br/>");
      },
    },
    grid: { left: 8, right: 8, top: 24, bottom: 32, containLabel: true },
    xAxis: {
      type: "category",
      data: labels,
      axisTick: { alignWithLabel: true },
      axisLabel: { color: "#5a7184", fontWeight: 600 },
      axisLine: { lineStyle: { color: "#d7e3ef" } },
    },
    yAxis: {
      type: "value",
      axisLabel: { color: "#5a7184" },
      splitLine: { lineStyle: { color: "#eaf0f5" } },
    },
    series: [
      {
        type: "bar",
        data: quantities.map((quantity, index) => ({
          value: quantity,
          itemStyle: {
            color: labels[index] === peakLabel ? "#f59e0b" : "#1976d2",
          },
        })),
        barWidth: 24,
        showBackground: true,
        backgroundStyle: { color: "#eef4fa" },
        label: {
          show: true,
          position: "top",
          color: "#1f3f60",
          fontWeight: 700,
          formatter: ({ value }) => formatNumber(value || 0),
        },
      },
    ],
  };
});

function getPerPieceYield(item) {
  const qty = Number(item?.harvest_quantity || 0);
  const totalPcs = Number(item?.total_pieces || 0);
  if (totalPcs <= 0 || qty <= 0) {
    return null;
  }
  return qty / totalPcs;
}

function getPerTreeYield(item) {
  const qty = Number(item?.harvest_quantity || 0);
  const totalPcs = Number(item?.total_pieces || 0);
  const germination = Number(item?.germination_percentage || 0);
  const product = productById.value.get(Number(item?.product_id || 0));
  const seedsPerPiece = Number(product?.jumlah_biji_per_pcs || 0);

  if (qty <= 0 || totalPcs <= 0 || seedsPerPiece <= 0 || germination <= 0) {
    return null;
  }

  const estimatedPlants = totalPcs * seedsPerPiece * (germination / 100);
  if (estimatedPlants <= 0) {
    return null;
  }

  return qty / estimatedPlants;
}

function getGalleryPhotoUrls(item) {
  const normalize = (raw) => {
    const value = String(raw || "").trim();
    if (!value) return null;

    if (value.startsWith("http://") || value.startsWith("https://")) {
      return value;
    }

    let normalized = value.replace(/\\\\/g, "/").replace(/^\/+/, "");
    if (normalized.startsWith("public/")) {
      normalized = normalized.slice(7);
    }

    return `${window.location.origin}/${normalized}`;
  };

  const urls = Array.isArray(item?.photo_urls) ? item.photo_urls.map(normalize).filter(Boolean) : [];
  if (urls.length > 0) {
    return Array.from(new Set(urls));
  }

  const fallback = getPhotoUrlLegacy(item);
  return fallback ? [fallback] : [];
}

function getPhotoUrl(item) {
  const urls = getPhotoUrls(item);
  return urls.length > 0 ? urls[0] : null;
}

function getPhotoUrls(item) {
  const candidates = new Set();

  const addCandidate = (url) => {
    const value = String(url || "").trim();
    if (value) {
      candidates.add(value);
    }
  };

  const addFromRawPath = (raw) => {
    const value = String(raw || "").trim();
    if (!value) return;

    if (value.startsWith("http://") || value.startsWith("https://")) {
      addCandidate(value);
      try {
        const parsed = new URL(value);
        const path = `${parsed.pathname}${parsed.search}`;
        addCandidate(path);
        addCandidate(`${window.location.origin}${path}`);
      } catch (error) {
        // Ignore malformed URL and keep original candidate.
      }
      return;
    }

    let normalized = value.replace(/\\\\/g, "/").replace(/^\/+/, "");
    if (normalized.startsWith("public/")) {
      normalized = normalized.slice(7);
    }

    const encoded = encodeURI(normalized);
    addCandidate(`/${normalized}`);
    addCandidate(`/${encoded}`);
    addCandidate(`${window.location.origin}/${normalized}`);
    addCandidate(`${window.location.origin}/${encoded}`);
  };

  (Array.isArray(item?.photo_urls) ? item.photo_urls : []).forEach(addFromRawPath);
  addFromRawPath(item?.photo_url);
  addFromRawPath(item?.photo_path);

  return Array.from(candidates);
}

function getPhotoUrlLegacy(item) {
  const explicitUrl = String(item?.photo_url || "").trim();
  if (explicitUrl) {
    if (explicitUrl.startsWith("http://") || explicitUrl.startsWith("https://")) {
      return explicitUrl;
    }

    let normalizedExplicit = explicitUrl.replace(/\\\\/g, "/").replace(/^\/+/, "");
    if (normalizedExplicit.startsWith("public/")) {
      normalizedExplicit = normalizedExplicit.slice(7);
    }
    return `${window.location.origin}/${normalizedExplicit}`;
  }

  const rawPath = String(item?.photo_path || "").trim();
  if (!rawPath) {
    return null;
  }

  if (rawPath.startsWith("http://") || rawPath.startsWith("https://")) {
    return rawPath;
  }

  let normalized = rawPath.replace(/^\/+/, "");
  if (normalized.startsWith("public/")) {
    normalized = normalized.slice(7);
  }

  return `${window.location.origin}/${normalized}`;
}

function handleCardPhotoError(event, item) {
  const imgEl = event?.target;
  if (!imgEl) return;

  const candidates = getPhotoUrls(item);
  if (candidates.length <= 1) return;

  const currentSrc = imgEl.getAttribute("src") || "";
  const currentIndexAttr = Number(imgEl.dataset.fallbackIndex || 0);
  const currentIndex = Number.isFinite(currentIndexAttr) ? currentIndexAttr : 0;

  let nextIndex = currentIndex + 1;
  const discoveredIndex = candidates.findIndex((url) => url === currentSrc);
  if (discoveredIndex >= 0) {
    nextIndex = discoveredIndex + 1;
  }

  if (nextIndex < candidates.length) {
    imgEl.dataset.fallbackIndex = String(nextIndex);
    imgEl.setAttribute("src", candidates[nextIndex]);
  }
}

function getHarvestCycleCount(item) {
  const cycles = Array.isArray(item?.harvest_cycles) ? item.harvest_cycles : [];
  if (cycles.length > 0) {
    return cycles.length;
  }
  return item?.is_multiple_harvest ? 1 : 1;
}

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

function altitudeZoneShort(value) {
  const altitude = Number(value);
  if (!Number.isFinite(altitude) || altitude < 0) {
    return "-";
  }
  if (altitude <= 400) {
    return "Low";
  }
  if (altitude <= 700) {
    return "Mid";
  }
  return "High";
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
  const items = filteredHarvestItems.value || [];
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
  rows.push(["Total Hasil Panen (kg)", formatNumber(analysis.totalHarvest)]);
  rows.push([
    "Zona Dominan",
    analysis.dominantZone ? `${analysis.dominantZone.label} (${formatNumber(analysis.dominantZone.totalHarvest)} kg)` : "-",
  ]);
  rows.push([]);

  rows.push(["Analisis Per Zona"]);
  rows.push(["Zona", "Range", "Jumlah Data", "Total Hasil (kg)", "Rata-rata per Data (kg)"]);
  analysis.zoneCards.forEach((zone) => {
    rows.push([
      zone.label,
      zone.range,
      zone.count,
      formatNumber(zone.totalHarvest),
      formatNumber(zone.avgHarvest),
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
      formatNumber(item.harvest_quantity),
      item.land_area ?? "-",
      productivity !== null ? formatNumber(productivity) : "-",
      item.strengths || "-",
      item.weaknesses || "-",
      item.notes || "-",
    ]);
  });

  downloadCsv("detail-hasil-panen.csv", rows);
  $q.notify({ type: "positive", message: "Detail hasil panen berhasil diexport.", position: "top" });
}

function resolveDownloadFilename(headers, fallback) {
  const disposition = headers?.["content-disposition"] || headers?.["Content-Disposition"] || "";
  const matchUtf = disposition.match(/filename\*=UTF-8''([^;]+)/i);
  if (matchUtf?.[1]) {
    return decodeURIComponent(matchUtf[1]);
  }

  const match = disposition.match(/filename="?([^";]+)"?/i);
  if (match?.[1]) {
    return match[1];
  }

  return fallback;
}

async function exportHarvestPdf(item) {
  if (!item?.id) {
    return;
  }

  try {
    const exportUrl = route("admin.harvest-result.export-pdf", item.id);

    // Pada beberapa perangkat BS (mobile/PWA), unduh blob sering gagal.
    // Gunakan direct download endpoint agar file PDF tetap bisa terunduh.
    if (isBs || $q.screen.lt.md) {
      window.location.href = exportUrl;
      return;
    }

    const response = await axios.get(route("admin.harvest-result.export-pdf", item.id), {
      responseType: "blob",
    });

    const contentType = String(response?.headers?.["content-type"] || "").toLowerCase();
    if (!contentType.includes("pdf")) {
      window.location.href = exportUrl;
      return;
    }

    const fallbackName = `laporan-hasil-panen-${item.id}.pdf`;
    const filename = resolveDownloadFilename(response.headers, fallbackName);
    const blob = new Blob([response.data], { type: "application/pdf" });
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.setAttribute("download", filename);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(link.href);
  } catch (error) {
    if (isBs || $q.screen.lt.md) {
      window.location.href = route("admin.harvest-result.export-pdf", item.id);
      return;
    }

    const message = error?.response?.data?.message || "Gagal mengunduh laporan PDF.";
    $q.notify({ type: "negative", message, position: "top" });
  }
}

function openHarvestDetail(item) {
  selectedHarvest.value = item;
  detailMobileTab.value = "summary";
  resetEditForm(item);
  editMode.value = false;
  harvestDetailDialog.value = true;
}

function openHarvestEdit(item) {
  openHarvestDetail(item);
  editMode.value = true;
}

function openHarvestPhotoViewer(url) {
  selectedHarvestPhotoViewerUrl.value = url;
  harvestPhotoViewerDialog.value = true;
}

function resetEditForm(item) {
  editForm.farmer_source = item?.demo_plot_id ? "demo_plot" : "manual";
  editForm.product_id = item?.product_id ?? null;
  editForm.demo_plot_id = item?.demo_plot_id ?? null;
  editForm.farmer_name = item?.farmer_name || "";
  editForm.harvest_date = item?.harvest_date ? String(item.harvest_date).slice(0, 10) : "";
  editForm.harvest_age_days = item?.harvest_age_days ?? null;
  editForm.harvest_quantity = item?.harvest_quantity ?? null;
  editForm.putren_quantity = item?.putren_quantity ?? null;
  editForm.total_pieces = item?.total_pieces ?? null;
  editForm.germination_percentage = item?.germination_percentage ?? null;
  editForm.is_multiple_harvest = Boolean(item?.is_multiple_harvest);
  editForm.is_completed = Boolean(item?.is_completed ?? !item?.is_multiple_harvest);
  editForm.harvest_cycles = Array.isArray(item?.harvest_cycles) && item.harvest_cycles.length
    ? item.harvest_cycles.map((cycle, index) => ({
      label: cycle?.label || `K${index + 1}`,
      date: cycle?.date ? String(cycle.date).slice(0, 10) : "",
      quantity: cycle?.quantity ?? null,
    }))
    : [{ label: "K1", date: "", quantity: null }];
  editForm.land_area = item?.land_area ?? null;
  editForm.altitude_mdpl = item?.altitude_mdpl ?? null;
  editForm.strengths = item?.strengths || "";
  editForm.weaknesses = item?.weaknesses || "";
  editForm.notes = item?.notes || "";
  editErrors.value = {};
  editPhotoPreviews.value.forEach((url) => URL.revokeObjectURL(url));
  editPhotoPreviews.value = [];
  editPhotoFiles.value = [];
  editWeaknessPhotoPreviews.value.forEach((url) => URL.revokeObjectURL(url));
  editWeaknessPhotoPreviews.value = [];
  editWeaknessPhotoFiles.value = [];
  editThumbnailSelection.value = resolveThumbnailSelection(item);
}

function handleEditPhotoChange(files) {
  editPhotoPreviews.value.forEach((url) => URL.revokeObjectURL(url));
  editPhotoPreviews.value = [];

  if (Array.isArray(files)) {
    editPhotoFiles.value = files.filter(Boolean);
    editPhotoPreviews.value = editPhotoFiles.value.map((file) => URL.createObjectURL(file));
    if (!editThumbnailSelection.value || !editThumbnailSelection.value.startsWith("new:")) {
      editThumbnailSelection.value = editPhotoPreviews.value.length > 0 ? "new:0" : editThumbnailSelection.value;
    }
    return;
  }

  editPhotoFiles.value = files ? [files] : [];
  editPhotoPreviews.value = editPhotoFiles.value.map((file) => URL.createObjectURL(file));
  if (!editThumbnailSelection.value || !editThumbnailSelection.value.startsWith("new:")) {
    editThumbnailSelection.value = editPhotoPreviews.value.length > 0 ? "new:0" : editThumbnailSelection.value;
  }
}

function handleEditWeaknessPhotoChange(files) {
  editWeaknessPhotoPreviews.value.forEach((url) => URL.revokeObjectURL(url));
  editWeaknessPhotoPreviews.value = [];

  if (Array.isArray(files)) {
    editWeaknessPhotoFiles.value = files.filter(Boolean);
    editWeaknessPhotoPreviews.value = editWeaknessPhotoFiles.value.map((file) => URL.createObjectURL(file));
    return;
  }

  editWeaknessPhotoFiles.value = files ? [files] : [];
  editWeaknessPhotoPreviews.value = editWeaknessPhotoFiles.value.map((file) => URL.createObjectURL(file));
}

watch(
  () => editForm.is_multiple_harvest,
  (isMultiple) => {
    if (isMultiple) {
      if (editForm.harvest_cycles.length === 0) {
        editForm.harvest_cycles.push({ label: "K1", date: "", quantity: null });
      }
      editForm.harvest_quantity = Number(editTotalHarvestQuantity.value || 0);
    }
  }
);

watch(
  () => editForm.farmer_source,
  (source) => {
    if (source === "manual") {
      editForm.demo_plot_id = null;
    }
  }
);

watch(editSelectedDemoPlot, (plot) => {
  if (!plot || editForm.farmer_source !== "demo_plot") {
    return;
  }

  editForm.farmer_name = plot.owner_name || "";
  editForm.product_id = plot.product_id || null;

  const referenceDate = editForm.harvest_date || dayjs().format("YYYY-MM-DD");
  if (plot.plant_date) {
    const ageDays = dayjs(referenceDate).diff(dayjs(plot.plant_date), "day");
    editForm.harvest_age_days = ageDays > 0 ? ageDays : null;
  }
});

watch(
  () => editForm.harvest_date,
  (date) => {
    if (!date || !editSelectedDemoPlot.value?.plant_date || editForm.farmer_source !== "demo_plot") {
      return;
    }
    const ageDays = dayjs(date).diff(dayjs(editSelectedDemoPlot.value.plant_date), "day");
    editForm.harvest_age_days = ageDays > 0 ? ageDays : null;
  }
);

watch(isFreshCornEdit, (isFresh) => {
  if (!isFresh) {
    editForm.putren_quantity = null;
  }
});

watch(editTotalHarvestQuantity, (value) => {
  if (editForm.is_multiple_harvest) {
    editForm.harvest_quantity = Number(value || 0);
  }
});

function addEditCycle() {
  const nextIndex = editForm.harvest_cycles.length + 1;
  editForm.harvest_cycles.push({
    label: `K${nextIndex}`,
    date: "",
    quantity: null,
  });
}

function removeEditCycle(index) {
  if (editForm.harvest_cycles.length === 1) {
    return;
  }
  editForm.harvest_cycles.splice(index, 1);
}

async function saveHarvestEdit() {
  if (!selectedHarvest.value?.id) {
    return;
  }

  savingEdit.value = true;
  editErrors.value = {};
  try {
    const formData = new FormData();
    formData.append("product_id", String(editForm.product_id || selectedHarvest.value.product_id || ""));
    formData.append("harvest_date", editForm.harvest_date || "");
    formData.append("harvest_quantity", String(editTotalHarvestQuantity.value || 0));
    formData.append("putren_quantity", isFreshCornEdit.value ? String(editForm.putren_quantity ?? "") : "");
    formData.append("total_pieces", String(editForm.total_pieces ?? ""));
    formData.append("germination_percentage", String(editForm.germination_percentage ?? ""));
    formData.append("is_multiple_harvest", editForm.is_multiple_harvest ? "1" : "0");
    formData.append("is_completed", editForm.is_completed ? "1" : "0");

    formData.append("demo_plot_id", editForm.demo_plot_id ? String(editForm.demo_plot_id) : "");
    formData.append("farmer_name", editForm.farmer_name || "");
    formData.append("harvest_age_days", editForm.harvest_age_days ?? "");
    formData.append("land_area", editForm.land_area ?? "");
    formData.append("altitude_mdpl", editForm.altitude_mdpl ?? "");
    formData.append("strengths", editForm.strengths || "");
    formData.append("weaknesses", editForm.weaknesses || "");
    formData.append("notes", editForm.notes || "");
    formData.append("thumbnail_selection", editThumbnailSelection.value || "");

    if (editForm.is_multiple_harvest) {
      editForm.harvest_cycles.forEach((cycle, index) => {
        formData.append(`harvest_cycles[${index}][label]`, cycle.label || `K${index + 1}`);
        formData.append(`harvest_cycles[${index}][date]`, cycle.date || "");
        formData.append(`harvest_cycles[${index}][quantity]`, cycle.quantity ?? "");
      });
    }

    const selectedFiles = Array.isArray(editPhotoFiles.value)
      ? editPhotoFiles.value
      : (editPhotoFiles.value ? [editPhotoFiles.value] : []);

    if (selectedFiles.length > 0) {
      selectedFiles.forEach((file) => {
        formData.append("photos[]", file);
      });
    }

    const selectedWeaknessFiles = Array.isArray(editWeaknessPhotoFiles.value)
      ? editWeaknessPhotoFiles.value
      : (editWeaknessPhotoFiles.value ? [editWeaknessPhotoFiles.value] : []);

    if (selectedWeaknessFiles.length > 0) {
      selectedWeaknessFiles.forEach((file) => {
        formData.append("weakness_photos[]", file);
      });
    }

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
    if (error?.response?.status === 422 && error?.response?.data?.errors) {
      editErrors.value = error.response.data.errors;
    }
    const message = error?.response?.data?.message || "Gagal memperbarui data hasil panen.";
    $q.notify({ type: "negative", message, position: "top" });
  } finally {
    savingEdit.value = false;
  }
}

function confirmDeleteHarvestPhoto(photo) {
  if (!selectedHarvest.value?.id || !photo) {
    return;
  }

  $q.dialog({
    title: "Hapus Foto Panen",
    message: "Foto yang dihapus tidak bisa dikembalikan. Lanjutkan?",
    cancel: true,
    persistent: true,
    ok: { color: "negative", label: "Hapus" },
  }).onOk(async () => {
    deletingPhotoKey.value = photo.key;
    try {
      if (photo.source === "legacy") {
        await axios.post(route("admin.harvest-result.photo.delete-legacy", selectedHarvest.value.id), {
          photo_path: photo.rawPath,
        });
      } else {
        await axios.post(route("admin.harvest-result.photo.delete", {
          id: selectedHarvest.value.id,
          photoId: photo.id,
        }));
      }

      await fetchHarvests();
      const updated = harvestItems.value.find((item) => Number(item.id) === Number(selectedHarvest.value.id));
      if (updated) {
        selectedHarvest.value = updated;
        resetEditForm(updated);
        editMode.value = true;
      }

      $q.notify({ type: "positive", message: "Foto panen berhasil dihapus.", position: "top" });
    } catch (error) {
      const message = error?.response?.data?.message || "Gagal menghapus foto panen.";
      $q.notify({ type: "negative", message, position: "top" });
    } finally {
      deletingPhotoKey.value = null;
    }
  });
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

watch(harvestStatusFilter, () => {
  harvestPagination.page = 1;
});

watch(
  () => harvestPagination.rowsPerPage,
  () => {
    harvestPagination.page = 1;
  }
);

watch(totalHarvestPages, (maxPage) => {
  if (harvestPagination.page > maxPage) {
    harvestPagination.page = maxPage;
  }
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
      <q-toolbar class="filter-bar harvest-toolbar">
        <div class="row items-center q-col-gutter-sm full-width">
          <div class="col-12 col-lg-auto">
            <div class="harvest-tab-shell">
              <q-btn-toggle
                v-model="activeTab"
                unelevated
                rounded
                spread
                toggle-color="primary"
                color="white"
                text-color="grey-8"
                class="harvest-tab-toggle"
                :options="[
                  { label: 'Gallery', icon: 'photo_library', value: 'gallery' },
                  { label: 'Hasil Panen', icon: 'inventory_2', value: 'harvest' },
                ]"
              />
            </div>
          </div>

          <div class="col-12 col-lg-auto q-ml-lg-auto" v-if="activeTab === 'harvest'">
            <div class="row q-gutter-xs justify-end harvest-summary-actions">
              <q-btn
                unelevated
                color="primary"
                icon="download"
                label="Summary CSV"
                class="harvest-summary-btn"
                @click="exportHarvestAnalysisCsv"
              />
              <q-btn
                unelevated
                color="secondary"
                icon="table_view"
                label="Detail CSV"
                class="harvest-summary-btn"
                @click="exportHarvestDetailCsv"
              />
            </div>
          </div>

          <div v-if="activeTab === 'gallery'" class="col-12 col-lg-auto q-ml-lg-auto">
            <div class="row q-col-gutter-sm justify-end harvest-gallery-filters">
              <div class="col-12 col-sm-auto">
                <q-input
                  v-model="filter.search"
                  dense
                  outlined
                  placeholder="Cari varietas..."
                  clearable
                  bg-color="white"
                  class="harvest-filter-input"
                >
                  <template #prepend><q-icon name="search" size="18px" /></template>
                </q-input>
              </div>
              <div class="col-12 col-sm-auto">
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
                  class="harvest-filter-select"
                />
              </div>
            </div>
          </div>

          <div v-if="activeTab === 'harvest'" class="col-12">
            <div class="row q-col-gutter-sm harvest-filter-grid">
              <div class="col-12 col-sm-6 col-lg-3">
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
              <div class="col-12 col-sm-6 col-lg-3">
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
              <div class="col-12 col-sm-6 col-lg-3">
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
              <div class="col-12 col-sm-6 col-lg-3">
                <q-select
                  v-model="harvestStatusFilter"
                  :options="harvestStatusOptions"
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

      <div v-else-if="filteredHarvestItems.length === 0" class="q-pa-xl text-center text-grey-5">
        <q-icon name="agriculture" size="56px" />
        <div class="text-subtitle2 q-mt-sm text-grey-6">Belum ada data hasil panen.</div>
      </div>

      <div v-else>
        <q-card flat bordered class="q-mb-md harvest-header-shell">
          <q-card-section>
            <div class="row items-center justify-between q-col-gutter-sm">
              <div class="col-12 col-md-auto">
                <div class="text-subtitle1 text-weight-bold">Data Input Hasil Panen BS</div>
                <div class="text-caption text-grey-7 q-mt-xs">
                  Tampilan galeri untuk membaca data panen lebih cepat dengan fokus foto dan ringkasan metrik.
                </div>
              </div>
              <div class="col-12 col-md-auto">
                <div class="row items-center q-gutter-sm justify-end">
                  <div class="text-caption text-grey-7">
                    Total data: <b>{{ filteredHarvestItems.length }}</b>
                  </div>
                  <q-btn-toggle
                    v-model="harvestViewMode"
                    dense
                    unelevated
                    toggle-color="primary"
                    color="grey-3"
                    text-color="grey-8"
                    :options="[
                      { label: 'Gallery', value: 'card', icon: 'collections' },
                      { label: 'Table', value: 'table', icon: 'table_rows' },
                    ]"
                  />
                </div>
              </div>
            </div>
          </q-card-section>
        </q-card>

        <div v-if="harvestViewMode === 'card'" class="harvest-gallery-modern q-mb-md">
          <q-card
            v-for="item in paginatedHarvestItems"
            :key="`card-${item.id}`"
            flat
            bordered
            class="harvest-modern-card"
            @click="openHarvestDetail(item)"
          >
            <div class="harvest-modern-photo-wrap">
              <img
                v-if="getPhotoUrl(item)"
                :src="getPhotoUrl(item)"
                class="harvest-modern-photo"
                loading="lazy"
                data-fallback-index="0"
                @error="handleCardPhotoError($event, item)"
              />
              <div v-else class="harvest-modern-photo-empty flex flex-center">
                <q-icon name="image_not_supported" size="26px" color="grey-6" />
              </div>

              <div class="harvest-modern-tags">
                <span class="harvest-modern-tag zone">
                  {{ item.altitude_mdpl !== null && item.altitude_mdpl !== undefined ? altitudeZone(item.altitude_mdpl) : 'Zona -' }}
                </span>
                <span v-if="item.is_multiple_harvest" class="harvest-modern-tag cycle">Multi Panen</span>
                <span class="harvest-modern-tag" :class="item.is_completed ? 'done' : 'pending'">
                  {{ item.is_completed ? 'Panen Selesai' : 'Belum Selesai' }}
                </span>
              </div>
            </div>

            <q-card-section class="harvest-modern-body">
              <div class="harvest-modern-title">{{ item.product?.name || '-' }}</div>
              <div class="harvest-modern-subtitle">{{ item.farmer_name || '-' }}</div>

              <div class="harvest-modern-kpi-row q-mt-sm">
                <div class="harvest-modern-kpi primary">
                  <div class="label">Total Panen</div>
                  <div class="value">{{ formatNumber(item.harvest_quantity) }} {{ item.harvest_unit || 'kg' }}</div>
                </div>
                <div class="harvest-modern-kpi">
                  <div class="label">Tanggal</div>
                  <div class="value">{{ formatDate(item.harvest_date) }}</div>
                </div>
              </div>

              <div class="harvest-modern-chip-row q-mt-sm">
                <span class="harvest-modern-chip">Per PCS: {{ getPerPieceYield(item) ? `${formatNumber(getPerPieceYield(item))} ${item.harvest_unit || 'kg'}` : '-' }}</span>
                <span class="harvest-modern-chip">Per Pohon: {{ getPerTreeYield(item) ? formatPerTreeYield(getPerTreeYield(item)) : '-' }}</span>
                <span class="harvest-modern-chip">Kali Panen: {{ getHarvestCycleCount(item) }}x</span>
              </div>

              <div class="harvest-modern-meta q-mt-sm">
                <div>Input: <b>{{ item.created_by?.name || '-' }}</b></div>
                <div>Waktu: {{ formatDateTime(item.created_datetime) }}</div>
              </div>

              <div class="row q-mt-sm justify-end q-gutter-sm">
                <q-btn dense flat color="primary" icon="visibility" label="Detail" @click.stop="openHarvestDetail(item)" />
                <q-btn dense flat color="accent" icon="picture_as_pdf" label="PDF" @click.stop="exportHarvestPdf(item)" />
                <q-btn
                  v-if="item.can_edit && !item.is_completed"
                  dense
                  unelevated
                  color="primary"
                  icon="update"
                  label="Update"
                  @click.stop="openHarvestEdit(item)"
                />
                <q-btn
                  v-else-if="item.can_edit"
                  dense
                  flat
                  color="secondary"
                  icon="edit"
                  label="Edit"
                  @click.stop="openHarvestEdit(item)"
                />
              </div>
            </q-card-section>
          </q-card>
        </div>

        <div v-else class="q-mt-md harvest-table-wrap">
              <q-markup-table flat bordered dense class="harvest-table">
                <thead>
                  <tr>
                    <th class="text-left">Tanggal</th>
                    <th class="text-left">Foto</th>
                    <th class="text-left">Varietas / Petani</th>
                    <th class="text-right">Panen</th>
                    <th class="text-right">Hasil / PCS</th>
                    <th class="text-right">Hasil / Pohon</th>
                    <th class="text-right">Kali Panen</th>
                    <th class="text-left">Zona</th>
                    <th class="text-left">Input</th>
                    <th class="text-left">Status</th>
                    <th class="text-right">Aksi</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="item in paginatedHarvestItems" :key="`table-${item.id}`">
                    <td>{{ formatDate(item.harvest_date) }}</td>
                    <td>
                      <div class="table-thumb-wrap">
                        <q-img
                          v-if="getPhotoUrl(item)"
                          :src="getPhotoUrl(item)"
                          ratio="1"
                          class="table-thumb"
                        >
                          <template #error>
                            <div class="table-thumb table-thumb-empty flex flex-center">
                              <q-icon name="broken_image" size="18px" color="grey-6" />
                            </div>
                          </template>
                        </q-img>
                        <div v-else class="table-thumb table-thumb-empty flex flex-center">
                          <q-icon name="image_not_supported" size="18px" color="grey-6" />
                        </div>
                      </div>
                    </td>
                    <td>
                      <div class="text-weight-medium">{{ item.product?.name || '-' }}</div>
                      <div class="text-caption text-grey-7">{{ item.farmer_name || '-' }}</div>
                    </td>
                    <td class="text-right">{{ formatNumber(item.harvest_quantity) }} {{ item.harvest_unit || 'kg' }}</td>
                    <td class="text-right">
                      {{ getPerPieceYield(item) ? `${formatNumber(getPerPieceYield(item))} ${item.harvest_unit || 'kg'}/pcs` : '-' }}
                    </td>
                    <td class="text-right">
                      {{ getPerTreeYield(item) ? formatPerTreeYield(getPerTreeYield(item)) : '-' }}
                    </td>
                    <td class="text-right">{{ getHarvestCycleCount(item) }}x</td>
                    <td>
                      {{ item.altitude_mdpl !== null && item.altitude_mdpl !== undefined ? altitudeZone(item.altitude_mdpl) : '-' }}
                    </td>
                    <td>
                      <div>{{ item.created_by?.name || '-' }}</div>
                      <div class="text-caption text-grey-7">{{ formatDateTime(item.created_datetime) }}</div>
                    </td>
                    <td>
                      <q-badge :color="item.is_completed ? 'positive' : 'warning'" outline>
                        {{ item.is_completed ? 'Panen Selesai' : 'Belum Selesai' }}
                      </q-badge>
                    </td>
                    <td class="text-right">
                      <q-btn dense flat color="primary" icon="visibility" @click="openHarvestDetail(item)" />
                      <q-btn dense flat color="accent" icon="picture_as_pdf" @click="exportHarvestPdf(item)" />
                      <q-btn
                        v-if="item.can_edit && !item.is_completed"
                        dense
                        flat
                        color="primary"
                        icon="update"
                        @click="openHarvestEdit(item)"
                      />
                      <q-btn
                        v-else-if="item.can_edit"
                        dense
                        flat
                        color="secondary"
                        icon="edit"
                        @click="openHarvestEdit(item)"
                      />
                    </td>
                  </tr>
                </tbody>
              </q-markup-table>
        </div>

        <q-card flat bordered class="q-mb-md harvest-pagination-card">
          <q-card-section class="q-py-sm">
            <div class="row items-center q-col-gutter-sm">
              <div class="col-12 col-md">
                <div class="text-caption text-grey-7">
                  Menampilkan <b>{{ harvestPageStart }}</b>-<b>{{ harvestPageEnd }}</b> dari <b>{{ filteredHarvestItems.length }}</b> data
                </div>
              </div>
              <div class="col-12 col-md-auto">
                <div class="row items-center q-gutter-sm justify-end">
                  <q-select
                    v-model="harvestPagination.rowsPerPage"
                    :options="harvestRowsPerPageOptions"
                    dense
                    outlined
                    emit-value
                    map-options
                    label="Per Halaman"
                    style="min-width: 130px"
                  />
                  <q-pagination
                    v-model="harvestPagination.page"
                    :max="totalHarvestPages"
                    :max-pages="7"
                    direction-links
                    boundary-links
                    color="primary"
                    active-color="primary"
                  />
                </div>
              </div>
            </div>
          </q-card-section>
        </q-card>

        <q-card flat bordered class="q-mb-md analysis-card">
          <q-card-section>
            <div class="row items-center justify-between q-col-gutter-sm">
              <div class="col-12 col-md-auto">
                <div class="text-subtitle1 text-weight-medium">Summary Analisis Hasil Panen</div>
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
                  <div class="text-h6 text-weight-bold">{{ formatNumber(harvestAnalysis.totalHarvest) }} kg</div>
                </div>
              </div>
              <div class="col-12 col-sm-6 col-lg-6">
                <div class="analysis-metric">
                  <div class="text-caption text-grey-7">Zona Dominan</div>
                  <div class="text-h6 text-weight-bold">
                    {{ harvestAnalysis.dominantZone?.label || '-' }}
                    <span class="text-body2 text-weight-regular" v-if="harvestAnalysis.dominantZone">
                      ({{ formatNumber(harvestAnalysis.dominantZone.totalHarvest) }} kg)
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
                  <div class="text-body2">Total: <b>{{ formatNumber(zone.totalHarvest) }} kg</b></div>
                  <div class="text-body2">Rata-rata: <b>{{ formatNumber(zone.avgHarvest) }} kg/data</b></div>
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
              :label="editMode ? 'Batal Edit' : (selectedHarvest?.is_completed ? 'Edit Data' : 'Update Data')"
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
                  <div class="col-12 col-md-6 col-lg-4">
                    <q-option-group
                      v-model="editForm.farmer_source"
                      :options="farmerSourceOptions"
                      type="radio"
                      inline
                      dense
                      label="Sumber Data Petani"
                    />
                  </div>

                  <div class="col-12 col-md-6 col-lg-8" v-if="editForm.farmer_source === 'demo_plot'">
                    <q-select
                      v-model="editForm.demo_plot_id"
                      :options="editDemoPlotOptions"
                      option-value="value"
                      option-label="label"
                      emit-value
                      map-options
                      dense
                      outlined
                      label="Pilih Demo Plot Petani"
                      :error="Boolean(editErrors.demo_plot_id)"
                      :error-message="firstError(editErrors.demo_plot_id)"
                    />
                  </div>

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
                      :disable="editForm.farmer_source === 'demo_plot' && Boolean(editForm.demo_plot_id)"
                      :error="Boolean(editErrors.product_id)"
                      :error-message="firstError(editErrors.product_id)"
                    />
                  </div>
                  <div class="col-12 col-md-4">
                    <q-input
                      v-model="editForm.farmer_name"
                      dense
                      outlined
                      label="Nama Petani"
                      :disable="editForm.farmer_source === 'demo_plot'"
                      :error="Boolean(editErrors.farmer_name)"
                      :error-message="firstError(editErrors.farmer_name)"
                    />
                  </div>
                  <div class="col-12 col-md-4">
                    <q-input
                      v-model="editForm.harvest_date"
                      type="date"
                      dense
                      outlined
                      label="Tanggal Panen"
                      :error="Boolean(editErrors.harvest_date)"
                      :error-message="firstError(editErrors.harvest_date)"
                    />
                  </div>

                  <div class="col-12 col-md-3">
                    <q-input
                      v-model.number="editForm.harvest_age_days"
                      type="number"
                      min="1"
                      dense
                      outlined
                      label="Umur Panen (hari)"
                      :error="Boolean(editErrors.harvest_age_days)"
                      :error-message="firstError(editErrors.harvest_age_days)"
                    />
                  </div>
                  <div class="col-12 col-md-3">
                    <q-input
                      v-model.number="editForm.land_area"
                      type="number"
                      min="0"
                      step="0.01"
                      dense
                      outlined
                      label="Luas Lahan (m²)"
                      :error="Boolean(editErrors.land_area)"
                      :error-message="firstError(editErrors.land_area)"
                    />
                  </div>
                  <div class="col-12 col-md-3">
                    <q-input
                      v-model.number="editForm.altitude_mdpl"
                      type="number"
                      min="0"
                      dense
                      outlined
                      label="Ketinggian (mdpl)"
                      :error="Boolean(editErrors.altitude_mdpl)"
                      :error-message="firstError(editErrors.altitude_mdpl)"
                    />
                  </div>
                  <div class="col-12 col-md-3">
                    <q-toggle
                      v-model="editForm.is_multiple_harvest"
                      color="primary"
                      label="Beberapa Kali Panen"
                    />
                  </div>
                  <div class="col-12 col-md-3">
                    <q-toggle
                      v-model="editForm.is_completed"
                      color="positive"
                      :label="editForm.is_completed ? 'Panen Selesai' : 'Belum Selesai'"
                    />
                  </div>

                  <div class="col-12 col-md-3">
                    <q-input
                      v-model.number="editForm.harvest_quantity"
                      type="number"
                      min="0"
                      step="0.01"
                      dense
                      outlined
                      :disable="editForm.is_multiple_harvest"
                      :hint="editForm.is_multiple_harvest ? 'Otomatis dari total K1/K2/dst (kg)' : ''"
                      label="Jumlah Panen (kg)"
                      :error="Boolean(editErrors.harvest_quantity)"
                      :error-message="firstError(editErrors.harvest_quantity)"
                    />
                  </div>
                  <div class="col-12 col-md-3" v-if="isFreshCornEdit">
                    <q-input
                      v-model.number="editForm.putren_quantity"
                      type="number"
                      min="0"
                      step="0.01"
                      dense
                      outlined
                      label="Hasil Putren (kg)"
                      hint="Khusus produk Fresh Corn"
                      :error="Boolean(editErrors.putren_quantity)"
                      :error-message="firstError(editErrors.putren_quantity)"
                    />
                  </div>
                  <div class="col-12 col-md-3">
                    <q-input
                      v-model.number="editForm.total_pieces"
                      type="number"
                      min="0"
                      step="1"
                      dense
                      outlined
                      label="Jumlah yang ditanam (PCS)"
                      :error="Boolean(editErrors.total_pieces)"
                      :error-message="firstError(editErrors.total_pieces)"
                    />
                  </div>
                  <div class="col-12 col-md-3">
                    <q-input
                      v-model.number="editForm.germination_percentage"
                      type="number"
                      min="0"
                      max="100"
                      step="0.01"
                      dense
                      outlined
                      label="DB / Germinasi (%)"
                      :error="Boolean(editErrors.germination_percentage)"
                      :error-message="firstError(editErrors.germination_percentage)"
                    />
                  </div>
                  <div class="col-12 col-md-3">
                    <q-input
                      :model-value="editSelectedDemoPlot?.population ? `${formatNumber(editSelectedDemoPlot.population, 0)} pohon` : '-'"
                      dense
                      outlined
                      disable
                      label="Populasi Demo Plot"
                    />
                  </div>

                  <div class="col-12" v-if="editForm.is_multiple_harvest">
                    <q-banner rounded class="bg-blue-1 text-blue-9 q-mb-sm">
                      Isi panen bertahap per siklus, misalnya K1, K2, K3.
                    </q-banner>
                    <div v-if="editErrors.harvest_cycles" class="text-negative text-caption q-mb-sm">
                      {{ firstError(editErrors.harvest_cycles) }}
                    </div>

                    <div class="column q-gutter-sm">
                      <q-card
                        v-for="(cycle, index) in editForm.harvest_cycles"
                        :key="`edit-cycle-${index}`"
                        flat
                        bordered
                      >
                        <q-card-section class="q-pa-sm">
                          <div class="row q-col-gutter-sm items-end">
                            <div class="col-12 col-md-3">
                              <q-input v-model="cycle.label" dense outlined :label="`Label ${index + 1}`" />
                            </div>
                            <div class="col-12 col-md-4">
                              <q-input v-model="cycle.date" type="date" dense outlined label="Tanggal Panen" />
                            </div>
                            <div class="col-12 col-md-4">
                              <q-input
                                v-model.number="cycle.quantity"
                                type="number"
                                dense
                                outlined
                                label="Jumlah (kg)"
                                min="0"
                                step="0.01"
                              />
                            </div>
                            <div class="col-12 col-md-1 flex justify-end">
                              <q-btn
                                flat
                                round
                                color="negative"
                                icon="delete"
                                @click="removeEditCycle(index)"
                                :disable="editForm.harvest_cycles.length === 1"
                              />
                            </div>
                          </div>
                        </q-card-section>
                      </q-card>
                    </div>

                    <q-btn class="q-mt-sm" flat color="primary" icon="add" label="Tambah K" @click="addEditCycle" />
                  </div>

                  <div class="col-12 col-md-6">
                    <q-input
                      v-model="editForm.strengths"
                      type="textarea"
                      autogrow
                      dense
                      outlined
                      label="Kelebihan / Keunggulan Panen"
                      :error="Boolean(editErrors.strengths)"
                      :error-message="firstError(editErrors.strengths)"
                    />
                  </div>
                  <div class="col-12 col-md-6">
                    <q-input
                      v-model="editForm.weaknesses"
                      type="textarea"
                      autogrow
                      dense
                      outlined
                      label="Kelemahan / Masalah Panen"
                      :error="Boolean(editErrors.weaknesses)"
                      :error-message="firstError(editErrors.weaknesses)"
                    />
                  </div>
                  <div class="col-12">
                    <q-input
                      v-model="editForm.notes"
                      type="textarea"
                      autogrow
                      dense
                      outlined
                      label="Catatan Umum"
                      :error="Boolean(editErrors.notes)"
                      :error-message="firstError(editErrors.notes)"
                    />
                  </div>
                  <div class="col-12 col-md-6">
                    <q-file
                      v-model="editPhotoFiles"
                      dense
                      outlined
                      accept="image/*"
                      label="Tambah foto panen (bisa banyak)"
                      multiple
                      use-chips
                      clearable
                      @update:model-value="handleEditPhotoChange"
                      :error="Boolean(editErrors.photos || editErrors.photo)"
                      :error-message="firstError(editErrors.photos || editErrors.photo)"
                    />
                    <div v-if="editPhotoPreviews.length" class="detail-upload-grid q-mt-sm">
                      <q-img
                        v-for="(img, idx) in editPhotoPreviews"
                        :key="`edit-upload-${idx}`"
                        :src="img"
                        ratio="1"
                        class="detail-upload-thumb"
                      >
                        <template #error>
                          <div class="detail-upload-thumb flex flex-center bg-grey-2">
                            <q-icon name="broken_image" size="18px" color="grey-6" />
                          </div>
                        </template>
                      </q-img>
                    </div>
                  </div>
                  <div class="col-12 col-md-6">
                    <q-file
                      v-model="editWeaknessPhotoFiles"
                      dense
                      outlined
                      accept="image/*"
                      label="Upload foto kelemahan (bisa banyak)"
                      multiple
                      use-chips
                      clearable
                      @update:model-value="handleEditWeaknessPhotoChange"
                      :error="Boolean(editErrors.weakness_photos)"
                      :error-message="firstError(editErrors.weakness_photos)"
                    />
                    <div v-if="editWeaknessPhotoPreviews.length" class="detail-upload-grid q-mt-sm">
                      <q-img
                        v-for="(img, idx) in editWeaknessPhotoPreviews"
                        :key="`edit-weakness-upload-${idx}`"
                        :src="img"
                        ratio="1"
                        class="detail-upload-thumb"
                      >
                        <template #error>
                          <div class="detail-upload-thumb flex flex-center bg-grey-2">
                            <q-icon name="broken_image" size="18px" color="grey-6" />
                          </div>
                        </template>
                      </q-img>
                    </div>
                  </div>
                  <div class="col-12 col-md-6">
                    <div class="text-subtitle2 text-weight-medium q-mb-xs">Pilih Thumbnail Foto</div>
                    <div class="text-caption text-grey-7 q-mb-sm">
                      Foto ini akan dipakai sebagai cover di card view dan tampilan ringkas.
                    </div>
                    <div v-if="editThumbnailChoices.length" class="detail-thumbnail-grid">
                      <button
                        v-for="choice in editThumbnailChoices"
                        :key="choice.value"
                        type="button"
                        class="detail-thumbnail-choice"
                        :class="{ selected: editThumbnailSelection === choice.value }"
                        @click="editThumbnailSelection = choice.value"
                      >
                        <q-img :src="choice.src" ratio="1" class="detail-thumbnail-choice-img">
                          <template #error>
                            <div class="detail-thumbnail-choice-img flex flex-center bg-grey-2">
                              <q-icon name="broken_image" size="18px" color="grey-6" />
                            </div>
                          </template>
                        </q-img>
                        <div class="detail-thumbnail-choice-label">
                          <span>{{ choice.label }}</span>
                          <q-badge v-if="editThumbnailSelection === choice.value" color="primary" rounded>
                            Terpilih
                          </q-badge>
                        </div>
                      </button>
                    </div>
                    <div v-else class="text-caption text-grey-7">
                      Tambahkan foto dulu untuk memilih thumbnail.
                    </div>
                  </div>
                  <div class="col-12">
                    <div class="text-subtitle2 text-weight-medium q-mb-xs">Galeri Foto Panen (Foto Lama)</div>
                    <div class="text-caption text-grey-7 q-mb-sm">
                      Anda bisa hapus foto yang tidak diperlukan dari data panen ini.
                    </div>
                    <div v-if="editExistingPhotos.length" class="edit-existing-photo-grid">
                      <div v-for="photo in editExistingPhotos" :key="`existing-photo-${photo.id}`" class="edit-existing-photo-item">
                        <q-img :src="photo.src" ratio="1" class="edit-existing-photo-thumb">
                          <template #error>
                            <div class="edit-existing-photo-thumb flex flex-center bg-grey-2">
                              <q-icon name="broken_image" size="18px" color="grey-6" />
                            </div>
                          </template>
                        </q-img>
                        <div class="edit-existing-photo-footer">
                          <span>{{ photo.label }}</span>
                          <q-btn
                            dense
                            flat
                            color="negative"
                            icon="delete"
                            :loading="deletingPhotoKey === photo.key"
                            :disable="deletingPhotoKey !== null"
                            @click="confirmDeleteHarvestPhoto(photo)"
                          />
                        </div>
                      </div>
                    </div>
                    <div v-else class="text-caption text-grey-7">
                      Belum ada foto lama yang bisa dihapus.
                    </div>
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
                  Ringkasan hasil panen menggunakan satu angka desimal agar lebih ringkas.
                </div>

                <div class="lt-md q-mt-sm">
                  <q-tabs
                    v-model="detailMobileTab"
                    dense
                    active-color="primary"
                    indicator-color="primary"
                    class="mobile-detail-tabs"
                    align="left"
                    narrow-indicator
                    inline-label
                  >
                    <q-tab name="summary" label="Summary" />
                    <q-tab name="main" label="Data Utama" />
                    <q-tab name="extra" label="Data Tambahan" />
                    <q-tab name="cycles" label="Rincian" />
                    <q-tab name="notes" label="Catatan" />
                  </q-tabs>
                </div>

                <div
                  class="row q-col-gutter-sm q-mt-sm"
                  v-if="selectedHarvestMetrics"
                  v-show="!$q.screen.lt.md || detailMobileTab === 'summary'"
                >
                  <div class="col-12 col-sm-6 col-md-4">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Total Panen</div>
                      <div class="detail-metric-value">{{ formatNumber(selectedHarvestMetrics.qty) }} {{ selectedHarvest.harvest_unit || 'kg' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4" v-if="selectedHarvestMetrics.isFreshCorn">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Hasil Putren</div>
                      <div class="detail-metric-value">{{ selectedHarvestMetrics.putrenQty ? `${formatNumber(selectedHarvestMetrics.putrenQty)} ${selectedHarvest.harvest_unit || 'kg'}` : '-' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Hasil per PCS</div>
                      <div class="detail-metric-value">{{ selectedHarvestMetrics.perPieceYield ? `${formatNumber(selectedHarvestMetrics.perPieceYield)} ${selectedHarvest.harvest_unit || 'kg'}/pcs` : '-' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4" v-if="selectedHarvestMetrics.isFreshCorn">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Putren per PCS</div>
                      <div class="detail-metric-value">{{ selectedHarvestMetrics.putrenPerPieceYield ? `${formatNumber(selectedHarvestMetrics.putrenPerPieceYield)} ${selectedHarvest.harvest_unit || 'kg'}/pcs` : '-' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Estimasi Tumbuh</div>
                      <div class="detail-metric-value">{{ selectedHarvestMetrics.estimatedGrownPlants ? `${formatNumber(selectedHarvestMetrics.estimatedGrownPlants, 0)} pohon` : '-' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Hasil per Pohon Tumbuh</div>
                      <div class="detail-metric-value">{{ selectedHarvestMetrics.perTreeYield ? formatPerTreeYield(selectedHarvestMetrics.perTreeYield) : '-' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4" v-if="selectedHarvestMetrics.isFreshCorn">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Putren per Pohon</div>
                      <div class="detail-metric-value">{{ selectedHarvestMetrics.putrenPerTreeYield ? formatPerTreeYield(selectedHarvestMetrics.putrenPerTreeYield) : '-' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Total PCS</div>
                      <div class="detail-metric-value">{{ selectedHarvestMetrics.totalPcs ? `${formatNumber(selectedHarvestMetrics.totalPcs, 0)} pcs` : '-' }}</div>
                    </div>
                  </div>
                  <div class="col-12 col-sm-6 col-md-4">
                    <div class="detail-metric-card">
                      <div class="detail-metric-label">Total Kali Panen</div>
                      <div class="detail-metric-value">{{ getHarvestCycleCount(selectedHarvest) }} kali</div>
                    </div>
                  </div>
                </div>
              </q-card-section>
            </q-card>

            <div class="row q-col-gutter-md detail-body-grid">
              <div
                class="col-12"
                v-if="selectedHarvestPhotoUrls.length"
                v-show="!$q.screen.lt.md || detailMobileTab === 'extra'"
              >
                <q-card flat bordered class="detail-photo-gallery-shell">
                  <q-card-section class="q-pb-sm">
                    <div class="row items-center justify-between q-col-gutter-sm">
                      <div class="col-12 col-sm-auto">
                        <div class="text-subtitle2 text-weight-medium">Galeri Foto Panen</div>
                        <div class="text-caption text-grey-7">
                          {{ selectedHarvestPhotoUrls.length }} foto terhubung ke data ini.
                        </div>
                      </div>
                      <div class="col-12 col-sm-auto text-right text-caption text-grey-7">
                        Foto utama: <b>{{ selectedHarvestCoverPhotoUrl ? 1 : 0 }}</b>
                      </div>
                    </div>
                  </q-card-section>
                  <q-card-section class="q-pt-none">
                    <div class="detail-photo-showcase-main" v-if="selectedHarvestCoverPhotoUrl">
                      <img
                        :src="selectedHarvestCoverPhotoUrl"
                        class="detail-photo-main-img"
                        loading="lazy"
                        alt="Foto utama panen"
                      />
                    </div>
                    <div class="detail-photo-grid q-mt-md">
                      <button
                        v-for="(img, idx) in selectedHarvestPhotoUrls"
                        :key="`harvest-photo-${idx}`"
                        type="button"
                        class="detail-photo-thumb-btn"
                        @click="openHarvestPhotoViewer(img)"
                      >
                        <img
                          :src="img"
                          class="detail-gallery-thumb-img"
                          loading="lazy"
                          :alt="`Foto panen ${idx + 1}`"
                        />
                        <span class="detail-photo-thumb-badge">{{ idx + 1 }}</span>
                      </button>
                    </div>
                  </q-card-section>
                </q-card>
              </div>
              <div class="col-12 col-md-6" v-show="!$q.screen.lt.md || detailMobileTab === 'main'">
                <q-card flat bordered>
                  <q-card-section>
                    <div class="text-subtitle2 text-weight-medium q-mb-sm">Data Utama</div>
                    <div class="detail-grid">
                      <div class="detail-key">Varietas</div><div class="detail-val">{{ selectedHarvest.product?.name || '-' }}</div>
                      <div class="detail-key">Nama Petani</div><div class="detail-val">{{ selectedHarvest.farmer_name || '-' }}</div>
                      <div class="detail-key">Tanggal Panen</div><div class="detail-val">{{ formatDate(selectedHarvest.harvest_date) }}</div>
                      <div class="detail-key">Umur Panen</div><div class="detail-val">{{ selectedHarvest.harvest_age_days ? `${selectedHarvest.harvest_age_days} hari` : '-' }}</div>
                      <div class="detail-key">Total Hasil</div><div class="detail-val">{{ formatNumber(selectedHarvest.harvest_quantity) }} {{ selectedHarvest.harvest_unit || 'kg' }}</div>
                      <div class="detail-key">Luas Lahan</div><div class="detail-val">{{ selectedHarvest.land_area ? `${formatNumber(selectedHarvest.land_area)} m²` : '-' }}</div>
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
              <div class="col-12 col-md-6" v-show="!$q.screen.lt.md || detailMobileTab === 'extra'">
                <q-card flat bordered>
                  <q-card-section>
                    <div class="text-subtitle2 text-weight-medium q-mb-sm">Data Tambahan</div>
                    <div class="detail-grid">
                      <div class="detail-key">Foto Thumbnail</div>
                      <div class="detail-val">
                        <q-img
                          v-if="getPhotoUrl(selectedHarvest)"
                          :src="getPhotoUrl(selectedHarvest)"
                          ratio="4/3"
                          class="detail-inline-thumb"
                        >
                          <template #error>
                            <div class="detail-inline-thumb flex flex-center bg-grey-2">
                              <q-icon name="broken_image" size="20px" color="grey-6" />
                            </div>
                          </template>
                        </q-img>
                        <div v-if="getPhotoUrls(selectedHarvest).length > 1" class="text-caption text-grey-7 q-mt-xs">
                          +{{ getPhotoUrls(selectedHarvest).length - 1 }} foto tambahan
                        </div>
                        <span v-if="!getPhotoUrl(selectedHarvest)">-</span>
                      </div>
                      <div class="detail-key">Lokasi</div><div class="detail-val">{{ selectedHarvest.location || '-' }}</div>
                      <div class="detail-key">Populasi Demo Plot</div><div class="detail-val">{{ selectedHarvest.demo_plot?.population ? `${formatNumber(selectedHarvest.demo_plot.population, 0)} pohon` : '-' }}</div>
                      <div class="detail-key">Total PCS</div><div class="detail-val">{{ selectedHarvest.total_pieces ? formatNumber(selectedHarvest.total_pieces, 0) : '-' }}</div>
                      <div class="detail-key">DB / Germinasi</div><div class="detail-val">{{ selectedHarvest.germination_percentage ? `${formatNumber(selectedHarvest.germination_percentage)} %` : '-' }}</div>
                      <div class="detail-key">Biji per PCS</div><div class="detail-val">{{ selectedHarvestMetrics?.seedsPerPiece ? `${formatNumber(selectedHarvestMetrics.seedsPerPiece, 0)} biji` : '-' }}</div>
                      <div class="detail-key">Total Biji</div><div class="detail-val">{{ selectedHarvestMetrics?.totalSeedCount ? `${formatNumber(selectedHarvestMetrics.totalSeedCount, 0)} biji` : '-' }}</div>
                      <div class="detail-key">Estimasi Tumbuh</div><div class="detail-val">{{ selectedHarvestMetrics?.estimatedGrownPlants ? `${formatNumber(selectedHarvestMetrics.estimatedGrownPlants, 0)} pohon` : '-' }}</div>
                      <div class="detail-key">Hasil per PCS</div><div class="detail-val">{{ selectedHarvestMetrics?.perPieceYield ? `${formatNumber(selectedHarvestMetrics.perPieceYield)} ${selectedHarvest.harvest_unit || 'kg'}/pcs` : '-' }}</div>
                      <div class="detail-key">Hasil per Pohon Tumbuh</div><div class="detail-val">{{ selectedHarvestMetrics?.perTreeYield ? formatPerTreeYield(selectedHarvestMetrics.perTreeYield) : '-' }}</div>
                      <template v-if="selectedHarvestMetrics?.isFreshCorn">
                        <div class="detail-key">Hasil Putren</div><div class="detail-val">{{ selectedHarvestMetrics?.putrenQty ? `${formatNumber(selectedHarvestMetrics.putrenQty)} ${selectedHarvest.harvest_unit || 'kg'}` : '-' }}</div>
                        <div class="detail-key">Putren per PCS</div><div class="detail-val">{{ selectedHarvestMetrics?.putrenPerPieceYield ? `${formatNumber(selectedHarvestMetrics.putrenPerPieceYield)} ${selectedHarvest.harvest_unit || 'kg'}/pcs` : '-' }}</div>
                        <div class="detail-key">Putren per Pohon</div><div class="detail-val">{{ selectedHarvestMetrics?.putrenPerTreeYield ? formatPerTreeYield(selectedHarvestMetrics.putrenPerTreeYield) : '-' }}</div>
                      </template>
                      <div class="detail-key">Mode Panen</div><div class="detail-val">{{ selectedHarvest.is_multiple_harvest ? 'Beberapa Kali Panen' : 'Sekali Panen' }}</div>
                      <div class="detail-key">Status Panen</div><div class="detail-val">{{ selectedHarvest.is_completed ? 'Panen Selesai' : 'Belum Selesai' }}</div>
                      <div class="detail-key">Penginput</div><div class="detail-val">{{ selectedHarvest.created_by?.name || '-' }}</div>
                      <div class="detail-key">Waktu Input</div><div class="detail-val">{{ formatDateTime(selectedHarvest.created_datetime) }}</div>
                    </div>
                  </q-card-section>
                </q-card>
              </div>

              <div
                class="col-12"
                v-if="selectedHarvest.is_multiple_harvest && selectedHarvest.harvest_cycles && selectedHarvest.harvest_cycles.length && (!$q.screen.lt.md || detailMobileTab === 'cycles')"
              >
                <q-card flat bordered>
                  <q-card-section>
                    <div class="text-subtitle2 text-weight-medium">Rincian Panen Bertahap</div>
                    <div class="text-caption text-grey-7 q-mt-xs">
                      Grafik membantu melihat siklus mana yang mencapai puncak panen.
                    </div>
                    <div v-if="selectedHarvestCycleChartOption" class="detail-cycle-chart q-mt-sm">
                      <ECharts :option="selectedHarvestCycleChartOption" autoresize style="height: 260px; width: 100%;" />
                    </div>
                    <div v-if="selectedHarvestCyclePeak" class="detail-cycle-peak q-mt-sm">
                      Puncak panen: <b>{{ selectedHarvestCyclePeak.label }}</b> dengan <b>{{ formatNumber(selectedHarvestCyclePeak.quantity) }} {{ selectedHarvest.harvest_unit || 'kg' }}</b>
                    </div>
                    <div class="cycle-grid-compact q-mt-sm">
                      <div
                        v-for="(cycle, idx) in selectedHarvest.harvest_cycles"
                        :key="`dlg-cycle-${idx}`"
                        class="cycle-grid-item"
                      >
                        <div class="cycle-label">{{ cycle.label || `K${idx + 1}` }}</div>
                        <div class="cycle-value">{{ formatNumber(cycle.quantity) }} {{ selectedHarvest.harvest_unit || 'kg' }}</div>
                        <div class="cycle-date" v-if="cycle.date">{{ formatDate(cycle.date) }}</div>
                      </div>
                    </div>
                  </q-card-section>
                </q-card>
              </div>

              <div
                class="col-12"
                v-if="selectedHarvest.strengths || selectedHarvest.weaknesses || selectedHarvest.notes"
                v-show="!$q.screen.lt.md || detailMobileTab === 'notes'"
              >
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

      <q-dialog
        v-model="harvestPhotoViewerDialog"
        maximized
        transition-show="scale"
        transition-hide="scale"
      >
        <div class="photo-viewer-container">
          <q-btn
            round
            flat
            dense
            icon="close"
            color="white"
            class="photo-viewer-close"
            @click="harvestPhotoViewerDialog = false"
          />
          <img
            v-if="selectedHarvestPhotoViewerUrl"
            :src="selectedHarvestPhotoViewerUrl"
            class="photo-viewer-image"
            alt="Pratinjau foto panen"
            @click="harvestPhotoViewerDialog = false"
          />
        </div>
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

.harvest-toolbar {
  background: linear-gradient(180deg, #f7fbff 0%, #eef5fb 100%);
  border-bottom: 1px solid #d9e6f1;
}

.harvest-tab-shell {
  display: inline-flex;
  padding: 6px;
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.76);
  border: 1px solid #d7e3ef;
  box-shadow: 0 10px 24px rgba(19, 42, 64, 0.06);
  backdrop-filter: blur(10px);
}

.harvest-tab-toggle {
  min-height: 42px;
}

.harvest-tab-toggle :deep(.q-btn) {
  min-height: 42px;
  padding: 0 16px;
  border-radius: 12px;
  font-weight: 700;
  letter-spacing: 0.2px;
}

.harvest-tab-toggle :deep(.q-btn--active) {
  color: #11324d !important;
  box-shadow: 0 8px 16px rgba(35, 84, 128, 0.12);
}

.harvest-summary-actions {
  min-width: 0;
}

.harvest-summary-btn {
  min-height: 42px;
  border-radius: 12px;
  padding-left: 14px;
  padding-right: 14px;
  font-weight: 600;
}

.harvest-gallery-filters {
  align-items: stretch;
}

.harvest-filter-input,
.harvest-filter-select {
  min-width: 240px;
}

@media (max-width: 599px) {
  .harvest-tab-shell {
    display: flex;
    width: 100%;
  }

  .harvest-tab-toggle {
    width: 100%;
  }

  .harvest-filter-input,
  .harvest-filter-select {
    min-width: 0;
    width: 100%;
  }

  .harvest-summary-btn {
    width: 100%;
  }
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

.harvest-header-shell {
  width: 100% !important;
  max-width: none !important;
  background: linear-gradient(135deg, #eef6ff 0%, #ffffff 100%);
  border-color: #d6e5f3;
}

.harvest-gallery-modern {
  display: grid;
  width: 100%;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 14px;
}

.harvest-modern-card {
  width: 100% !important;
  max-width: none !important;
  border-radius: 14px;
  overflow: hidden;
  border-color: #d8e4f1;
  background: #fff;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  cursor: pointer;
}

.harvest-modern-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 24px rgba(18, 48, 84, 0.14);
}

.harvest-modern-photo-wrap {
  position: relative;
  overflow: hidden;
}

.harvest-modern-photo,
.harvest-modern-photo-empty {
  width: 100%;
  height: 122px;
  object-fit: cover;
  display: block;
}

.harvest-modern-photo-empty {
  background: #ecf2f8;
}

@media (min-width: 1024px) {
  .harvest-modern-photo,
  .harvest-modern-photo-empty {
    height: 110px;
  }
}

.harvest-modern-tags {
  position: absolute;
  top: 10px;
  left: 10px;
  right: 10px;
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.harvest-modern-tag {
  font-size: 11px;
  font-weight: 700;
  border-radius: 999px;
  padding: 4px 10px;
  color: #fff;
}

.harvest-modern-tag.zone {
  background: rgba(26, 74, 130, 0.9);
}

.harvest-modern-tag.cycle {
  background: rgba(13, 102, 64, 0.9);
}

.harvest-modern-tag.done {
  background: rgba(46, 125, 50, 0.92);
}

.harvest-modern-tag.pending {
  background: rgba(237, 108, 2, 0.92);
}

.harvest-modern-body {
  padding: 10px 12px 12px !important;
}

.harvest-modern-title {
  font-size: 16px;
  line-height: 1.2;
  font-weight: 800;
  color: #1f3f60;
}

.harvest-modern-subtitle {
  margin-top: 3px;
  font-size: 13px;
  font-weight: 600;
  color: #55708a;
}

.harvest-modern-kpi-row {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
}

.harvest-modern-kpi {
  border: 1px solid #e3ecf4;
  border-radius: 9px;
  padding: 8px;
  background: #f8fbff;
}

.harvest-modern-kpi.primary {
  background: #edf5ff;
  border-color: #d1e4fb;
}

.harvest-modern-kpi .label {
  font-size: 10px;
  color: #73879b;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.harvest-modern-kpi .value {
  margin-top: 2px;
  font-size: 13px;
  font-weight: 700;
  color: #173554;
}

.harvest-modern-chip-row {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.harvest-modern-chip {
  font-size: 11px;
  font-weight: 600;
  color: #395b79;
  border: 1px solid #dde8f2;
  background: #fff;
  border-radius: 999px;
  padding: 4px 10px;
}

.harvest-modern-meta {
  border-top: 1px dashed #d9e5ef;
  padding-top: 8px;
  font-size: 12px;
  color: #597086;
  line-height: 1.45;
}

.harvest-table-wrap {
  width: 100%;
  overflow-x: auto;
}

.harvest-table {
  min-width: 980px;
}

.table-thumb-wrap {
  width: 52px;
}

.table-thumb {
  width: 52px;
  height: 52px;
  border-radius: 8px;
  border: 1px solid #dce7ef;
  overflow: hidden;
}

.table-thumb-empty {
  background: #f3f7fc;
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
  align-items: flex-start;
}

.harvest-tag-row.compact {
  top: 6px;
  left: 6px;
  right: 6px;
  gap: 4px;
}

@media (max-width: 480px) {
  .harvest-tag-row.compact {
    top: 4px;
    left: 4px;
    right: 4px;
    gap: 3px;
  }
}

.harvest-tag {
  font-size: 11px;
  font-weight: 700;
  border-radius: 999px;
  padding: 4px 9px;
  color: #fff;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: fit-content;
  display: inline-block;
}

.zone-tag {
  background: rgba(27, 74, 130, 0.84);
  max-width: 140px;
}

@media (max-width: 768px) {
  .harvest-tag {
    font-size: 10px;
    padding: 3px 8px;
  }
  
  .zone-tag {
    max-width: 110px;
  }
}

@media (max-width: 480px) {
  .harvest-tag {
    font-size: 9px;
    padding: 2px 6px;
  }
  
  .zone-tag {
    max-width: 85px;
  }
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

.detail-photo-gallery-shell {
  width: 100% !important;
  max-width: none !important;
  border-color: #dbe7f3;
  background: linear-gradient(180deg, #f8fbff 0%, #ffffff 100%);
}

.detail-photo-showcase-main {
  width: 100%;
  border-radius: 14px;
  overflow: hidden;
  background: #eef4fa;
  border: 1px solid #dbe7f3;
}

.detail-photo-main-img {
  display: block;
  width: 100%;
  aspect-ratio: 16 / 9;
  object-fit: cover;
}

.detail-photo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(104px, 1fr));
  gap: 10px;
}

.detail-photo-thumb-btn {
  position: relative;
  display: block;
  width: 100%;
  padding: 0;
  border: 0;
  background: transparent;
  cursor: pointer;
}

.detail-gallery-thumb-img {
  display: block;
  width: 100%;
  aspect-ratio: 1 / 1;
  object-fit: cover;
  border-radius: 12px;
  border: 1px solid #dce7ef;
}

.detail-photo-thumb-badge {
  position: absolute;
  right: 6px;
  bottom: 6px;
  min-width: 20px;
  height: 20px;
  border-radius: 999px;
  background: rgba(17, 24, 39, 0.75);
  color: #fff;
  font-size: 11px;
  line-height: 20px;
  text-align: center;
  padding: 0 6px;
}

.detail-cycle-chart {
  border: 1px solid #dbe7f3;
  border-radius: 12px;
  background: #fff;
  overflow: hidden;
}

.detail-cycle-peak {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 10px;
  border-radius: 999px;
  background: #fff7e6;
  border: 1px solid #f6d9a8;
  color: #8a4b00;
  font-size: 12px;
}

.photo-viewer-container {
  position: relative;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.96);
  overflow: hidden;
}

.photo-viewer-image {
  max-width: 92vw;
  max-height: 92vh;
  object-fit: contain;
  cursor: zoom-out;
}

.photo-viewer-close {
  position: absolute !important;
  top: 20px;
  right: 20px;
  z-index: 2;
  background: rgba(255, 255, 255, 0.16);
}

.photo-viewer-close:hover {
  background: rgba(255, 255, 255, 0.25);
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

.detail-inline-thumb {
  width: 140px;
  border-radius: 8px;
  border: 1px solid #dce7ef;
  overflow: hidden;
}

.detail-photo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 8px;
}

.detail-upload-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(84px, 1fr));
  gap: 8px;
}

.detail-upload-thumb {
  border-radius: 8px;
  border: 1px solid #dce7ef;
  overflow: hidden;
}

.detail-thumbnail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(110px, 1fr));
  gap: 10px;
}

.detail-thumbnail-choice {
  appearance: none;
  border: 1px solid #d8e1ea;
  border-radius: 14px;
  background: #fff;
  padding: 8px;
  text-align: left;
  cursor: pointer;
  transition: border-color 0.15s ease, box-shadow 0.15s ease, transform 0.15s ease;
}

.detail-thumbnail-choice:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 18px rgba(18, 48, 84, 0.08);
}

.detail-thumbnail-choice.selected {
  border-color: #1f5ea8;
  box-shadow: 0 0 0 2px rgba(31, 94, 168, 0.14);
}

.detail-thumbnail-choice-img {
  width: 100%;
  border-radius: 10px;
  overflow: hidden;
}

.detail-thumbnail-choice-label {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-top: 8px;
  font-size: 12px;
  font-weight: 600;
  color: #38516d;
}

.edit-existing-photo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(126px, 1fr));
  gap: 10px;
}

.edit-existing-photo-item {
  border: 1px solid #dce7ef;
  border-radius: 10px;
  overflow: hidden;
  background: #fff;
}

.edit-existing-photo-thumb {
  width: 100%;
}

.edit-existing-photo-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
  padding: 4px 6px;
  font-size: 11px;
  font-weight: 600;
  color: #425f7d;
}

.detail-gallery-thumb {
  border-radius: 8px;
  border: 1px solid #dce7ef;
  overflow: hidden;
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
  .harvest-gallery-modern {
    grid-template-columns: 1fr;
  }

  .harvest-modern-kpi-row {
    grid-template-columns: 1fr;
  }

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

.mobile-detail-tabs {
  border-bottom: 1px solid #e3ebf4;
}
</style>
