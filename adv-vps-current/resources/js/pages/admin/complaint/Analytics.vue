<script setup>
import { computed, onMounted, reactive, ref } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import axios from "axios";
import ECharts from "vue-echarts";
import { create_year_options, create_month_options, formatNumber } from "@/helpers/utils";

const page = usePage();
const title = "Analitik Keluhan";
const loading = ref(false);

const filter = reactive({
  year: "all",
  month: "all",
  product_id: "all",
  status: "all",
});

const data = reactive({
  total: { daily: 0, monthly: 0, yearly: 0, all: 0 },
  by_category: [],
  by_product: [],
  trend: [],
});

const yearNow = new Date().getFullYear();
const years = [{ value: "all", label: "Semua Tahun" }, ...create_year_options(yearNow - 2, yearNow + 1)];
const months = [{ value: "all", label: "Semua Bulan" }, ...create_month_options()];
const productOptions = computed(() => [
  { value: "all", label: "Semua Produk" },
  ...(page.props.products || []).map((p) => ({ value: p.id, label: p.name })),
]);
const statusOptions = [
  { value: "all", label: "Semua Status" },
  { value: "open", label: "Open" },
  { value: "in_progress", label: "In Progress" },
  { value: "resolved", label: "Resolved" },
  { value: "closed", label: "Closed" },
];

const trendOption = computed(() => ({
  tooltip: { trigger: "axis" },
  grid: { top: 12, right: 8, bottom: 28, left: 32, containLabel: true },
  xAxis: {
    type: "category",
    axisLabel: { color: "#4f5965", fontSize: 11 },
    data: (data.trend || []).map((x) => x.label),
  },
  yAxis: {
    type: "value",
    axisLabel: { color: "#4f5965", fontSize: 11 },
    splitLine: { lineStyle: { color: "#e8eff8", type: "dashed" } },
  },
  series: [{
    type: "bar",
    barMaxWidth: 28,
    itemStyle: { color: "#0a3b82", borderRadius: [4, 4, 0, 0] },
    data: (data.trend || []).map((x) => x.total),
    name: "Keluhan",
  }],
}));

const pieOption = computed(() => ({
  tooltip: { trigger: "item" },
  legend: { bottom: 0, textStyle: { fontSize: 11 } },
  series: [{
    type: "pie",
    radius: ["38%", "65%"],
    center: ["50%", "43%"],
    label: { fontSize: 11 },
    data: (data.by_category || []).map((x) => ({ value: x.total, name: x.label })),
  }],
}));

const fetchAnalytics = async () => {
  loading.value = true;
  try {
    const res = await axios.get(route("admin.complaint.analytics-data"), { params: { filter } });
    const d = res.data || {};
    data.total = d.total || { daily: 0, monthly: 0, yearly: 0, all: 0 };
    data.by_category = d.by_category || [];
    data.by_product = d.by_product || [];
    data.trend = d.trend || [];
  } finally {
    loading.value = false;
  }
};

onMounted(fetchAnalytics);
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>
    <template #right-button>
      <q-btn icon="list_alt" dense color="primary" @click="router.get(route('admin.complaint.index'))" />
    </template>

    <div class="analytics-wrap">

      <q-card flat bordered class="panel-card">
        <q-card-section>
          <div class="panel-title">Filter Data</div>
          <div class="filter-grid q-mt-sm">
            <div>
              <div class="field-label">Tahun</div>
              <q-select dense outlined map-options emit-value v-model="filter.year" :options="years" @update:model-value="fetchAnalytics" />
            </div>
            <div>
              <div class="field-label">Bulan</div>
              <q-select dense outlined map-options emit-value v-model="filter.month" :options="months" @update:model-value="fetchAnalytics" />
            </div>
            <div>
              <div class="field-label">Produk</div>
              <q-select dense outlined map-options emit-value v-model="filter.product_id" :options="productOptions" @update:model-value="fetchAnalytics" />
            </div>
            <div>
              <div class="field-label">Status</div>
              <q-select dense outlined map-options emit-value v-model="filter.status" :options="statusOptions" @update:model-value="fetchAnalytics" />
            </div>
          </div>
        </q-card-section>
      </q-card>

      <div class="kpi-grid">
        <q-card flat bordered class="panel-card kpi-card">
          <q-card-section class="kpi-body">
            <div class="kpi-label">Hari Ini</div>
            <div class="kpi-value">{{ formatNumber(data.total.daily || 0) }}</div>
          </q-card-section>
        </q-card>
        <q-card flat bordered class="panel-card kpi-card">
          <q-card-section class="kpi-body">
            <div class="kpi-label">Bulan Ini</div>
            <div class="kpi-value">{{ formatNumber(data.total.monthly || 0) }}</div>
          </q-card-section>
        </q-card>
        <q-card flat bordered class="panel-card kpi-card">
          <q-card-section class="kpi-body">
            <div class="kpi-label">Tahun Ini</div>
            <div class="kpi-value">{{ formatNumber(data.total.yearly || 0) }}</div>
          </q-card-section>
        </q-card>
        <q-card flat bordered class="panel-card kpi-card">
          <q-card-section class="kpi-body">
            <div class="kpi-label">Total</div>
            <div class="kpi-value">{{ formatNumber(data.total.all || 0) }}</div>
          </q-card-section>
        </q-card>
      </div>

      <div class="content-grid">
        <q-card flat bordered class="panel-card panel-trend">
          <q-card-section>
            <div class="panel-title">Trend Keluhan (12 Bulan Terakhir)</div>
            <q-intersection once transition="fade">
              <ECharts class="chart-bar" :option="trendOption" autoresize />
            </q-intersection>
          </q-card-section>
        </q-card>

        <q-card flat bordered class="panel-card panel-pie">
          <q-card-section>
            <div class="panel-title">Distribusi Kategori</div>
            <q-intersection once transition="fade">
              <ECharts class="chart-pie" :option="pieOption" autoresize />
            </q-intersection>
          </q-card-section>
        </q-card>

        <q-card flat bordered class="panel-card panel-table">
          <q-card-section>
            <div class="panel-title">Ringkasan per Kategori</div>
            <div class="table-wrap q-mt-sm">
              <q-markup-table flat bordered dense separator="cell">
                <thead>
                  <tr>
                    <th class="text-left">Kategori</th>
                    <th class="text-right">Jumlah</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="row in data.by_category" :key="row.category">
                    <td>{{ row.label }}</td>
                    <td class="text-right text-weight-bold">{{ formatNumber(row.total || 0) }}</td>
                  </tr>
                  <tr v-if="!data.by_category.length">
                    <td colspan="2" class="text-center text-grey-6">Belum ada data</td>
                  </tr>
                </tbody>
              </q-markup-table>
            </div>
          </q-card-section>
        </q-card>

        <q-card flat bordered class="panel-card panel-table">
          <q-card-section>
            <div class="panel-title">Keluhan per Produk (Top 10)</div>
            <div class="table-wrap q-mt-sm">
              <q-markup-table flat bordered dense separator="cell">
                <thead>
                  <tr>
                    <th class="text-left">Produk</th>
                    <th class="text-right">Keluhan</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="row in (data.by_product || []).slice(0, 10)" :key="row.product_id">
                    <td>{{ row.product_name || '-' }}</td>
                    <td class="text-right text-weight-bold">{{ formatNumber(row.total || 0) }}</td>
                  </tr>
                  <tr v-if="!data.by_product.length">
                    <td colspan="2" class="text-center text-grey-6">Belum ada data</td>
                  </tr>
                </tbody>
              </q-markup-table>
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <q-inner-loading :showing="loading" color="primary" />
  </authenticated-layout>
</template>

<style scoped>
.analytics-wrap {
  padding: 10px;
  width: 100%;
  max-width: 100vw;
  box-sizing: border-box;
  overflow-x: clip;
  margin: 0 auto;
}

.panel-card {
  border-radius: 10px;
  margin-bottom: 10px;
  width: 100%;
  min-width: 0;
  max-width: 100%;
  box-sizing: border-box;
}

.panel-card :deep(.q-card__section) {
  padding: 12px;
}

.filter-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 8px;
}

@media (min-width: 600px) {
  .filter-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (min-width: 1024px) {
  .filter-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

.field-label {
  font-size: 12px;
  margin-bottom: 4px;
}

.filter-grid :deep(.q-field--dense .q-field__control),
.filter-grid :deep(.q-field--outlined .q-field__control) {
  min-height: 40px;
}

.filter-grid :deep(.q-field__native),
.filter-grid :deep(.q-field__input) {
  font-size: 13px;
}

.kpi-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
  margin-bottom: 10px;
}

@media (min-width: 1024px) {
  .kpi-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

.kpi-card {
  overflow: hidden;
  min-height: 96px;
}

.kpi-body {
  text-align: left;
  padding: 12px 10px !important;
  display: flex;
  flex-direction: column;
  justify-content: center;
  height: 100%;
}

.kpi-label {
  font-size: 12px;
  margin-bottom: 6px;
}

.kpi-value {
  font-size: clamp(20px, 5.5vw, 28px);
  font-weight: 800;
  line-height: 1.1;
  font-variant-numeric: tabular-nums;
  word-break: break-all;
}

.content-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 10px;
  width: 100%;
}

@media (min-width: 1024px) {
  .content-grid {
    grid-template-columns: minmax(0, 2fr) minmax(0, 1fr);
  }
}

.panel-trend,
.panel-pie,
.panel-table {
  min-width: 0;
}

@media (min-width: 1024px) {
  .panel-trend {
    grid-column: 1;
  }

  .panel-pie {
    grid-column: 2;
  }

  .panel-table {
    grid-column: span 1;
  }
}

.panel-title {
  font-size: 14px;
  font-weight: 700;
  line-height: 1.3;
  margin-bottom: 2px;
}

.chart-bar {
  height: 240px;
  width: 100%;
}

.chart-pie {
  height: 240px;
  width: 100%;
}

.table-wrap {
  width: 100%;
  overflow-x: auto;
}

.table-wrap :deep(table) {
  width: 100%;
  min-width: 280px;
}

.table-wrap :deep(th) {
  font-size: 12px;
}

.table-wrap :deep(td) {
  font-size: 13px;
}

@media (min-width: 1024px) {
  .analytics-wrap {
    max-width: 1280px;
    padding: 12px;
  }

  .panel-card {
    margin-bottom: 12px;
  }

  .content-grid {
    gap: 12px;
  }

  .chart-bar,
  .chart-pie {
    height: 260px;
  }
}

@media (max-width: 480px) {
  .analytics-wrap {
    padding: 8px;
  }

  .kpi-body {
    padding: 10px 8px !important;
  }

  .kpi-value {
    font-size: 22px;
  }

  .chart-bar,
  .chart-pie {
    height: 210px;
  }
}
</style>

