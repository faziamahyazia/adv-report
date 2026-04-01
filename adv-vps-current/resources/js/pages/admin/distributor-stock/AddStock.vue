<script setup>
import { router, useForm, usePage } from "@inertiajs/vue3";
import { computed } from "vue";
import { useQuasar } from "quasar";
import { handleSubmit } from "@/helpers/client-req-handler";

const page = usePage();
const $q = useQuasar();
const title = "Tambah Stok Distributor";
const isMobile = computed(() => $q.screen.lt.md);

const distributorOptions = computed(() =>
  (page.props.distributors || []).map((item) => ({
    value: item.id,
    label: item.name,
  }))
);

const productOptions = computed(() =>
  (page.props.products || []).map((item) => ({
    value: item.id,
    label: item.name,
  }))
);

const selectedProduct = computed(() =>
  (page.props.products || []).find((item) => Number(item.id) === Number(form.product_id)) || null
);

const lotUnitOptions = computed(() => {
  const p = selectedProduct.value;
  if (!p) return [];
  const units = [p.uom_1, p.uom_2].filter((u) => !!u);
  return [...new Set(units)].map((u) => ({ value: u, label: u }));
});

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

const form = useForm({
  distributor_id: null,
  product_id: null,
  notes: "",
  lots: [{ lot_number: "", expired_date: null, quantity: null, unit: "" }],
});

const totalQty = computed(() =>
  form.lots.reduce((sum, l) => sum + toBaseQty(selectedProduct.value, parseFloat(l.quantity) || 0, l.unit || selectedProduct.value?.uom_1), 0)
);

const addLot = () => form.lots.push({ lot_number: "", expired_date: null, quantity: null, unit: selectedProduct.value?.uom_1 || "" });
const removeLot = (i) => {
  if (form.lots.length > 1) form.lots.splice(i, 1);
};

const onProductChange = () => {
  const defaultUnit = selectedProduct.value?.uom_1 || "";
  form.lots.forEach((lot) => {
    lot.unit = lot.unit || defaultUnit;
  });
};

const submit = () => {
  if (!selectedProduct.value) {
    return;
  }

  const defaultUnit = selectedProduct.value.uom_1 || selectedProduct.value.uom_2 || "";
  form.lots.forEach((lot) => {
    lot.unit = lot.unit || defaultUnit;
  });

  handleSubmit({
    form,
    url: route("admin.distributor-stock.save"),
  });
};
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>

    <template #left-button>
      <q-btn
        icon="arrow_back"
        dense
        color="grey-7"
        flat
        rounded
        @click="router.get(route('admin.distributor-stock.index'))"
      />
    </template>

    <q-page class="row justify-center">
      <div class="col col-md-6 q-pa-sm">
        <q-form class="row" @submit.prevent="submit">
          <q-card square flat bordered class="col">
            <q-inner-loading :showing="form.processing">
              <q-spinner size="50px" color="primary" />
            </q-inner-loading>

            <q-card-section>
              <q-select
                v-model="form.distributor_id"
                label="Distributor"
                :options="distributorOptions"
                map-options
                emit-value
                use-input
                fill-input
                hide-selected
                :disable="form.processing"
                :error="!!form.errors.distributor_id"
                :error-message="form.errors.distributor_id"
              />

              <q-select
                v-model="form.product_id"
                label="Produk"
                :options="productOptions"
                map-options
                emit-value
                use-input
                fill-input
                hide-selected
                @update:model-value="onProductChange"
                :disable="form.processing"
                :error="!!form.errors.product_id"
                :error-message="form.errors.product_id"
              />

              <!-- Rincian No Lot -->
              <div class="q-mt-sm">
                <div class="row items-center justify-between q-mb-xs">
                  <div class="text-subtitle2 text-grey-8">Rincian No. Lot</div>
                  <div class="text-caption text-grey-6">
                    Total ({{ selectedProduct?.uom_1 || 'base unit' }}):
                    <strong>{{ totalQty.toLocaleString("id-ID") }}</strong>
                  </div>
                </div>

                <div
                  v-for="(lot, i) in form.lots"
                  :key="i"
                  class="q-mb-sm"
                >
                  <q-card flat bordered class="bg-grey-1">
                    <q-card-section class="q-pa-sm">
                      <div class="row items-center justify-between q-mb-xs">
                        <div class="text-caption text-weight-medium text-grey-8">Lot #{{ i + 1 }}</div>
                        <q-btn
                          flat
                          round
                          dense
                          icon="remove_circle_outline"
                          color="negative"
                          :disable="form.lots.length <= 1 || form.processing"
                          @click="removeLot(i)"
                        />
                      </div>

                      <div class="row q-col-gutter-sm">
                        <div class="col-12 col-md-4">
                          <q-input
                            v-model.trim="lot.lot_number"
                            dense
                            outlined
                            :label="'No. Lot'"
                            placeholder="Contoh: LOT-001"
                            :disable="form.processing"
                          />
                        </div>

                        <div class="col-12 col-md-3">
                          <q-input
                            v-model="lot.expired_date"
                            dense
                            outlined
                            type="date"
                            label="Expired"
                            :disable="form.processing"
                            :error="!!form.errors['lots.' + i + '.expired_date']"
                            :error-message="form.errors['lots.' + i + '.expired_date']"
                          />
                        </div>

                        <div class="col-7 col-md-3">
                          <q-input
                            v-model.number="lot.quantity"
                            dense
                            outlined
                            type="number"
                            min="0.01"
                            step="0.01"
                            label="Qty"
                            :disable="form.processing"
                            :error="!!form.errors['lots.' + i + '.quantity']"
                            :error-message="form.errors['lots.' + i + '.quantity']"
                          />
                        </div>

                        <div class="col-5 col-md-2">
                          <q-select
                            v-model="lot.unit"
                            dense
                            outlined
                            map-options
                            emit-value
                            :options="lotUnitOptions"
                            label="Satuan"
                            :disable="form.processing || !selectedProduct"
                            :error="!!form.errors['lots.' + i + '.unit']"
                            :error-message="form.errors['lots.' + i + '.unit']"
                          />
                        </div>
                      </div>
                    </q-card-section>
                  </q-card>
                </div>

                <q-btn
                  flat
                  dense
                  icon="add_circle_outline"
                  color="primary"
                  label="Tambah Lot"
                  :disable="form.processing"
                  @click="addLot"
                />
                <div v-if="form.errors.lots" class="text-negative text-caption q-mt-xs">
                  {{ form.errors.lots }}
                </div>
                <div v-if="isMobile" class="text-caption text-grey-7 q-mt-xs">
                  Tip: isi Qty lalu pilih satuan agar perhitungan stok akurat.
                </div>
              </div>

              <q-input
                v-model.trim="form.notes"
                type="textarea"
                autogrow
                maxlength="500"
                counter
                label="Catatan"
                :disable="form.processing"
                :error="!!form.errors.notes"
                :error-message="form.errors.notes"
              />
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
                @click="router.get(route('admin.distributor-stock.index'))"
              />
            </q-card-section>
          </q-card>
        </q-form>
      </div>
    </q-page>
  </authenticated-layout>
</template>
