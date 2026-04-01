<script setup>
import { computed, nextTick, onMounted, reactive, ref, watch } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import { Dialog, Notify, useQuasar } from "quasar";
import axios from "axios";
import { formatDate } from "@/helpers/datetime";
import { create_month_options, formatNumber } from "@/helpers/utils";
import { usePageStorage } from "@/helpers/usePageStorage";
import useTableHeight from "@/composables/useTableHeight";

const page = usePage();
const $q = useQuasar();
const isBsInbox = !!page.props.bs_inbox;
const storage = usePageStorage(isBsInbox ? "sale-bs-inbox-v1" : "sale-v2");

const title = isBsInbox ? "Review Penjualan BS" : "Penjualan";
const rows = ref([]);
const loading = ref(false);
const totalSalesSum = ref(0);
const totalQtySum = ref(0);
const byDistributor = ref([]);
const byRetailer = ref([]);
const tableRef = ref(null);
const showFilter = ref(storage.get("show-filter", true));
const showSummary = ref(storage.get("show-summary", true));
const filterToolbarRef = ref(null);
const tableHeight = useTableHeight(filterToolbarRef);

const importDialog = ref(false);
const importing = ref(false);
const importFile = ref(null);
const importResult = ref(null);
const releaseDialog = ref(false);
const releasing = ref(false);
const releaseSale = ref(null);
const releaseItems = ref([]);
const distributorDetailDialog = ref(false);
const distributorDetailLoading = ref(false);
const distributorDetailRows = ref([]);
const distributorDetailSummary = reactive({
  distributor_name: "",
  total_amount: 0,
  total_qty: 0,
  total_rows: 0,
});

const now = new Date();
const thisFiscalYear = now.getMonth() + 1 >= 4 ? now.getFullYear() : now.getFullYear() - 1;
const userRole = page.props.auth?.user?.role || "";
const isAgronomist = computed(() => userRole === "agronomist");
const isBS = computed(() => {
  const role = String(userRole || "").toLowerCase();
  return role === "bs" || role === "field_officer";
});
const canFilterByBs = computed(() => userRole === "admin" || userRole === "agronomist");
const canForceDelete = computed(() => userRole === "admin" || userRole === "agronomist");
const isMobileView = computed(() => $q.screen.lt.md);

const filter = reactive(
  storage.get("filter", {
    search: "",
    status: null,
    distributor_id: null,
    retailer_id: null,
    bs_user_id: null,
    fiscal_year: null,
    month: null,
  })
);

const pagination = ref(
  storage.get("pagination", {
    page: 1,
    rowsPerPage: 10,
    rowsNumber: 0,
    sortBy: "date",
    descending: true,
  })
);

const columns = [
  {
    name: "date",
    label: $q.screen.gt.sm ? "Tanggal" : "Penjualan",
    field: "date",
    align: "left",
    sortable: true,
  },
  {
    name: "sale_type",
    label: "Jenis",
    field: "sale_type",
    align: "left",
    sortable: true,
  },
  {
    name: "status",
    label: "Status",
    field: "status",
    align: "left",
    sortable: true,
  },
  {
    name: "distributor",
    label: "Distributor",
    field: "distributor",
    align: "left",
    sortable: false,
  },
  {
    name: "retailer",
    label: "R1/R2",
    field: "retailer",
    align: "left",
    sortable: false,
  },
  {
    name: "total_amount",
    label: "Total (Rp)",
    field: "total_amount",
    align: "right",
    sortable: true,
  },
  {
    name: "created_by_user",
    label: "Input By",
    field: "created_by_user",
    align: "left",
  },
  { name: "action", align: "right" },
];

const fiscalYearOptions = computed(() => {
  const out = [{ value: null, label: "Semua FY" }];
  for (let i = 0; i < 8; i++) {
    const fy = thisFiscalYear - i;
    out.push({ value: fy, label: `FY ${fy}/${fy + 1}` });
  }
  return out;
});

const monthOptions = computed(() => [{ value: null, label: "Semua Bulan" }, ...create_month_options()]);
const statusOptions = [
  { value: null, label: "Semua Status" },
  { value: "released", label: "Released" },
  { value: "pending", label: "Pending (PO)" },
];

const distributorOptions = computed(() => [
  { value: null, label: "Semua Distributor" },
  ...(page.props.distributors || []).map((item) => ({ value: item.id, label: item.name })),
]);

const retailerOptions = computed(() => [
  { value: null, label: "Semua R1/R2" },
  ...(page.props.retailers || []).map((item) => ({ value: item.id, label: `${item.name} (${item.type})` })),
]);

const filteredRetailerOptions = computed(() => {
  const selectedBsUserId = Number(filter.bs_user_id || 0);
  const baseRetailers = (page.props.retailers || []).filter((item) => {
    if (!selectedBsUserId || !canFilterByBs.value) return true;
    return Number(item.created_by_uid || 0) === selectedBsUserId
      || Number(item.assigned_user_id || 0) === selectedBsUserId;
  });

  return [
    { value: null, label: "Semua R1/R2" },
    ...baseRetailers.map((item) => ({ value: item.id, label: `${item.name} (${item.type})` })),
  ];
});

const bsOptions = computed(() => [
  { value: null, label: "Semua BS" },
  ...(page.props.bs_users || []).map((item) => ({
    value: item.id,
    label: item.username ? `${item.name} (${item.username})` : item.name,
  })),
]);

const computedColumns = computed(() => {
  const baseColumns = isAgronomist.value
    ? columns.filter((col) => col.name !== "retailer")
    : columns;

  if ($q.screen.gt.sm) return baseColumns;
  return baseColumns.filter((col) => ["date", "total_amount", "action"].includes(col.name));
});

const distributorDetailColumns = computed(() => {
  const cols = [
    { name: "date", label: "Tanggal", field: "date", align: "left" },
    { name: "sale_type", label: "Jenis", field: "sale_type", align: "left" },
    { name: "notes", label: "Sumber", field: "notes", align: "left" },
    { name: "total_amount", label: "Nilai (Rp)", field: "total_amount", align: "right" },
  ];

  if (!isAgronomist.value) {
    cols.splice(2, 0, { name: "retailer", label: "R1/R2", field: (r) => r.retailer?.name || "-", align: "left" });
  }

  return cols;
});

const distributorColumns = [
  { name: "distributor_name", label: "Distributor", field: "distributor_name", align: "left" },
  { name: "total_rows", label: "Jumlah Data", field: "total_rows", align: "center" },
  { name: "total_qty", label: "Total Qty", field: "total_qty", align: "right" },
  { name: "total_amount", label: "Total Nilai (Rp)", field: "total_amount", align: "right" },
];

const retailerSummaryColumns = [
  { name: "retailer_name", label: "R1/R2", field: "retailer_name", align: "left" },
  { name: "retailer_type", label: "Tipe", field: "retailer_type", align: "center" },
  { name: "total_rows", label: "Jumlah Data", field: "total_rows", align: "center" },
  { name: "total_qty", label: "Total Qty", field: "total_qty", align: "right" },
  { name: "total_amount", label: "Total Nilai (Rp)", field: "total_amount", align: "right" },
];

const rowsPerPageOptions = [
  { label: "10 / halaman", value: 10 },
  { label: "25 / halaman", value: 25 },
  { label: "50 / halaman", value: 50 },
];

const totalPages = computed(() => {
  const perPage = Number(pagination.value.rowsPerPage || 10);
  const total = Number(pagination.value.rowsNumber || 0);
  return Math.max(1, Math.ceil(total / perPage));
});

const isTargetImport = (row) => {
  const notes = String(row?.notes || "");
  return notes.startsWith("[TARGET_IMPORT]");
};

const saleTypeLabel = (row) => {
  if (row?.sale_type === "retailer" && (isBS.value || !isTargetImport(row))) return "Retailer";
  return "Distributor";
};

const statusLabel = (row) =>
  row?.status === "released" ? "Released" : "Pending";

const statusColor = (row) =>
  row?.status === "released" ? "positive" : "warning";

const isPending = (row) => row?.status === "pending";

const effectiveRetailerId = computed(() => (isAgronomist.value ? null : filter.retailer_id));

const buildParams = (sourcePagination) => ({
  page: sourcePagination.page,
  per_page: sourcePagination.rowsPerPage,
  order_by: sourcePagination.sortBy || "date",
  order_type: sourcePagination.descending ? "desc" : "asc",
  filter: {
    search: filter.search,
    status: filter.status,
    distributor_id: isBS.value ? null : filter.distributor_id,
    retailer_id: effectiveRetailerId.value,
    bs_user_id: canFilterByBs.value ? filter.bs_user_id : null,
    fiscal_year: filter.fiscal_year,
    month: filter.month,
    bs_only: isBsInbox ? 1 : null,
  },
});

const fetchItems = async (props = null) => {
  const source = props ? props.pagination : pagination.value;
  loading.value = true;
  try {
    const response = await axios.get(route("admin.sale.data"), {
      params: buildParams(source),
    });

    rows.value = response.data.data || [];
    totalSalesSum.value = Number(response.data.total_sales_sum || 0);
    totalQtySum.value = Number(response.data.total_qty_sum || 0);
    byDistributor.value = response.data.by_distributor || [];
    byRetailer.value = response.data.by_retailer || [];

    pagination.value.page = response.data.current_page;
    pagination.value.rowsPerPage = response.data.per_page;
    pagination.value.rowsNumber = response.data.total;

    if (props) {
      pagination.value.sortBy = source.sortBy;
      pagination.value.descending = source.descending;
    }
  } finally {
    loading.value = false;
    nextTick(() => {
      const scrollableElement = tableRef.value?.$el?.querySelector(".q-table__middle");
      if (scrollableElement) scrollableElement.scrollTop = 0;
    });
  }
};

const openDistributorDetail = async (row) => {
  distributorDetailDialog.value = true;
  distributorDetailLoading.value = true;
  distributorDetailRows.value = [];
  distributorDetailSummary.distributor_name = row.distributor_name || "-";
  distributorDetailSummary.total_amount = Number(row.total_amount || 0);
  distributorDetailSummary.total_qty = Number(row.total_qty || 0);
  distributorDetailSummary.total_rows = Number(row.total_rows || 0);

  try {
    const response = await axios.get(route("admin.sale.distributor-detail"), {
      params: {
        distributor_id: row.distributor_id,
        filter: {
          search: filter.search,
          status: filter.status,
          distributor_id: filter.distributor_id,
          retailer_id: effectiveRetailerId.value,
          bs_user_id: canFilterByBs.value ? filter.bs_user_id : null,
          fiscal_year: filter.fiscal_year,
          month: filter.month,
        },
      },
    });

    distributorDetailRows.value = response.data.rows || [];
    distributorDetailSummary.total_amount = Number(response.data.total_amount || distributorDetailSummary.total_amount);
    distributorDetailSummary.total_qty = Number(response.data.total_qty || distributorDetailSummary.total_qty);
    distributorDetailSummary.total_rows = Number(response.data.total_rows || distributorDetailSummary.total_rows);
  } catch (error) {
    Notify.create({
      message: error?.response?.data?.message || "Gagal memuat detail distributor",
      color: "negative",
    });
  } finally {
    distributorDetailLoading.value = false;
  }
};

const onFilterChange = () => {
  pagination.value.page = 1;
  fetchItems();
};

const onBsFilterChange = () => {
  const retailerStillExists = filteredRetailerOptions.value.some(
    (item) => item.value === filter.retailer_id
  );

  if (!retailerStillExists) {
    filter.retailer_id = null;
  }

  onFilterChange();
};

const onMobilePageChange = (pageNumber) => {
  pagination.value.page = pageNumber;
  fetchItems();
};

const onMobileRowsPerPageChange = (rowsPerPage) => {
  pagination.value.rowsPerPage = rowsPerPage;
  pagination.value.page = 1;
  fetchItems();
};

const onRowClicked = (row) => {
  router.get(route("admin.sale.detail", { id: row.id }));
};

const deleteItem = (row) => {
  const isReleased = !isPending(row);
  Dialog.create({
    title: "Konfirmasi Hapus",
    message: isReleased
      ? `Penjualan #${row.id} sudah RELEASED. Menghapus akan membalik stok terkait. Yakin ingin menghapus?`
      : `Hapus data penjualan #${row.id}?`,
    cancel: true,
    persistent: true,
  }).onOk(async () => {
    loading.value = true;
    try {
      const response = await axios.post(route("admin.sale.delete", row.id));
      Notify.create({ message: response.data.message || "Berhasil dihapus", color: "positive" });
      await fetchItems();
    } catch (error) {
      Notify.create({
        message: error?.response?.data?.message || "Gagal menghapus data",
        color: "negative",
      });
    } finally {
      loading.value = false;
    }
  });
};

const openReleaseDialog = async (row) => {
  try {
    const response = await axios.get(route("admin.sale.release-data", row.id));
    const data = response.data?.data;
    if (!data) return;

    releaseSale.value = data;
    releaseItems.value = (data.items || []).map((item) => ({
      id: item.id,
      product_name: item.product_name,
      quantity: item.quantity,
      quantity_release: item.quantity,
      unit: item.unit,
      remaining_stock: null,
      lot_number: item.lot_number || "",
      expired_date: item.expired_date || null,
    }));
    releaseDialog.value = true;
  } catch (error) {
    Notify.create({
      message: error?.response?.data?.message || "Gagal memuat data release",
      color: "negative",
    });
  }
};

const submitRelease = async () => {
  if (!releaseSale.value) return;

  for (const item of releaseItems.value) {
    const qtyPo = Number(item.quantity || 0);
    const qtyRelease = Number(item.quantity_release || 0);
    if (qtyRelease <= 0) {
      Notify.create({
        message: `Qty release untuk ${item.product_name || "item"} harus lebih dari 0`,
        color: "warning",
      });
      return;
    }
    if (qtyRelease > qtyPo) {
      Notify.create({
        message: `Qty release ${item.product_name || "item"} tidak boleh melebihi qty PO`,
        color: "warning",
      });
      return;
    }
  }

  releasing.value = true;
  try {
    const response = await axios.post(route("admin.sale.release", releaseSale.value.id), {
      items: releaseItems.value.map((item) => ({
        id: item.id,
        quantity: Number(item.quantity_release || 0),
        remaining_stock: item.remaining_stock === null || item.remaining_stock === ""
          ? null
          : Number(item.remaining_stock),
        lot_number: item.lot_number?.trim() || null,
        expired_date: item.expired_date || null,
      })),
    });

    Notify.create({
      message: response.data?.message || "Berhasil release",
      color: "positive",
    });

    releaseDialog.value = false;
    releaseSale.value = null;
    releaseItems.value = [];
    await fetchItems();
  } catch (error) {
    Notify.create({
      message: error?.response?.data?.message || "Gagal release data",
      color: "negative",
    });
  } finally {
    releasing.value = false;
  }
};

const openImportDialog = () => {
  importFile.value = null;
  importResult.value = null;
  importDialog.value = true;
};

const submitImport = async () => {
  if (!importFile.value) {
    Notify.create({ message: "Pilih file Excel terlebih dahulu", color: "warning" });
    return;
  }

  importing.value = true;
  try {
    const formData = new FormData();
    formData.append("file", importFile.value);

    const response = await axios.post(route("admin.sale.import"), formData, {
      headers: { "Content-Type": "multipart/form-data" },
    });

    importResult.value = response.data;

    const errorCount = response.data.errors?.length || 0;
    const successCount = Number(response.data.success || 0);
    Notify.create({
      message: `Import selesai. Berhasil: ${successCount}, Error: ${errorCount}`,
      color: errorCount > 0 ? "warning" : "positive",
    });

    if (successCount > 0) {
      await fetchItems();
    }
  } catch (error) {
    const message =
      error?.response?.data?.errors?.[0] ||
      error?.response?.data?.message ||
      "Import gagal";
    Notify.create({ message, color: "negative" });
  } finally {
    importing.value = false;
  }
};

const buildExportUrl = (format) => {
  const query = new URLSearchParams();
  query.append("format", format);

  const f = {
    search: filter.search,
    status: filter.status,
    distributor_id: isBS.value ? null : filter.distributor_id,
    retailer_id: effectiveRetailerId.value,
    bs_user_id: canFilterByBs.value ? filter.bs_user_id : null,
    fiscal_year: filter.fiscal_year,
    month: filter.month,
    bs_only: isBsInbox ? 1 : null,
  };

  Object.entries(f).forEach(([key, value]) => {
    if (value !== null && value !== "") {
      query.append(`filter[${key}]`, String(value));
    }
  });

  return `${route("admin.sale.export")}?${query.toString()}`;
};

onMounted(fetchItems);

watch(filter, () => storage.set("filter", filter), { deep: true });
watch(showFilter, () => storage.set("show-filter", showFilter.value));
watch(showSummary, () => storage.set("show-summary", showSummary.value));
watch(pagination, () => storage.set("pagination", pagination.value), { deep: true });
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>

    <template #right-button>
      <div class="sales-actions">
        <q-btn
          v-if="$can('admin.sale.add') && !isBsInbox"
          icon="add"
          :label="isMobileView ? '' : 'Tambah'"
          no-caps
          :dense="isMobileView"
          color="primary"
          class="action-btn"
          @click="router.get(route('admin.sale.add'))"
        >
          <q-tooltip v-if="isMobileView">Tambah</q-tooltip>
        </q-btn>

        <q-btn
          class="action-btn"
          :icon="!showFilter ? 'filter_alt' : 'filter_alt_off'"
          :label="isMobileView ? '' : showFilter ? 'Sembunyikan Filter' : 'Tampilkan Filter'"
          :dense="isMobileView"
          color="grey-7"
          outline
          no-caps
          @click="showFilter = !showFilter"
        >
          <q-tooltip v-if="isMobileView">Filter</q-tooltip>
        </q-btn>

        <q-btn
          v-if="$can('admin.sale.import-template') && !isBsInbox"
          class="action-btn"
          icon="download"
          :label="isMobileView ? '' : 'Template'"
          :dense="isMobileView"
          color="grey-7"
          outline
          no-caps
          :href="route('admin.sale.import-template')"
          target="_blank"
        >
          <q-tooltip>Template Import</q-tooltip>
        </q-btn>

        <q-btn
          v-if="$can('admin.sale.import') && !isBsInbox"
          class="action-btn"
          icon="upload_file"
          :label="isMobileView ? '' : 'Import'"
          :dense="isMobileView"
          color="grey-7"
          outline
          no-caps
          @click="openImportDialog"
        >
          <q-tooltip>Import Penjualan</q-tooltip>
        </q-btn>

        <q-btn
          class="action-btn"
          icon="file_export"
          :label="isMobileView ? '' : 'Export'"
          :dense="isMobileView"
          color="grey-7"
          outline
          no-caps
        >
          <q-tooltip v-if="isMobileView">Export</q-tooltip>
          <q-menu anchor="bottom right" self="top right">
            <q-list style="min-width: 190px">
              <q-item clickable v-ripple :href="buildExportUrl('pdf')">
                <q-item-section avatar>
                  <q-icon name="picture_as_pdf" color="red-8" />
                </q-item-section>
                <q-item-section>Export PDF</q-item-section>
              </q-item>
              <q-item clickable v-ripple :href="buildExportUrl('excel')">
                <q-item-section avatar>
                  <q-icon name="csv" color="green-8" />
                </q-item-section>
                <q-item-section>Export Excel</q-item-section>
              </q-item>
            </q-list>
          </q-menu>
        </q-btn>
      </div>
    </template>

    <template #header v-if="showFilter">
      <div class="filter-shell q-mx-sm q-mt-sm" ref="filterToolbarRef">
        <div class="row q-col-gutter-sm items-center">
          <q-select
            class="custom-select col-12 col-sm-6 col-md-2"
            v-model="filter.fiscal_year"
            :options="fiscalYearOptions"
            label="Fiscal Year"
            dense
            outlined
            map-options
            emit-value
            @update:model-value="onFilterChange"
          />

          <q-select
            class="custom-select col-12 col-sm-6 col-md-2"
            v-model="filter.month"
            :options="monthOptions"
            label="Bulan"
            dense
            outlined
            map-options
            emit-value
            @update:model-value="onFilterChange"
          />

          <q-select
            class="custom-select col-12 col-sm-6 col-md-2"
            v-model="filter.status"
            :options="statusOptions"
            label="Status"
            dense
            outlined
            map-options
            emit-value
            @update:model-value="onFilterChange"
          />

          <q-select
            class="custom-select col-12 col-sm-6 col-md-2"
            v-model="filter.distributor_id"
            :options="distributorOptions"
            label="Distributor"
            dense
            v-if="!isBS"
            outlined
            map-options
            emit-value
            @update:model-value="onFilterChange"
          />

          <q-select
            v-if="canFilterByBs"
            class="custom-select col-12 col-sm-6 col-md-2"
            v-model="filter.bs_user_id"
            :options="bsOptions"
            label="BS"
            dense
            outlined
            map-options
            emit-value
            @update:model-value="onBsFilterChange"
          />

          <q-select
            v-if="!isAgronomist"
            class="custom-select col-12 col-sm-6 col-md-2"
            v-model="filter.retailer_id"
            :options="filteredRetailerOptions"
            label="R1/R2"
            dense
            outlined
            map-options
            emit-value
            @update:model-value="onFilterChange"
          />

          <q-input
            class="col-12"
            outlined
            dense
            debounce="300"
            v-model="filter.search"
            placeholder="Cari distributor atau retailer"
            clearable
            @update:model-value="onFilterChange"
          >
            <template #append>
              <q-icon name="search" />
            </template>
          </q-input>
        </div>
      </div>
    </template>

    <div class="sales-page q-pa-sm">
      <div class="stats-grid q-mb-sm">
        <div class="stat-card stat-nilai">
          <q-icon class="stat-icon" name="payments" size="26px" />
          <div class="stat-body">
            <div class="stat-label">
              Total Nilai<span v-if="isBS" class="text-caption text-grey-6 q-ml-xs">(released)</span>
            </div>
            <div class="stat-value">Rp {{ formatNumber(totalSalesSum) }}</div>
          </div>
        </div>
        <div class="stat-card stat-qty">
          <q-icon class="stat-icon" name="inventory_2" size="26px" />
          <div class="stat-body">
            <div class="stat-label">
              Total Qty<span v-if="isBS" class="text-caption text-grey-6 q-ml-xs">(released)</span>
            </div>
            <div class="stat-value">{{ formatNumber(totalQtySum) }}</div>
          </div>
        </div>
        <div class="stat-card stat-count">
          <q-icon class="stat-icon" name="receipt_long" size="26px" />
          <div class="stat-body">
            <div class="stat-label">Jumlah Transaksi</div>
            <div class="stat-value">{{ formatNumber(pagination.rowsNumber) }}</div>
          </div>
        </div>
      </div>

      <div class="summary-shell q-mb-sm">
        <div class="summary-header row items-center justify-between" @click="showSummary = !showSummary">
          <span class="text-subtitle2 text-grey-8">
            {{ isBS ? 'Ringkasan Penjualan per R1/R2 (Released)' : 'Ringkasan per Distributor' }}
          </span>
          <q-icon :name="showSummary ? 'expand_less' : 'expand_more'" color="grey-7" />
        </div>
        <q-slide-transition>
          <div v-show="showSummary">
            <!-- BS: ringkasan per retailer (R1/R2) -->
            <template v-if="isBS">
              <div v-if="isMobileView" class="dist-mobile-list">
                <div
                  v-for="row in byRetailer"
                  :key="row.retailer_id"
                  class="dist-mobile-row"
                >
                  <span class="dist-mobile-name">{{ row.retailer_name }} ({{ row.retailer_type }})</span>
                  <span class="text-caption text-grey-7">Rp {{ formatNumber(row.total_amount || 0) }}</span>
                </div>
                <div v-if="byRetailer.length === 0" class="text-center text-caption text-grey-5 q-py-sm">
                  Belum ada penjualan yang released
                </div>
              </div>
              <q-table
                v-else
                class="summary-table"
                flat
                dense
                row-key="retailer_id"
                :rows="byRetailer"
                :columns="retailerSummaryColumns"
                :pagination="{ rowsPerPage: 10 }"
                hide-bottom
              >
                <template #body-cell-total_qty="props">
                  <q-td :props="props" class="text-right">{{ formatNumber(props.row.total_qty || 0) }}</q-td>
                </template>
                <template #body-cell-total_amount="props">
                  <q-td :props="props" class="text-right text-weight-medium">
                    Rp {{ formatNumber(props.row.total_amount || 0) }}
                  </q-td>
                </template>
              </q-table>
            </template>

            <!-- Agronomist/Admin: ringkasan per distributor -->
            <template v-else>
              <!-- Mobile: compact list tanpa scroll -->
              <div v-if="isMobileView" class="dist-mobile-list">
                <div
                  v-for="row in byDistributor"
                  :key="row.distributor_id"
                  class="dist-mobile-row"
                >
                  <span class="dist-mobile-name">{{ row.distributor_name }}</span>
                  <q-btn
                    flat dense no-caps
                    color="grey-8"
                    size="sm"
                    :label="`Rp ${formatNumber(row.total_amount || 0)}`"
                    @click="openDistributorDetail(row)"
                  />
                </div>
                <div v-if="byDistributor.length === 0" class="text-center text-caption text-grey-5 q-py-sm">
                  Tidak ada data
                </div>
              </div>
              <!-- Desktop: full table -->
              <q-table
                v-else
                class="summary-table"
                flat
                dense
                row-key="distributor_id"
                :rows="byDistributor"
                :columns="distributorColumns"
                :pagination="{ rowsPerPage: 10 }"
                hide-bottom
              >
                <template #body-cell-total_qty="props">
                  <q-td :props="props" class="text-right">{{ formatNumber(props.row.total_qty || 0) }}</q-td>
                </template>
                <template #body-cell-total_amount="props">
                  <q-td :props="props" class="text-right">
                    <q-btn
                      flat
                      dense
                      no-caps
                      color="primary"
                      :label="`Rp ${formatNumber(props.row.total_amount || 0)}`"
                      @click="openDistributorDetail(props.row)"
                    />
                  </q-td>
                </template>
              </q-table>
            </template>
          </div>
        </q-slide-transition>
      </div>

      <q-table
        v-if="!isMobileView"
        ref="tableRef"
        :style="{ height: tableHeight }"
        class="full-height-table"
        flat
        bordered
        square
        row-key="id"
        virtual-scroll
        v-model:pagination="pagination"
        :loading="loading"
        :columns="computedColumns"
        :rows="rows"
        :rows-per-page-options="[10, 25, 50]"
        @request="fetchItems"
        binary-state-sort
      >
        <template #loading>
          <q-inner-loading showing color="red" />
        </template>

        <template #body="props">
          <q-tr :props="props" class="cursor-pointer" @click="onRowClicked(props.row)">
            <q-td key="date" :props="props" class="wrap-column">
              {{ formatDate(props.row.date) }}
            </q-td>
            <q-td key="sale_type" :props="props">
              <q-badge :color="props.row.sale_type === 'retailer' && !isTargetImport(props.row) ? 'grey-7' : 'primary'">
                {{ saleTypeLabel(props.row) }}
              </q-badge>
              <q-badge
                v-if="props.row.sale_type === 'retailer' && props.row.source_from === 'r1'"
                color="orange-7"
                class="q-ml-xs"
              >
                Dari R1
              </q-badge>
            </q-td>
            <q-td key="status" :props="props">
              <q-badge :color="statusColor(props.row)">
                {{ statusLabel(props.row) }}
              </q-badge>
            </q-td>
            <q-td key="distributor" :props="props">
              {{ props.row.distributor?.name || '-' }}
            </q-td>
            <q-td v-if="!isAgronomist" key="retailer" :props="props">
              {{ props.row.retailer?.name || '-' }}
            </q-td>
            <q-td key="total_amount" :props="props" class="text-right">
              Rp {{ formatNumber(props.row.total_amount) }}
            </q-td>
            <q-td key="created_by_user" :props="props">
              {{ props.row.created_by_user?.name || '-' }}
            </q-td>
            <q-td key="action" :props="props" @click.stop>
              <q-btn flat dense icon="more_vert">
                <q-menu anchor="bottom right" self="top right">
                  <q-list style="min-width: 190px">
                    <q-item clickable v-ripple @click="router.get(route('admin.sale.detail', props.row.id))">
                      <q-item-section avatar>
                        <q-icon name="visibility" />
                      </q-item-section>
                      <q-item-section>Detail</q-item-section>
                    </q-item>
                    <q-item
                      v-if="isPending(props.row)"
                      clickable
                      v-ripple
                      @click="openReleaseDialog(props.row)"
                    >
                      <q-item-section avatar>
                        <q-icon name="published_with_changes" color="positive" />
                      </q-item-section>
                      <q-item-section>Release</q-item-section>
                    </q-item>
                    <q-item
                      v-if="$can('admin.sale.edit') && (isPending(props.row) || canForceDelete)"
                      clickable
                      v-ripple
                      @click="router.get(route('admin.sale.edit', props.row.id))"
                    >
                      <q-item-section avatar>
                        <q-icon name="edit" />
                      </q-item-section>
                      <q-item-section>Edit</q-item-section>
                    </q-item>
                    <q-item
                      v-if="$can('admin.sale.delete') && (isPending(props.row) || canForceDelete)"
                      clickable
                      v-ripple
                      class="text-red"
                      @click="deleteItem(props.row)"
                    >
                      <q-item-section avatar>
                        <q-icon name="delete" color="red" />
                      </q-item-section>
                      <q-item-section>Hapus</q-item-section>
                    </q-item>
                  </q-list>
                </q-menu>
              </q-btn>
            </q-td>
          </q-tr>
        </template>
      </q-table>

      <div v-else class="mobile-sales-list">
        <q-inner-loading :showing="loading" color="red" />

        <q-card
          v-for="row in rows"
          :key="row.id"
          flat
          bordered
          class="mobile-sale-card q-mb-sm"
          :class="row.sale_type === 'retailer' && !isTargetImport(row) ? 'card-retailer' : 'card-distributor'"
          @click="onRowClicked(row)"
        >
          <q-card-section class="q-pb-sm">
            <div class="row items-center justify-between q-col-gutter-sm">
              <div class="col">
                <div class="text-caption text-grey-7">Tanggal</div>
                <div class="text-subtitle2 text-bold">{{ formatDate(row.date) }}</div>
              </div>
              <q-badge outline :color="row.sale_type === 'retailer' && !isTargetImport(row) ? 'grey-7' : 'blue-8'">
                {{ saleTypeLabel(row) }}
              </q-badge>
              <q-badge outline :color="statusColor(row)">
                {{ statusLabel(row) }}
              </q-badge>
            </div>

            <div class="mobile-meta q-mt-sm">
              <div class="mobile-meta-item">
                <span class="meta-label">Distributor</span>
                <span class="meta-value">{{ row.distributor?.name || '-' }}</span>
              </div>
              <div v-if="!isAgronomist" class="mobile-meta-item">
                <span class="meta-label">R1/R2</span>
                <span class="meta-value">{{ row.retailer?.name || '-' }}</span>
              </div>
              <div class="mobile-meta-item">
                <span class="meta-label">Input By</span>
                <span class="meta-value">{{ row.created_by_user?.name || '-' }}</span>
              </div>
            </div>
          </q-card-section>

          <q-separator />

          <q-card-section class="row items-center justify-between q-py-sm mobile-card-footer">
            <div class="mobile-total-wrap">
              <div class="text-caption text-grey-7">Total Nilai</div>
              <div class="text-subtitle1 text-bold text-primary">Rp {{ formatNumber(row.total_amount) }}</div>
            </div>

            <div class="row items-center q-gutter-xs mobile-card-actions" @click.stop>
              <q-btn flat dense icon="visibility" color="grey-7" @click="router.get(route('admin.sale.detail', row.id))" />
              <q-btn
                v-if="isPending(row)"
                flat
                dense
                icon="published_with_changes"
                color="positive"
                @click="openReleaseDialog(row)"
              />
              <q-btn
                v-if="$can('admin.sale.edit') && (isPending(row) || canForceDelete)"
                flat
                dense
                icon="edit"
                color="grey-7"
                @click="router.get(route('admin.sale.edit', row.id))"
              />
              <q-btn
                v-if="$can('admin.sale.delete') && (isPending(row) || canForceDelete)"
                flat
                dense
                icon="delete_outline"
                color="grey-7"
                @click="deleteItem(row)"
              />
            </div>
          </q-card-section>
        </q-card>

        <q-banner v-if="!loading && rows.length === 0" class="bg-grey-2 text-grey-8 rounded-borders">
          Tidak ada data penjualan pada filter saat ini.
        </q-banner>

        <div class="mobile-pagination q-mt-sm">
          <q-select
            dense
            outlined
            map-options
            emit-value
            :options="rowsPerPageOptions"
            :model-value="pagination.rowsPerPage"
            label="Baris"
            @update:model-value="onMobileRowsPerPageChange"
          />
          <q-pagination
            :model-value="pagination.page"
            :max="totalPages"
            :max-pages="6"
            boundary-numbers
            direction-links
            @update:model-value="onMobilePageChange"
          />
        </div>
      </div>
    </div>

    <q-dialog v-model="importDialog">
      <q-card style="min-width: 520px; max-width: 92vw">
        <q-card-section class="text-subtitle1 text-bold">
          Import Penjualan
        </q-card-section>

        <q-card-section>
          <q-file
            v-model="importFile"
            outlined
            accept=".xlsx,.xls"
            label="Pilih file Excel"
            :disable="importing"
          />

          <div class="q-mt-sm text-caption text-grey-8">
            Gunakan template resmi agar format data valid.
          </div>

          <q-banner v-if="importResult" class="q-mt-md" :class="(importResult.errors?.length || 0) > 0 ? 'bg-orange-1 text-orange-10' : 'bg-green-1 text-green-10'">
            Berhasil: {{ importResult.success || 0 }} baris
            <br />
            Error: {{ importResult.errors?.length || 0 }} baris
          </q-banner>

          <q-list
            v-if="importResult?.errors?.length"
            bordered
            separator
            class="q-mt-md"
            style="max-height: 220px; overflow: auto"
          >
            <q-item v-for="(err, idx) in importResult.errors" :key="idx">
              <q-item-section>
                <q-item-label caption class="text-red">{{ err }}</q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Tutup" :disable="importing" @click="importDialog = false" />
          <q-btn
            color="primary"
            icon="upload"
            label="Import"
            :loading="importing"
            :disable="!importFile"
            @click="submitImport"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="releaseDialog" persistent>
      <q-card :style="isMobileView ? 'width: 96vw; max-width: 96vw' : 'min-width: 640px; max-width: 95vw'">
        <q-card-section class="text-subtitle1 text-bold">
          Release PO #{{ releaseSale?.id || "-" }}
        </q-card-section>

        <q-card-section>
          <div class="text-caption text-grey-7 q-mb-sm">
            Distributor: {{ releaseSale?.distributor?.name || "-" }}
          </div>

          <div v-if="isMobileView" class="release-mobile-list">
            <q-card
              v-for="item in releaseItems"
              :key="item.id"
              flat
              bordered
              class="release-mobile-card q-mb-sm"
            >
              <q-card-section class="q-pb-sm">
                <div class="text-subtitle2 text-weight-bold">{{ item.product_name || '-' }}</div>
                <div class="text-caption text-grey-7">
                  Qty PO: {{ formatNumber(item.quantity, 'id-ID', 2) }} {{ item.unit || '-' }}
                </div>
              </q-card-section>

              <q-separator />

              <q-card-section class="q-gutter-sm">
                <q-input
                  v-model.number="item.quantity_release"
                  type="number"
                  dense
                  outlined
                  min="0.01"
                  step="0.01"
                  :disable="releasing"
                  label="Qty Release"
                >
                  <template #append>
                    <span class="text-caption text-grey-7">{{ item.unit || '-' }}</span>
                  </template>
                </q-input>

                <q-input
                  v-model.number="item.remaining_stock"
                  type="number"
                  dense
                  outlined
                  min="0"
                  step="0.01"
                  :disable="releasing"
                  label="Sisa Stok Tersedia"
                  placeholder="Opsional"
                >
                  <template #append>
                    <span class="text-caption text-grey-7">{{ item.unit || '-' }}</span>
                  </template>
                </q-input>

                <q-input
                  v-model.trim="item.lot_number"
                  dense
                  outlined
                  label="No. Lot"
                  placeholder="No. Lot"
                  :disable="releasing"
                />

                <q-input
                  v-model="item.expired_date"
                  type="date"
                  dense
                  outlined
                  label="Expired"
                  :disable="releasing"
                />
              </q-card-section>
            </q-card>
          </div>

          <q-markup-table v-else flat bordered square separator="cell">
            <thead>
              <tr>
                <th class="text-left">Produk</th>
                <th class="text-right">Qty PO</th>
                <th class="text-right">Qty Release</th>
                <th class="text-left">Satuan</th>
                <th class="text-right">Sisa Stok Tersedia</th>
                <th class="text-left">No. Lot</th>
                <th class="text-left">Expired</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in releaseItems" :key="item.id">
                <td>{{ item.product_name || '-' }}</td>
                <td class="text-right">{{ formatNumber(item.quantity, 'id-ID', 2) }}</td>
                <td>
                  <q-input
                    v-model.number="item.quantity_release"
                    type="number"
                    dense
                    outlined
                    min="0.01"
                    step="0.01"
                    :disable="releasing"
                  />
                </td>
                <td>{{ item.unit || '-' }}</td>
                <td>
                  <q-input
                    v-model.number="item.remaining_stock"
                    type="number"
                    dense
                    outlined
                    min="0"
                    step="0.01"
                    :disable="releasing"
                    placeholder="Opsional"
                  />
                </td>
                <td>
                  <q-input
                    v-model.trim="item.lot_number"
                    dense
                    outlined
                    placeholder="No. Lot"
                    :disable="releasing"
                  />
                </td>
                <td>
                  <q-input
                    v-model="item.expired_date"
                    type="date"
                    dense
                    outlined
                    :disable="releasing"
                  />
                </td>
              </tr>
            </tbody>
          </q-markup-table>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Batal" :disable="releasing" @click="releaseDialog = false" />
          <q-btn
            color="positive"
            icon="published_with_changes"
            label="Release"
            :loading="releasing"
            @click="submitRelease"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="distributorDetailDialog" maximized="false">
      <q-card style="width: 900px; max-width: 95vw; max-height: 90vh; display: flex; flex-direction: column;">
        <q-card-section class="row items-center q-pb-none q-pt-sm q-px-md" style="flex-shrink:0">
          <div class="text-subtitle2 text-bold">{{ distributorDetailSummary.distributor_name }}</div>
          <q-space />
          <q-btn icon="close" flat round dense @click="distributorDetailDialog = false" />
        </q-card-section>

        <q-card-section class="q-pt-xs q-pb-sm q-px-md" style="flex-shrink:0">
          <div class="dist-detail-stats">
            <div class="dist-detail-stat">
              <span class="dist-detail-stat-label">Total Nilai</span>
              <span class="dist-detail-stat-val">Rp {{ formatNumber(distributorDetailSummary.total_amount) }}</span>
            </div>
            <div class="dist-detail-stat">
              <span class="dist-detail-stat-label">Total Qty</span>
              <span class="dist-detail-stat-val">{{ formatNumber(distributorDetailSummary.total_qty) }}</span>
            </div>
            <div class="dist-detail-stat">
              <span class="dist-detail-stat-label">Jumlah Data</span>
              <span class="dist-detail-stat-val">{{ distributorDetailSummary.total_rows }}</span>
            </div>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-section class="q-pt-sm col overflow-auto">
          <!-- Mobile: card view -->
          <div v-if="isMobileView">
            <q-inner-loading :showing="distributorDetailLoading" color="grey-6" />
            <template v-if="!distributorDetailLoading">
              <div
                v-for="row in distributorDetailRows"
                :key="row.id"
                class="detail-mobile-card q-mb-sm"
              >
                <div class="row items-center justify-between q-mb-xs">
                  <span class="text-caption text-grey-7">{{ formatDate(row.date) }}</span>
                  <q-badge outline :color="row.sale_type === 'retailer' && !isTargetImport(row) ? 'grey-7' : 'blue-8'">
                    {{ saleTypeLabel(row) }}
                  </q-badge>
                </div>
                <div v-if="!isAgronomist" class="detail-mobile-meta">
                  <span class="detail-mobile-label">R1/R2</span>
                  <span class="detail-mobile-val">{{ row.retailer?.name || '-' }}</span>
                </div>
                <div class="detail-mobile-meta">
                  <span class="detail-mobile-label">Sumber</span>
                  <span class="detail-mobile-val">{{ row.notes || '-' }}</span>
                </div>
                <q-separator class="q-my-xs" />
                <div class="row items-center justify-between">
                  <span class="text-caption text-grey-6">Total Nilai</span>
                  <span class="text-subtitle2 text-bold">Rp {{ formatNumber(row.total_amount || 0) }}</span>
                </div>
              </div>
              <div v-if="distributorDetailRows.length === 0" class="text-center text-caption text-grey-5 q-py-md">
                Tidak ada data.
              </div>
            </template>
          </div>
          <!-- Desktop: table view -->
          <q-table
            v-else
            dense
            flat
            bordered
            row-key="id"
            :rows="distributorDetailRows"
            :loading="distributorDetailLoading"
            :columns="distributorDetailColumns"
            :pagination="{ rowsPerPage: 15 }"
          >
            <template #body-cell-date="props">
              <q-td :props="props">{{ formatDate(props.row.date) }}</q-td>
            </template>
            <template #body-cell-sale_type="props">
              <q-td :props="props">{{ saleTypeLabel(props.row) }}</q-td>
            </template>
            <template #body-cell-total_amount="props">
              <q-td :props="props" class="text-right">Rp {{ formatNumber(props.row.total_amount || 0) }}</q-td>
            </template>
          </q-table>
        </q-card-section>
      </q-card>
    </q-dialog>
  </authenticated-layout>
</template>

<style scoped>
.release-mobile-list {
  display: flex;
  flex-direction: column;
}

.release-mobile-card {
  border-radius: 12px;
  box-shadow: 0 4px 14px rgba(16, 24, 40, 0.06);
}
</style>

<style scoped>
.sales-actions {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: flex-end;
  gap: 8px;
}

.action-btn {
  min-height: 34px;
}

.filter-shell {
  padding: 10px;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
}

.sales-page {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 8px;
}

.stat-card {
  border-radius: 12px;
  padding: 14px 16px;
  display: flex;
  align-items: center;
  gap: 14px;
  background: #fff;
  border: 1px solid #e5e7eb;
}

.stat-icon { color: #94a3b8; }

.stat-label {
  font-size: 11px;
  color: #64748b;
  font-weight: 500;
  margin-bottom: 2px;
}

.stat-value {
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
  line-height: 1.2;
}

.summary-shell {
  border-radius: 14px;
  border: 1px solid #dde8e4;
  background: #fff;
  overflow: hidden;
}

.summary-header {
  padding: 10px 16px;
  background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
  cursor: pointer;
  user-select: none;
}

.summary-header:hover {
  background: linear-gradient(180deg, #f1f5f9 0%, #e8f0f7 100%);
}

.summary-table :deep(.q-table) {
  width: 100%;
  table-layout: fixed;
}

.summary-table :deep(th),
.summary-table :deep(td) {
  white-space: normal;
}

.mobile-sales-list {
  position: relative;
  min-height: 120px;
  width: 100%;
}

.mobile-sale-card {
  width: 100%;
  display: block;
  box-sizing: border-box;
  border-radius: 12px;
}

.mobile-meta {
  display: grid;
  gap: 6px;
}

.mobile-meta-item {
  display: grid;
  grid-template-columns: 104px minmax(0, 1fr);
  gap: 8px;
  align-items: start;
}

.meta-label {
  color: #64748b;
  font-size: 12px;
}

.meta-value {
  color: #0f172a;
  font-weight: 600;
  font-size: 13px;
  text-align: left;
  min-width: 0;
  word-break: break-word;
  line-height: 1.35;
}

.mobile-card-footer {
  border-top: 1px solid #e5e7eb;
}

.mobile-total-wrap {
  min-width: 0;
}

.mobile-card-actions :deep(.q-btn) {
  width: 32px;
  height: 32px;
}

.dist-mobile-list {
  padding: 6px 12px 8px;
  display: flex;
  flex-direction: column;
}

.dist-mobile-row {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: center;
  padding: 3px 0;
  border-bottom: 1px solid #f1f5f9;
  gap: 8px;
}

.dist-mobile-row:last-child { border-bottom: none; }

.dist-mobile-name {
  font-size: 12px;
  color: #334155;
  font-weight: 500;
  min-width: 0;
  word-break: break-word;
}

.detail-mobile-card {
  border: 1px solid #e5e7eb;
  border-radius: 10px;
  padding: 10px 12px;
  background: #fafafa;
}

.detail-mobile-meta {
  display: grid;
  grid-template-columns: 96px minmax(0, 1fr);
  gap: 4px;
  align-items: baseline;
  margin-bottom: 2px;
}

.detail-mobile-label {
  font-size: 11px;
  color: #94a3b8;
}

.detail-mobile-val {
  font-size: 12px;
  color: #1e293b;
  font-weight: 500;
  text-align: right;
  min-width: 0;
  word-break: break-word;
}

.dist-detail-stats {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

.dist-detail-stat {
  display: flex;
  flex-direction: column;
}

.dist-detail-stat-label {
  font-size: 10px;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.dist-detail-stat-val {
  font-size: 14px;
  font-weight: 700;
  color: #1e293b;
}

.mobile-pagination {
  display: grid;
  grid-template-columns: 132px 1fr;
  gap: 8px;
  align-items: center;
}

@media (max-width: 1023px) {
  .sales-actions {
    width: auto;
    margin-left: auto;
    justify-content: flex-end;
    flex-wrap: nowrap;
    gap: 6px;
    padding: 0;
  }
}

@media (max-width: 600px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .mobile-pagination {
    grid-template-columns: 1fr;
  }
}

.mobile-sale-card.card-distributor {
  border-top: 3px solid #90caf9;
}

.mobile-sale-card.card-retailer {
  border-top: 3px solid #cbd5e1;
}
</style>
