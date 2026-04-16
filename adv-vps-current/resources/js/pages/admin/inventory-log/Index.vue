<script setup>
import { computed, onMounted, reactive, ref, watch } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import { handleDelete, handleFetchItems } from "@/helpers/client-req-handler";
import { getQueryParams, formatNumber, check_role } from "@/helpers/utils";
import { Dialog, Notify, useQuasar } from "quasar";
import axios from "axios";
import { usePageStorage } from "@/helpers/usePageStorage";
import { formatDate } from "@/helpers/datetime";
import { useProductFilter } from "@/composables/useProductFilter";
import { useCustomerFilter } from "@/composables/useCustomerFilter";
import useTableHeight from "@/composables/useTableHeight";

const page = usePage();
const storage = usePageStorage("inventory-log");

const title = "Log Inventori";
const $q = useQuasar();
const showFilter = ref(storage.get("show-filter", false));
const rows = ref([]);
const loading = ref(true);
const updatingStock = ref(false);
const updateStockDialog = ref(false);
const updateStockRow = ref(null);
const tableRef = ref(null);
const filterToolbarRef = ref(null);
const tableHeight = useTableHeight(filterToolbarRef);

// State untuk customers yang difilter berdasarkan user_id
const filteredCustomersForUser = ref([]);

const filter = reactive(
  storage.get("filter", {
    search: "",
    customer_id: null,
    product_id: "all",
    stock_status: "all",
    user_id: "all",
    ...getQueryParams(),
  })
);

if (page.props.auth.user.role === "bs" || page.props.auth.user.role === "field_officer") {
  // BS/Field Officer should not be implicitly filtered by checker,
  // because sale release can be executed by admin but still belongs to BS.
  filter.user_id = "all";
}
const pagination = ref(
  storage.get("pagination", {
    page: 1,
    rowsPerPage: 10,
    rowsNumber: 10,
    sortBy: "id",
    descending: true,
  })
);

const columns = [
  {
    name: "check_date",
    label: $q.screen.gt.sm ? "Tanggal" : "Log Item",
    field: "check_date",
    align: "left",
  },
  { name: "area", label: "Area", field: "area", align: "left" },
  {
    name: "category",
    label: "Crops",
    field: "category",
    align: "left",
    sortable: true,
  },
  {
    name: "user",
    label: "Checker",
    field: "user",
    align: "left",
    sortable: true,
  },
  {
    name: "customer",
    label: "Kiosk / Distributor",
    field: "customer",
    align: "left",
    sortable: true,
  },
  {
    name: "product",
    label: "Hybrid",
    field: "product",
    align: "left",
    sortable: true,
  },
  {
    name: "lot_package",
    label: "LOT Package",
    field: "lot_package",
    align: "left",
    sortable: true,
  },
  {
    name: "quantity",
    label: "Quantity",
    field: "quantity",
    align: "right",
    sortable: true,
  },
  { name: "action", align: "right" },
];

const canDeleteInventory = computed(() => {
  const role = page.props.auth?.user?.role;
  return role === "admin" || role === "agronomist";
});

const canUpdateStock = computed(() => {
  const role = page.props.auth?.user?.role;
  return (
    (role === "bs" || role === "field_officer") &&
    page.props.auth?.permissions?.includes("admin.inventory-log.update-stock")
  );
});

const updateStockForm = reactive({
  check_date: new Date().toISOString().slice(0, 10),
  remaining_stock: 0,
  remaining_stock_unit: "",
});

const users = [
  { value: "all", label: "Semua" },
  ...page.props.users.map((user) => ({
    value: user.id,
    label: `${user.name} (${user.username})`,
  })),
];

const { products } = useProductFilter(page.props.products, true);
const { filterCustomers, filteredCustomers } = useCustomerFilter(
  page.props.customers
);
const productOptions = products;

// Computed untuk menentukan customer options yang ditampilkan
const customerOptionsForFilter = computed(() => {
  // Jika user_id dipilih dan berbeda dengan "all", gunakan customers yang difilter untuk user tersebut
  if (filter.user_id && filter.user_id !== "all" && filteredCustomersForUser.value.length > 0) {
    return filteredCustomersForUser.value;
  }
  // Jika tidak ada filter user atau user_id = "all", gunakan semua customers
  return page.props.customers.map((item) => ({
    value: item.id,
    label: item.name,
  }));
});

const stockStatusOptions = [
  { value: "all", label: "Semua Stok" },
  { value: "available", label: "Stok Tersedia (> 0)" },
  { value: "empty", label: "Stok Kosong (= 0)" },
];
const exportQtyUnit = ref("kg");
const exportQtyUnitOptions = [
  { value: "kg", label: "KG" },
  { value: "pcs", label: "PCS" },
];

// Function untuk fetch customers berdasarkan user_id
const fetchCustomersByUser = async (userId) => {
  if (!userId || userId === "all") {
    filteredCustomersForUser.value = [];
    filter.customer_id = null; // Reset customer filter
    return;
  }

  try {
    const response = await axios.get(route("admin.inventory-log.customers-by-user"), {
      params: { user_id: userId },
    });
    filteredCustomersForUser.value = response.data.rows || [];
    filter.customer_id = null; // Reset customer filter saat user berubah
  } catch (error) {
    filteredCustomersForUser.value = [];
    filter.customer_id = null;
  }
};

onMounted(() => {
  fetchItems();
});

const deleteItem = (row) =>
  handleDelete({
    message: `Hapus Log Inventori #${row.id}?`,
    url: route("admin.inventory-log.delete", row.id),
    fetchItemsCallback: fetchItems,
    loading,
  });

const deleteAllItems = () => {
  if (!canDeleteInventory.value) {
    Notify.create({
      message: "Hanya Admin/Agronomis yang dapat menghapus semua log inventori.",
      color: "warning",
    });
    return;
  }

  Dialog.create({
    title: "Konfirmasi Hapus Semua",
    message:
      "Hapus semua log inventori sesuai filter saat ini? Tindakan ini tidak dapat dibatalkan.",
    cancel: true,
    persistent: true,
    ok: {
      color: "negative",
      label: "Ya, Hapus Semua",
    },
  }).onOk(async () => {
    loading.value = true;
    try {
      const response = await axios.post(route("admin.inventory-log.delete-all"), {
        filter: {
          search: filter.search,
          customer_id: filter.customer_id,
          product_id: filter.product_id,
          user_id: filter.user_id,
        },
      });

      Notify.create({
        message: response.data?.message || "Berhasil menghapus data.",
        color: "positive",
      });

      pagination.value.page = 1;
      await fetchItems();
    } catch (error) {
      Notify.create({
        message:
          error?.response?.data?.message ||
          "Gagal menghapus semua log inventori.",
        color: "negative",
      });
    } finally {
      loading.value = false;
    }
  });
};

const getPrimaryUnit = (row) => {
  return String(row?.product?.uom_1 || row?.product?.unit || "kg").toLowerCase();
};

const getSecondaryUnit = (row) => {
  const primary = getPrimaryUnit(row);
  const fallback = primary === "kg" ? "pcs" : "kg";
  return String(row?.product?.uom_2 || fallback).toLowerCase();
};

const getStockUnitOptions = (row) => {
  if (!row) return [];
  const units = [getPrimaryUnit(row), getSecondaryUnit(row)].filter((u) => !!u);
  return [...new Set(units)].map((u) => ({
    label: String(u).toUpperCase(),
    value: u,
  }));
};

const getCurrentPrimaryStock = (row) => {
  const saleItem = getSaleItemForRow(row);
  if (saleItem) {
    return Number(saleItem.base_quantity || 0);
  }

  const uom1 = getPrimaryUnit(row);
  return uom1 === "pcs" ? Number(row?.base_quantity || 0) : Number(row?.quantity || 0);
};

const convertPrimaryQtyToUnit = (row, primaryQty, targetUnit) => {
  const numericQty = Number(primaryQty || 0);
  const uom1 = getPrimaryUnit(row);
  const uom2 = getSecondaryUnit(row);
  const selected = String(targetUnit || uom1).toLowerCase();
  const weightGram = Number(row?.product?.weight || 0);

  if (!selected || selected === uom1) return numericQty;
  if (selected !== uom2 || weightGram <= 0) return numericQty;

  if (uom1 === "kg" && uom2 === "pcs") {
    return Number(((numericQty * 1000) / weightGram).toFixed(2));
  }
  if (uom1 === "pcs" && uom2 === "kg") {
    return Number(((numericQty * weightGram) / 1000).toFixed(3));
  }

  return numericQty;
};

const syncCurrentStockBySelectedUnit = () => {
  if (!updateStockRow.value) return;

  const primaryQty = getCurrentPrimaryStock(updateStockRow.value);
  const selectedUnit = updateStockForm.remaining_stock_unit || getPrimaryUnit(updateStockRow.value);
  updateStockForm.remaining_stock = convertPrimaryQtyToUnit(
    updateStockRow.value,
    primaryQty,
    selectedUnit
  );
};

const openUpdateStockDialog = (row) => {
  updateStockRow.value = row;
  updateStockForm.check_date = new Date().toISOString().slice(0, 10);
  updateStockForm.remaining_stock_unit = getPrimaryUnit(row);
  syncCurrentStockBySelectedUnit();
  updateStockDialog.value = true;
};

const submitUpdateStock = async () => {
  if (!updateStockRow.value) return;

  const remainingStock = Number(updateStockForm.remaining_stock);
  if (Number.isNaN(remainingStock) || remainingStock < 0) {
    Notify.create({
      message: "Stok tersisa harus angka 0 atau lebih.",
      color: "negative",
    });
    return;
  }

  updatingStock.value = true;
  try {
    const response = await axios.post(
      route("admin.inventory-log.update-stock", updateStockRow.value.id),
      {
        check_date: updateStockForm.check_date,
        remaining_stock: remainingStock,
        remaining_stock_unit: updateStockForm.remaining_stock_unit,
      }
    );

    Notify.create({
      message: response.data?.message || "Stok log inventori berhasil diperbarui.",
      color: "positive",
    });

    updateStockDialog.value = false;
    await fetchItems();
  } catch (error) {
    Notify.create({
      message:
        error?.response?.data?.errors?.remaining_stock?.[0] ||
        error?.response?.data?.errors?.check_date?.[0] ||
        error?.response?.data?.message ||
        "Gagal memperbarui stok log inventori.",
      color: "negative",
    });
  } finally {
    updatingStock.value = false;
  }
};

const fetchItems = (props = null) => {
  handleFetchItems({
    pagination,
    filter,
    props,
    rows,
    url: route("admin.inventory-log.data"),
    loading,
    tableRef,
  });
};

const onFilterChange = () => {
  fetchItems();
};

const computedColumns = computed(() =>
  $q.screen.gt.sm
    ? columns
    : columns.filter((col) => ["check_date", "action"].includes(col.name))
);

const formatKg = (value) =>
  new Intl.NumberFormat("id-ID", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 3,
  }).format(Number(value || 0));

const normalizeUnit = (value) => String(value || "").trim().toLowerCase();

const convertToPrimaryFromUnit = (product, qty, unit) => {
  const numericQty = Number(qty || 0);
  if (numericQty <= 0) return 0;

  const uom1 = normalizeUnit(product?.uom_1 || product?.unit);
  const uom2 = normalizeUnit(product?.uom_2);
  const srcUnit = normalizeUnit(unit);
  const weightGram = Number(product?.weight || 0);

  if (!srcUnit || !uom1 || srcUnit === uom1) return numericQty;

  if (srcUnit === uom2 && weightGram > 0) {
    if (uom1 === "kg" && uom2 === "pcs") {
      return Number(((numericQty * weightGram) / 1000).toFixed(6));
    }

    if (uom1 === "pcs" && uom2 === "kg") {
      return Number(((numericQty * 1000) / weightGram).toFixed(6));
    }
  }

  return numericQty;
};

const getSaleItemForRow = (row) => {
  const saleItems = row?.sale?.items || [];
  return saleItems.find((item) => Number(item.product_id) === Number(row?.product_id)) || null;
};

const getDisplayCustomerName = (row) => {
  if (row?.sale?.retailer?.name && String(row?.notes || "").startsWith("[SALE_SYNC")) {
    return row.sale.retailer.name;
  }

  return row?.customer?.name || "-";
};

const formatInventoryQuantity = (row) => {
  const saleItem = getSaleItemForRow(row);
  const product = row?.product || {};
  const uom1 = normalizeUnit(product.uom_1 || product.unit || "kg");
  const uom2 = normalizeUnit(product.uom_2 || (uom1 === "kg" ? "pcs" : "kg"));
  const weightGram = Number(product.weight || 0);

  const rowPrimaryQty = Number(row?.quantity || 0);
  const movementPrimaryQty = Math.abs(Number(row?.movement_quantity || 0));
  const salePrimaryQty = saleItem
    ? convertToPrimaryFromUnit(product, saleItem.quantity, saleItem.unit)
    : 0;

  const saleBaseQuantity = Number(saleItem?.base_quantity || 0);
  const rowBaseQuantity = Number(row?.base_quantity || 0);
  const convertedBaseQuantity = (() => {
    const primaryCandidate = rowPrimaryQty > 0
      ? rowPrimaryQty
      : (movementPrimaryQty > 0 ? movementPrimaryQty : salePrimaryQty);

    if (primaryCandidate <= 0 || weightGram <= 0) return 0;

    if (uom1 === "kg" && uom2 === "pcs") {
      return Number(((primaryCandidate * 1000) / weightGram).toFixed(2));
    }

    if (uom1 === "pcs" && uom2 === "kg") {
      return Number(primaryCandidate.toFixed(2));
    }

    return 0;
  })();

  const baseQuantityValue = saleBaseQuantity > 0
    ? saleBaseQuantity
    : (rowBaseQuantity > 0 ? rowBaseQuantity : convertedBaseQuantity);

  const quantityValue = rowPrimaryQty > 0
    ? rowPrimaryQty
    : (movementPrimaryQty > 0
      ? movementPrimaryQty
      : (salePrimaryQty > 0
        ? salePrimaryQty
        : (uom1 === "kg" && uom2 === "pcs" && baseQuantityValue > 0 && weightGram > 0
          ? Number(((baseQuantityValue * weightGram) / 1000).toFixed(3))
          : 0)));

  const primaryValue = uom1 === "pcs"
    ? formatNumber(baseQuantityValue)
    : formatKg(quantityValue);
  const secondaryValue = uom2 === "pcs"
    ? formatNumber(baseQuantityValue)
    : formatKg(quantityValue);

  return `${primaryValue} ${uom1} / ${secondaryValue} ${uom2}`;
};

watch(filter, () => storage.set("filter", filter), { deep: true });
watch(showFilter, () => storage.set("show-filter", showFilter.value), {
  deep: true,
});
watch(pagination, () => storage.set("pagination", pagination.value), {
  deep: true,
});

// Watch untuk user_id filter - fetch customers terkait
watch(
  () => filter.user_id,
  (newUserId) => {
    fetchCustomersByUser(newUserId);
  }
);
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>
    <template #right-button>
      <q-btn
        icon="add"
        dense
        color="primary"
        @click="router.get(route('admin.inventory-log.add'))"
        v-if="$can('admin.inventory-log.add')"
      />
      <q-btn
        class="q-ml-sm"
        :icon="!showFilter ? 'filter_alt' : 'filter_alt_off'"
        color="grey"
        dense
        @click="showFilter = !showFilter"
      />
      <q-btn
        v-if="canDeleteInventory && $can('admin.inventory-log.delete')"
        class="q-ml-sm"
        icon="delete_sweep"
        dense
        color="negative"
        @click="deleteAllItems"
      >
        <q-tooltip>Hapus Semua (sesuai filter)</q-tooltip>
      </q-btn>
      <q-btn
        v-if="$can('admin.inventory-log.export')"
        icon="file_export"
        dense
        class="q-ml-sm"
        color="grey"
        style=""
        @click.stop
      >
        <q-menu
          anchor="bottom right"
          self="top right"
          transition-show="scale"
          transition-hide="scale"
        >
          <q-list style="width: 200px">
            <q-item>
              <q-item-section>
                <q-select
                  v-model="exportQtyUnit"
                  :options="exportQtyUnitOptions"
                  emit-value
                  map-options
                  dense
                  outlined
                  label="Satuan Qty"
                />
              </q-item-section>
            </q-item>
            <q-item
              clickable
              v-ripple
              v-close-popup
              :href="route('admin.inventory-log.export', { format: 'pdf', qty_unit: exportQtyUnit, filter })"
            >
              <q-item-section avatar>
                <q-icon name="picture_as_pdf" color="red-9" />
              </q-item-section>
              <q-item-section>Export PDF</q-item-section>
            </q-item>
            <q-item
              clickable
              v-ripple
              v-close-popup
              :href="route('admin.inventory-log.export', { format: 'excel', qty_unit: exportQtyUnit, filter })"
            >
              <q-item-section avatar>
                <q-icon name="csv" color="green-9" />
              </q-item-section>
              <q-item-section>Export Excel</q-item-section>
            </q-item>
          </q-list>
        </q-menu>
      </q-btn>
    </template>
    <template #header v-if="showFilter">
      <q-toolbar class="filter-bar" ref="filterToolbarRef">
        <div class="row q-col-gutter-xs items-center q-pa-sm full-width">
          <q-select
            class="custom-select col-xs-12 col-sm-2"
            style="min-width: 150px"
            v-model="filter.user_id"
            v-show="check_role(['admin', 'agronomist'])"
            :options="users"
            label="Checker"
            dense
            map-options
            emit-value
            outlined
            @update:model-value="onFilterChange"
          />
          <q-select
            class="custom-select col-xs-12 col-sm-2"
            v-model="filter.customer_id"
            style="min-width: 150px"
            label="Client"
            use-input
            dense
            outlined
            input-debounce="300"
            clearable
            :options="customerOptionsForFilter"
            map-options
            emit-value
            @filter="filterCustomers"
            @update:model-value="onFilterChange"
          >
            <template v-slot:no-option>
              <q-item>
                <q-item-section>Client tidak ditemukan</q-item-section>
              </q-item>
            </template>
          </q-select>
          <q-select
            class="custom-select col-xs-6 col-sm-2"
            style="min-width: 150px"
            v-model="filter.product_id"
            :options="productOptions"
            label="Varietas"
            dense
            map-options
            emit-value
            outlined
            @update:model-value="onFilterChange"
          />
          <q-select
            class="custom-select col-xs-6 col-sm-2"
            style="min-width: 180px"
            v-model="filter.stock_status"
            :options="stockStatusOptions"
            label="Status Stok"
            dense
            map-options
            emit-value
            outlined
            @update:model-value="onFilterChange"
          />
          <q-input
            class="col"
            outlined
            dense
            debounce="300"
            v-model="filter.search"
            placeholder="Cari"
            clearable
          >
            <template v-slot:append>
              <q-icon name="search" />
            </template>
          </q-input>
        </div>
      </q-toolbar>
    </template>
    <div class="q-pa-sm">
      <q-table
        ref="tableRef"
        :style="{ height: tableHeight }"
        class="full-height-table"
        flat
        bordered
        square
        color="primary"
        row-key="id"
        virtual-scroll
        v-model:pagination="pagination"
        :filter="filter.search"
        :loading="loading"
        :columns="computedColumns"
        :rows="rows"
        :rows-per-page-options="[10, 25, 50]"
        @request="fetchItems"
        binary-state-sort
      >
        <template v-slot:loading>
          <q-inner-loading showing color="red" />
        </template>
        <template v-slot:no-data="{ icon, message, filter }">
          <div class="full-width row flex-center text-grey-8 q-gutter-sm">
            <span
              >{{ message }} {{ filter ? " with term " + filter : "" }}</span
            >
          </div>
        </template>
        <template v-slot:body="props">
          <q-tr
            :props="props"
            class="cursor-pointer"
            @click="
              router.get(route('admin.inventory-log.detail', props.row.id))
            "
          >
            <q-td key="check_date" :props="props" class="wrap-column">
              <template v-if="!$q.screen.gt.sm">Tgl: </template
              >{{ formatDate(props.row.check_date) }}
              <template v-if="!$q.screen.gt.sm">
                <div>Area: {{ props.row.area }}</div>
                <div>Crops: {{ props.row.product.category.name }}</div>
                <div>Checker: {{ props.row.user.name }}</div>
                <div>Client: {{ getDisplayCustomerName(props.row) }}</div>
                <div>Hybrid: {{ props.row.product.name }}</div>
                <div>Lot Package: {{ props.row.lot_package }}</div>
                <div>
                  Qty: {{ formatInventoryQuantity(props.row) }}
                </div>
              </template>
            </q-td>
            <q-td key="area" :props="props">
              {{ props.row.area }}
            </q-td>
            <q-td key="category" :props="props">
              {{ props.row.product.category.name }}
            </q-td>
            <q-td key="user" :props="props">
              {{ props.row.user.name }}
            </q-td>
            <q-td key="customer" :props="props">
              {{ getDisplayCustomerName(props.row) }}
            </q-td>
            <q-td key="product" :props="props">
              {{ props.row.product.name }}
            </q-td>
            <q-td key="lot_package" :props="props">
              {{ props.row.lot_package }}
            </q-td>
            <q-td key="quantity" :props="props">
              {{ formatInventoryQuantity(props.row) }}
            </q-td>
            <q-td key="action" :props="props">
              <div
                class="flex justify-end"
                v-if="
                  canUpdateStock ||
                  $can('admin.inventory-log.edit') ||
                  ($can('admin.inventory-log.delete') && canDeleteInventory)
                "
              >
                <q-btn
                  icon="more_vert"
                  dense
                  flat
                  style="height: 40px; width: 30px"
                  @click.stop
                >
                  <q-menu
                    anchor="bottom right"
                    self="top right"
                    transition-show="scale"
                    transition-hide="scale"
                  >
                    <q-list style="width: 200px">
                      <q-item
                        v-if="canUpdateStock"
                        clickable
                        v-ripple
                        v-close-popup
                        @click.stop="openUpdateStockDialog(props.row)"
                      >
                        <q-item-section avatar>
                          <q-icon name="update" />
                        </q-item-section>
                        <q-item-section>Update Stok</q-item-section>
                      </q-item>
                      <q-item
                        v-if="$can('admin.inventory-log.edit')"
                        clickable
                        v-ripple
                        v-close-popup
                        @click.stop="
                          router.get(
                            route('admin.inventory-log.edit', props.row.id)
                          )
                        "
                      >
                        <q-item-section avatar>
                          <q-icon name="edit" />
                        </q-item-section>
                        <q-item-section icon="edit">Edit</q-item-section>
                      </q-item>
                      <q-item
                        v-if="$can('admin.inventory-log.delete') && canDeleteInventory"
                        @click.stop="deleteItem(props.row)"
                        clickable
                        v-ripple
                        v-close-popup
                      >
                        <q-item-section avatar>
                          <q-icon name="delete_forever" />
                        </q-item-section>
                        <q-item-section>Hapus</q-item-section>
                      </q-item>
                    </q-list>
                  </q-menu>
                </q-btn>
              </div>
            </q-td>
          </q-tr>
        </template>
      </q-table>
    </div>

    <q-dialog v-model="updateStockDialog" persistent>
      <q-card style="min-width: 380px; max-width: 95vw">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Update Stok Log Inventory</div>
        </q-card-section>

        <q-card-section>
          <div class="text-caption text-grey-8 q-mb-sm">
            {{ updateStockRow?.customer?.name || '-' }} - {{ updateStockRow?.product?.name || '-' }}
          </div>

          <q-input
            v-model.number="updateStockForm.remaining_stock"
            type="number"
            min="0"
            step="0.01"
            dense
            outlined
            :label="`Stok Tersisa Saat Ini (${(updateStockForm.remaining_stock_unit || getPrimaryUnit(updateStockRow)).toUpperCase()})`"
            class="q-mb-sm"
          />

          <q-select
            v-model="updateStockForm.remaining_stock_unit"
            :options="getStockUnitOptions(updateStockRow)"
            map-options
            emit-value
            dense
            outlined
            label="Satuan"
            class="q-mb-sm"
            @update:model-value="syncCurrentStockBySelectedUnit"
          />

          <q-input
            v-model="updateStockForm.check_date"
            type="date"
            dense
            outlined
            label="Tanggal Update"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Batal" v-close-popup :disable="updatingStock" />
          <q-btn color="primary" label="Update" :loading="updatingStock" @click="submitUpdateStock" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </authenticated-layout>
</template>
