<script setup>
import { computed, onMounted, reactive, ref, watch } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import { Dialog, Notify, useQuasar } from "quasar";
import axios from "axios";
import { usePageStorage } from "@/helpers/usePageStorage";

const page = usePage();
const $q = useQuasar();
const storage = usePageStorage("distributor-target");
const title = "Target Distributor";

const nowMonth = new Date().getMonth() + 1;
const nowYear = new Date().getFullYear();
const thisFiscalYear = nowMonth >= 4 ? nowYear : nowYear - 1;
const initialFiscalYear = Number(page.props.initial_fiscal_year ?? thisFiscalYear);

const monthLabels = page.props.month_labels ?? {};
const desktopMonthColumns = Object.entries(monthLabels).map(([key, label]) => ({
  name: key,
  label,
  field: key,
  align: "right",
  sortable: false,
}));

const filter = reactive(
  {
    ...storage.get("filter", {
      fiscal_year: thisFiscalYear,
      distributor_id: null,
      product_id: null,
    }),
    fiscal_year: initialFiscalYear,
  }
);

const showFilter = ref(storage.get("show-filter", true));
const loading = ref(false);
const rows = ref([]);
const breakdownDialog = ref(false);
const breakdownLoading = ref(false);
const breakdownTitle = ref("Breakdown Bulanan");
const breakdownSubtitle = ref("");
const breakdownRows = ref([]);
const summary = reactive({
  total_target: 0,
  total_actual: 0,
  total_target_value: 0,
  total_actual_value: 0,
  fiscal_year: initialFiscalYear,
});

// ── Import ──────────────────────────────────────────────────────────────────
const importDialog = ref(false);
const importing = ref(false);
const importFile = ref(null);
const importResult = ref(null);

function openImport() {
  importFile.value = null;
  importResult.value = null;
  importDialog.value = true;
}

async function submitImport() {
  if (!importFile.value) {
    Notify.create({ type: "warning", message: "Pilih file CSV terlebih dahulu." });
    return;
  }
  importing.value = true;
  try {
    const formData = new FormData();
    formData.append("file", importFile.value);
    const res = await axios.post(route("admin.distributor-target.import"), formData);
    importResult.value = res.data;
    const errCount = res.data.errors?.length ?? 0;
    Notify.create({
      type: errCount > 0 ? "warning" : "positive",
      message: `Import selesai: ${res.data.created} dibuat, ${res.data.updated} diperbarui, ${errCount} error.`,
    });
    if (res.data.success > 0) fetchData();
  } catch (err) {
    const msg = err?.response?.data?.message || err?.response?.data?.errors?.[0] || "Import gagal.";
    Notify.create({ type: "negative", message: msg });
  } finally {
    importing.value = false;
  }
}

const fiscalYearOptions = computed(() => {
  const options = [];
  for (let year = thisFiscalYear + 1; year >= thisFiscalYear - 3; year -= 1) {
    options.push({ value: year, label: `FY ${year}/${year + 1}` });
  }
  return options;
});

const distributorOptions = computed(() => [
  { value: null, label: "Semua Distributor" },
  ...(page.props.distributors ?? []).map((item) => ({ value: item.id, label: item.name })),
]);

const productOptions = computed(() => [
  { value: null, label: "Semua Produk" },
  ...(page.props.products ?? []).map((item) => ({ value: item.id, label: item.name })),
]);

const columns = computed(() => {
  const baseColumns = [
    { name: "distributor_name", label: "Distributor", field: "distributor_name", align: "left", sortable: true },
    { name: "product_name", label: "Produk", field: "product_name", align: "left", sortable: true },
    { name: "total_target_qty", label: "Target", field: "total_target_qty", align: "right", sortable: true },
    { name: "total_actual_qty", label: "Realisasi", field: "total_actual_qty", align: "right", sortable: true },
    { name: "total_target_value", label: "Nilai Target (Rp)", field: "total_target_value", align: "right", sortable: true },
    { name: "total_actual_value", label: "Nilai Realisasi (Rp)", field: "total_actual_value", align: "right", sortable: true },
    { name: "achievement", label: "Pencapaian", field: "achievement", align: "center", sortable: true },
  ];

  if ($q.screen.gt.md) {
    baseColumns.splice(3, 0, ...desktopMonthColumns);
  }

  baseColumns.push({ name: "action", label: "", field: "action", align: "right" });
  return baseColumns;
});

const breakdownColumns = [
  { name: "month_label", label: "Bulan", field: "month_label", align: "left" },
  { name: "target_qty", label: "Target Qty", field: "target_qty", align: "right" },
  { name: "actual_qty", label: "Realisasi Qty", field: "actual_qty", align: "right" },
  { name: "target_value", label: "Nilai Target (Rp)", field: "target_value", align: "right" },
  { name: "actual_value", label: "Nilai Realisasi (Rp)", field: "actual_value", align: "right" },
  { name: "achievement", label: "Pencapaian", field: "achievement", align: "center" },
];

async function fetchData() {
  loading.value = true;
  try {
    const { data } = await axios.get(route("admin.distributor-target.data"), {
      params: {
        fiscal_year: filter.fiscal_year,
        distributor_id: filter.distributor_id || undefined,
        product_id: filter.product_id || undefined,
      },
    });

    rows.value = data.rows ?? [];
    summary.total_target = Number(data.total_target ?? 0);
    summary.total_actual = Number(data.total_actual ?? 0);
    summary.total_target_value = Number(data.total_target_value ?? 0);
    summary.total_actual_value = Number(data.total_actual_value ?? 0);
    summary.fiscal_year = Number(data.fiscal_year ?? filter.fiscal_year);
  } finally {
    loading.value = false;
  }
}

function buildExportUrl(format) {
  const query = new URLSearchParams();
  query.append("format", format);

  if (filter.fiscal_year) {
    query.append("fiscal_year", String(filter.fiscal_year));
  }
  if (filter.distributor_id) {
    query.append("distributor_id", String(filter.distributor_id));
  }
  if (filter.product_id) {
    query.append("product_id", String(filter.product_id));
  }

  return `${route("admin.distributor-target.export")}?${query.toString()}`;
}

function formatQty(value) {
  if (value === null || value === undefined) return "-";
  return Number(value).toLocaleString("id-ID", { minimumFractionDigits: 0, maximumFractionDigits: 2 });
}

function formatCurrency(value) {
  if (value === null || value === undefined) return "-";
  return Number(value).toLocaleString("id-ID", { minimumFractionDigits: 0, maximumFractionDigits: 0 });
}

function achievementColor(achievement) {
  if (achievement >= 100) return "positive";
  if (achievement >= 75) return "warning";
  return "negative";
}

function editRow(row) {
  router.get(route("admin.distributor-target.edit", row.id));
}

function deleteRow(row) {
  Dialog.create({
    title: "Konfirmasi",
    message: `Hapus target distributor ${row.distributor_name} untuk ${row.product_name}?`,
    cancel: true,
    persistent: true,
  }).onOk(async () => {
    try {
      const response = await axios.post(route("admin.distributor-target.delete", row.id));
      Notify.create({ type: "positive", message: response.data.message || "Target berhasil dihapus." });
      fetchData();
    } catch (error) {
      Notify.create({ type: "negative", message: error?.response?.data?.message || "Gagal menghapus target distributor." });
    }
  });
}

async function openBreakdown(row) {
  breakdownDialog.value = true;
  breakdownLoading.value = true;
  breakdownRows.value = [];
  breakdownTitle.value = "Breakdown Bulanan";
  breakdownSubtitle.value = `${row.distributor_name} - ${row.product_name}`;

  try {
    const { data } = await axios.get(route("admin.distributor-target.breakdown", row.id));
    breakdownTitle.value = data.title || "Breakdown Bulanan";
    breakdownSubtitle.value = data.subtitle || breakdownSubtitle.value;
    breakdownRows.value = data.rows || [];
  } catch (error) {
    Notify.create({
      type: "negative",
      message: error?.response?.data?.message || "Gagal memuat breakdown bulanan.",
    });
    breakdownDialog.value = false;
  } finally {
    breakdownLoading.value = false;
  }
}

function onRowClick(_evt, row) {
  openBreakdown(row);
}

onMounted(fetchData);

watch(filter, () => {
  storage.set("filter", filter);
  fetchData();
}, { deep: true });

watch(showFilter, () => storage.set("show-filter", showFilter.value));
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>
    <template #right-button>
      <q-btn
        v-if="$can('admin.distributor-target.add')"
        icon="add"
        dense
        color="primary"
        @click="router.get(route('admin.distributor-target.add'))"
      />
      <q-btn
        v-if="$can('admin.distributor-target.import')"
        class="q-ml-sm"
        icon="upload_file"
        dense
        color="secondary"
        @click="openImport"
      >
        <q-tooltip>Import CSV Target</q-tooltip>
      </q-btn>
      <q-btn
        v-if="$can('admin.distributor-target.export')"
        class="q-ml-sm"
        icon="file_export"
        dense
        color="grey-7"
        outline
      >
        <q-tooltip>Export</q-tooltip>
        <q-menu anchor="bottom right" self="top right">
          <q-list style="min-width: 180px">
            <q-item clickable v-ripple :href="buildExportUrl('pdf')" target="_blank">
              <q-item-section avatar>
                <q-icon name="picture_as_pdf" color="red-8" />
              </q-item-section>
              <q-item-section>Export PDF</q-item-section>
            </q-item>
            <q-item clickable v-ripple :href="buildExportUrl('excel')" target="_blank">
              <q-item-section avatar>
                <q-icon name="csv" color="green-8" />
              </q-item-section>
              <q-item-section>Export Excel</q-item-section>
            </q-item>
          </q-list>
        </q-menu>
      </q-btn>
      <q-btn
        class="q-ml-sm"
        :icon="!showFilter ? 'filter_alt' : 'filter_alt_off'"
        dense
        color="grey"
        @click="showFilter = !showFilter"
      />
    </template>

    <template #header v-if="showFilter">
      <q-toolbar class="filter-bar">
        <div class="row q-col-gutter-xs items-center q-pa-sm full-width">
          <q-select class="col-xs-12 col-sm-3" v-model="filter.fiscal_year" :options="fiscalYearOptions" emit-value map-options dense outlined label="Tahun Fiskal" />
          <q-select class="col-xs-12 col-sm-4" v-model="filter.distributor_id" :options="distributorOptions" emit-value map-options dense outlined label="Distributor" />
          <q-select class="col-xs-12 col-sm-4" v-model="filter.product_id" :options="productOptions" emit-value map-options dense outlined label="Produk" />
        </div>
      </q-toolbar>
    </template>

    <div class="q-pa-sm">
      <div class="row q-col-gutter-sm q-mb-sm">
        <div class="col-xs-12 col-sm-4">
          <q-card flat bordered>
            <q-card-section class="q-py-sm">
              <div class="text-caption text-grey-6">Total Target</div>
              <div class="text-h6 text-primary text-bold">{{ formatQty(summary.total_target) }} kg</div>
              <div class="text-caption text-grey-7">Rp {{ formatCurrency(summary.total_target_value) }}</div>
              <div class="text-caption text-grey-5">FY {{ summary.fiscal_year }}/{{ summary.fiscal_year + 1 }}</div>
            </q-card-section>
          </q-card>
        </div>
        <div class="col-xs-12 col-sm-4">
          <q-card flat bordered>
            <q-card-section class="q-py-sm">
              <div class="text-caption text-grey-6">Total Realisasi</div>
              <div class="text-h6 text-teal text-bold">{{ formatQty(summary.total_actual) }} kg</div>
              <div class="text-caption text-grey-7">Rp {{ formatCurrency(summary.total_actual_value) }}</div>
              <div class="text-caption text-grey-5">FY {{ summary.fiscal_year }}/{{ summary.fiscal_year + 1 }}</div>
            </q-card-section>
          </q-card>
        </div>
        <div class="col-xs-12 col-sm-4">
          <q-card flat bordered>
            <q-card-section class="q-py-sm">
              <div class="text-caption text-grey-6">Pencapaian</div>
              <div class="text-h6 text-bold" :class="achievementColor(summary.total_target > 0 ? (summary.total_actual / summary.total_target) * 100 : 0)">
                {{ summary.total_target > 0 ? ((summary.total_actual / summary.total_target) * 100).toFixed(1) + '%' : '-' }}
              </div>
              <div class="text-caption text-grey-5">Berdasarkan penjualan qty</div>
            </q-card-section>
          </q-card>
        </div>
      </div>

      <q-table flat bordered square dense row-key="id" :rows="rows" :columns="columns" :loading="loading" :pagination="{ rowsPerPage: 25 }" @row-click="onRowClick">
        <template #loading>
          <q-inner-loading showing color="primary" />
        </template>

        <template #no-data>
          <div class="full-width row flex-center text-grey-6 q-pa-md">
            Belum ada target distributor untuk FY {{ filter.fiscal_year }}/{{ filter.fiscal_year + 1 }}.
          </div>
        </template>

        <template #body-cell-total_target_qty="slotProps">
          <q-td :props="slotProps" class="text-right">{{ formatQty(slotProps.row.total_target_qty) }}</q-td>
        </template>

        <template #body-cell-total_actual_qty="slotProps">
          <q-td :props="slotProps" class="text-right">{{ formatQty(slotProps.row.total_actual_qty) }}</q-td>
        </template>

        <template #body-cell-total_target_value="slotProps">
          <q-td :props="slotProps" class="text-right">Rp {{ formatCurrency(slotProps.row.total_target_value) }}</q-td>
        </template>

        <template #body-cell-total_actual_value="slotProps">
          <q-td :props="slotProps" class="text-right">Rp {{ formatCurrency(slotProps.row.total_actual_value) }}</q-td>
        </template>

        <template v-for="(label, key) in monthLabels" #[`body-cell-${key}`]="slotProps" :key="key">
          <q-td :props="slotProps" class="text-right">{{ formatQty(slotProps.row[key]) }}</q-td>
        </template>

        <template #body-cell-achievement="slotProps">
          <q-td :props="slotProps" class="text-center">
            <q-badge :color="achievementColor(slotProps.row.achievement)">{{ slotProps.row.achievement }}%</q-badge>
          </q-td>
        </template>

        <template #body-cell-action="slotProps">
          <q-td :props="slotProps" class="text-right no-wrap">
            <q-btn v-if="$can('admin.distributor-target.edit')" flat dense round icon="edit" color="primary" @click.stop="editRow(slotProps.row)" />
            <q-btn v-if="$can('admin.distributor-target.delete')" flat dense round icon="delete" color="negative" @click.stop="deleteRow(slotProps.row)" />
          </q-td>
        </template>
      </q-table>
    </div>

    <q-dialog v-model="breakdownDialog" :maximized="$q.screen.lt.sm">
      <q-card :style="$q.screen.gt.xs ? 'width: 900px; max-width: 96vw' : 'width: 100%'">
        <q-card-section class="row items-center q-pb-none">
          <div>
            <div class="text-subtitle1 text-bold">{{ breakdownTitle }}</div>
            <div class="text-caption text-grey-7">{{ breakdownSubtitle }}</div>
          </div>
          <q-space />
          <q-btn icon="close" flat round dense @click="breakdownDialog = false" />
        </q-card-section>

        <q-card-section>
          <q-table
            flat
            bordered
            dense
            row-key="month_key"
            :rows="breakdownRows"
            :columns="breakdownColumns"
            :loading="breakdownLoading"
            :pagination="{ rowsPerPage: 12 }"
            hide-bottom
          >
            <template #body-cell-target_qty="slotProps">
              <q-td :props="slotProps" class="text-right">{{ formatQty(slotProps.row.target_qty) }}</q-td>
            </template>
            <template #body-cell-actual_qty="slotProps">
              <q-td :props="slotProps" class="text-right">{{ formatQty(slotProps.row.actual_qty) }}</q-td>
            </template>
            <template #body-cell-target_value="slotProps">
              <q-td :props="slotProps" class="text-right">Rp {{ formatCurrency(slotProps.row.target_value) }}</q-td>
            </template>
            <template #body-cell-actual_value="slotProps">
              <q-td :props="slotProps" class="text-right">Rp {{ formatCurrency(slotProps.row.actual_value) }}</q-td>
            </template>
            <template #body-cell-achievement="slotProps">
              <q-td :props="slotProps" class="text-center">
                <q-badge :color="achievementColor(slotProps.row.achievement)">{{ slotProps.row.achievement }}%</q-badge>
              </q-td>
            </template>
          </q-table>
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- Import Dialog -->
    <q-dialog v-model="importDialog" :maximized="$q.screen.lt.sm">
      <q-card :style="$q.screen.gt.xs ? 'width: 520px; max-width: 92vw' : 'width: 100%'">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-subtitle1 text-bold">Import Target Distributor dari CSV</div>
          <q-space />
          <q-btn icon="close" flat round dense @click="importDialog = false" />
        </q-card-section>

        <q-card-section>
          <q-file
            v-model="importFile"
            outlined
            accept=".csv,.txt,text/csv,text/plain,application/csv"
            label="Pilih file CSV"
            :disable="importing"
            clearable
          />
          <div class="q-mt-sm text-caption text-grey-7">
            Format kolom wajib: <b>Distributor, Tahun Fiskal, Varietas, Satuan, Bulan, Target</b>.<br />
            Kolom <b>Realisasi</b> akan ikut diimport jika tersedia.<br />
            Satu baris = satu bulan. Data akan di-<i>upsert</i> (ditambah atau diperbarui).
          </div>

          <!-- Result summary -->
          <q-banner
            v-if="importResult"
            class="q-mt-md rounded-borders"
            :class="(importResult.errors?.length ?? 0) > 0 ? 'bg-orange-1 text-orange-10' : 'bg-green-1 text-green-10'"
          >
            Berhasil: <strong>{{ importResult.created }}</strong> dibuat &nbsp;|
            <strong>{{ importResult.updated }}</strong> diperbarui
            <span v-if="(importResult.errors?.length ?? 0) > 0">
              &nbsp;| Error: <strong>{{ importResult.errors.length }}</strong>
            </span>
          </q-banner>

          <!-- Error list -->
          <q-list
            v-if="importResult?.errors?.length"
            bordered
            separator
            class="q-mt-sm"
            style="max-height: 220px; overflow: auto"
          >
            <q-item v-for="(err, idx) in importResult.errors" :key="idx">
              <q-item-section>
                <q-item-label caption class="text-red">{{ err }}</q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
        </q-card-section>

        <q-card-actions align="right" class="q-pb-md q-px-md">
          <q-btn flat label="Tutup" :disable="importing" @click="importDialog = false" />
          <q-btn
            color="primary"
            icon="upload"
            label="Import"
            :loading="importing"
            :disable="!importFile"
            class="full-width-xs"
            @click="submitImport"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </authenticated-layout>
</template>
