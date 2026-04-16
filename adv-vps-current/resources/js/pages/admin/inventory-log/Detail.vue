<script setup>
import { formatNumber } from "@/helpers/utils";
import { router, usePage } from "@inertiajs/vue3";
import { useQuasar } from "quasar";

const page = usePage();
const title = `Rincian Log Inventori #${page.props.data.id}`;
const $q = useQuasar();

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

const getDisplayCustomerName = (item) => {
  if (item?.sale?.retailer?.name && String(item?.notes || "").startsWith("[SALE_SYNC")) {
    return item.sale.retailer.name;
  }

  return item?.customer?.name || "-";
};

const getSaleItemForRow = (item) => {
  const saleItems = item?.sale?.items || [];
  return saleItems.find((saleItem) => Number(saleItem.product_id) === Number(item?.product_id)) || null;
};

const formatInventoryQuantity = (item) => {
  const saleItem = getSaleItemForRow(item);
  const product = item?.product || {};
  const uom1 = normalizeUnit(product.uom_1 || product.unit || "kg");
  const uom2 = normalizeUnit(product.uom_2 || (uom1 === "kg" ? "pcs" : "kg"));
  const weight = parseFloat(product.weight || 0);

  let primaryValue, primaryUOM;
  let secondaryValue, secondaryUOM;
  const rowPrimaryQty = Number(item?.quantity || 0);
  const movementPrimaryQty = Math.abs(Number(item?.movement_quantity || 0));
  const salePrimaryQty = saleItem
    ? convertToPrimaryFromUnit(product, saleItem.quantity, saleItem.unit)
    : 0;

  const saleBaseQuantity = Number(saleItem?.base_quantity || 0);
  const rowBaseQuantity = Number(item?.base_quantity || 0);
  const convertedBaseQuantity = (() => {
    const primaryCandidate = rowPrimaryQty > 0
      ? rowPrimaryQty
      : (movementPrimaryQty > 0 ? movementPrimaryQty : salePrimaryQty);

    if (primaryCandidate <= 0 || weight <= 0) return 0;

    if (uom1 === "kg" && uom2 === "pcs") {
      return Number(((primaryCandidate * 1000) / weight).toFixed(2));
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
        : (uom1 === "kg" && uom2 === "pcs" && baseQuantityValue > 0 && weight > 0
          ? Number(((baseQuantityValue * weight) / 1000).toFixed(3))
          : 0)));

  if (uom1 === "pcs") {
    primaryUOM = uom1;
    secondaryUOM = uom2;
    primaryValue = formatNumber(baseQuantityValue);
    
    if (weight > 0 && baseQuantityValue) {
      const calc = (baseQuantityValue * weight) / 1000;
      secondaryValue = formatKg(calc);
    } else {
      secondaryValue = formatKg(quantityValue);
    }
  } else if (uom1 === "kg") {
    primaryUOM = uom1;
    secondaryUOM = uom2;
    primaryValue = formatKg(quantityValue);
    
    if (weight > 0 && quantityValue) {
      const calc = (quantityValue * 1000) / weight;
      secondaryValue = formatNumber(calc);
    } else {
      secondaryValue = formatNumber(baseQuantityValue);
    }
  } else {
    primaryUOM = uom1;
    secondaryUOM = uom2;
    primaryValue = formatNumber(baseQuantityValue);
    secondaryValue = formatKg(quantityValue);
  }

  return `${primaryValue} ${primaryUOM} / ${secondaryValue} ${secondaryUOM}`;
};
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>

    <template #left-button>
      <div class="q-gutter-sm">
        <q-btn
          icon="arrow_back"
          dense
          color="grey-7"
          flat
          rounded
          @click="router.get(route('admin.inventory-log.index'))"
        />
      </div>
    </template>

    <template #right-button>
      <div class="q-gutter-sm">
        <q-btn
          icon="edit"
          dense
          color="primary"
          v-if="$can('admin.inventory-log.edit')"
          @click="
            router.get(
              route('admin.inventory-log.edit', { id: page.props.data.id })
            )
          "
        />
      </div>
    </template>

    <div class="row justify-center">
      <div class="col col-lg-6 q-pa-sm">
        <div class="row">
          <q-card square flat bordered class="col">
            <q-card-section>
              <table class="detail">
                <tbody>
                  <tr>
                    <td style="width: 120px">Tanggal Cek</td>
                    <td style="width: 1px">:</td>
                    <td>
                      {{
                        $dayjs(new Date(page.props.data.check_date)).format(
                          "dddd, D MMMM YYYY"
                        )
                      }}
                    </td>
                  </tr>
                  <tr>
                    <td>Area</td>
                    <td>:</td>
                    <td>{{ page.props.data.area || "-" }}</td>
                  </tr>
                  <tr>
                    <td>Varietas</td>
                    <td>:</td>
                    <td>{{ page.props.data.product?.name || "-" }}</td>
                  </tr>
                  <tr>
                    <td>Client</td>
                    <td>:</td>
                    <td>{{ page.props.data.customer?.name || "-" }}</td>
                  </tr>
                  <tr>
                    <td>Lot/Package</td>
                    <td>:</td>
                    <td>{{ page.props.data.lot_package || "-" }}</td>
                  </tr>
                  <tr>
                    <td>Quantity</td>
                    <td>:</td>
                    <td>
                      {{ formatInventoryQuantity(page.props.data) }}
                    </td>
                  </tr>
                  <tr>
                    <td>Catatan</td>
                    <td>:</td>
                    <td>{{ page.props.data.notes || "-" }}</td>
                  </tr>
                  <tr v-if="!!page.props.data.created_datetime">
                    <td>Dibuat</td>
                    <td>:</td>
                    <td>
                      <template v-if="page.props.data.created_by">
                        <i-link
                          :href="
                            route('admin.user.detail', {
                              id: page.props.data.created_by_uid,
                            })
                          "
                        >
                          {{ page.props.data.created_by.username }} -
                          {{ page.props.data.created_by.name }}
                        </i-link>
                        -
                      </template>
                      {{
                        $dayjs(
                          new Date(page.props.data.created_datetime)
                        ).format("dddd, D MMMM YYYY [pukul] HH:mm:ss")
                      }}
                    </td>
                  </tr>

                  <tr v-if="!!page.props.data.updated_datetime">
                    <td>Diperbarui</td>
                    <td>:</td>
                    <td>
                      <template v-if="page.props.data.updated_by">
                        <i-link
                          :href="
                            route('admin.user.detail', {
                              id: page.props.data.updated_by_uid,
                            })
                          "
                        >
                          {{ page.props.data.updated_by.username }} -
                          {{ page.props.data.updated_by.name }}
                        </i-link>
                        -
                      </template>
                      {{
                        $dayjs(
                          new Date(page.props.data.updated_datetime)
                        ).format("dddd, D MMMM YYYY [pukul] HH:mm:ss")
                      }}
                    </td>
                  </tr>
                </tbody>
              </table>
            </q-card-section>
          </q-card>
        </div>
      </div>
    </div>
  </authenticated-layout>
</template>
