<template>
  <Layout>
    <Head title="Input Data Hasil Panen" />

    <div class="harvest-page q-pa-sm q-pa-md-md">
      <div class="row q-col-gutter-md items-stretch">
        <div class="col-12 col-lg-8">
          <q-card flat bordered class="harvest-card">
            <q-card-section class="q-pb-none">
              <div class="text-h6 text-weight-bold">Input Data Hasil Panen</div>
              <div class="text-caption text-grey-7 q-mt-xs">
                Form sudah dioptimasi untuk mobile dan desktop, termasuk panen bertahap K1/K2/dst.
              </div>
            </q-card-section>

            <q-card-section>
              <div class="row q-col-gutter-md">
                <div class="col-12 col-md-6">
                  <q-option-group
                    v-model="form.farmer_source"
                    :options="farmerSourceOptions"
                    type="radio"
                    inline
                    dense
                    label="Sumber Data Petani"
                  />
                </div>

                <div class="col-12 col-md-6" v-if="form.farmer_source === 'demo_plot'">
                  <q-select
                    v-model="form.demo_plot_id"
                    :options="demoPlotOptions"
                    option-value="value"
                    option-label="label"
                    emit-value
                    map-options
                    outlined
                    dense
                    label="Pilih Demo Plot Petani"
                    :error="Boolean(errors.demo_plot_id)"
                    :error-message="firstError(errors.demo_plot_id)"
                  />
                </div>

                <div class="col-12 col-md-6">
                  <q-select
                    v-model="form.product_id"
                    :options="productOptions"
                    option-value="value"
                    option-label="label"
                    emit-value
                    map-options
                    outlined
                    dense
                    label="Produk *"
                    :disable="form.farmer_source === 'demo_plot' && Boolean(form.demo_plot_id)"
                    :error="Boolean(errors.product_id)"
                    :error-message="firstError(errors.product_id)"
                  />
                </div>
                <div class="col-12 col-md-6">
                  <q-input
                    v-model="form.farmer_name"
                    outlined
                    dense
                    label="Nama Petani"
                    :disable="form.farmer_source === 'demo_plot'"
                    :error="Boolean(errors.farmer_name)"
                    :error-message="firstError(errors.farmer_name)"
                  />
                </div>

                <div class="col-12" v-if="selectedDemoPlot">
                  <q-banner rounded class="bg-green-1 text-green-9">
                    <div class="text-weight-medium">Data Basic dari Demo Plot otomatis terisi</div>
                    <div class="text-caption q-mt-xs">
                      Petani: <b>{{ selectedDemoPlot.owner_name || '-' }}</b>
                      | Produk: <b>{{ selectedDemoPlot.product_name || '-' }}</b>
                      | Populasi Tanam: <b>{{ safeNumber(selectedDemoPlot.population, 0) }} pohon</b>
                      <span v-if="selectedDemoPlot.plant_date"> | Tgl Tanam: <b>{{ selectedDemoPlot.plant_date }}</b></span>
                    </div>
                  </q-banner>
                </div>

                <div class="col-12 col-md-6">
                  <q-input
                    v-model="form.harvest_date"
                    type="date"
                    outlined
                    dense
                    label="Tanggal Panen *"
                    :error="Boolean(errors.harvest_date)"
                    :error-message="firstError(errors.harvest_date)"
                  />
                </div>
                <div class="col-12 col-md-6">
                  <q-input
                    v-model.number="form.harvest_age_days"
                    type="number"
                    outlined
                    dense
                    label="Umur Tanaman (hari)"
                    min="1"
                    max="999"
                    :error="Boolean(errors.harvest_age_days)"
                    :error-message="firstError(errors.harvest_age_days)"
                  />
                </div>

                <div class="col-12 col-md-6">
                  <q-input
                    v-model.number="form.land_area"
                    type="number"
                    outlined
                    dense
                    label="Luas Lahan (m2)"
                    step="0.01"
                    min="0"
                    :error="Boolean(errors.land_area)"
                    :error-message="firstError(errors.land_area)"
                  />
                </div>
                <div class="col-12 col-md-6 flex items-center">
                  <q-toggle
                    v-model="form.is_multiple_harvest"
                    color="primary"
                    label="Beberapa Kali Panen"
                  />
                </div>

                <div class="col-12 col-md-4">
                  <q-input
                    v-model.number="form.harvest_quantity"
                    type="number"
                    outlined
                    dense
                    :disable="form.is_multiple_harvest"
                    :hint="form.is_multiple_harvest ? 'Otomatis dari total K1/K2/dst (kg)' : 'Satuan panen dipatenkan: kg'"
                    label="Jumlah Panen (kg) *"
                    step="0.01"
                    min="0"
                    :error="Boolean(errors.harvest_quantity)"
                    :error-message="firstError(errors.harvest_quantity)"
                  />
                </div>

                <div class="col-12 col-md-4">
                  <q-input
                    :model-value="selectedDemoPlot ? safeNumber(selectedDemoPlot.population, 0) : '-'"
                    type="number"
                    outlined
                    dense
                    disable
                    label="Populasi Tanam dari Demo Plot (pohon)"
                    min="0"
                  />
                </div>

                <div class="col-12" v-if="form.is_multiple_harvest">
                  <q-banner rounded class="bg-blue-1 text-blue-9 q-mb-sm">
                    Isi panen bertahap per siklus, misalnya K1, K2, K3.
                  </q-banner>
                  <div v-if="errors.harvest_cycles" class="text-negative text-caption q-mb-sm">
                    {{ firstError(errors.harvest_cycles) }}
                  </div>
                  <div class="column q-gutter-sm">
                    <q-card
                      v-for="(cycle, index) in form.harvest_cycles"
                      :key="index"
                      flat
                      bordered
                      class="cycle-card"
                    >
                      <q-card-section class="q-pa-sm">
                        <div class="row q-col-gutter-sm items-center">
                          <div class="col-12 col-md-2">
                            <q-input v-model="cycle.label" dense outlined :label="`Label ${index + 1}`" />
                          </div>
                          <div class="col-12 col-md-3">
                            <q-input v-model="cycle.date" type="date" dense outlined label="Tanggal Panen" />
                          </div>
                          <div class="col-12 col-md-3">
                            <q-input
                              v-model.number="cycle.quantity"
                              type="number"
                              dense
                              outlined
                              label="Jumlah (kg)"
                              min="0"
                              step="0.01"
                            />
                          </div>
                          <div class="col-12 col-md-4 text-right">
                            <q-btn
                              flat
                              round
                              color="negative"
                              icon="delete"
                              @click="removeCycle(index)"
                              :disable="form.harvest_cycles.length === 1"
                            />
                          </div>
                        </div>
                      </q-card-section>
                    </q-card>
                  </div>
                  <q-btn class="q-mt-sm" flat color="primary" icon="add" label="Tambah K" @click="addCycle" />
                </div>

                <div class="col-12 col-md-6">
                  <q-input outlined dense disable model-value="kg" label="Satuan Panen" />
                </div>

                <div class="col-12 col-md-6">
                  <q-input
                    v-model="form.strengths"
                    type="textarea"
                    autogrow
                    outlined
                    dense
                    label="Kelebihan / Keunggulan Panen"
                    :error="Boolean(errors.strengths)"
                    :error-message="firstError(errors.strengths)"
                  />
                </div>
                <div class="col-12 col-md-6">
                  <q-input
                    v-model="form.weaknesses"
                    type="textarea"
                    autogrow
                    outlined
                    dense
                    label="Kelemahan / Masalah Panen"
                    :error="Boolean(errors.weaknesses)"
                    :error-message="firstError(errors.weaknesses)"
                  />
                  <q-file
                    v-model="form.photoFile"
                    outlined
                    dense
                    class="q-mt-sm"
                    label="Upload Foto Kelemahan / Masalah Panen"
                    accept="image/*"
                    clearable
                    @update:model-value="handlePhotoChange"
                    :error="Boolean(errors.photo)"
                    :error-message="firstError(errors.photo)"
                  />
                  <div class="text-caption text-grey-7 q-mt-xs">Format JPG/PNG, maksimal 10MB.</div>
                </div>
                <div class="col-12">
                  <q-input
                    v-model="form.notes"
                    type="textarea"
                    autogrow
                    outlined
                    dense
                    label="Catatan Umum"
                    :error="Boolean(errors.notes)"
                    :error-message="firstError(errors.notes)"
                  />
                </div>
              </div>
            </q-card-section>

            <q-separator />

            <q-card-actions align="right" class="q-pa-md">
              <q-btn flat color="grey-7" label="Reset" @click="resetForm" />
              <q-btn color="primary" :loading="submitting" label="Simpan Data Hasil Panen" @click="submitHarvest" />
            </q-card-actions>
          </q-card>
        </div>

        <div class="col-12 col-lg-4">
          <q-card flat bordered class="harvest-card sticky-summary">
            <q-card-section>
              <div class="text-subtitle1 text-weight-medium">Ringkasan Input</div>
              <div class="text-caption text-grey-7 q-mb-sm">Preview hasil perhitungan otomatis.</div>

              <q-list dense separator>
                <q-item>
                  <q-item-section>Total Panen</q-item-section>
                  <q-item-section side>{{ safeNumber(totalHarvestQuantity, 2) }} kg</q-item-section>
                </q-item>
                <q-item>
                  <q-item-section>Populasi Tanam</q-item-section>
                  <q-item-section side>{{ selectedDemoPlot ? safeNumber(selectedDemoPlot.population, 0) : '-' }} pohon</q-item-section>
                </q-item>
                <q-item>
                  <q-item-section>Produktivitas</q-item-section>
                  <q-item-section side>
                    <span v-if="estimatedProductivity !== null">{{ safeNumber(estimatedProductivity, 2) }} kg/m2</span>
                    <span v-else>-</span>
                  </q-item-section>
                </q-item>
                <q-item v-if="form.is_multiple_harvest">
                  <q-item-section>Siklus Aktif</q-item-section>
                  <q-item-section side>{{ form.harvest_cycles.length }} (K1/K2/dst)</q-item-section>
                </q-item>
              </q-list>
            </q-card-section>
          </q-card>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";
import { Head, usePage } from "@inertiajs/vue3";
import { useQuasar } from "quasar";
import axios from "axios";
import dayjs from "dayjs";
import Layout from "@/layouts/AuthenticatedLayout.vue";

const $q = useQuasar();
const page = usePage();

const products = page.props.products ?? [];
const demoPlots = page.props.demoPlots ?? [];
const productOptions = products.map((product) => ({
  value: product.id,
  label: product.name,
}));
const farmerSourceOptions = [
  { label: "Dropdown Demo Plot", value: "demo_plot" },
  { label: "Input Manual", value: "manual" },
];

const submitting = ref(false);
const errors = ref({});

const form = reactive({
  farmer_source: "demo_plot",
  demo_plot_id: null,
  product_id: null,
  farmer_name: "",
  land_area: null,
  harvest_date: "",
  harvest_age_days: null,
  harvest_quantity: null,
  harvest_unit: "kg",
  is_multiple_harvest: false,
  harvest_cycles: [
    { label: "K1", date: "", quantity: null },
  ],
  strengths: "",
  weaknesses: "",
  notes: "",
  photoFile: null,
});

const demoPlotOptions = computed(() => {
  const selectedProductId = Number(form.product_id || 0);
  return demoPlots
    .filter((item) => {
      if (!selectedProductId) {
        return true;
      }
      return Number(item.product_id) === selectedProductId;
    })
    .map((item) => ({
      value: item.id,
      label: `${item.owner_name || '-'} | ${item.product_name || '-'} | ${safeNumber(item.population, 0)} pohon`,
    }));
});

const selectedDemoPlot = computed(() => {
  return demoPlots.find((item) => Number(item.id) === Number(form.demo_plot_id || 0)) || null;
});

function firstError(value) {
  if (Array.isArray(value)) {
    return value[0] || "";
  }
  return value || "";
}

const totalHarvestQuantity = computed(() => {
  if (!form.is_multiple_harvest) {
    return Number(form.harvest_quantity || 0);
  }
  return form.harvest_cycles.reduce((sum, cycle) => sum + Number(cycle.quantity || 0), 0);
});

const estimatedProductivity = computed(() => {
  const land = Number(form.land_area || 0);
  if (land > 0 && totalHarvestQuantity.value > 0) {
    return totalHarvestQuantity.value / land;
  }
  return null;
});

watch(
  () => form.is_multiple_harvest,
  (isMultiple) => {
    if (isMultiple) {
      form.harvest_quantity = Number(totalHarvestQuantity.value || 0);
      if (form.harvest_cycles.length === 0) {
        form.harvest_cycles.push({ label: "K1", date: "", quantity: null });
      }
    }
  }
);

watch(
  () => form.farmer_source,
  (source) => {
    if (source === "manual") {
      form.demo_plot_id = null;
    }
  }
);

watch(selectedDemoPlot, (plot) => {
  if (!plot || form.farmer_source !== "demo_plot") {
    return;
  }
  form.farmer_name = plot.owner_name || "";
  form.product_id = plot.product_id || null;

  const referenceDate = form.harvest_date || dayjs().format("YYYY-MM-DD");
  if (plot.plant_date) {
    const ageDays = dayjs(referenceDate).diff(dayjs(plot.plant_date), "day");
    form.harvest_age_days = ageDays > 0 ? ageDays : null;
  }
});

watch(
  () => form.harvest_date,
  (date) => {
    if (!date || !selectedDemoPlot.value?.plant_date || form.farmer_source !== "demo_plot") {
      return;
    }
    const ageDays = dayjs(date).diff(dayjs(selectedDemoPlot.value.plant_date), "day");
    form.harvest_age_days = ageDays > 0 ? ageDays : null;
  }
);

watch(totalHarvestQuantity, (value) => {
  if (form.is_multiple_harvest) {
    form.harvest_quantity = Number(value || 0);
  }
});

function addCycle() {
  const nextIndex = form.harvest_cycles.length + 1;
  form.harvest_cycles.push({
    label: `K${nextIndex}`,
    date: "",
    quantity: null,
  });
}

function removeCycle(index) {
  if (form.harvest_cycles.length === 1) {
    return;
  }
  form.harvest_cycles.splice(index, 1);
}

function handlePhotoChange(file) {
  form.photoFile = file || null;
}

function safeNumber(value, decimals) {
  const numeric = Number(value);
  if (!Number.isFinite(numeric) || numeric <= 0) {
    return "0";
  }
  return numeric.toFixed(decimals);
}

function resetForm() {
  form.product_id = null;
  form.farmer_name = "";
  form.land_area = null;
  form.harvest_date = "";
  form.harvest_age_days = null;
  form.harvest_quantity = null;
  form.harvest_unit = "kg";
  form.farmer_source = "demo_plot";
  form.demo_plot_id = null;
  form.is_multiple_harvest = false;
  form.harvest_cycles = [{ label: "K1", date: "", quantity: null }];
  form.strengths = "";
  form.weaknesses = "";
  form.notes = "";
  form.photoFile = null;
  errors.value = {};
}

async function submitHarvest() {
  if (submitting.value) {
    return;
  }

  submitting.value = true;
  errors.value = {};

  try {
    const payload = new FormData();
    payload.append("demo_plot_id", form.demo_plot_id ?? "");
    payload.append("product_id", form.product_id ?? "");
    payload.append("farmer_name", form.farmer_name || "");
    payload.append("land_area", form.land_area ?? "");
    payload.append("harvest_date", form.harvest_date || "");
    payload.append("harvest_age_days", form.harvest_age_days ?? "");
    payload.append("harvest_quantity", totalHarvestQuantity.value || 0);
    payload.append("harvest_unit", "kg");
    payload.append("is_multiple_harvest", form.is_multiple_harvest ? 1 : 0);
    payload.append("strengths", form.strengths || "");
    payload.append("weaknesses", form.weaknesses || "");
    payload.append("notes", form.notes || "");

    if (form.is_multiple_harvest) {
      form.harvest_cycles.forEach((cycle, index) => {
        payload.append(`harvest_cycles[${index}][label]`, cycle.label || `K${index + 1}`);
        payload.append(`harvest_cycles[${index}][date]`, cycle.date || "");
        payload.append(`harvest_cycles[${index}][quantity]`, cycle.quantity ?? "");
      });
    }

    if (form.photoFile) {
      payload.append("photo", form.photoFile);
    }

    const response = await axios.post(route("admin.harvest-result.store"), payload, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });

    $q.notify({
      type: "positive",
      position: "top",
      message: response?.data?.message || "Data hasil panen berhasil disimpan.",
    });
    resetForm();
  } catch (error) {
    if (error?.response?.status === 422 && error?.response?.data?.errors) {
      errors.value = error.response.data.errors;
    }
    $q.notify({
      type: "negative",
      position: "top",
      message: error?.response?.data?.message || "Gagal menyimpan data hasil panen.",
    });
  } finally {
    submitting.value = false;
  }
}
</script>

<style scoped>
.harvest-page {
  max-width: 1400px;
  margin: 0 auto;
}

.harvest-card {
  border-radius: 12px;
}

.cycle-card {
  border-radius: 10px;
  background: #fbfdff;
}

@media (min-width: 1200px) {
  .sticky-summary {
    position: sticky;
    top: 16px;
  }
}
</style>
