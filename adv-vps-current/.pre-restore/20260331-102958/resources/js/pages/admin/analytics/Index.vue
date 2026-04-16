<script setup>
import { reactive, ref, computed, onMounted, watch } from "vue";
import { usePage } from "@inertiajs/vue3";
import { useQuasar } from "quasar";
import ECharts from "vue-echarts";
import axios from "axios";
import { formatNumber, create_month_options, current_year, current_month } from "@/helpers/utils";

const $q      = useQuasar();
const page    = usePage();
const title   = "Analitik Penjualan";
const loading = ref(true);  // Start with true to show spinner initially
const showFilter = ref(true);
const compareChartType = ref("line");
const showCompareTable = ref(true);

const defaultFiscalYear = page.props.default_fiscal_year ?? current_year();
const nowMonth          = current_month();
const isMobile          = computed(() => $q.screen.lt.sm);

// ── Filter ────────────────────────────────────────────────────────────────
const filter = reactive({
  fiscal_year:    defaultFiscalYear,
  compare_fy_a:   defaultFiscalYear,
  compare_fy_b:   defaultFiscalYear - 1,
  month:          0,       // 0 = all months
  sale_type:      "",      // "" = all
  distributor_id: "",
});

const fiscalYears = Array.from({ length: 4 }, (_, i) => {
  const y = defaultFiscalYear - 1 + i;
  return { value: y, label: `${y} / ${y + 1}` };
});

const monthOptions = [
  { value: 0, label: "Semua Bulan" },
  ...create_month_options(),
];

const saleTypeOptions = [
  { value: "",            label: "Semua Tipe"   },
  { value: "retailer",    label: "Retailer"     },
  { value: "distributor", label: "Distributor"  },
];

const distributors = computed(() => [
  { value: "", label: "Semua Distributor" },
  ...(page.props.distributors ?? []).map(d => ({ value: d.id, label: d.name })),
]);

// ── Data ──────────────────────────────────────────────────────────────────
const summary       = ref({ total_sales: 0, total_transactions: 0, avg_per_transaction: 0 });
const monthly       = ref([]);
const byProduct     = ref([]);
const fyCompare     = ref({
  fy_current: filter.fiscal_year,
  fy_previous: Number(filter.fiscal_year) - 1,
  labels: [],
  current_monthly: [],
  previous_monthly: [],
  current_total: 0,
  previous_total: 0,
  total_growth_percent: null,
  current_avg_monthly: 0,
  previous_avg_monthly: 0,
  avg_growth_percent: null,
});

const monthlyXAxisLabels = computed(() => {
  return monthly.value.map((m) => {
    if (!isMobile.value) return m.label;
    const raw = String(m.label ?? "");
    return raw.length > 3 ? raw.slice(0, 3) : raw;
  });
});
const byDistributor = ref([]);
const byRegion      = ref([]);

async function fetchData() {
  loading.value = true;
  try {
    const params = {
      fiscal_year: filter.fiscal_year,
      compare_fy_a: filter.compare_fy_a,
      compare_fy_b: filter.compare_fy_b,
    };
    if (filter.month)          params.month          = filter.month;
    if (filter.sale_type)      params.sale_type      = filter.sale_type;
    if (filter.distributor_id) params.distributor_id = filter.distributor_id;

    const res = await axios.get(route("admin.analytics.sales-chart"), { params });
    if (res.data && res.data.summary) {
      summary.value       = res.data.summary || {};
      monthly.value       = res.data.monthly || [];
      byProduct.value     = res.data.by_product || [];
      byDistributor.value = res.data.by_distributor || [];
      byRegion.value      = res.data.by_region || [];
      fyCompare.value     = res.data.fy_compare || fyCompare.value;
    }
  } catch (e) {
    console.error("Analytics Error:", e);
    $q.notify({ type: "negative", message: "Gagal memuat data analitik: " + (e.message || "Unknown error") });
    // Set empty state
    summary.value = { total_sales: 0, total_transactions: 0, avg_per_transaction: 0 };
    monthly.value = [];
    byProduct.value = [];
    byDistributor.value = [];
    byRegion.value = [];
  } finally {
    loading.value = false;
  }
}

onMounted(fetchData);
watch(filter, fetchData, { deep: true });

// ── Chart colors ──────────────────────────────────────────────────────────
const COLORS = [
  "#1976D2","#43A047","#FB8C00","#E53935","#8E24AA",
  "#00ACC1","#F4511E","#6D4C41","#546E7A","#039BE5",
];

// ── Monthly Trend ─────────────────────────────────────────────────────────
const monthlyOption = computed(() => ({
  grid: isMobile.value
    ? { left: 14, right: 8, top: 62, bottom: 44, containLabel: true }
    : { left: 60, right: 60, top: 32, bottom: 44, containLabel: true },
  tooltip: { trigger: "axis", axisPointer: { type: "shadow" },
    formatter(params) {
      const label = params[0]?.axisValue ?? "";
      let html = `<div style="font-size:12px;font-weight:700;margin-bottom:4px">${label}</div>`;
      params.forEach(p => {
        const val = p.seriesIndex === 0
          ? "Rp " + formatNumber(p.value, "id-ID", 0)
          : p.value + " transaksi";
        html += `<div style="display:flex;gap:8px;font-size:12px"><span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:${p.color};margin-top:3px;flex-shrink:0"></span><span style="flex:1">${p.seriesName}</span><b>${val}</b></div>`;
      });
      return html;
    }
  },
  legend: isMobile.value
    ? { top: 8, left: "center", data: ["Total Penjualan", "Transaksi"], textStyle: { fontSize: 10 } }
    : { bottom: 0, data: ["Total Penjualan", "Transaksi"] },
  xAxis: {
    type: "category",
    data: monthlyXAxisLabels.value,
    axisTick: { alignWithLabel: true },
    axisLabel: {
      fontSize: isMobile.value ? 9 : 10,
      rotate: 0,
      margin: isMobile.value ? 10 : 8,
      hideOverlap: true,
    },
  },
  yAxis:   [
    { type: "value", name: "Rp", axisLabel: { fontSize: 9, formatter: v => v >= 1e6 ? (v/1e6).toFixed(0)+"Jt" : v >= 1e3 ? (v/1e3).toFixed(0)+"K" : v } },
    { type: "value", name: "Trx", axisLabel: { fontSize: 9 }, splitLine: { show: false } },
  ],
  series:  [
    {
      name: "Total Penjualan", type: "bar", data: monthly.value.map(m => m.total),
      itemStyle: { color: "#1976D2" }, yAxisIndex: 0,
      label: { show: false },
    },
    {
      name: "Transaksi", type: "line", data: monthly.value.map(m => m.count),
      itemStyle: { color: "#FB8C00" }, yAxisIndex: 1,
      symbol: "circle", symbolSize: 6,
    },
  ],
}));

// ── By Product (Pie) ──────────────────────────────────────────────────────
const byProductOption = computed(() => ({
  tooltip: { trigger: "item", formatter: "{b}: Rp{c} ({d}%)" },
  legend:  { orient: "vertical", right: 0, top: "center", textStyle: { fontSize: 10 } },
  series:  [{
    type: "pie", radius: ["40%", "70%"],
    center: ["35%", "50%"],
    data: byProduct.value.map((p, i) => ({
      name: p.name.length > 20 ? p.name.substring(0, 18) + "…" : p.name,
      value: p.total,
      itemStyle: { color: COLORS[i % COLORS.length] },
    })),
    label: { show: false },
    emphasis: { label: { show: true, fontSize: 12 } },
  }],
}));

// ── By Distributor (Bar) ─────────────────────────────────────────────────
const byDistributorOption = computed(() => ({
  grid: { left: 20, right: 60, top: 8, bottom: 8, containLabel: true },
  tooltip: { trigger: "axis", formatter(params) {
    const p = params[0];
    return `<b>${p.name}</b><br>Rp ${formatNumber(p.value, "id-ID", 0)}`;
  }},
  xAxis: { type: "value", axisLabel: { fontSize: 9, formatter: v => v >= 1e6 ? (v/1e6).toFixed(0)+"Jt" : v } },
  yAxis: {
    type: "category",
    data: byDistributor.value.map(d => d.name.length > 18 ? d.name.substring(0, 16) + "…" : d.name).reverse(),
    axisLabel: { fontSize: 10 },
  },
  series: [{
    type: "bar", barMaxWidth: 18,
    data: byDistributor.value.map(d => d.total).reverse(),
    itemStyle: { color: "#43A047" },
    label: { show: true, position: "right", fontSize: 9, formatter: v => v.value >= 1e6 ? "Rp"+(v.value/1e6).toFixed(1)+"Jt" : "" },
  }],
}));

// ── By Region (Bar) ──────────────────────────────────────────────────────
const byRegionOption = computed(() => ({
  grid: { left: 20, right: 60, top: 8, bottom: 8, containLabel: true },
  tooltip: { trigger: "axis", formatter(params) {
    const p = params[0];
    return `<b>${p.name}</b><br>Rp ${formatNumber(p.value, "id-ID", 0)}`;
  }},
  xAxis: { type: "value", axisLabel: { fontSize: 9, formatter: v => v >= 1e6 ? (v/1e6).toFixed(0)+"Jt" : v } },
  yAxis: {
    type: "category",
    data: byRegion.value.map(r => r.name).reverse(),
    axisLabel: { fontSize: 10 },
  },
  series: [{
    type: "bar", barMaxWidth: 18,
    data: byRegion.value.map(r => r.total).reverse(),
    itemStyle: { color: "#8E24AA" },
    label: { show: true, position: "right", fontSize: 9, formatter: v => v.value >= 1e6 ? "Rp"+(v.value/1e6).toFixed(1)+"Jt" : "" },
  }],
}));

// ── Helpers ───────────────────────────────────────────────────────────────
function rupiah(val) {
  if (val >= 1e9)  return "Rp " + formatNumber(val / 1e9, "id-ID", 1) + " M";
  if (val >= 1e6)  return "Rp " + formatNumber(val / 1e6, "id-ID", 1) + " Jt";
  return "Rp " + formatNumber(val, "id-ID", 0);
}

const periodLabel = computed(() => {
  const fy = Number(filter.fiscal_year);
  const monthLabel = monthOptions.find((m) => m.value === filter.month)?.label ?? "Semua Bulan";
  return `FY ${fy}/${fy + 1} • ${monthLabel}`;
});

const activeFilterCount = computed(() => {
  let count = 1; // fiscal year is always active
  if (filter.month) count += 1;
  if (filter.sale_type) count += 1;
  if (filter.distributor_id) count += 1;
  return count;
});

const topProducts = computed(() => byProduct.value.slice(0, 5));
const topDistributors = computed(() => byDistributor.value.slice(0, 5));

const fyGrowthLabel = computed(() => {
  const growth = fyCompare.value?.total_growth_percent;
  if (growth === null || growth === undefined) return "-";
  return `${growth >= 0 ? "+" : ""}${formatNumber(growth, "id-ID", 2)}%`;
});

const fyAvgGrowthLabel = computed(() => {
  const growth = fyCompare.value?.avg_growth_percent;
  if (growth === null || growth === undefined) return "-";
  return `${growth >= 0 ? "+" : ""}${formatNumber(growth, "id-ID", 2)}%`;
});

const fyCompareOption = computed(() => {
  const labels = fyCompare.value?.labels || [];
  const currentData = fyCompare.value?.current_monthly || [];
  const previousData = fyCompare.value?.previous_monthly || [];
  const growthData = fyCompare.value?.growth_monthly || [];
  const currentLabel = `FY ${fyCompare.value?.fy_current}/${Number(fyCompare.value?.fy_current || 0) + 1}`;
  const previousLabel = `FY ${fyCompare.value?.fy_previous}/${Number(fyCompare.value?.fy_previous || 0) + 1}`;
  const isBar = compareChartType.value === "bar";
  const isMixed = compareChartType.value === "mixed";
  const isArea = compareChartType.value === "area";
  const isScatter = compareChartType.value === "scatter";
  const isRadar = compareChartType.value === "radar";

  // Scatter chart data preparation
  const scatterData = labels.map((label, idx) => ({
    value: [currentData[idx] || 0, previousData[idx] || 0],
    name: label,
    itemStyle: {
      color: growthData[idx] >= 0 ? "#22c55e" : "#ef4444",
    },
  }));

  // Radar chart data preparation
  const maxVal = Math.max(...currentData, ...previousData, 1) * 1.2;
  const radarConfig = {
    tooltip: { trigger: "item", formatter: params => {
      if (!params || !params.name) return "";
      const name = params.name || "";
      const val = Number(params.value || 0);
      return `<b>${name}</b><br>Value: Rp ${formatNumber(val, "id-ID", 0)}`;
    }},
    legend: { bottom: 0, textStyle: { fontSize: 10 }, data: [currentLabel, previousLabel] },
    radar: {
      indicator: labels.map(label => ({ name: label, max: maxVal })),
      shape: "polygon",
      splitNumber: 4,
      name: {
        textStyle: { color: "#666", fontSize: 9 }
      },
      splitLine: { lineStyle: { color: ["#f0f0f0", "#d9d9d9", "#b3b3b3", "#8c8c8c"] } },
      axisLine: { lineStyle: { color: "#ddd" } }
    },
    series: [
      {
        name: currentLabel,
        value: currentData,
        type: "radar",
        symbol: "circle",
        symbolSize: 4,
        lineStyle: { width: 2, color: "#1976D2" },
        areaStyle: { color: "rgba(25, 118, 210, 0.15)" },
        itemStyle: { color: "#1976D2", borderColor: "#fff", borderWidth: 1 }
      },
      {
        name: previousLabel,
        value: previousData,
        type: "radar",
        symbol: "rect",
        symbolSize: 4,
        lineStyle: { width: 2, color: "#90A4AE", type: "dashed" },
        areaStyle: { color: "rgba(144, 164, 174, 0.1)" },
        itemStyle: { color: "#90A4AE", borderColor: "#fff", borderWidth: 1 }
      }
    ]
  };

  if (isRadar) return radarConfig;

  if (isScatter) {
    return {
      tooltip: { trigger: "item", formatter(params) {
        try {
          if (!params || !params.value) return "";
          const data = params.value;
          const name = params.name || "";
          return `<b>${name}</b><br>${currentLabel}: Rp ${formatNumber(data[0] || 0, "id-ID", 0)}<br>${previousLabel}: Rp ${formatNumber(data[1] || 0, "id-ID", 0)}`;
        } catch (e) {
          return "";
        }
      }},
      grid: { left: 60, right: 40, top: 40, bottom: 40, containLabel: true },
      xAxis: {
        type: "value",
        name: currentLabel,
        axisLabel: { fontSize: 9, formatter: v => v >= 1e6 ? (v/1e6).toFixed(0)+"Jt" : v >= 1e3 ? (v/1e3).toFixed(0)+"K" : v },
        nameTextStyle: { fontSize: 10, fontWeight: "bold" }
      },
      yAxis: {
        type: "value",
        name: previousLabel,
        axisLabel: { fontSize: 9, formatter: v => v >= 1e6 ? (v/1e6).toFixed(0)+"Jt" : v >= 1e3 ? (v/1e3).toFixed(0)+"K" : v },
        nameTextStyle: { fontSize: 10, fontWeight: "bold" },
        splitLine: { lineStyle: { type: "dashed", color: "#e4ece9" } }
      },
      legend: { top: 0, textStyle: { fontSize: 10 } },
      series: [{
        name: "Growth Comparison",
        type: "scatter",
        symbolSize: 8,
        data: scatterData,
      }]
    };
  }

  return {
    grid: isMobile.value
      ? { left: 12, right: 8, top: 50, bottom: 36, containLabel: true }
      : { left: 56, right: 24, top: 28, bottom: 40, containLabel: true },
    tooltip: {
      trigger: "axis",
      formatter(params) {
        const label = params[0]?.axisValue ?? "";
        let html = `<div style="font-size:12px;font-weight:700;margin-bottom:4px">${label}</div>`;
        params.forEach(p => {
          html += `<div style="display:flex;gap:8px;font-size:12px"><span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:${p.color};margin-top:3px;flex-shrink:0"></span><span style="flex:1">${p.seriesName}</span><b>Rp ${formatNumber(p.value, "id-ID", 0)}</b></div>`;
        });
        return html;
      }
    },
    legend: {
      top: 0,
      textStyle: { fontSize: isMobile.value ? 10 : 11 },
      data: [currentLabel, previousLabel],
    },
    xAxis: {
      type: "category",
      data: labels,
      axisLabel: {
        fontSize: isMobile.value ? 8 : 10,
        interval: 0,
        rotate: isMobile.value ? 35 : 0,
      },
    },
    yAxis: {
      type: "value",
      axisLabel: {
        fontSize: 9,
        formatter: v => v >= 1e6 ? (v / 1e6).toFixed(0) + "Jt" : v >= 1e3 ? (v / 1e3).toFixed(0) + "K" : v,
      },
      splitLine: { lineStyle: { type: "dashed", color: "#e4ece9" } },
    },
    series: isArea
      ? [
          {
            name: currentLabel,
            type: "line",
            smooth: true,
            symbol: "circle",
            symbolSize: 5,
            data: currentData,
            itemStyle: { color: "#1976D2" },
            lineStyle: { width: 2.5, color: "#1976D2" },
            areaStyle: { color: "rgba(25,118,210,0.22)" },
          },
          {
            name: previousLabel,
            type: "line",
            smooth: true,
            symbol: "circle",
            symbolSize: 5,
            data: previousData,
            itemStyle: { color: "#90A4AE" },
            lineStyle: { width: 2, color: "#90A4AE" },
            areaStyle: { color: "rgba(144,164,174,0.22)" },
          },
        ]
      : isMixed
      ? [
          {
            name: currentLabel,
            type: "line",
            smooth: true,
            symbol: "circle",
            symbolSize: 6,
            data: currentData,
            itemStyle: { color: "#1976D2" },
            lineStyle: { width: 3, color: "#1976D2" },
            areaStyle: { color: "rgba(25,118,210,0.12)" },
          },
          {
            name: previousLabel,
            type: "bar",
            barMaxWidth: 18,
            data: previousData,
            itemStyle: { color: "#90A4AE" },
          },
        ]
      : isBar
      ? [
          {
            name: currentLabel,
            type: "bar",
            barMaxWidth: 22,
            data: currentData,
            itemStyle: { color: "#1976D2" },
          },
          {
            name: previousLabel,
            type: "bar",
            barMaxWidth: 22,
            data: previousData,
            itemStyle: { color: "#90A4AE" },
          },
        ]
      : [
          {
            name: currentLabel,
            type: "line",
            smooth: true,
            symbol: "circle",
            symbolSize: 6,
            data: currentData,
            itemStyle: { color: "#1976D2" },
            lineStyle: { width: 3, color: "#1976D2" },
            areaStyle: { color: "rgba(25,118,210,0.12)" },
          },
          {
            name: previousLabel,
            type: "line",
            smooth: true,
            symbol: "circle",
            symbolSize: 5,
            data: previousData,
            itemStyle: { color: "#90A4AE" },
            lineStyle: { width: 2, color: "#90A4AE", type: "dashed" },
          },
        ],
  };
});

const compareDistributorName = computed(() => {
  if (!filter.distributor_id) return "Semua Distributor";
  return distributors.value.find((d) => String(d.value) === String(filter.distributor_id))?.label || "Semua Distributor";
});

const compareTypeLabel = computed(() => {
  if (filter.sale_type === "distributor") return "Distributor";
  if (filter.sale_type === "retailer") return "Retailer";
  return "Semua Tipe";
});

const compareFyCaption = computed(() => {
  const fyA = Number(fyCompare.value?.fy_current || 0);
  const fyB = Number(fyCompare.value?.fy_previous || 0);
  return `FY ${fyA}/${fyA + 1} vs FY ${fyB}/${fyB + 1}`;
});

const fyCompareRows = computed(() => {
  const labels = fyCompare.value?.labels || [];
  const current = fyCompare.value?.current_monthly || [];
  const previous = fyCompare.value?.previous_monthly || [];
  const deltas = fyCompare.value?.delta_monthly || [];
  const growths = fyCompare.value?.growth_monthly || [];

  return labels.map((label, idx) => ({
    label,
    current: Number(current[idx] || 0),
    previous: Number(previous[idx] || 0),
    delta: Number(deltas[idx] || 0),
    growth: growths[idx] === null || growths[idx] === undefined ? null : Number(growths[idx]),
  }));
});

const formatGrowth = (value) => {
  if (value === null || value === undefined) return "-";
  return `${value >= 0 ? "+" : ""}${formatNumber(value, "id-ID", 2)}%`;
};

const fyCompareFooter = computed(() => {
  const currentTotal = Number(fyCompare.value?.current_total || 0);
  const previousTotal = Number(fyCompare.value?.previous_total || 0);
  const deltaTotal = currentTotal - previousTotal;
  const growthTotal = fyCompare.value?.total_growth_percent;

  return {
    currentTotal,
    previousTotal,
    deltaTotal,
    growthTotal,
  };
});

const csvSafe = (value) => {
  const str = String(value ?? "").replace(/"/g, '""');
  return `"${str}"`;
};

const exportFyCompareCsv = () => {
  const currentFy = `${fyCompare.value?.fy_current}/${Number(fyCompare.value?.fy_current || 0) + 1}`;
  const prevFy = `${fyCompare.value?.fy_previous}/${Number(fyCompare.value?.fy_previous || 0) + 1}`;

  const header = [
    "Bulan",
    `Penjualan FY ${currentFy}`,
    `Penjualan FY ${prevFy}`,
    "Selisih",
    "Growth %",
  ];

  const rows = fyCompareRows.value.map((row) => [
    row.label,
    row.current,
    row.previous,
    row.delta,
    row.growth === null || row.growth === undefined ? "" : row.growth,
  ]);

  rows.push([
    "TOTAL FY",
    fyCompareFooter.value.currentTotal,
    fyCompareFooter.value.previousTotal,
    fyCompareFooter.value.deltaTotal,
    fyCompareFooter.value.growthTotal === null || fyCompareFooter.value.growthTotal === undefined ? "" : fyCompareFooter.value.growthTotal,
  ]);

  const csvLines = [header, ...rows].map((cols) => cols.map(csvSafe).join(","));
  const csvContent = "\uFEFF" + csvLines.join("\n");

  const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `compare-distributor-fy-${fyCompare.value?.fy_current || ""}.csv`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
};
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>
    <template #right-button>
      <q-btn
        class="q-ml-sm filter-toggle-btn"
        :icon="!showFilter ? 'filter_alt' : 'filter_alt_off'"
        color="primary"
        outline
        dense
        @click="showFilter = !showFilter"
      />
    </template>

    <template #header v-if="showFilter">
      <q-toolbar class="filter-shell">
        <div class="filter-grid">
          <div class="filter-grid-item">
            <q-select
              class="filter-field"
              v-model="filter.fiscal_year"
              :options="fiscalYears"
              label="Tahun Fiskal"
              dense emit-value map-options outlined
            />
          </div>
          <div class="filter-grid-item">
            <q-select
              class="filter-field"
              v-model="filter.compare_fy_a"
              :options="fiscalYears"
              label="Compare FY A"
              dense emit-value map-options outlined
            />
          </div>
          <div class="filter-grid-item">
            <q-select
              class="filter-field"
              v-model="filter.compare_fy_b"
              :options="fiscalYears"
              label="Compare FY B"
              dense emit-value map-options outlined
            />
          </div>
          <div class="filter-grid-item">
            <q-select
              class="filter-field"
              v-model="filter.month"
              :options="monthOptions"
              label="Bulan"
              dense emit-value map-options outlined
            />
          </div>
          <div class="filter-grid-item">
            <q-select
              class="filter-field"
              v-model="filter.sale_type"
              :options="saleTypeOptions"
              label="Tipe"
              dense emit-value map-options outlined
            />
          </div>
          <div class="filter-grid-item">
            <q-select
              class="filter-field"
              v-model="filter.distributor_id"
              :options="distributors"
              label="Distributor"
              dense emit-value map-options outlined
            />
          </div>
        </div>
      </q-toolbar>
    </template>

    <div class="analytics-wrap" v-if="loading">
      <div class="flex flex-center q-pa-xl">
        <q-spinner color="primary" size="40px" />
      </div>
    </div>

    <div class="analytics-wrap" v-else>
      <q-card flat bordered class="hero-panel q-mb-md">
        <q-card-section class="hero-inner">
          <div class="hero-title-wrap">
            <div class="hero-title">Ringkasan Analitik Penjualan</div>
            <div class="hero-subtitle">{{ periodLabel }}</div>
          </div>
          <div class="hero-badges">
            <q-chip dense color="white" text-color="primary" icon="tune">
              {{ activeFilterCount }} filter aktif
            </q-chip>
            <q-chip dense color="white" text-color="primary" icon="insights">
              Update realtime
            </q-chip>
          </div>
        </q-card-section>
      </q-card>

      <div class="kpi-grid q-mb-md">
        <q-card flat bordered class="kpi-card kpi-primary">
          <q-card-section class="kpi-section">
            <div class="kpi-label">Total Penjualan</div>
            <div class="kpi-value">{{ rupiah(summary.total_sales) }}</div>
            <div class="kpi-meta">Akumulasi periode aktif</div>
          </q-card-section>
        </q-card>

        <q-card flat bordered class="kpi-card kpi-teal">
          <q-card-section class="kpi-section">
            <div class="kpi-label">Total Transaksi</div>
            <div class="kpi-value">{{ formatNumber(summary.total_transactions, "id-ID", 0) }}</div>
            <div class="kpi-meta">Jumlah nota penjualan</div>
          </q-card-section>
        </q-card>

        <q-card flat bordered class="kpi-card kpi-amber">
          <q-card-section class="kpi-section">
            <div class="kpi-label">Rata-rata per Transaksi</div>
            <div class="kpi-value">{{ rupiah(summary.avg_per_transaction) }}</div>
            <div class="kpi-meta">Indikator nilai order</div>
          </q-card-section>
        </q-card>
      </div>

      <q-card flat bordered class="chart-shell q-mb-md">
        <q-card-section class="chart-shell-head">
          <div class="chart-shell-title">Tren Penjualan Bulanan</div>
          <div class="chart-shell-subtitle">Perbandingan nilai penjualan dan jumlah transaksi</div>
        </q-card-section>
        <q-card-section class="chart-shell-body monthly-chart-body">
          <ECharts
            :option="monthlyOption"
            autoresize
            :style="{ width: '100%', height: isMobile ? '260px' : '280px', display: 'block' }"
          />
        </q-card-section>
      </q-card>

      <q-card flat bordered class="chart-shell q-mb-md">
        <q-card-section class="chart-shell-head">
          <div class="compare-head-row">
            <div>
              <div class="chart-shell-title">Compare Penjualan Antar FY</div>
              <div class="chart-shell-subtitle">{{ compareFyCaption }}</div>
              <div class="chart-shell-subtitle">{{ compareTypeLabel }} • {{ compareDistributorName }}</div>
            </div>
            <div class="compare-head-actions">
              <q-btn-toggle
                v-model="compareChartType"
                dense
                unelevated
                toggle-color="primary"
                color="grey-3"
                text-color="dark"
                :options="[
                  { label: 'Line', value: 'line' },
                  { label: 'Batang', value: 'bar' },
                  { label: 'Area', value: 'area' },
                  { label: 'Line+Batang', value: 'mixed' },
                  { label: 'Scatter', value: 'scatter' },
                  { label: 'Radar', value: 'radar' },
                ]"
              />
              <q-btn
                color="primary"
                outline
                dense
                icon="download"
                label="Export CSV"
                @click="exportFyCompareCsv"
              />
            </div>
          </div>
        </q-card-section>
        <q-card-section class="chart-shell-body">
          <div class="compare-kpi-grid q-mb-sm">
            <div class="compare-kpi-item compare-kpi-current">
              <div class="compare-kpi-label">Total FY Saat Ini</div>
              <div class="compare-kpi-value">{{ rupiah(fyCompare.current_total || 0) }}</div>
            </div>
            <div class="compare-kpi-item compare-kpi-previous">
              <div class="compare-kpi-label">Total FY Sebelumnya</div>
              <div class="compare-kpi-value">{{ rupiah(fyCompare.previous_total || 0) }}</div>
            </div>
            <div class="compare-kpi-item compare-kpi-growth">
              <div class="compare-kpi-label">Growth YoY Total</div>
              <div class="compare-kpi-value-growth" :class="(fyCompare.value?.total_growth_percent || 0) >= 0 ? 'growth-up' : 'growth-down'">
                <span class="growth-icon">{{ (fyCompare.value?.total_growth_percent || 0) >= 0 ? '📈' : '📉' }}</span>
                <span class="growth-text">{{ fyGrowthLabel }}</span>
              </div>
            </div>
            <div class="compare-kpi-item compare-kpi-avg">
              <div class="compare-kpi-label">Growth Rata-rata Bulanan</div>
              <div class="compare-kpi-value-growth" :class="(fyCompare.value?.avg_growth_percent || 0) >= 0 ? 'growth-up' : 'growth-down'">
                <span class="growth-icon">{{ (fyCompare.value?.avg_growth_percent || 0) >= 0 ? '📈' : '📉' }}</span>
                <span class="growth-text">{{ fyAvgGrowthLabel }}</span>
              </div>
            </div>
          </div>

          <ECharts
            :option="fyCompareOption"
            autoresize
            :style="{ width: '100%', height: isMobile ? '260px' : '300px', display: 'block' }"
          />

          <div class="compare-table-wrap q-mt-md">
            <q-markup-table flat bordered dense separator="cell" class="compare-table">
              <thead>
                <tr>
                  <th class="text-left">Bulan</th>
                  <th class="text-right">FY {{ fyCompare.fy_current }}/{{ Number(fyCompare.fy_current) + 1 }}</th>
                  <th class="text-right">FY {{ fyCompare.fy_previous }}/{{ Number(fyCompare.fy_previous) + 1 }}</th>
                  <th class="text-right">Selisih</th>
                  <th class="text-right">Growth %</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in fyCompareRows" :key="row.label">
                  <td class="text-left table-month">{{ row.label }}</td>
                  <td class="text-right text-weight-bold table-current">{{ rupiah(row.current) }}</td>
                  <td class="text-right table-previous">{{ rupiah(row.previous) }}</td>
                  <td class="text-right" :class="row.delta >= 0 ? 'growth-up' : 'growth-down'">
                    <span class="delta-badge" :class="row.delta >= 0 ? 'delta-up' : 'delta-down'">
                      {{ row.delta >= 0 ? '▲' : '▼' }} {{ rupiah(row.delta) }}
                    </span>
                  </td>
                  <td class="text-right text-weight-bold" :class="row.growth === null ? '' : (row.growth >= 0 ? 'growth-up' : 'growth-down')">
                    <span class="growth-badge" :class="row.growth === null ? '' : (row.growth >= 0 ? 'grow-up' : 'grow-down')">
                      {{ formatGrowth(row.growth) }}
                    </span>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="compare-total-row">
                  <th class="text-left table-month">TOTAL FY</th>
                  <th class="text-right">{{ rupiah(fyCompareFooter.currentTotal) }}</th>
                  <th class="text-right">{{ rupiah(fyCompareFooter.previousTotal) }}</th>
                  <th class="text-right" :class="(fyCompareFooter.deltaTotal || 0) >= 0 ? 'growth-up' : 'growth-down'">
                    <span class="delta-badge" :class="(fyCompareFooter.deltaTotal || 0) >= 0 ? 'delta-up' : 'delta-down'">
                      {{ (fyCompareFooter.deltaTotal || 0) >= 0 ? '▲' : '▼' }} {{ rupiah(fyCompareFooter.deltaTotal) }}
                    </span>
                  </th>
                  <th class="text-right text-weight-bold" :class="(fyCompareFooter.growthTotal || 0) === 0 || fyCompareFooter.growthTotal === null || fyCompareFooter.growthTotal === undefined ? '' : ((fyCompareFooter.growthTotal || 0) >= 0 ? 'growth-up' : 'growth-down')">
                    <span class="growth-badge" :class="fyCompareFooter.growthTotal === null || fyCompareFooter.growthTotal === undefined ? '' : ((fyCompareFooter.growthTotal || 0) >= 0 ? 'grow-up' : 'grow-down')">
                      {{ formatGrowth(fyCompareFooter.growthTotal) }}
                    </span>
                  </th>
                </tr>
              </tfoot>
            </q-markup-table>
          </div>
        </q-card-section>
      </q-card>

      <div class="split-grid q-mb-md">
        <q-card flat bordered class="chart-shell">
          <q-card-section class="chart-shell-head">
            <div class="chart-shell-title">Komposisi Penjualan per Produk</div>
            <div class="chart-shell-subtitle">5 produk teratas ditampilkan sebagai ringkasan cepat</div>
          </q-card-section>
          <q-card-section class="chart-shell-body">
            <div v-if="byProduct.length === 0" class="empty-hint">Belum ada data</div>
            <ECharts
              v-else
              :option="byProductOption"
              autoresize
              style="width:100%;height:240px;display:block"
            />
            <div v-if="topProducts.length" class="mini-list q-mt-sm">
              <div v-for="(row, idx) in topProducts" :key="row.name" class="mini-row">
                <div class="mini-left">
                  <span class="mini-index">{{ idx + 1 }}</span>
                  <span class="mini-name">{{ row.name }}</span>
                </div>
                <div class="mini-value">{{ rupiah(row.total) }}</div>
              </div>
            </div>
          </q-card-section>
        </q-card>

        <q-card flat bordered class="chart-shell">
          <q-card-section class="chart-shell-head">
            <div class="chart-shell-title">Top Distributor</div>
            <div class="chart-shell-subtitle">Peringkat berdasarkan nilai penjualan</div>
          </q-card-section>
          <q-card-section class="chart-shell-body">
            <div v-if="byDistributor.length === 0" class="empty-hint">Belum ada data</div>
            <ECharts
              v-else
              :option="byDistributorOption"
              autoresize
              :style="{ width:'100%', height: Math.max(220, byDistributor.length * 30)+'px', display:'block' }"
            />
            <div v-if="topDistributors.length" class="mini-list q-mt-sm">
              <div v-for="(row, idx) in topDistributors" :key="row.name" class="mini-row">
                <div class="mini-left">
                  <span class="mini-index">{{ idx + 1 }}</span>
                  <span class="mini-name">{{ row.name }}</span>
                </div>
                <div class="mini-value">{{ rupiah(row.total) }}</div>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>

      <q-card flat bordered class="chart-shell q-mb-md">
        <q-card-section class="chart-shell-head">
          <div class="chart-shell-title">Sebaran Penjualan per Wilayah</div>
          <div class="chart-shell-subtitle">Monitoring kontribusi wilayah secara cepat</div>
        </q-card-section>
        <q-card-section class="chart-shell-body">
          <div v-if="byRegion.length === 0" class="empty-hint">Data wilayah belum tersedia.</div>
          <ECharts
            v-else
            :option="byRegionOption"
            autoresize
            :style="{ width:'100%', height: Math.max(220, byRegion.length * 30)+'px', display:'block' }"
          />
        </q-card-section>
      </q-card>
    </div>
  </authenticated-layout>
</template>

<style scoped>
.analytics-wrap {
  padding: 14px;
  box-sizing: border-box;
  width: 100%;
  overflow-x: hidden;
  background: linear-gradient(180deg, #f4f8f7 0%, #eef3f2 100%);
}

.filter-toggle-btn {
  border-radius: 10px;
}

.filter-shell {
  background: #ffffff;
  border-top: 1px solid #e6ecea;
  border-bottom: 1px solid #e6ecea;
}

.filter-grid {
  width: 100%;
  display: grid;
  grid-template-columns: repeat(7, minmax(150px, 1fr));
  gap: 10px;
  padding: 10px 14px;
}

.filter-grid-item {
  width: 100%;
}

.filter-field {
  width: 100%;
}

.filter-field :deep(.q-field__control) {
  min-height: 40px;
}

.hero-panel {
  width: 100%;
  border-radius: 16px;
  border-color: #dce8e5;
  background: radial-gradient(circle at 15% 20%, #ddf4ee 0%, #f6fffc 45%, #ffffff 100%);
}

.hero-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.hero-title {
  font-size: 22px;
  line-height: 1.2;
  font-weight: 800;
  color: #0f3c33;
}

.hero-subtitle {
  margin-top: 4px;
  font-size: 12px;
  color: #4f6c64;
  font-weight: 600;
}

.hero-badges {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.kpi-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(180px, 1fr));
  gap: 12px;
}

.kpi-card {
  width: 100%;
  border-radius: 14px;
  border-width: 1px;
}

.kpi-section {
  padding: 14px;
  text-align: center;
}

.kpi-label {
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.kpi-value {
  margin-top: 8px;
  font-size: 27px;
  line-height: 1.15;
  font-weight: 800;
}

.kpi-meta {
  margin-top: 6px;
  font-size: 12px;
  color: #65807a;
}

.kpi-primary {
  background: linear-gradient(140deg, #e6f5ff 0%, #f7fbff 100%);
  border-color: #c8e3f5;
  color: #115983;
}

.kpi-teal {
  background: linear-gradient(140deg, #e9faf4 0%, #f7fffc 100%);
  border-color: #cdeedf;
  color: #146b51;
}

.kpi-amber {
  background: linear-gradient(140deg, #fff5e8 0%, #fffdf8 100%);
  border-color: #f2ddbe;
  color: #8b4d07;
}

.chart-shell {
  width: 100%;
  border-radius: 14px;
  border-color: #dde8e4;
  background: #fff;
}

.chart-shell-head {
  padding: 12px 12px 0;
}

.compare-head-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 10px;
  flex-wrap: wrap;
}

.compare-head-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.chart-shell-title {
  font-size: 15px;
  font-weight: 800;
  color: #1d4338;
}

.chart-shell-subtitle {
  margin-top: 3px;
  font-size: 12px;
  color: #728b83;
}

.chart-shell-body {
  padding: 8px 10px 12px;
  width: 100%;
}

.monthly-chart-body {
  padding-left: 6px;
  padding-right: 6px;
}

.chart-shell-body :deep(.echarts-for-vue) {
  width: 100% !important;
}

.chart-shell-body :deep(canvas) {
  width: 100% !important;
}

.split-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 12px;
}

.compare-kpi-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(140px, 1fr));
  gap: 10px;
}

.compare-kpi-item {
  border: 1px solid #dbe7e3;
  border-radius: 10px;
  padding: 12px;
  background: #f9fcfb;
  transition: all 0.3s ease;
}

.compare-kpi-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transform: translateY(-2px);
}

.compare-kpi-current {
  border-left: 4px solid #1976D2;
  background: linear-gradient(135deg, #f0f7ff 0%, #f9fcfb 100%);
}

.compare-kpi-previous {
  border-left: 4px solid #90A4AE;
  background: linear-gradient(135deg, #f5f7f8 0%, #f9fcfb 100%);
}

.compare-kpi-growth {
  border-left: 4px solid #22c55e;
  background: linear-gradient(135deg, #f0fdf4 0%, #f9fcfb 100%);
}

.compare-kpi-avg {
  border-left: 4px solid #f59e0b;
  background: linear-gradient(135deg, #fffbf0 0%, #f9fcfb 100%);
}

.compare-kpi-label {
  font-size: 11px;
  color: #66847a;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.02em;
}

.compare-kpi-value {
  margin-top: 6px;
  font-size: 16px;
  font-weight: 800;
  color: #17493c;
}

.compare-kpi-value-growth {
  margin-top: 6px;
  font-size: 16px;
  font-weight: 800;
  display: flex;
  align-items: center;
  gap: 4px;
}

.growth-icon {
  font-size: 18px;
  display: inline-block;
  animation: growth-pulse 2s infinite;
}

.growth-up {
  color: #16a34a;
}

.growth-down {
  color: #dc2626;
}

@keyframes growth-pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.15); }
}

.growth-text {
  display: inline-block;
}

.compare-table-wrap {
  width: 100%;
  overflow-x: auto;
}

.compare-table {
  min-width: 700px;
}

.compare-table thead th {
  background: #f0f5f3;
  font-weight: 700;
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  color: #465b56;
  border-color: #dbe7e3;
  padding: 10px 8px;
}

.compare-table tbody td {
  padding: 10px 8px;
  border-color: #ede9e6;
}

.compare-table tbody tr:hover {
  background: #fafcfb;
}

.table-month {
  font-weight: 700;
  color: #1d4338;
  width: 15%;
}

.table-current {
  color: #0d47a1;
}

.table-previous {
  color: #546e7a;
}

.delta-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 700;
}

.delta-up {
  background: linear-gradient(135deg, #dcfce7 0%, #bbf7d0 100%);
  color: #166534;
}

.delta-down {
  background: linear-gradient(135deg, #fee2e2 0%, #fca5a5 100%);
  color: #7f1d1d;
}

.growth-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 700;
}

.grow-up {
  background: linear-gradient(135deg, #dcfce7 0%, #bbf7d0 100%);
  color: #166534;
}

.grow-down {
  background: linear-gradient(135deg, #fee2e2 0%, #fca5a5 100%);
  color: #7f1d1d;
}

.compare-total-row {
  background: linear-gradient(90deg, #eef9f8 0%, #f5fbfa 100%);
  border-top: 2px solid #dbe7e3;
  font-weight: 700;
}

.compare-total-row th {
  border-color: #dbe7e3;
  padding: 12px 8px;
  color: #0f3c33;
}

.mini-list {
  width: 100%;
  border-top: 1px dashed #dce8e4;
  padding-top: 8px;
}

.mini-row {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 0;
  gap: 10px;
}

.mini-left {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}

.mini-index {
  width: 20px;
  height: 20px;
  border-radius: 999px;
  background: #edf5f2;
  color: #2d5e50;
  font-size: 11px;
  font-weight: 700;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.mini-name {
  font-size: 12px;
  color: #395e54;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.mini-value {
  font-size: 12px;
  font-weight: 700;
  color: #1f4e40;
  text-align: right;
  flex-shrink: 0;
}

.analytics-wrap :deep(.q-table) {
  width: 100%;
}

.analytics-wrap :deep(.q-table th),
.analytics-wrap :deep(.q-table td) {
  text-align: right;
}

.analytics-wrap :deep(.q-table th:first-child),
.analytics-wrap :deep(.q-table td:first-child) {
  text-align: left;
}

.empty-hint {
  text-align: center;
  color: #8ba39b;
  font-size: 12px;
  padding: 24px 10px;
}

@media (max-width: 1024px) {
  .filter-grid {
    grid-template-columns: repeat(3, minmax(150px, 1fr));
  }

  .kpi-grid {
    grid-template-columns: 1fr;
  }

  .split-grid {
    grid-template-columns: 1fr;
  }

  .compare-kpi-grid {
    grid-template-columns: repeat(2, minmax(140px, 1fr));
  }
}

@media (max-width: 600px) {
  .analytics-wrap {
    padding: 8px;
  }

  .filter-grid {
    grid-template-columns: repeat(2, minmax(140px, 1fr));
    padding: 10px;
  }

  .filter-grid-item,
  .filter-field {
    width: 100%;
  }

  .hero-title {
    font-size: 18px;
  }

  .kpi-value {
    font-size: 24px;
  }

  .monthly-chart-body {
    padding-left: 0;
    padding-right: 0;
  }

  .compare-kpi-grid {
    grid-template-columns: 1fr;
  }
}
</style>
