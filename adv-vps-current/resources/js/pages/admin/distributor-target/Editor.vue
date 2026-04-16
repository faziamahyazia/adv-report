<script setup>
import { computed, reactive, ref } from "vue";
import { router } from "@inertiajs/vue3";
import { useQuasar } from "quasar";
import axios from "axios";

const $q = useQuasar();

const props = defineProps({
  data: { type: Object, default: null },
  distributors: { type: Array, default: () => [] },
  products: { type: Array, default: () => [] },
  month_labels: { type: Object, default: () => ({}) },
});

const title = props.data ? "Edit Target Distributor" : "Tambah Target Distributor";
const nowMonth = new Date().getMonth() + 1;
const nowYear = new Date().getFullYear();
const thisFiscalYear = nowMonth >= 4 ? nowYear : nowYear - 1;
const monthEntries = Object.entries(props.month_labels);

const fiscalYearOptions = computed(() => {
  const options = [];
  for (let year = thisFiscalYear + 1; year >= thisFiscalYear - 3; year -= 1) {
    options.push({ value: year, label: `FY ${year}/${year + 1}` });
  }
  return options;
});

const distributorOptions = computed(() =>
  props.distributors.map((item) => ({ value: item.id, label: item.name }))
);

const productOptions = computed(() =>
  props.products.map((item) => ({ value: item.id, label: item.name }))
);

const form = reactive({
  id: props.data?.id ?? null,
  distributor_id: props.data?.distributor_id ?? null,
  product_id: props.data?.product_id ?? null,
  fiscal_year: props.data?.fiscal_year ?? thisFiscalYear,
  notes: props.data?.notes ?? "",
  total_target_qty: Number(props.data?.total_target_qty ?? 0),
  monthly_targets: monthEntries.reduce((carry, [key]) => {
    carry[key] = Number(props.data?.[key] ?? 0);
    return carry;
  }, {}),
});

const totalMonthlyTarget = computed(() =>
  Object.values(form.monthly_targets).reduce((sum, value) => sum + Number(value || 0), 0)
);

function distributeEvenly(totalQty) {
  const totalInCents = Math.round(Number(totalQty || 0) * 100);
  const monthCount = monthEntries.length;
  const baseValue = Math.floor(totalInCents / monthCount);
  const remainder = totalInCents - (baseValue * monthCount);

  monthEntries.forEach(([key], index) => {
    form.monthly_targets[key] = (baseValue + (index < remainder ? 1 : 0)) / 100;
  });

  form.total_target_qty = totalInCents / 100;
}

function formatQty(value) {
  return Number(value || 0).toLocaleString("id-ID", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  });
}

const applyingAi = ref(false);

async function applyAiBreakdown() {
  if (!form.distributor_id || !form.product_id || !form.fiscal_year) {
    $q.notify({
      type: "warning",
      message: "Pilih Tahun Fiskal, Distributor, dan Produk sebelum menggunakan AI.",
    });
    return;
  }

  if (Number(form.total_target_qty || 0) <= 0) {
    $q.notify({
      type: "warning",
      message: "Isi dulu Total Target (kg) lebih dari 0.",
    });
    return;
  }

  applyingAi.value = true;
  try {
    const { data } = await axios.get(route("admin.distributor-target.ai-breakdown"), {
      params: {
        distributor_id: form.distributor_id,
        product_id: form.product_id,
        fiscal_year: form.fiscal_year,
        total_target_qty: form.total_target_qty,
      },
    });

    monthEntries.forEach(([key]) => {
      form.monthly_targets[key] = Number(data?.monthly_targets?.[key] ?? 0);
    });

    $q.notify({
      type: "positive",
      message: data?.message || "AI breakdown berhasil diterapkan.",
    });
  } catch (error) {
    const responseErrors = error?.response?.data?.errors;
    const firstError = responseErrors ? Object.values(responseErrors)[0]?.[0] : null;
    $q.notify({
      type: "negative",
      message: firstError || error?.response?.data?.message || "Gagal membuat AI breakdown.",
    });
  } finally {
    applyingAi.value = false;
  }
}

async function submit() {
  try {
    await axios.post(route("admin.distributor-target.save"), {
      id: form.id,
      distributor_id: form.distributor_id,
      product_id: form.product_id,
      fiscal_year: form.fiscal_year,
      notes: form.notes,
      monthly_targets: form.monthly_targets,
    });

    $q.notify({ type: "positive", message: "Target distributor berhasil disimpan." });
    router.get(route("admin.distributor-target.index"), { fiscal_year: form.fiscal_year });
  } catch (error) {
    const responseErrors = error?.response?.data?.errors;
    const firstError = responseErrors ? Object.values(responseErrors)[0]?.[0] : null;
    $q.notify({
      type: "negative",
      message: firstError || error?.response?.data?.message || "Gagal menyimpan target distributor.",
    });
  }
}
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>
    <div class="q-pa-sm editor-page">
      <q-card flat bordered class="editor-card full-width">
        <q-card-section class="q-pb-sm">
          <div class="row q-col-gutter-md">
            <q-select
              class="col-12 col-md-6 col-lg-3"
              v-model="form.fiscal_year"
              :options="fiscalYearOptions"
              emit-value
              map-options
              dense
              outlined
              label="Tahun Fiskal"
            />
            <q-select
              class="col-12 col-md-6 col-lg-3"
              v-model="form.distributor_id"
              :options="distributorOptions"
              emit-value
              map-options
              dense
              outlined
              label="Distributor"
            />
            <q-select
              class="col-12 col-md-6 col-lg-3"
              v-model="form.product_id"
              :options="productOptions"
              emit-value
              map-options
              dense
              outlined
              label="Produk"
            />
            <div class="col-12 col-md-6 col-lg-3">
              <div class="row q-col-gutter-sm items-center">
                <q-input
                  class="col"
                  v-model.number="form.total_target_qty"
                  type="number"
                  min="0"
                  step="0.01"
                  dense
                  outlined
                  label="Total Target (kg)"
                />
                <div class="col-auto row q-gutter-sm">
                  <q-btn
                    color="secondary"
                    icon="calendar_view_month"
                    label="Bagi Rata 12 Bulan"
                    no-caps
                    @click="distributeEvenly(form.total_target_qty)"
                  />
                  <q-btn
                    color="primary"
                    icon="auto_awesome"
                    label="Gunakan AI"
                    no-caps
                    :loading="applyingAi"
                    @click="applyAiBreakdown"
                  />
                </div>
              </div>
            </div>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-section>
          <div class="text-subtitle1 text-weight-bold q-mb-sm">Breakdown Bulanan</div>
          <div class="month-grid">
            <q-input
              v-for="([key, label]) in monthEntries"
              :key="key"
              v-model.number="form.monthly_targets[key]"
              type="number"
              min="0"
              step="0.01"
              dense
              outlined
              :label="`${label} (kg)`"
            />
          </div>
          <div class="text-caption text-grey-7 q-mt-sm">
            Total breakdown saat ini: <b>{{ formatQty(totalMonthlyTarget) }} kg</b>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-section>
          <q-input
            v-model="form.notes"
            type="textarea"
            autogrow
            outlined
            dense
            label="Catatan"
          />
        </q-card-section>

        <q-card-actions align="right" class="q-px-md q-pb-md">
          <q-btn flat label="Batal" no-caps @click="router.get(route('admin.distributor-target.index'))" />
          <q-btn color="primary" label="Simpan" no-caps @click="submit" />
        </q-card-actions>
      </q-card>
    </div>
  </authenticated-layout>
</template>

<style scoped>
.editor-page {
  width: 100%;
}

.editor-card {
  width: 100%;
}

.month-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
}

@media (min-width: 768px) {
  .month-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

@media (min-width: 1280px) {
  .month-grid {
    grid-template-columns: repeat(6, minmax(0, 1fr));
  }
}
</style>