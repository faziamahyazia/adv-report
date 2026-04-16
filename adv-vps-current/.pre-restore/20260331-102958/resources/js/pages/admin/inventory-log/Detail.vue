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

const formatInventoryQuantity = (item) => {
  const product = item?.product || {};
  const uom1 = String(product.uom_1 || "pcs").toLowerCase();
  const uom2 = String(product.uom_2 || "kg").toLowerCase();
  const weight = parseFloat(product.weight || 0);

  let primaryValue, primaryUOM;
  let secondaryValue, secondaryUOM;

  // Determine which field is primary based on uom_1
  if (uom1 === "pcs") {
    // Primary: base_quantity (pcs), Secondary: quantity (kg)
    primaryUOM = uom1;
    secondaryUOM = uom2;
    primaryValue = formatNumber(item?.base_quantity || 0);
    
    // Secondary calculated from base_quantity
    if (weight > 0 && item?.base_quantity) {
      const calc = (item.base_quantity * weight) / 1000;
      secondaryValue = formatKg(calc);
    } else {
      secondaryValue = formatKg(item?.quantity || 0);
    }
  } else if (uom1 === "kg") {
    // Primary: quantity (kg), Secondary: base_quantity (pcs)
    primaryUOM = uom1;
    secondaryUOM = uom2;
    primaryValue = formatKg(item?.quantity || 0);
    
    // Secondary calculated from quantity
    if (weight > 0 && item?.quantity) {
      const calc = (item.quantity * 1000) / weight;
      secondaryValue = formatNumber(calc);
    } else {
      secondaryValue = formatNumber(item?.base_quantity || 0);
    }
  } else {
    // Default fallback
    primaryUOM = uom1;
    secondaryUOM = uom2;
    primaryValue = formatNumber(item?.base_quantity || 0);
    secondaryValue = formatKg(item?.quantity || 0);
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
