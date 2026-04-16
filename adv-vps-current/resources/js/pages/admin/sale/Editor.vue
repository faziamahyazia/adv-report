<script setup>
import { computed, onMounted, ref, watch } from "vue";
import { router, useForm, usePage } from "@inertiajs/vue3";
import { useQuasar } from "quasar";
import axios from "axios";
import { handleSubmit } from "@/helpers/client-req-handler";
import { formatNumber } from "@/helpers/utils";

const page = usePage();
const $q = useQuasar();
const isMobile = computed(() => $q.screen.lt.md);
const currentUser = page.props.auth.user;

const rawData = page.props.data || {};
const isEdit = !!rawData.id;
const title = `${isEdit ? "Edit" : "Tambah"} Penjualan`;

const toNumberOrNull = (val) => {
  if (val === null || val === undefined || val === "") return null;
  return Number(val);
};

const emptyItem = () => ({
  product_id: null,
  quantity: 1,
  unit: "",
  price: 0,
  subtotal: 0,
});

const mappedItems = (rawData.items || []).map((item) => {
  const quantity = Number(item.quantity || 0);
  const price = Number(item.price || 0);
  return {
    product_id: toNumberOrNull(item.product_id || item.product?.id),
    quantity,
    unit: item.unit || "",
    price,
    subtotal: Number(item.subtotal || quantity * price),
  };
});

const initialSaleType = rawData.sale_type || page.props.saleType || "distributor";
const initialDistributorId =
  toNumberOrNull(rawData.distributor_id) ||
  toNumberOrNull(page.props.defaultDistributorId) ||
  null;

const form = useForm({
  id: rawData.id || null,
  sale_type: initialSaleType,
  date: rawData.date ? String(rawData.date).substring(0, 10) : new Date().toISOString().slice(0, 10),
  distributor_id: initialDistributorId,
  retailer_id: toNumberOrNull(rawData.retailer_id),
  source_from: rawData.source_from || "distributor",
  notes: rawData.notes || "",
  items: mappedItems.length > 0 ? mappedItems : [emptyItem()],
});

const distributorStocks = ref([]);
const distributorStocksLoading = ref(false);

const shouldShowDistributorStock = computed(
  () => form.sale_type === "retailer" && !!form.distributor_id
);

const selectedDistributorName = computed(() => {
  const distributor = (page.props.distributors || []).find(
    (item) => Number(item.id) === Number(form.distributor_id)
  );
  return distributor?.name || "-";
});

const sourceStockLabel = computed(() => {
  if (form.sale_type === "retailer" && selectedRetailerType.value === "R2" && form.source_from === "r1") {
    return "Sumber Stok R1";
  }

  return "Distributor";
});

const stockByProductId = computed(() => {
  const out = {};
  (distributorStocks.value || []).forEach((row) => {
    out[Number(row.product_id)] = Number(row.stock_quantity || 0);
  });
  return out;
});

const productOptions = computed(() =>
  (page.props.products || []).map((product) => ({
    value: Number(product.id),
    label: product.name,
  }))
);

const itemProductOptions = computed(() =>
  (page.props.products || []).map((product) => {
    const productId = Number(product.id);
    const stock = Number(stockByProductId.value[productId] || 0);
    const showStock = shouldShowDistributorStock.value;

    return {
      value: productId,
      label: showStock ? `${product.name} (stok: ${formatNumber(stock)})` : product.name,
      disable: showStock ? stock <= 0 : false,
    };
  })
);

const productMap = computed(() => {
  const out = {};
  (page.props.products || []).forEach((product) => {
    out[Number(product.id)] = product;
  });
  return out;
});

const sourceStockOptions = computed(() => {
  const allSources = (page.props.distributors || []).map((item) => ({
    value: Number(item.id),
    label: item.type ? `${item.name} (${item.type})` : item.name,
    type: item.type,
  }));

  if (form.sale_type !== "retailer") {
    return allSources.filter((item) => item.type === "Distributor");
  }

  if (selectedRetailerType.value === "R2" && form.source_from === "r1") {
    return allSources.filter((item) => item.type === "R1");
  }

  return allSources.filter((item) => item.type === "Distributor");
});

const retailerOptions = computed(() =>
  (page.props.retailers || []).map((item) => ({
    value: Number(item.id),
    label: `${item.name} (${item.type})`,
  }))
);

// Tipe retailer yang sedang dipilih (R1 atau R2)
const selectedRetailerType = computed(() => {
  if (!form.retailer_id) return null;
  const retailer = (page.props.retailers || []).find((r) => Number(r.id) === Number(form.retailer_id));
  return retailer?.type || null;
});

// Tampilkan pilihan sumber barang hanya jika retailer = R2
const showSourceFrom = computed(
  () => form.sale_type === "retailer" && selectedRetailerType.value === "R2"
);

const sourceFromOptions = [
  { value: "distributor", label: "Dari Distributor" },
  { value: "r1", label: "Dari R1" },
];

const hasStockForProduct = (productId) => Number(stockByProductId.value[Number(productId)] || 0) > 0;

const saleTypeOptions = computed(() => [
  { value: "distributor", label: "Distributor (masuk ke stok distributor)" },
  { value: "retailer", label: "Retailer (keluar dari stok distributor)" },
]);

const isSaleTypeLocked = computed(() => ["bs", "field_officer"].includes(currentUser.role));
const isDistributorLocked = computed(
  () => currentUser.role === "distributor" && !!page.props.defaultDistributorId
);

const updateSubtotal = (item) => {
  const quantity = Number(item.quantity || 0);
  const price = Number(item.price || 0);
  item.subtotal = Number((quantity * price).toFixed(2));
};

const productById = (productId) => productMap.value[Number(productId)] || null;

const normalizeUnit = (unit) => String(unit || "").trim().toLowerCase();

const toBaseQty = (product, qty, unit) => {
  const numericQty = Number(qty || 0);
  if (!product || numericQty <= 0) return numericQty;

  const uom1 = normalizeUnit(product.uom_1);
  const uom2 = normalizeUnit(product.uom_2);
  const unitNorm = normalizeUnit(unit);

  if (!unitNorm || !uom1 || unitNorm === uom1) return numericQty;

  if (unitNorm === uom2) {
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

const fromBaseQty = (product, baseQty, targetUnit) => {
  const qty = Number(baseQty || 0);
  if (!product || qty <= 0) return qty;

  const uom1 = normalizeUnit(product.uom_1);
  const uom2 = normalizeUnit(product.uom_2);
  const target = normalizeUnit(targetUnit || product.uom_1);

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

const stockDisplayForItem = (item) => {
  const product = productById(item.product_id);
  if (!product) return "-";

  const baseStock = Number(stockByProductId.value[Number(item.product_id)] || 0);
  const targetUnit = item.unit || product.uom_1 || "";
  const converted = fromBaseQty(product, baseStock, targetUnit);
  return `${formatNumber(converted)} ${targetUnit || ""}`.trim();
};

const stockSecondaryDisplayForRow = (row) => {
  const product = productById(row.product_id);
  if (!product || !product.uom_2) return "";

  const converted = fromBaseQty(product, Number(row.stock_quantity || 0), product.uom_2);
  return `≈ ${formatNumber(converted)} ${product.uom_2}`;
};

const suggestedPriceByUnit = (product, unit) => {
  if (!product) return 0;

  const unitStr = String(unit || "").trim().toLowerCase();
  const uom1 = String(product.uom_1 || "").trim().toLowerCase();
  const uom2 = String(product.uom_2 || "").trim().toLowerCase();

  if (unitStr && unitStr === uom2 && Number(product.price_2 || 0) > 0) {
    return Number(product.price_2);
  }

  if (unitStr && unitStr === uom1 && Number(product.price_1 || 0) > 0) {
    return Number(product.price_1);
  }

  return Number(product.price_1 || product.price_2 || 0);
};

const onProductChange = (item) => {
  if (shouldShowDistributorStock.value && item.product_id && !hasStockForProduct(item.product_id)) {
    $q.notify({ type: "warning", message: "Stok produk di distributor 0, tidak bisa dipilih." });
    item.product_id = null;
    return;
  }

  const product = productById(item.product_id);
  if (!product) return;

  if (!item.unit) {
    item.unit = product.uom_1 || product.uom_2 || "";
  }

  item.price = suggestedPriceByUnit(product, item.unit);

  updateSubtotal(item);
};

const onUnitChange = (item) => {
  const product = productById(item.product_id);
  if (!product) return;

  item.price = suggestedPriceByUnit(product, item.unit);
  updateSubtotal(item);
};

const fetchDistributorStocks = async () => {
  if (!form.distributor_id) {
    distributorStocks.value = [];
    return;
  }

  distributorStocksLoading.value = true;
  try {
    const response = await axios.get(route("admin.sale.distributor-stocks"), {
      params: { distributor_id: form.distributor_id },
    });
    distributorStocks.value = response.data.rows || [];
    console.log("[DEBUG] fetchDistributorStocks - distributor_id:", form.distributor_id, "rows:", distributorStocks.value);
  } catch (error) {
    distributorStocks.value = [];
    console.error("[DEBUG] fetchDistributorStocks error:", error);
    $q.notify({
      type: "negative",
      message: error?.response?.data?.message || "Gagal memuat stok distributor",
    });
  } finally {
    distributorStocksLoading.value = false;
  }
};

const itemUnitOptions = (item) => {
  const product = productById(item.product_id);
  if (!product) return [];

  const units = [product.uom_1, product.uom_2].filter((u) => !!u);
  return [...new Set(units)].map((u) => ({ value: u, label: u }));
};

const addItem = () => {
  form.items.push(emptyItem());
};

const removeItem = (index) => {
  if (form.items.length === 1) return;
  form.items.splice(index, 1);
};

const grandTotal = computed(() =>
  form.items.reduce((carry, item) => carry + Number(item.quantity || 0) * Number(item.price || 0), 0)
);

const submit = () => {
  // Validasi stok hanya jika source_from = distributor (bukan R1 ke R2)
  if (shouldShowDistributorStock.value && form.source_from !== "r1") {
    const requested = {};
    for (const item of form.items) {
      const productId = Number(item.product_id || 0);
      const product = productById(productId);
      const qtyBase = toBaseQty(product, Number(item.quantity || 0), item.unit);
      if (!productId || qtyBase <= 0) continue;
      requested[productId] = (requested[productId] || 0) + qtyBase;
    }

    for (const [productIdText, qtyBase] of Object.entries(requested)) {
      const productId = Number(productIdText);
      const available = Number(stockByProductId.value[productId] || 0);
      const product = productById(productId);
      const baseUnit = product?.uom_1 || "unit";
      if (available <= 0) {
        $q.notify({ type: "warning", message: `Produk #${productId} stok 0 ${baseUnit}, tidak bisa disimpan.` });
        return;
      }
      if (qtyBase > available) {
        $q.notify({
          type: "warning",
          message: `Qty produk #${productId} melebihi stok. Diminta ${formatNumber(qtyBase)} ${baseUnit}, tersedia ${formatNumber(available)} ${baseUnit}.`,
        });
        return;
      }
    }
  }

  form.transform((data) => ({
    ...data,
    distributor_id: toNumberOrNull(data.distributor_id),
    retailer_id: data.sale_type === "retailer" ? toNumberOrNull(data.retailer_id) : null,
    source_from: data.sale_type === "retailer" ? (data.source_from || "distributor") : null,
    items: data.items
      .filter(
        (item) =>
          toNumberOrNull(item.product_id) &&
          Number(item.quantity) > 0 &&
          Number(item.price) > 0
      )
      .map((item) => ({
        product_id: toNumberOrNull(item.product_id),
        quantity: Number(item.quantity || 0),
        unit: item.unit || null,
        price: Number(item.price || 0),
      })),
  }));

  handleSubmit({
    form,
    url: route("admin.sale.save"),
  });
};

watch(
  () => form.sale_type,
  (value) => {
    if (value === "distributor") {
      form.retailer_id = null;
    }

    if (shouldShowDistributorStock.value || !!form.distributor_id) {
      fetchDistributorStocks();
    } else {
      distributorStocks.value = [];
    }
  }
);

watch(
  () => form.distributor_id,
  () => {
    if (shouldShowDistributorStock.value || !!form.distributor_id) {
      fetchDistributorStocks();
    } else {
      distributorStocks.value = [];
    }
  }
);

watch(
  () => form.retailer_id,
  () => {
    if (selectedRetailerType.value === "R1") {
      form.source_from = "distributor";
      return;
    }

    if (!form.source_from) {
      form.source_from = "distributor";
    }
  }
);

watch(
  () => form.source_from,
  () => {
    const allowedIds = new Set(sourceStockOptions.value.map((item) => Number(item.value)));
    if (form.distributor_id && !allowedIds.has(Number(form.distributor_id))) {
      form.distributor_id = null;
    }

    if (shouldShowDistributorStock.value || !!form.distributor_id) {
      fetchDistributorStocks();
    } else {
      distributorStocks.value = [];
    }
  }
);

if (isSaleTypeLocked.value) {
  form.sale_type = "retailer";
}

onMounted(async () => {
  if (shouldShowDistributorStock.value) {
    await fetchDistributorStocks();
  }

  form.items.forEach((item) => {
    if (!item.unit) {
      onProductChange(item);
    } else {
      updateSubtotal(item);
    }
  });
});
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>

    <q-page class="row justify-center">
      <div class="col col-lg-10 q-pa-sm">
        <q-form class="row" @submit.prevent="submit">
          <q-card square flat bordered class="col">
            <q-inner-loading :showing="form.processing">
              <q-spinner size="50px" color="primary" />
            </q-inner-loading>

            <q-card-section>
              <div class="text-subtitle1 text-bold q-mb-sm">Informasi Penjualan</div>

              <div class="row q-col-gutter-md">
                <div class="col-xs-12 col-sm-6 col-md-4">
                  <q-select
                    v-model="form.sale_type"
                    label="Jenis Penjualan"
                    :options="saleTypeOptions"
                    map-options
                    emit-value
                    :disable="form.processing || isSaleTypeLocked"
                    :error="!!form.errors.sale_type"
                    :error-message="form.errors.sale_type"
                  />
                </div>

                <div class="col-xs-12 col-sm-6 col-md-4">
                  <q-input
                    v-model="form.date"
                    type="date"
                    label="Tanggal"
                    :disable="form.processing"
                    :error="!!form.errors.date"
                    :error-message="form.errors.date"
                  />
                </div>

                <div class="col-xs-12 col-sm-6 col-md-4">
                  <q-select
                    v-model="form.distributor_id"
                    :label="sourceStockLabel"
                    :options="sourceStockOptions"
                    map-options
                    emit-value
                    :disable="form.processing || isDistributorLocked"
                    :error="!!form.errors.distributor_id"
                    :error-message="form.errors.distributor_id"
                    use-input
                    fill-input
                    hide-selected
                  />
                </div>

                <div class="col-xs-12 col-sm-6 col-md-4" v-if="form.sale_type === 'retailer'">
                  <q-select
                    v-model="form.retailer_id"
                    label="R1/R2"
                    :options="retailerOptions"
                    map-options
                    emit-value
                    :disable="form.processing"
                    :error="!!form.errors.retailer_id"
                    :error-message="form.errors.retailer_id"
                    use-input
                    fill-input
                    hide-selected
                  />
                </div>

                <!-- Sumber barang: hanya tampil untuk R2 -->
                <div class="col-xs-12 col-sm-6 col-md-4" v-if="showSourceFrom">
                  <q-select
                    v-model="form.source_from"
                    label="Barang Diambil Dari"
                    :options="sourceFromOptions"
                    map-options
                    emit-value
                    :disable="form.processing"
                    :error="!!form.errors.source_from"
                    :error-message="form.errors.source_from"
                  >
                    <template #hint>
                      <span class="text-caption text-grey-7">
                        Pilih asal barang: langsung dari distributor atau dari R1
                      </span>
                    </template>
                  </q-select>
                </div>

                <!-- Info: R1 selalu dari distributor -->
                <div class="col-xs-12 col-sm-6 col-md-4" v-if="form.sale_type === 'retailer' && selectedRetailerType === 'R1'">
                  <q-field
                    label="Barang Diambil Dari"
                    stack-label
                    borderless
                    readonly
                  >
                    <template #control>
                      <span class="text-body2 text-positive text-weight-medium">
                        <q-icon name="check_circle" size="16px" class="q-mr-xs" />Distributor (otomatis)
                      </span>
                    </template>
                    <template #hint>
                      <span class="text-caption text-grey-7">R1 selalu mengambil barang dari distributor</span>
                    </template>
                  </q-field>
                </div>

                <div class="col-12" v-if="shouldShowDistributorStock">
                  <q-card flat bordered class="bg-grey-1">
                    <q-card-section class="q-pa-sm">
                      <div class="text-subtitle2 text-weight-bold q-mb-xs">Stok Toko Terpilih</div>
                      <div class="text-caption text-grey-7 q-mb-sm">
                        {{ selectedDistributorName }}
                      </div>
                      <q-inner-loading :showing="distributorStocksLoading" color="primary" />

                      <div class="overflow-auto" style="max-height: 220px">
                        <q-markup-table flat dense separator="cell">
                          <thead>
                            <tr>
                              <th class="text-left">Produk</th>
                              <th class="text-left">Satuan</th>
                              <th class="text-right">Stok</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr v-for="row in distributorStocks" :key="row.product_id">
                              <td>{{ row.product_name || '-' }}</td>
                              <td>{{ row.uom_1 || row.unit || '-' }}</td>
                              <td class="text-right" :class="Number(row.stock_quantity || 0) <= 0 ? 'text-negative text-weight-bold' : ''">
                                <div>{{ formatNumber(row.stock_quantity || 0) }} {{ row.uom_1 || row.unit || '' }}</div>
                                <div v-if="stockSecondaryDisplayForRow(row)" class="text-caption text-grey-7">
                                  {{ stockSecondaryDisplayForRow(row) }}
                                </div>
                              </td>
                            </tr>
                            <tr v-if="!distributorStocksLoading && distributorStocks.length === 0">
                              <td colspan="3" class="text-center text-grey">Tidak ada stok distributor</td>
                            </tr>
                          </tbody>
                        </q-markup-table>
                      </div>
                    </q-card-section>
                  </q-card>
                </div>

                <div class="col-12">
                  <q-input
                    v-model="form.notes"
                    type="textarea"
                    autogrow
                    maxlength="500"
                    counter
                    label="Catatan"
                    :disable="form.processing"
                    :error="!!form.errors.notes"
                    :error-message="form.errors.notes"
                  />
                </div>
              </div>
            </q-card-section>

            <q-separator />

            <q-card-section>
              <div class="row items-center justify-between q-mb-sm">
                <div class="text-subtitle1 text-bold">Item Penjualan</div>
                <q-btn
                  icon="add"
                  label="Tambah Item"
                  color="primary"
                  dense
                  :disable="form.processing"
                  @click="addItem"
                />
              </div>

              <q-banner v-if="form.errors.items" class="bg-red-1 text-red-10 q-mb-sm">
                {{ form.errors.items }}
              </q-banner>

              <!-- Desktop: tabel -->
              <div v-if="!isMobile" class="overflow-auto">
                <q-markup-table flat bordered square separator="cell" style="min-width: 1100px">
                  <thead>
                    <tr>
                      <th style="width: 28%; padding: 12px 8px">Produk</th>
                      <th style="width: 11%; padding: 12px 8px; text-align: center">Qty</th>
                      <th style="width: 10%; padding: 12px 8px; text-align: center">Satuan</th>
                      <th style="width: 15%; padding: 12px 8px; text-align: right">Harga</th>
                      <th style="width: 20%; padding: 12px 8px; text-align: right">Subtotal</th>
                      <th style="width: 3%; padding: 12px 4px"></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(item, index) in form.items" :key="index">
                      <td style="padding: 8px">
                        <q-select
                          v-model="item.product_id"
                          :options="itemProductOptions"
                          map-options
                          emit-value
                          dense
                          outlined
                          use-input
                          fill-input
                          hide-selected
                          :disable="form.processing"
                          @update:model-value="onProductChange(item)"
                        />
                        <div v-if="form.errors[`items.${index}.product_id`]" class="text-caption text-red q-mt-xs">
                          {{ form.errors[`items.${index}.product_id`] }}
                        </div>
                      </td>

                      <td style="padding: 8px; text-align: center; vertical-align: middle">
                        <q-input
                          v-model.number="item.quantity"
                          type="number"
                          dense
                          outlined
                          min="0.01"
                          step="0.01"
                          :disable="form.processing"
                          class="full-width"
                          style="min-width: 90px"
                          input-class="text-center"
                          @update:model-value="updateSubtotal(item)"
                        />
                        <div v-if="form.errors[`items.${index}.quantity`]" class="text-caption text-red q-mt-xs">
                          {{ form.errors[`items.${index}.quantity`] }}
                        </div>
                        <div v-if="shouldShowDistributorStock && item.product_id" class="text-caption text-grey-7 q-mt-xs">
                          Stok tersedia: {{ stockDisplayForItem(item) }}
                        </div>
                      </td>

                      <td style="padding: 8px; text-align: center">
                        <q-select
                          v-model="item.unit"
                          :options="itemUnitOptions(item)"
                          map-options
                          emit-value
                          dense
                          outlined
                          clearable
                          :disable="form.processing"
                          @update:model-value="onUnitChange(item)"
                        />
                      </td>

                      <td style="padding: 8px; text-align: right; vertical-align: middle">
                        <q-input
                          v-model.number="item.price"
                          type="number"
                          dense
                          outlined
                          min="0.01"
                          step="0.01"
                          :disable="form.processing"
                          class="full-width"
                          style="min-width: 120px"
                          input-class="text-right"
                          @update:model-value="updateSubtotal(item)"
                        />
                        <div v-if="form.errors[`items.${index}.price`]" class="text-caption text-red q-mt-xs">
                          {{ form.errors[`items.${index}.price`] }}
                        </div>
                      </td>

                      <td style="padding: 8px; text-align: right; text-weight-medium; vertical-align: middle; min-width: 150px">
                        Rp {{ formatNumber(item.subtotal) }}
                      </td>

                      <td style="padding: 4px; text-align: center; vertical-align: middle">
                        <q-btn
                          flat
                          round
                          dense
                          icon="delete"
                          color="red"
                          :disable="form.processing || form.items.length <= 1"
                          @click="removeItem(index)"
                        />
                      </td>
                    </tr>
                  </tbody>
                </q-markup-table>
              </div>

              <!-- Mobile: kartu per item -->
              <div v-else class="mobile-items-list">
                <div
                  v-for="(item, index) in form.items"
                  :key="index"
                  class="mobile-item-card q-mb-sm"
                >
                  <div class="row items-center justify-between q-mb-sm">
                    <span class="text-caption text-grey-7 text-weight-medium">Produk #{{ index + 1 }}</span>
                    <q-btn
                      flat round dense icon="delete" color="negative" size="sm"
                      :disable="form.processing || form.items.length <= 1"
                      @click="removeItem(index)"
                    />
                  </div>
                  <q-select
                    v-model="item.product_id"
                    :options="itemProductOptions"
                    label="Produk"
                    map-options
                    emit-value
                    dense
                    outlined
                    use-input
                    fill-input
                    hide-selected
                    :disable="form.processing"
                    class="q-mb-sm"
                    @update:model-value="onProductChange(item)"
                  />
                  <div v-if="form.errors[`items.${index}.product_id`]" class="text-caption text-red q-mb-xs">
                    {{ form.errors[`items.${index}.product_id`] }}
                  </div>
                  <div class="row q-col-gutter-sm q-mb-sm">
                    <div class="col-6">
                      <q-input
                        v-model.number="item.quantity"
                        type="number"
                        label="Qty"
                        dense
                        outlined
                        min="0"
                        step="0.01"
                        :disable="form.processing"
                        @update:model-value="updateSubtotal(item)"
                      />
                    </div>
                    <div class="col-6">
                      <q-select
                        v-model="item.unit"
                        :options="itemUnitOptions(item)"
                        label="Satuan"
                        map-options
                        emit-value
                        dense
                        outlined
                        clearable
                        :disable="form.processing"
                        @update:model-value="onUnitChange(item)"
                      />
                    </div>
                  </div>

                  <q-input
                    v-model.number="item.price"
                    type="number"
                    label="Harga (Rp)"
                    dense
                    outlined
                    min="0.01"
                    step="0.01"
                    :disable="form.processing"
                    class="q-mb-sm"
                    @update:model-value="updateSubtotal(item)"
                  />
                  <div v-if="form.errors[`items.${index}.price`]" class="text-caption text-red q-mb-xs">
                    {{ form.errors[`items.${index}.price`] }}
                  </div>
                  <div class="text-right text-weight-bold text-body2 q-mt-xs">
                    Subtotal: Rp {{ formatNumber(item.subtotal) }}
                  </div>
                </div>
              </div>

              <div class="row justify-end q-mt-md">
                <div class="text-subtitle1 text-weight-bold">
                  Grand Total: Rp {{ formatNumber(grandTotal) }}
                </div>
              </div>
            </q-card-section>

            <q-card-section class="q-gutter-sm">
              <q-btn
                icon="save"
                type="submit"
                label="Simpan"
                color="primary"
                :disable="form.processing"
              />
              <q-btn
                icon="cancel"
                label="Batal"
                :disable="form.processing"
                @click="router.get(route('admin.sale.index'))"
              />
            </q-card-section>
          </q-card>
        </q-form>
      </div>
    </q-page>
  </authenticated-layout>
</template>

<style scoped>
.mobile-items-list {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.mobile-item-card {
  border: 1px solid #dde8e4;
  border-radius: 12px;
  padding: 14px;
  background: #fafcfb;
}
</style>
