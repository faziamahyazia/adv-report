<template>
  <Layout>
    <Head title="Input Data Hasil Panen" />

    <div class="harvest-page q-pa-sm q-pa-md-md">
      <div class="row q-col-gutter-md items-stretch harvest-layout">
        <div class="col-12 harvest-main-col">
          <q-card flat bordered class="harvest-card">
            <q-card-section class="q-pb-none">
              <div class="text-h6 text-weight-bold">Input Data Hasil Panen</div>
              <div class="text-caption text-grey-7 q-mt-xs">
                Form sudah dioptimasi untuk mobile dan desktop, termasuk panen bertahap K1/K2/dst.
              </div>
            </q-card-section>

            <q-card-section>
              <div class="row q-col-gutter-md form-grid">
                <div class="col-12 col-md-6 col-xl-3">
                  <q-option-group
                    v-model="form.farmer_source"
                    :options="farmerSourceOptions"
                    type="radio"
                    inline
                    dense
                    label="Sumber Data Petani"
                  />
                </div>

                <div class="col-12 col-md-6 col-xl-9" v-if="form.farmer_source === 'demo_plot'">
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

                <div class="col-12 col-md-6 col-xl-3">
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
                <div class="col-12 col-md-6 col-xl-3">
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

                <div class="col-12 col-md-6 col-xl-3">
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
                <div class="col-12 col-md-6 col-xl-3">
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

                <div class="col-12 col-md-6 col-xl-3">
                  <q-input
                    v-model.number="form.altitude_mdpl"
                    type="number"
                    outlined
                    dense
                    label="Ketinggian (mdpl)"
                    min="0"
                    :hint="altitudeHint"
                    :error="Boolean(errors.altitude_mdpl)"
                    :error-message="firstError(errors.altitude_mdpl)"
                  />
                </div>
                <div class="col-12 col-md-6 col-xl-3 flex items-center">
                  <q-toggle
                    v-model="form.is_multiple_harvest"
                    color="primary"
                    label="Beberapa Kali Panen"
                  />
                </div>

                <div class="col-12 col-md-6 col-xl-3">
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

                <div class="col-12 col-md-6 col-xl-3" v-if="isFreshCornSelected">
                  <q-input
                    v-model.number="form.putren_quantity"
                    type="number"
                    outlined
                    dense
                    label="Hasil Putren (kg)"
                    step="0.01"
                    min="0"
                    hint="Khusus produk Fresh Corn"
                    :error="Boolean(errors.putren_quantity)"
                    :error-message="firstError(errors.putren_quantity)"
                  />
                </div>

                <div class="col-12 col-md-6 col-xl-3">
                  <q-input
                    v-model.number="form.total_pieces"
                    type="number"
                    outlined
                    dense
                    label="Jumlah yang ditanam (PCS)"
                    min="0"
                    step="1"
                    :error="Boolean(errors.total_pieces)"
                    :error-message="firstError(errors.total_pieces)"
                  />
                </div>

                <div class="col-12 col-md-6 col-xl-3">
                  <q-input
                    v-model.number="form.germination_percentage"
                    type="number"
                    outlined
                    dense
                    label="DB / Germinasi (%)"
                    min="0"
                    max="100"
                    step="0.01"
                    :disable="form.farmer_source === 'manual' && form.population_calc_mode === 'from_population'"
                    hint="Contoh: 85 berarti 85% biji tumbuh"
                    :error="Boolean(errors.germination_percentage)"
                    :error-message="firstError(errors.germination_percentage)"
                  />
                </div>

                <div class="col-12 col-md-6 col-xl-6" v-if="form.farmer_source === 'manual'">
                  <q-option-group
                    v-model="form.population_calc_mode"
                    :options="populationCalcModeOptions"
                    type="radio"
                    inline
                    dense
                    label="Mode Perhitungan Estimasi"
                  />
                </div>

                <div class="col-12 col-md-6 col-xl-3">
                  <q-input
                    v-if="form.farmer_source === 'manual' && form.population_calc_mode === 'from_population'"
                    v-model.number="form.estimated_population_input"
                    type="number"
                    outlined
                    dense
                    label="Estimasi Populasi (pohon)"
                    min="0"
                    hint="Isi populasi, germinasi akan terhitung otomatis"
                    :error="Boolean(errors.germination_percentage)"
                    :error-message="firstError(errors.germination_percentage)"
                  />
                  <q-input
                    v-else
                    :model-value="estimatedPopulation !== null ? safeNumber(estimatedPopulation, 0) : '-'"
                    type="number"
                    outlined
                    dense
                    disable
                    label="Estimasi Populasi (pohon)"
                    :hint="form.farmer_source === 'demo_plot' ? 'Otomatis dari populasi demo plot terpilih' : 'Otomatis dari: Jumlah PCS × Biji/PCS × Germinasi%'"
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
                  <div class="column q-gutter-sm cycle-list">
                    <q-card
                      v-for="(cycle, index) in form.harvest_cycles"
                      :key="index"
                      flat
                      bordered
                      class="cycle-card"
                    >
                      <q-card-section class="q-pa-sm">
                        <div class="cycle-grid">
                          <div class="cycle-field cycle-label">
                            <q-input v-model="cycle.label" dense outlined :label="`Label ${index + 1}`" />
                          </div>
                          <div class="cycle-field cycle-date">
                            <q-input v-model="cycle.date" type="date" dense outlined label="Tanggal Panen" />
                          </div>
                          <div class="cycle-field cycle-qty">
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
                          <div class="cycle-field cycle-action">
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

                <div class="col-12 col-md-6 col-xl-3">
                  <q-input outlined dense disable model-value="kg" label="Satuan Panen" />
                </div>

                <div class="col-12 col-md-6 col-xl-6">
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
                <div class="col-12 col-md-6 col-xl-6">
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
                    v-model="form.photoFiles"
                    outlined
                    dense
                    class="q-mt-sm"
                    label="Upload Foto Kelemahan / Masalah Panen"
                    accept="image/*"
                    multiple
                    use-chips
                    clearable
                    @update:model-value="handlePhotoChange"
                    :error="Boolean(errors.weakness_photos)"
                    :error-message="firstError(errors.weakness_photos)"
                  />
                  <div class="text-caption text-grey-7 q-mt-xs">Format JPG/PNG, maksimal 10MB per foto, maksimal 10 foto.</div>
                  <div v-if="photoPreviews.length" class="harvest-photo-grid q-mt-sm">
                    <q-img
                      v-for="(img, idx) in photoPreviews"
                      :key="`new-photo-${idx}`"
                      :src="img"
                      ratio="1"
                      class="harvest-photo-thumb"
                    >
                      <template #error>
                        <div class="harvest-photo-thumb flex flex-center bg-grey-2">
                          <q-icon name="broken_image" size="18px" color="grey-6" />
                        </div>
                      </template>
                    </q-img>
                  </div>
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

        <div class="col-12 harvest-summary-col">
          <q-card flat bordered class="harvest-card summary-card">
            <q-card-section>
              <div class="text-subtitle1 text-weight-medium">Ringkasan Input</div>
              <div class="text-caption text-grey-7 q-mb-sm">Preview hasil perhitungan otomatis.</div>

              <q-list dense separator>
                <q-item>
                  <q-item-section>Total Panen</q-item-section>
                  <q-item-section side>{{ safeNumber(totalHarvestQuantity, 2) }} kg</q-item-section>
                </q-item>
                <q-item>
                  <q-item-section>Jumlah yang ditanam</q-item-section>
                  <q-item-section side>{{ form.total_pieces ? safeNumber(form.total_pieces, 0) : '-' }} PCS</q-item-section>
                </q-item>
                <q-item>
                  <q-item-section>Hasil per PCS</q-item-section>
                  <q-item-section side>
                    <span v-if="estimatedPerPieceYield !== null">{{ safeNumber(estimatedPerPieceYield, 4) }} kg/pcs</span>
                    <span v-else>-</span>
                  </q-item-section>
                </q-item>
                <q-item v-if="isFreshCornSelected">
                  <q-item-section>Hasil Putren</q-item-section>
                  <q-item-section side>{{ form.putren_quantity ? `${safeNumber(form.putren_quantity, 2)} kg` : '-' }}</q-item-section>
                </q-item>
                <q-item v-if="isFreshCornSelected">
                  <q-item-section>Putren per PCS</q-item-section>
                  <q-item-section side>
                    <span v-if="estimatedPutrenPerPieceYield !== null">{{ safeNumber(estimatedPutrenPerPieceYield, 4) }} kg/pcs</span>
                    <span v-else>-</span>
                  </q-item-section>
                </q-item>
                <q-item>
                  <q-item-section>Biji per PCS</q-item-section>
                  <q-item-section side>{{ seedsPerPiece > 0 ? `${safeNumber(seedsPerPiece, 0)} biji` : '-' }}</q-item-section>
                </q-item>
                <q-item>
                  <q-item-section>Total Biji</q-item-section>
                  <q-item-section side>{{ totalSeedCount !== null ? `${safeNumber(totalSeedCount, 0)} biji` : '-' }}</q-item-section>
                </q-item>
                <q-item>
                  <q-item-section>Estimasi Tumbuh</q-item-section>
                  <q-item-section side>
                    <span v-if="estimatedGrownPlants !== null">{{ safeNumber(estimatedGrownPlants, 0) }} pohon</span>
                    <span v-else>-</span>
                  </q-item-section>
                </q-item>
                <q-item>
                  <q-item-section>Hasil per Pohon Tumbuh</q-item-section>
                  <q-item-section side>
                    <span v-if="productivityPerGrownPlant !== null">{{ safeNumber(productivityPerGrownPlant, 4) }} kg/pohon</span>
                    <span v-else>-</span>
                  </q-item-section>
                </q-item>
                <q-item v-if="isFreshCornSelected">
                  <q-item-section>Putren per Pohon</q-item-section>
                  <q-item-section side>
                    <span v-if="putrenPerGrownPlant !== null">{{ safeNumber(putrenPerGrownPlant, 4) }} kg/pohon</span>
                    <span v-else>-</span>
                  </q-item-section>
                </q-item>
                <q-item>
                  <q-item-section>Estimasi Populasi</q-item-section>
                  <q-item-section side>{{ estimatedPopulation !== null ? `${safeNumber(estimatedPopulation, 0)} pohon` : '-' }}</q-item-section>
                </q-item>
                <q-item>
                  <q-item-section>Produktivitas</q-item-section>
                  <q-item-section side>
                    <span v-if="estimatedProductivity !== null">{{ safeNumber(estimatedProductivity, 2) }} kg/m2</span>
                    <span v-else>-</span>
                  </q-item-section>
                </q-item>
                <q-item>
                  <q-item-section>Ketinggian</q-item-section>
                  <q-item-section side>
                    <span v-if="form.altitude_mdpl !== null && form.altitude_mdpl !== ''">
                      {{ safeNumber(form.altitude_mdpl, 0) }} mdpl ({{ altitudeZoneLabel }})
                    </span>
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
  label: product.jumlah_biji_per_pcs
    ? `${product.name} (${safeNumber(product.jumlah_biji_per_pcs, 0)} biji/pcs)`
    : product.name,
}));
const farmerSourceOptions = [
  { label: "Dropdown Demo Plot", value: "demo_plot" },
  { label: "Input Manual", value: "manual" },
];
const populationCalcModeOptions = [
  { label: "Isi Germinasi -> Estimasi Populasi", value: "from_germination" },
  { label: "Isi Estimasi Populasi -> Germinasi", value: "from_population" },
];

const submitting = ref(false);
const errors = ref({});
const photoPreviews = ref([]);

const form = reactive({
  farmer_source: "demo_plot",
  demo_plot_id: null,
  product_id: null,
  farmer_name: "",
  land_area: null,
  altitude_mdpl: null,
  harvest_date: "",
  harvest_age_days: null,
  harvest_quantity: null,
  putren_quantity: null,
  total_pieces: null,
  germination_percentage: null,
  population_calc_mode: "from_germination",
  estimated_population_input: null,
  harvest_unit: "kg",
  is_multiple_harvest: false,
  harvest_cycles: [
    { label: "K1", date: "", quantity: null },
  ],
  strengths: "",
  weaknesses: "",
  notes: "",
  photoFiles: [],
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

const selectedProduct = computed(() => {
  return products.find((item) => Number(item.id) === Number(form.product_id || 0)) || null;
});

const seedsPerPiece = computed(() => {
  return Number(selectedProduct.value?.jumlah_biji_per_pcs || 0);
});

const isFreshCornSelected = computed(() => {
  const categoryName = String(selectedProduct.value?.category_name || "").toLowerCase();
  if (categoryName) {
    return categoryName.includes("fresh corn");
  }
  const name = String(selectedProduct.value?.name || "").toLowerCase();
  return name.includes("fresh corn");
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

const estimatedPerPieceYield = computed(() => {
  const pieces = Number(form.total_pieces || 0);
  if (pieces > 0 && totalHarvestQuantity.value > 0) {
    return totalHarvestQuantity.value / pieces;
  }
  return null;
});

const estimatedPutrenPerPieceYield = computed(() => {
  const pieces = Number(form.total_pieces || 0);
  const putrenQty = Number(form.putren_quantity || 0);
  if (pieces > 0 && putrenQty > 0) {
    return putrenQty / pieces;
  }
  return null;
});

const totalSeedCount = computed(() => {
  const pieces = Number(form.total_pieces || 0);
  if (pieces > 0 && seedsPerPiece.value > 0) {
    return pieces * seedsPerPiece.value;
  }
  return null;
});

const estimatedGrownPlants = computed(() => {
  const germination = Number(form.germination_percentage || 0);
  if (totalSeedCount.value !== null && germination > 0) {
    return totalSeedCount.value * (germination / 100);
  }
  return null;
});

const estimatedPopulation = computed(() => {
  if (form.farmer_source === "demo_plot") {
    const plotPopulation = Number(selectedDemoPlot.value?.population || 0);
    return plotPopulation > 0 ? plotPopulation : null;
  }

  if (form.population_calc_mode === "from_population") {
    const manualPopulation = Number(form.estimated_population_input || 0);
    return manualPopulation > 0 ? Math.round(manualPopulation) : null;
  }

  if (estimatedGrownPlants.value !== null && estimatedGrownPlants.value > 0) {
    return Math.round(estimatedGrownPlants.value);
  }

  return null;
});

const productivityPerGrownPlant = computed(() => {
  if (estimatedGrownPlants.value && estimatedGrownPlants.value > 0 && totalHarvestQuantity.value > 0) {
    return totalHarvestQuantity.value / estimatedGrownPlants.value;
  }
  return null;
});

const putrenPerGrownPlant = computed(() => {
  const putrenQty = Number(form.putren_quantity || 0);
  if (estimatedGrownPlants.value && estimatedGrownPlants.value > 0 && putrenQty > 0) {
    return putrenQty / estimatedGrownPlants.value;
  }
  return null;
});

const altitudeZoneLabel = computed(() => {
  const altitude = Number(form.altitude_mdpl);
  if (!Number.isFinite(altitude) || altitude < 0) {
    return "-";
  }
  if (altitude <= 400) {
    return "Lowland";
  }
  if (altitude <= 700) {
    return "Middleland";
  }
  return "Highland";
});

const altitudeHint = computed(() => {
  const altitude = Number(form.altitude_mdpl);
  if (!Number.isFinite(altitude) || altitude < 0) {
    return "Input angka saja, contoh: 200";
  }
  return `Kategori otomatis: ${altitudeZoneLabel.value}`;
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
      return;
    }

    form.population_calc_mode = "from_germination";
    form.estimated_population_input = null;
  }
);

watch(
  () => form.population_calc_mode,
  (mode) => {
    if (form.farmer_source !== "manual") {
      return;
    }

    if (mode === "from_population") {
      const fallbackPopulation =
        estimatedGrownPlants.value !== null && estimatedGrownPlants.value > 0
          ? Math.round(estimatedGrownPlants.value)
          : null;
      form.estimated_population_input = form.estimated_population_input ?? fallbackPopulation;
    }
  }
);

watch(
  [() => form.farmer_source, () => form.population_calc_mode, totalSeedCount, () => form.estimated_population_input],
  ([source, mode, seeds, populationInput]) => {
    if (source !== "manual" || mode !== "from_population") {
      return;
    }

    const totalSeeds = Number(seeds || 0);
    const population = Number(populationInput || 0);

    if (totalSeeds > 0 && population > 0) {
      const computedGermination = (population / totalSeeds) * 100;
      form.germination_percentage = Number(Math.min(100, computedGermination).toFixed(2));
      return;
    }

    form.germination_percentage = null;
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

watch(isFreshCornSelected, (isFreshCorn) => {
  if (!isFreshCorn) {
    form.putren_quantity = null;
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

function handlePhotoChange(files) {
  photoPreviews.value.forEach((url) => URL.revokeObjectURL(url));
  photoPreviews.value = [];

  if (Array.isArray(files)) {
    form.photoFiles = files.filter(Boolean);
    photoPreviews.value = form.photoFiles.map((file) => URL.createObjectURL(file));
    return;
  }

  form.photoFiles = files ? [files] : [];
  photoPreviews.value = form.photoFiles.map((file) => URL.createObjectURL(file));
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
  form.altitude_mdpl = null;
  form.harvest_date = "";
  form.harvest_age_days = null;
  form.harvest_quantity = null;
  form.putren_quantity = null;
  form.total_pieces = null;
  form.germination_percentage = null;
  form.population_calc_mode = "from_germination";
  form.estimated_population_input = null;
  form.harvest_unit = "kg";
  form.farmer_source = "demo_plot";
  form.demo_plot_id = null;
  form.is_multiple_harvest = false;
  form.harvest_cycles = [{ label: "K1", date: "", quantity: null }];
  form.strengths = "";
  form.weaknesses = "";
  form.notes = "";
  photoPreviews.value.forEach((url) => URL.revokeObjectURL(url));
  photoPreviews.value = [];
  form.photoFiles = [];
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
    payload.append("altitude_mdpl", form.altitude_mdpl ?? "");
    payload.append("harvest_date", form.harvest_date || "");
    payload.append("harvest_age_days", form.harvest_age_days ?? "");
    payload.append("harvest_quantity", totalHarvestQuantity.value || 0);
    payload.append("putren_quantity", isFreshCornSelected.value ? (form.putren_quantity ?? "") : "");
    payload.append("total_pieces", form.total_pieces ?? "");
    payload.append("germination_percentage", form.germination_percentage ?? "");
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

    const selectedFiles = Array.isArray(form.photoFiles)
      ? form.photoFiles
      : (form.photoFiles ? [form.photoFiles] : []);

    if (selectedFiles.length > 0) {
      selectedFiles.forEach((file) => {
        payload.append("weakness_photos[]", file);
      });
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
  width: 100%;
  max-width: none;
  margin: 0;
}

.harvest-card {
  border-radius: 12px;
  width: 100%;
  background: #ffffff;
  border-color: #e5e7eb;
}

.cycle-card {
  border-radius: 10px;
  background: #fbfdff;
}

.cycle-list {
  width: 100%;
}

.cycle-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 8px;
  align-items: end;
}

.cycle-field {
  min-width: 0;
}

.cycle-action {
  display: flex;
  justify-content: flex-end;
}

.harvest-photo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(84px, 1fr));
  gap: 8px;
}

.harvest-photo-thumb {
  border-radius: 8px;
  border: 1px solid #dce7ef;
  overflow: hidden;
}

.harvest-layout {
  width: 100%;
  margin: 0;
}

.harvest-main-col,
.harvest-summary-col {
  width: 100%;
}

.form-grid {
  align-items: start;
}

.summary-card {
  background: #f9fafb;
}

@media (min-width: 1200px) {
  .harvest-page {
    padding-left: 12px;
    padding-right: 12px;
  }

  .harvest-layout {
    margin-left: 0 !important;
    margin-right: 0 !important;
  }

  .harvest-main-col,
  .harvest-summary-col {
    flex: 0 0 100% !important;
    max-width: 100% !important;
    padding-left: 0 !important;
    padding-right: 0 !important;
  }

  .harvest-card {
    border-radius: 14px;
  }

  .form-grid :deep(.q-field__control) {
    min-height: 46px;
  }

  .form-grid :deep(.q-field--outlined .q-field__control) {
    border-radius: 10px;
  }

  .cycle-grid {
    grid-template-columns: 140px minmax(260px, 1fr) minmax(220px, 1fr) 56px;
    gap: 12px;
  }

  .summary-card .q-list {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px;
  }

  .summary-card .q-item {
    border: 1px solid #e5e7eb;
    border-radius: 8px;
  }
}

@media (min-width: 1700px) {
  .harvest-page {
    padding-left: 16px;
    padding-right: 16px;
  }

  .summary-card .q-list {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}
</style>
