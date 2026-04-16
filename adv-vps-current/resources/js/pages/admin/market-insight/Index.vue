<script setup>
import { computed, onMounted, reactive, ref, watch } from "vue";
import { usePage } from "@inertiajs/vue3";
import { Dialog, Notify, useQuasar } from "quasar";
import axios from "axios";

const page = usePage();
const $q = useQuasar();

const title = "Market Insight";
const userRole = page.props.auth?.user?.role;

const nowMonth = new Date().getMonth() + 1;
const nowYear = new Date().getFullYear();
const thisFiscalYear = nowMonth >= 4 ? nowYear : nowYear - 1;

const filter = reactive({
  fiscal_year: Number(page.props.default_fiscal_year ?? thisFiscalYear),
  month: null,
  district_id: null,
  product_id: null,
  bs_user_id: null,
});

const loading = ref(false);
const saving = ref(false);
const rows = ref([]);
const summary = reactive({
  total_market_size_seed_kg: 0,
  total_actual_sales_seed_kg: 0,
  total_market_size_value: 0,
  total_potential_value: 0,
  avg_market_share_percent: 0,
  total_rows: 0,
});
const nationalSummary = reactive({
  total_market_size_seed_kg: 0,
  total_actual_sales_seed_kg: 0,
  total_market_size_value: 0,
  avg_market_share_percent: 0,
  total_rows: 0,
});

const dialog = ref(false);
const editingId = ref(null);
const form = reactive({
  district_id: null,
  product_id: null,
  fiscal_year: Number(page.props.default_fiscal_year ?? thisFiscalYear),
  month: null,
  market_size_seed_kg: null,
  price_per_kg: null,
  potential_value: null,
  potential_notes: "",
});

const totalMarketValueInput = computed(() => {
  const qty = Number(form.market_size_seed_kg || 0);
  const price = Number(form.price_per_kg || 0);
  return qty > 0 && price > 0 ? qty * price : 0;
});

const canSave = computed(() => page.props.auth?.permissions?.includes("admin.market-insight.save"));
const canDelete = computed(() => page.props.auth?.permissions?.includes("admin.market-insight.delete"));
const canFilterBs = computed(() => userRole !== "bs");

const fiscalYearOptions = computed(() => {
  const opts = [];
  for (let year = thisFiscalYear + 1; year >= thisFiscalYear - 3; year -= 1) {
    opts.push({ value: year, label: `FY ${year}/${year + 1}` });
  }
  return opts;
});

const monthOptions = [
  { value: null, label: "Semua Bulan" },
  { value: 1, label: "Januari" },
  { value: 2, label: "Februari" },
  { value: 3, label: "Maret" },
  { value: 4, label: "April" },
  { value: 5, label: "Mei" },
  { value: 6, label: "Juni" },
  { value: 7, label: "Juli" },
  { value: 8, label: "Agustus" },
  { value: 9, label: "September" },
  { value: 10, label: "Oktober" },
  { value: 11, label: "November" },
  { value: 12, label: "Desember" },
];

const districtOptions = computed(() => [
  { value: null, label: "Semua Kabupaten" },
  ...(page.props.districts ?? []).map((item) => ({
    value: item.id,
    label: item.province_name ? `${item.name} (${item.province_name})` : item.name,
  })),
]);

const formDistrictOptions = computed(() =>
  (page.props.districts ?? []).map((item) => ({
    value: item.id,
    label: item.province_name ? `${item.name} (${item.province_name})` : item.name,
  }))
);

const productOptions = computed(() => [
  { value: null, label: "Semua Produk" },
  ...(page.props.products ?? []).map((item) => ({ value: item.id, label: item.name })),
]);

const formProductOptions = computed(() =>
  (page.props.products ?? []).map((item) => ({ value: item.id, label: item.name }))
);

const bsUserOptions = computed(() => [
  { value: null, label: "Semua BS" },
  ...(page.props.bs_users ?? []).map((item) => ({ value: item.id, label: item.name })),
]);

const monthMap = {
  1: "Januari",
  2: "Februari",
  3: "Maret",
  4: "April",
  5: "Mei",
  6: "Juni",
  7: "Juli",
  8: "Agustus",
  9: "September",
  10: "Oktober",
  11: "November",
  12: "Desember",
};

const columns = [
  { name: "bs_user_name", label: "BS", field: "bs_user_name", align: "left" },
  { name: "district_name", label: "Kabupaten", field: "district_name", align: "left" },
  { name: "province_name", label: "Provinsi", field: "province_name", align: "left" },
  { name: "product_name", label: "Produk", field: "product_name", align: "left" },
  { name: "fiscal_year", label: "Tahun Fiskal", field: (r) => `FY ${r.fiscal_year}/${Number(r.fiscal_year) + 1}`, align: "left" },
  { name: "month", label: "Bulan", field: (r) => (r.month ? monthMap[r.month] : "Semua Bulan"), align: "left" },
  { name: "market_size_seed_kg", label: "Market Size (Kg/Tahun)", field: "market_size_seed_kg", align: "right" },
  { name: "actual_sales_seed_kg", label: "Realisasi Jual (Kg)", field: "actual_sales_seed_kg", align: "right" },
  { name: "market_size_value", label: "Estimasi Nilai (Rp)", field: "market_size_value", align: "right" },
  { name: "market_share_percent", label: "Market Share Otomatis (%)", field: "market_share_percent", align: "right" },
  { name: "potential_value", label: "Potensi (Rp)", field: "potential_value", align: "right" },
  { name: "potential_notes", label: "Catatan Potensi", field: "potential_notes", align: "left" },
  { name: "action", label: "", field: "action", align: "right" },
];

function formatKg(val) {
  return Number(val || 0).toLocaleString("id-ID", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  });
}

function formatCurrency(val) {
  return Number(val || 0).toLocaleString("id-ID", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  });
}

function formatPercent(val) {
  return Number(val || 0).toLocaleString("id-ID", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  });
}

function resetForm() {
  editingId.value = null;
  form.district_id = null;
  form.product_id = null;
  form.fiscal_year = Number(filter.fiscal_year || page.props.default_fiscal_year || thisFiscalYear);
  form.month = null;
  form.market_size_seed_kg = null;
  form.price_per_kg = null;
  form.potential_value = null;
  form.potential_notes = "";
}

function getProductPrice(productId) {
  const product = (page.props.products ?? []).find((item) => Number(item.id) === Number(productId));
  return Number(product?.price_1 || product?.price_2 || 0);
}

function openAddDialog() {
  resetForm();
  dialog.value = true;
}

function openEditDialog(row) {
  editingId.value = row.id;
  form.district_id = row.district_id;
  form.product_id = row.product_id;
  form.fiscal_year = row.fiscal_year;
  form.month = row.month;
  form.market_size_seed_kg = row.market_size_seed_kg;
  form.price_per_kg = row.reference_price_per_kg || getProductPrice(row.product_id);
  form.potential_value = null;
  form.potential_notes = "";
  dialog.value = true;
}

async function fetchData() {
  loading.value = true;
  try {
    const { data } = await axios.get(route("admin.market-insight.data"), {
      params: {
        fiscal_year: filter.fiscal_year,
        month: filter.month || undefined,
        district_id: filter.district_id || undefined,
        product_id: filter.product_id || undefined,
        bs_user_id: canFilterBs.value ? (filter.bs_user_id || undefined) : undefined,
      },
    });

    rows.value = data.rows || [];
    summary.total_market_size_seed_kg = Number(data.summary?.total_market_size_seed_kg || 0);
    summary.total_actual_sales_seed_kg = Number(data.summary?.total_actual_sales_seed_kg || 0);
    summary.total_market_size_value = Number(data.summary?.total_market_size_value || 0);
    summary.total_potential_value = Number(data.summary?.total_potential_value || 0);
    summary.avg_market_share_percent = Number(data.summary?.avg_market_share_percent || 0);
    summary.total_rows = Number(data.summary?.total_rows || 0);

    nationalSummary.total_market_size_seed_kg = Number(data.national_summary?.total_market_size_seed_kg || 0);
    nationalSummary.total_actual_sales_seed_kg = Number(data.national_summary?.total_actual_sales_seed_kg || 0);
    nationalSummary.total_market_size_value = Number(data.national_summary?.total_market_size_value || 0);
    nationalSummary.avg_market_share_percent = Number(data.national_summary?.avg_market_share_percent || 0);
    nationalSummary.total_rows = Number(data.national_summary?.total_rows || 0);
  } catch (error) {
    Notify.create({
      type: "negative",
      message: error?.response?.data?.message || "Gagal memuat data market insight.",
    });
  } finally {
    loading.value = false;
  }
}

async function saveData() {
  saving.value = true;
  try {
    await axios.post(route("admin.market-insight.save"), {
      id: editingId.value,
      district_id: form.district_id,
      product_id: form.product_id,
      fiscal_year: form.fiscal_year || filter.fiscal_year,
      month: form.month,
      market_size_seed_kg: form.market_size_seed_kg,
      price_per_kg: form.price_per_kg,
      potential_value: form.potential_value,
      potential_notes: form.potential_notes,
    });

    Notify.create({
      type: "positive",
      message: editingId.value ? "Data market berhasil diperbarui." : "Data market berhasil ditambahkan.",
    });

    dialog.value = false;
    fetchData();
  } catch (error) {
    const msg = error?.response?.data?.errors
      ? Object.values(error.response.data.errors)[0]?.[0]
      : error?.response?.data?.message;

    Notify.create({
      type: "negative",
      message: msg || "Gagal menyimpan data market insight.",
    });
  } finally {
    saving.value = false;
  }
}

function deleteRow(row) {
  Dialog.create({
    title: "Konfirmasi",
    message: "Hapus data market insight ini?",
    cancel: true,
    persistent: true,
  }).onOk(async () => {
    try {
      await axios.post(route("admin.market-insight.delete", row.id));
      Notify.create({ type: "positive", message: "Data market berhasil dihapus." });
      fetchData();
    } catch (error) {
      Notify.create({
        type: "negative",
        message: error?.response?.data?.message || "Gagal menghapus data market insight.",
      });
    }
  });
}

onMounted(fetchData);

watch(filter, fetchData, { deep: true });

watch(
  () => form.product_id,
  (newProductId) => {
    if (!newProductId) {
      form.price_per_kg = null;
      return;
    }
    if (!editingId.value || !form.price_per_kg) {
      form.price_per_kg = getProductPrice(newProductId);
    }
  }
);
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>
    <template #right-button>
      <q-btn
        v-if="canSave"
        icon="add"
        color="primary"
        dense
        @click="openAddDialog"
      />
    </template>

    <template #header>
      <q-toolbar class="filter-bar">
        <div class="row q-col-gutter-sm full-width q-pa-sm">
          <q-select
            class="col-12 col-md-3"
            v-model="filter.fiscal_year"
            :options="fiscalYearOptions"
            dense
            outlined
            emit-value
            map-options
            label="Tahun Fiskal"
          />
          <q-select
            class="col-12 col-md-3"
            v-model="filter.month"
            :options="monthOptions"
            dense
            outlined
            emit-value
            map-options
            label="Bulan"
          />
          <q-select
            class="col-12 col-md-3"
            v-model="filter.district_id"
            :options="districtOptions"
            dense
            outlined
            emit-value
            map-options
            label="Kabupaten"
          />
          <q-select
            class="col-12 col-md-3"
            v-model="filter.product_id"
            :options="productOptions"
            dense
            outlined
            emit-value
            map-options
            label="Produk"
          />
          <q-select
            v-if="canFilterBs"
            class="col-12 col-md-3"
            v-model="filter.bs_user_id"
            :options="bsUserOptions"
            dense
            outlined
            emit-value
            map-options
            label="BS"
          />
        </div>
      </q-toolbar>
    </template>

    <div class="q-pa-sm">
      <div class="market-header market-header-local q-mb-sm">
        <div>
          <div class="text-subtitle1 text-weight-bold">Total Market Size</div>
          <div class="text-caption market-header-subtitle">Nilai pasar keseluruhan (Rp) berdasarkan filter aktif</div>
        </div>
        <div class="text-h5 text-weight-bold">Rp {{ formatCurrency(summary.total_market_size_value) }}</div>
      </div>

      <div class="market-header market-header-indonesia q-mb-sm">
        <div>
          <div class="text-subtitle1 text-weight-bold">Indonesian Market Size</div>
          <div class="text-caption market-header-subtitle">Akumulasi nasional untuk tahun fiskal dan produk terpilih</div>
        </div>
        <div class="text-h5 text-weight-bold">Rp {{ formatCurrency(nationalSummary.total_market_size_value) }}</div>
      </div>

      <div class="row q-col-gutter-sm q-mb-sm">
        <div class="col-12 col-md-3">
          <q-card flat bordered>
            <q-card-section>
              <div class="text-caption text-grey-7">Total Market Size Benih</div>
              <div class="text-h6 text-weight-bold">{{ formatKg(summary.total_market_size_seed_kg) }} Kg</div>
            </q-card-section>
          </q-card>
        </div>
        <div class="col-12 col-md-3">
          <q-card flat bordered>
            <q-card-section>
              <div class="text-caption text-grey-7">Realisasi Jual Benih</div>
              <div class="text-h6 text-weight-bold">{{ formatKg(summary.total_actual_sales_seed_kg) }} Kg</div>
            </q-card-section>
          </q-card>
        </div>
        <div class="col-12 col-md-3">
          <q-card flat bordered>
            <q-card-section>
              <div class="text-caption text-grey-7">Market Share (Filter Aktif)</div>
              <div class="text-h6 text-weight-bold">{{ formatPercent(summary.avg_market_share_percent) }}%</div>
            </q-card-section>
          </q-card>
        </div>
        <div class="col-12 col-md-3">
          <q-card flat bordered>
            <q-card-section>
              <div class="text-caption text-grey-7">Jumlah Data</div>
              <div class="text-h6 text-weight-bold">{{ summary.total_rows }}</div>
            </q-card-section>
          </q-card>
        </div>
      </div>

      <div class="row q-col-gutter-sm q-mb-sm">
        <div class="col-12 col-md-4">
          <q-card flat bordered>
            <q-card-section>
              <div class="text-caption text-grey-7">Market Size Nasional (Kg)</div>
              <div class="text-h6 text-weight-bold">{{ formatKg(nationalSummary.total_market_size_seed_kg) }} Kg</div>
            </q-card-section>
          </q-card>
        </div>
        <div class="col-12 col-md-4">
          <q-card flat bordered>
            <q-card-section>
              <div class="text-caption text-grey-7">Realisasi Jual Nasional (Kg)</div>
              <div class="text-h6 text-weight-bold">{{ formatKg(nationalSummary.total_actual_sales_seed_kg) }} Kg</div>
            </q-card-section>
          </q-card>
        </div>
        <div class="col-12 col-md-4">
          <q-card flat bordered>
            <q-card-section>
              <div class="text-caption text-grey-7">Market Share Nasional</div>
              <div class="text-h6 text-weight-bold">{{ formatPercent(nationalSummary.avg_market_share_percent) }}%</div>
            </q-card-section>
          </q-card>
        </div>
      </div>

      <q-table
        flat
        bordered
        dense
        row-key="id"
        :rows="rows"
        :columns="columns"
        :loading="loading"
        :pagination="{ rowsPerPage: 15 }"
      >
        <template #body-cell-market_size_value="slotProps">
          <q-td :props="slotProps" class="text-right">Rp {{ formatCurrency(slotProps.row.market_size_value) }}</q-td>
        </template>
        <template #body-cell-market_size_seed_kg="slotProps">
          <q-td :props="slotProps" class="text-right">{{ formatKg(slotProps.row.market_size_seed_kg) }} Kg</q-td>
        </template>
        <template #body-cell-actual_sales_seed_kg="slotProps">
          <q-td :props="slotProps" class="text-right">{{ formatKg(slotProps.row.actual_sales_seed_kg) }} Kg</q-td>
        </template>
        <template #body-cell-market_share_percent="slotProps">
          <q-td :props="slotProps" class="text-right">{{ formatPercent(slotProps.row.market_share_percent) }}%</q-td>
        </template>
        <template #body-cell-potential_value="slotProps">
          <q-td :props="slotProps" class="text-right">Rp {{ formatCurrency(slotProps.row.potential_value) }}</q-td>
        </template>
        <template #body-cell-action="slotProps">
          <q-td :props="slotProps" class="text-right no-wrap">
            <q-btn v-if="canSave" flat dense round icon="edit" color="primary" @click="openEditDialog(slotProps.row)" />
            <q-btn v-if="canDelete" flat dense round icon="delete" color="negative" @click="deleteRow(slotProps.row)" />
          </q-td>
        </template>
      </q-table>
    </div>

    <q-dialog v-model="dialog" persistent>
      <q-card class="simple-market-dialog" style="min-width: 560px; max-width: 96vw">
        <q-card-section class="text-h6 text-weight-bold text-white q-pb-sm">
          {{ editingId ? "Edit Data Market Size" : "Tambah Data Market Size" }}
        </q-card-section>

        <q-card-section class="row q-col-gutter-sm">
          <q-select
            class="col-12"
            v-model="form.district_id"
            :options="formDistrictOptions"
            dense
            outlined
            emit-value
            map-options
            label="Kabupaten"
          />
          <q-select
            class="col-12"
            v-model="form.product_id"
            :options="formProductOptions"
            dense
            outlined
            emit-value
            map-options
            label="Crop"
          />
          <q-input
            class="col-12 col-md-4"
            v-model.number="form.market_size_seed_kg"
            type="number"
            min="0"
            step="0.01"
            dense
            outlined
            label="Qty (kg)"
          />
          <q-input
            class="col-12 col-md-4"
            v-model.number="form.price_per_kg"
            type="number"
            min="0"
            step="0.01"
            dense
            outlined
            label="Harga per kg (Rp)"
          />
          <q-input
            class="col-12 col-md-4"
            :model-value="formatCurrency(totalMarketValueInput)"
            readonly
            dense
            outlined
            label="Total (Rp)"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat class="simple-cancel-btn" label="Batal" v-close-popup />
          <q-btn color="primary" label="Simpan" :loading="saving" @click="saveData" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </authenticated-layout>
</template>

<style scoped>
.market-header {
  border-radius: 10px;
  padding: 16px;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.market-header-local {
  background: #1e3a8a;
}

.market-header-indonesia {
  background: #1d4e89;
}

.market-header-subtitle {
  color: #dbeafe;
}

.simple-market-dialog {
  background: #0b2340;
  color: #e8f0ff;
}

.simple-market-dialog :deep(.q-field__native),
.simple-market-dialog :deep(.q-field__input),
.simple-market-dialog :deep(.q-field__label),
.simple-market-dialog :deep(.q-field__marginal) {
  color: #0f172a;
}

.simple-market-dialog :deep(.q-field--outlined .q-field__control) {
  background: #ffffff;
}

.simple-cancel-btn {
  background: #e5e7eb;
  color: #0f172a;
}

@media (max-width: 767px) {
  .market-header {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
