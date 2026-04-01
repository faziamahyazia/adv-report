<script setup>
import { computed, nextTick, onMounted, reactive, ref, watch } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import axios from "axios";
import { useQuasar } from "quasar";
import { formatNumber } from "@/helpers/utils";
import { usePageStorage } from "@/helpers/usePageStorage";
import useTableHeight from "@/composables/useTableHeight";

const page = usePage();
const $q = useQuasar();
const storage = usePageStorage("distributor-stock");

const title = "Stok Distributor";
const rows = ref([]);
const loading = ref(false);
const adjusting = ref(false);
const deleting = ref(false);
const adjustmentDialog = ref(false);
const adjustmentRow = ref(null);
const showFilter = ref(storage.get("show-filter", true));
const tableRef = ref(null);
const filterToolbarRef = ref(null);
const tableHeight = useTableHeight(filterToolbarRef);

const adjustmentForm = reactive({
  type: "in",
  quantity: null,
  remaining_stock: null,
  remaining_stock_unit: "",
  lot_number: "",
  expired_date: null,
  reference: "manual-adjustment",
  notes: "",
});

const filter = reactive(
  storage.get("filter", {
    distributor_id: null,
    product_id: null,
  })
);

const pagination = ref(
  storage.get("pagination", {
    page: 1,
    rowsPerPage: 20,
    rowsNumber: 0,
    sortBy: "stock_quantity",
    descending: true,
  })
);

const columns = [
  {
    name: "distributor",
    label: $q.screen.gt.sm ? "Distributor" : "Stok",
    field: "distributor",
    align: "left",
  },
  {
    name: "product",
    label: "Produk",
    field: "product",
    align: "left",
  },
  {
    name: "unit",
    label: "Satuan",
    field: "unit",
    align: "left",
  },
  {
    name: "lot_number",
    label: "No. Lot",
    field: "lot_number",
    align: "left",
  },
  {
    name: "expired_date",
    label: "Expired",
    field: "expired_date",
    align: "left",
  },
  {
    name: "aging_days",
    label: "Aging (hari)",
    field: "aging_days",
    align: "right",
    sortable: true,
  },
  {
    name: "stock_quantity",
    label: "Qty",
    field: "stock_quantity",
    align: "right",
    sortable: true,
  },
  {
    name: "remaining_stock",
    label: "Stok Tersisa",
    field: "stock_quantity",
    align: "right",
    sortable: true,
  },
  { name: "action", align: "right" },
];

const distributorOptions = computed(() => [
  { value: null, label: "Semua Distributor" },
  ...((page.props.distributors || []).map((item) => ({ value: item.id, label: item.name })) || []),
]);

const productOptions = computed(() => [
  { value: null, label: "Semua Produk" },
  ...((page.props.products || []).map((item) => ({ value: item.id, label: item.name })) || []),
]);

const canDeleteStock = computed(() => ["admin", "agronomist"].includes(page.props.auth?.user?.role));

const computedColumns = computed(() => {
  if ($q.screen.gt.sm) return columns;
  return columns.filter((col) => ["distributor", "lot_number", "expired_date", "remaining_stock", "action"].includes(col.name));
});

const fetchItems = async (props = null) => {
  const source = props ? props.pagination : pagination.value;

  loading.value = true;
  try {
    const response = await axios.get(route("admin.distributor-stock.data"), {
      params: {
        page: source.page,
        per_page: source.rowsPerPage,
        order_by: source.sortBy || "stock_quantity",
        order_type: source.descending ? "desc" : "asc",
        filter: {
          distributor_id: filter.distributor_id,
          product_id: filter.product_id,
        },
      },
    });

    rows.value = response.data.data || [];

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

const onFilterChange = () => {
  pagination.value.page = 1;
  fetchItems();
};

const openMovements = (row) => {
  router.get(route("admin.distributor-stock.movements", { id: row.distributor_id }));
};

const openAdjustment = (row, type = "in") => {
  adjustmentRow.value = row;
  adjustmentForm.type = type;
  adjustmentForm.quantity = null;
  adjustmentForm.remaining_stock = Number(row?.stock_quantity || 0);
  adjustmentForm.remaining_stock_unit = row?.product?.uom_1 || row?.product?.unit || "";
  adjustmentForm.lot_number = row?.lot_number || "";
  adjustmentForm.expired_date = row?.expired_date || null;
  adjustmentForm.reference = "manual-adjustment";
  adjustmentForm.notes = "";
  adjustmentDialog.value = true;
};

const normalizeUnit = (unit) => String(unit || "").trim().toLowerCase();

const convertBaseToUnit = (row, baseQty, targetUnit) => {
  const qty = Number(baseQty || 0);
  const product = row?.product || {};
  const uom1 = normalizeUnit(product.uom_1 || product.unit);
  const uom2 = normalizeUnit(product.uom_2);
  const target = normalizeUnit(targetUnit);

  if (!target || !uom1 || target === uom1) return qty;

  if (target === uom2) {
    const weightGram = Number(product.weight || 0);
    if (weightGram > 0) {
      if (uom1 === "kg" && uom2 === "pcs") {
        return Number(((qty * 1000) / weightGram).toFixed(2));
      }
      if (uom1 === "pcs" && uom2 === "kg") {
        return Number(((qty * weightGram) / 1000).toFixed(3));
      }
    }
  }

  return qty;
};

const convertToBaseUnit = (row, qty, sourceUnit) => {
  const numericQty = Number(qty || 0);
  const product = row?.product || {};
  const uom1 = normalizeUnit(product.uom_1 || product.unit);
  const uom2 = normalizeUnit(product.uom_2);
  const source = normalizeUnit(sourceUnit);

  if (!source || !uom1 || source === uom1) return numericQty;

  if (source === uom2) {
    const weightGram = Number(product.weight || 0);
    if (weightGram > 0) {
      if (uom1 === "kg" && uom2 === "pcs") {
        return Number(((numericQty * weightGram) / 1000).toFixed(6));
      }
      if (uom1 === "pcs" && uom2 === "kg") {
        return Number(((numericQty * 1000) / weightGram).toFixed(6));
      }
    }
  }

  return numericQty;
};

const remainingUnitOptions = computed(() => {
  const row = adjustmentRow.value;
  if (!row?.product) return [];

  const out = [row.product.uom_1 || row.product.unit, row.product.uom_2]
    .filter((u) => !!u)
    .map((u) => ({ label: u, value: u }));

  return [...new Map(out.map((i) => [i.value, i])).values()];
});

const displayedCurrentStock = computed(() => {
  const row = adjustmentRow.value;
  if (!row) return 0;
  return convertBaseToUnit(row, Number(row.stock_quantity || 0), adjustmentForm.remaining_stock_unit || row.product?.uom_1 || row.product?.unit);
});

const submitAdjustment = async () => {
  if (!adjustmentRow.value) return;

  const remainingStockInput = Number(adjustmentForm.remaining_stock);
  if (Number.isNaN(remainingStockInput) || remainingStockInput < 0) {
    $q.notify({ color: "negative", message: "Stok tersisa harus angka 0 atau lebih." });
    return;
  }

  const unit = adjustmentForm.remaining_stock_unit || adjustmentRow.value.product?.uom_1 || adjustmentRow.value.product?.unit;
  const remainingStockBase = convertToBaseUnit(adjustmentRow.value, remainingStockInput, unit);
  const currentStock = Number(adjustmentRow.value.stock_quantity || 0);
  if (Math.abs(remainingStockBase - currentStock) < 0.000001) {
    $q.notify({ color: "warning", message: "Stok tersisa sama dengan stok saat ini." });
    return;
  }

  const diffQty = Math.abs(remainingStockBase - currentStock);
  if (diffQty <= 0) {
    $q.notify({ color: "negative", message: "Qty harus lebih dari 0." });
    return;
  }

  adjusting.value = true;
  try {
    const response = await axios.post(route("admin.distributor-stock.adjust"), {
      distributor_id: adjustmentRow.value.distributor_id,
      product_id: adjustmentRow.value.product_id,
      type: remainingStockBase > currentStock ? "in" : "out",
      quantity: diffQty,
      remaining_stock: remainingStockInput,
      remaining_stock_unit: unit,
      lot_number: adjustmentForm.lot_number || null,
      expired_date: adjustmentForm.expired_date || null,
      reference: adjustmentForm.reference || null,
      notes: adjustmentForm.notes || null,
    });

    $q.notify({ color: "positive", message: response.data?.message || "Penyesuaian stok berhasil." });
    adjustmentDialog.value = false;
    await fetchItems();
  } catch (error) {
    $q.notify({
      color: "negative",
      message: error?.response?.data?.errors?.quantity?.[0] || error?.response?.data?.message || "Gagal menyimpan penyesuaian stok.",
    });
  } finally {
    adjusting.value = false;
  }
};

const deleteRow = (row) => {
  if (!canDeleteStock.value) return;

  $q.dialog({
    title: "Hapus Stok Distributor",
    message: `Hapus stok untuk lot ${row?.lot_number || "NO-LOT"} (${row?.product?.name || "Produk"})?`,
    cancel: true,
    persistent: true,
    ok: { color: "negative", label: "Hapus" },
  }).onOk(async () => {
    deleting.value = true;
    try {
      const response = await axios.post(route("admin.distributor-stock.delete"), {
        distributor_id: row.distributor_id,
        product_id: row.product_id,
        lot_number: row.lot_number || null,
        expired_date: row.expired_date || null,
      });

      $q.notify({ color: "positive", message: response.data?.message || "Stok berhasil dihapus." });
      await fetchItems();
    } catch (error) {
      $q.notify({
        color: "negative",
        message: error?.response?.data?.errors?.lot_number?.[0] || error?.response?.data?.message || "Gagal menghapus stok.",
      });
    } finally {
      deleting.value = false;
    }
  });
};

onMounted(fetchItems);

watch(filter, () => storage.set("filter", filter), { deep: true });
watch(showFilter, () => storage.set("show-filter", showFilter.value));
watch(pagination, () => storage.set("pagination", pagination.value), { deep: true });
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>

    <template #right-button>
      <q-btn
        v-if="$can('admin.distributor-stock.add')"
        icon="add"
        dense
        color="primary"
        @click="router.get(route('admin.distributor-stock.add'))"
      />
      <q-btn
        class="q-ml-sm"
        :icon="!showFilter ? 'filter_alt' : 'filter_alt_off'"
        color="grey"
        dense
        @click="showFilter = !showFilter"
      />
    </template>

    <template #header v-if="showFilter">
      <div class="stock-content-shell q-mt-sm" ref="filterToolbarRef">
        <div class="filter-shell">
        <div class="row q-col-gutter-sm">
          <div class="col-12 col-sm-6">
            <q-select
              class="custom-select"
              v-model="filter.distributor_id"
              :options="distributorOptions"
              label="Distributor"
              dense
              outlined
              map-options
              emit-value
              @update:model-value="onFilterChange"
            />
          </div>

          <div class="col-12 col-sm-6">
            <q-select
              class="custom-select"
              v-model="filter.product_id"
              :options="productOptions"
              label="Produk"
              dense
              outlined
              map-options
              emit-value
              @update:model-value="onFilterChange"
            />
          </div>
        </div>
        </div>
      </div>
    </template>

    <div class="stock-content-shell q-pa-sm">
      <q-table
        ref="tableRef"
        :style="{ height: tableHeight }"
        class="full-height-table"
        flat
        bordered
        square
        row-key="id"
        virtual-scroll
        :grid="$q.screen.lt.md"
        :hide-header="$q.screen.lt.md"
        v-model:pagination="pagination"
        :loading="loading"
        :columns="computedColumns"
        :rows="rows"
        :rows-per-page-options="[10, 20, 50]"
        @request="fetchItems"
        binary-state-sort
      >
        <template #loading>
          <q-inner-loading showing color="red" />
        </template>

        <template #item="props">
          <div class="col-12 q-py-xs q-px-none">
            <q-card flat bordered class="mobile-stock-card full-width">
              <q-card-section class="q-pb-sm">
                <div class="row items-start q-col-gutter-sm">
                  <div class="col-12 col-sm-7">
                    <div class="text-caption text-grey-7 q-mb-xs">Distributor</div>
                    <div class="text-weight-bold text-body2" style="line-height: 1.3; word-break: break-word;">
                      {{ props.row.distributor?.name || '-' }}
                    </div>
                  </div>
                  <div class="col-12 col-sm-5">
                    <div class="text-caption text-grey-7 q-mb-xs">Stok Tersisa</div>
                    <div class="text-weight-bold text-primary text-h6" style="line-height: 1.2;">
                      {{ formatNumber(props.row.stock_quantity, 'id-ID', 2) }} {{ props.row.product?.unit || 'kg' }}
                    </div>
                  </div>
                </div>
              </q-card-section>

              <q-separator />

              <q-card-section class="q-pt-sm q-pb-sm">
                <div class="mobile-stock-meta">
                  <div><span class="label">Produk</span><span class="value">{{ props.row.product?.name || '-' }}</span></div>
                  <div><span class="label">Satuan</span><span class="value">{{ props.row.product?.unit || '-' }}</span></div>
                  <div><span class="label">No. Lot</span><span class="value">{{ props.row.lot_number || '-' }}</span></div>
                  <div><span class="label">Expired</span><span class="value">{{ props.row.expired_date || '-' }}</span></div>
                  <div><span class="label">Aging</span><span class="value">{{ props.row.aging_days ?? '-' }}</span></div>
                </div>
              </q-card-section>

              <q-separator />

              <q-card-actions align="around" class="q-pa-sm q-gutter-xs">
                <q-btn
                  v-if="$can('admin.distributor-stock.adjust')"
                  icon="tune"
                  label="Adjust"
                  size="sm"
                  dense
                  flat
                  color="orange-8"
                  :disable="deleting"
                  @click="openAdjustment(props.row, 'in')"
                />
                <q-btn
                  v-if="$can('admin.distributor-stock.movements')"
                  icon="history"
                  label="Riwayat"
                  size="sm"
                  dense
                  flat
                  color="primary"
                  :disable="deleting"
                  @click="openMovements(props.row)"
                />
                <q-btn
                  v-if="canDeleteStock"
                  icon="delete"
                  label="Hapus"
                  size="sm"
                  dense
                  flat
                  color="negative"
                  :loading="deleting"
                  @click="deleteRow(props.row)"
                />
              </q-card-actions>
            </q-card>
          </div>
        </template>

        <template #body="props">
          <q-tr :props="props">
            <q-td key="distributor" :props="props" class="wrap-column">
              <div class="text-weight-medium">{{ props.row.distributor?.name || '-' }}</div>
              <template v-if="$q.screen.lt.md">
                <div>Produk: {{ props.row.product?.name || '-' }}</div>
                <div>Satuan: {{ props.row.product?.unit || '-' }}</div>
                <div>Lot: {{ props.row.lot_number || '-' }}</div>
                <div>Expired: {{ props.row.expired_date || '-' }}</div>
                <div>Aging: {{ props.row.aging_days ?? '-' }}</div>
                <div>Qty: {{ formatNumber(props.row.stock_quantity, 'id-ID', 2) }}</div>
                <div>Stok Tersisa: {{ formatNumber(props.row.stock_quantity, 'id-ID', 2) }}</div>
              </template>
            </q-td>

            <q-td key="product" :props="props">{{ props.row.product?.name || '-' }}</q-td>
            <q-td key="unit" :props="props">{{ props.row.product?.unit || '-' }}</q-td>
            <q-td key="lot_number" :props="props">{{ props.row.lot_number || '-' }}</q-td>
            <q-td key="expired_date" :props="props">{{ props.row.expired_date || '-' }}</q-td>
            <q-td key="aging_days" :props="props" class="text-right">{{ props.row.aging_days ?? '-' }}</q-td>
            <q-td key="stock_quantity" :props="props" class="text-right text-weight-medium">
              {{ formatNumber(props.row.stock_quantity, "id-ID", 2) }}
            </q-td>
            <q-td key="remaining_stock" :props="props" class="text-right text-weight-bold text-primary">
              {{ formatNumber(props.row.stock_quantity, "id-ID", 2) }}
            </q-td>

            <q-td key="action" :props="props" class="text-right">
              <q-btn
                v-if="$can('admin.distributor-stock.adjust')"
                icon="tune"
                dense
                flat
                color="orange-8"
                :disable="deleting"
                @click="openAdjustment(props.row, 'in')"
              >
                <q-tooltip>Penyesuaian Stok</q-tooltip>
              </q-btn>
              <q-btn
                v-if="$can('admin.distributor-stock.movements')"
                icon="history"
                dense
                flat
                color="primary"
                :disable="deleting"
                @click="openMovements(props.row)"
              >
                <q-tooltip>Pergerakan Stok</q-tooltip>
              </q-btn>
              <q-btn
                v-if="canDeleteStock"
                icon="delete"
                dense
                flat
                color="negative"
                :loading="deleting"
                @click="deleteRow(props.row)"
              >
                <q-tooltip>Hapus Stok</q-tooltip>
              </q-btn>
            </q-td>
          </q-tr>
        </template>
      </q-table>
    </div>

    <q-dialog v-model="adjustmentDialog" persistent>
      <q-card style="min-width: 360px; max-width: 95vw">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Penyesuaian Stok</div>
        </q-card-section>

        <q-card-section>
          <div class="text-caption text-grey-7 q-mb-sm">
            {{ adjustmentRow?.distributor?.name || '-' }} - {{ adjustmentRow?.product?.name || '-' }}
          </div>

          <div class="text-caption text-grey-8 q-mb-sm">
            Stok saat ini:
            <span class="text-weight-bold">
              {{ formatNumber(displayedCurrentStock, 'id-ID', 2) }} {{ adjustmentForm.remaining_stock_unit || adjustmentRow?.product?.uom_1 || adjustmentRow?.product?.unit || '' }}
            </span>
          </div>

          <q-select
            v-model="adjustmentForm.remaining_stock_unit"
            :options="remainingUnitOptions"
            map-options
            emit-value
            dense
            outlined
            label="Satuan Stok Tersisa"
            class="q-mb-sm"
          />

          <q-input
            v-model.number="adjustmentForm.remaining_stock"
            type="number"
            min="0"
            step="0.01"
            dense
            outlined
            label="Stok Tersisa"
            class="q-mb-sm"
          />

          <q-input
            v-model="adjustmentForm.lot_number"
            dense
            outlined
            label="No. Lot (opsional)"
            class="q-mb-sm"
          />

          <q-input
            v-model="adjustmentForm.expired_date"
            type="date"
            dense
            outlined
            label="Tanggal Expired (opsional)"
            class="q-mb-sm"
          />

          <q-input
            v-model="adjustmentForm.reference"
            dense
            outlined
            label="Referensi"
            class="q-mb-sm"
          />

          <q-input
            v-model="adjustmentForm.notes"
            type="textarea"
            autogrow
            dense
            outlined
            label="Catatan"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Batal" v-close-popup :disable="adjusting" />
          <q-btn color="primary" label="Simpan" :loading="adjusting" @click="submitAdjustment" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </authenticated-layout>
</template>

<style scoped>
.stock-content-shell {
  width: 100%;
}

.filter-shell {
  padding: 10px;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
}

.mobile-stock-card {
  border-radius: 8px;
  overflow: hidden;
}

.mobile-stock-meta {
  display: grid;
  grid-template-columns: 1fr;
  gap: 6px;
}

.mobile-stock-meta .label {
  display: inline-block;
  min-width: 82px;
  color: #6b7280;
  font-size: 12px;
  margin-right: 8px;
}

.mobile-stock-meta .value {
  color: #111827;
  font-weight: 500;
  word-break: break-word;
}

@media (min-width: 1024px) {
  .stock-content-shell {
    max-width: 1200px;
    margin-left: auto;
    margin-right: auto;
  }
}
</style>
