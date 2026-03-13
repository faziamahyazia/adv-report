<script setup>
import { usePage } from "@inertiajs/vue3";
import { computed, ref } from "vue";
import { useQuasar } from "quasar";
import ECharts from "vue-echarts";

const $q = useQuasar();
const data = computed(() => usePage().props.data ?? {});
const activityTypes = computed(() => data.value.activity_types ?? []);
const rows = computed(() => data.value.rows ?? []);
const columns = computed(() => data.value.columns ?? []);
const columnTotals = computed(() => data.value.column_totals ?? []);
const colTypeTotals = computed(() => data.value.col_type_totals ?? []);
const grandTotal = computed(() => data.value.grand_total ?? 0);
const periodLabel = computed(() => data.value.period_label ?? "");
const multiPeriod = computed(() => columns.value.length > 1);
const summary = computed(() => data.value.summary ?? null);

// ── summary stats ─────────────────────────────────────────────────────────────
const avgKpi = computed(() => {
  if (!summary.value) return null;
  const kpis = summary.value.rows.map((r) => r.kpi).filter((k) => k !== null);
  if (!kpis.length) return null;
  return Math.round(kpis.reduce((a, b) => a + b, 0) / kpis.length);
});

const topBs = computed(() => {
  if (!summary.value || !summary.value.rows.length) return null;
  return summary.value.rows.reduce((best, r) => {
    if (r.kpi === null) return best;
    return !best || r.kpi > best.kpi ? r : best;
  }, null);
});

// ── ECharts stacked bar ───────────────────────────────────────────────────────
const CHART_COLORS = ["#1976D2", "#388E3C", "#F57C00", "#7B1FA2", "#D32F2F", "#0097A7", "#795548"];

const barChartOption = computed(() => {
  if (!rows.value.length || !activityTypes.value.length) return {};
  const isMobile = $q.screen.lt.sm;
  const bsNames = rows.value.map((r) =>
    isMobile ? shortName(r.name) : r.name
  );
  const series = activityTypes.value.map((t, i) => ({
    name: t.name,
    type: "bar",
    stack: "total",
    data: rows.value.map((row) =>
      row.data.reduce((sum, d) => sum + (d.type_counts[t.id] ?? 0), 0)
    ),
    itemStyle: { color: CHART_COLORS[i % CHART_COLORS.length] },
    label: {
      show: !isMobile,
      position: "inside",
      fontSize: 10,
      color: "#fff",
      formatter: (p) => (p.value > 0 ? p.value : ""),
    },
  }));

  return {
    tooltip: {
      trigger: "axis",
      axisPointer: { type: "shadow" },
      textStyle: { fontSize: 12 },
    },
    legend: {
      top: 4,
      textStyle: { fontSize: isMobile ? 10 : 11 },
      itemWidth: isMobile ? 10 : 12,
      itemHeight: isMobile ? 10 : 12,
      data: activityTypes.value.map((t) => t.name),
    },
    grid: { left: 8, right: 8, bottom: 8, top: isMobile ? 48 : 36, containLabel: true },
    xAxis: {
      type: "category",
      data: bsNames,
      axisLabel: {
        fontSize: isMobile ? 10 : 11,
        interval: 0,
        rotate: bsNames.length > (isMobile ? 4 : 6) ? (isMobile ? 30 : 20) : 0,
      },
    },
    yAxis: {
      type: "value",
      minInterval: 1,
      axisLabel: { fontSize: 10 },
      splitLine: { lineStyle: { type: "dashed", color: "#eee" } },
    },
    series,
  };
});

// ── activity type donut per period (single period only) ───────────────────────
const donutOption = computed(() => {
  if (!activityTypes.value.length || !colTypeTotals.value.length) return null;
  // Sum across all columns
  const totals = activityTypes.value.map((t) => ({
    name: t.name,
    value: colTypeTotals.value.reduce((sum, ct) => sum + (ct[t.id] ?? 0), 0),
  })).filter((d) => d.value > 0);
  if (!totals.length) return null;

  return {
    tooltip: { trigger: "item", textStyle: { fontSize: 11 } },
    legend: { show: false },
    series: [
      {
        type: "pie",
        radius: ["45%", "72%"],
        center: ["50%", "52%"],
        data: totals.map((d, i) => ({
          ...d,
          itemStyle: { color: CHART_COLORS[i % CHART_COLORS.length] },
        })),
        label: { fontSize: 10, formatter: "{b}\n{c}" },
        labelLine: { length: 8, length2: 6 },
      },
    ],
  };
});

// ── table toggle ──────────────────────────────────────────────────────────────
const showDetail = ref(false);

// ── helpers ───────────────────────────────────────────────────────────────────
function kpiClass(kpi) {
  if (kpi === null || kpi === undefined) return "kpi-none";
  if (kpi >= 100) return "kpi-green";
  if (kpi >= 75) return "kpi-yellow";
  return "kpi-red";
}

function kpiColor(kpi) {
  if (kpi === null || kpi === undefined) return "grey";
  if (kpi >= 100) return "green";
  if (kpi >= 75) return "orange";
  return "red";
}

const nameAliases = { fatkhur: "fatur" };
function shortName(name) {
  if (!name) return "";
  const firstWord = name.trim().split(/\s+/)[0];
  const lower = firstWord.toLowerCase();
  for (const [key, val] of Object.entries(nameAliases)) {
    if (lower === key || lower.startsWith(key)) return val;
  }
  return firstWord.length > 9 ? firstWord.slice(0, 5) : firstWord;
}

function shortTypeName(name) {
  if (!name) return "";
  return name.length > 12 ? name.slice(0, 12) : name;
}
</script>

<template>
  <div>
    <!-- Period label -->
    <div class="text-caption text-grey-6 q-mb-sm">{{ periodLabel }}</div>

    <div v-if="rows.length === 0" class="text-center text-grey-7 q-py-lg">
      <q-icon name="group" size="32px" class="q-mb-sm" />
      <div>Tidak ada BS yang terdaftar di bawah Anda.</div>
    </div>

    <template v-else>
      <!-- ── SUMMARY CARDS ──────────────────────────────────────────────── -->
      <div class="row q-col-gutter-sm q-mb-sm">
        <!-- Total BS -->
        <div class="col-6 col-sm-3">
          <div class="s-card">
            <div class="s-card__icon" style="background:#1976D2">
              <q-icon name="group" color="white" size="18px" />
            </div>
            <div class="s-card__body">
              <div class="s-card__value">{{ rows.length }}</div>
              <div class="s-card__label">Total BS</div>
            </div>
          </div>
        </div>

        <!-- Total Kegiatan -->
        <div class="col-6 col-sm-3">
          <div class="s-card">
            <div class="s-card__icon" style="background:#388E3C">
              <q-icon name="event" color="white" size="18px" />
            </div>
            <div class="s-card__body">
              <div class="s-card__value">{{ grandTotal }}</div>
              <div class="s-card__label">Total Kegiatan</div>
            </div>
          </div>
        </div>

        <!-- Rata-rata KPI (quarter/fiscal only) -->
        <div v-if="avgKpi !== null" class="col-6 col-sm-3">
          <div class="s-card">
            <div
              class="s-card__icon"
              :style="{ background: avgKpi >= 100 ? '#388E3C' : avgKpi >= 75 ? '#F57C00' : '#D32F2F' }"
            >
              <q-icon name="trending_up" color="white" size="18px" />
            </div>
            <div class="s-card__body">
              <div
                class="s-card__value"
                :style="{ color: avgKpi >= 100 ? '#2e7d32' : avgKpi >= 75 ? '#e65100' : '#c62828' }"
              >
                {{ avgKpi }}%
              </div>
              <div class="s-card__label">Rata-rata KPI</div>
            </div>
          </div>
        </div>

        <!-- Top BS -->
        <div v-if="topBs" class="col-6 col-sm-3">
          <div class="s-card">
            <div class="s-card__icon" style="background:#F57C00">
              <q-icon name="star" color="white" size="18px" />
            </div>
            <div class="s-card__body">
              <div class="s-card__value s-card__value--sm">{{ shortName(topBs.name) }}</div>
              <div class="s-card__label">Top BS · {{ topBs.kpi }}%</div>
            </div>
          </div>
        </div>
      </div>

      <!-- ── CHARTS ROW ─────────────────────────────────────────────────── -->
      <div class="row q-col-gutter-sm q-mb-sm">
        <!-- Stacked bar chart -->
        <div :class="donutOption ? 'col-12 col-sm-8' : 'col-12'">
          <div class="chart-card">
            <div class="chart-card__title">
              <q-icon name="bar_chart" size="14px" class="q-mr-xs" />
              Aktivitas per BS
            </div>
            <ECharts
              v-if="barChartOption.series"
              :option="barChartOption"
              autoresize
              class="agro-chart"
            />
          </div>
        </div>

        <!-- Donut / breakdown -->
        <div v-if="donutOption" class="col-12 col-sm-4">
          <div class="chart-card">
            <div class="chart-card__title">
              <q-icon name="donut_large" size="14px" class="q-mr-xs" />
              Distribusi Jenis
            </div>
            <ECharts :option="donutOption" autoresize class="agro-chart" />
          </div>
        </div>
      </div>

      <!-- ── KPI PROGRESS BARS (quarter / fiscal year) ──────────────────── -->
      <template v-if="summary">
        <div class="section-title q-mb-xs">
          <q-icon name="leaderboard" size="14px" class="q-mr-xs" />
          Ringkasan KPI
        </div>
        <div class="kpi-list q-mb-sm">
          <div v-for="row in summary.rows" :key="row.name" class="kpi-row">
            <div class="kpi-row__name">
              {{ $q.screen.lt.sm ? shortName(row.name) : row.name }}
            </div>
            <div class="kpi-row__bar">
              <q-linear-progress
                :value="Math.min((row.kpi ?? 0) / 100, 1)"
                size="12px"
                rounded
                :color="kpiColor(row.kpi)"
                track-color="grey-3"
              />
            </div>
            <div class="kpi-row__pct kpi-badge" :class="kpiClass(row.kpi)">
              {{ row.kpi !== null ? row.kpi + "%" : "-" }}
            </div>
            <div class="kpi-row__sub text-grey-6">
              {{ row.total_actual }}/{{ row.total_target }}
            </div>
          </div>

          <!-- Total row -->
          <div class="kpi-row kpi-row--total">
            <div class="kpi-row__name text-bold">Total</div>
            <div class="kpi-row__bar">
              <q-linear-progress
                :value="Math.min((summary.totals.kpi ?? 0) / 100, 1)"
                size="12px"
                rounded
                :color="kpiColor(summary.totals.kpi)"
                track-color="grey-3"
              />
            </div>
            <div class="kpi-row__pct kpi-badge text-bold" :class="kpiClass(summary.totals.kpi)">
              {{ summary.totals.kpi !== null ? summary.totals.kpi + "%" : "-" }}
            </div>
            <div class="kpi-row__sub text-bold text-grey-7">
              {{ summary.totals.total_actual }}/{{ summary.totals.total_target }}
            </div>
          </div>
        </div>
      </template>

      <!-- ── COLLAPSIBLE DETAIL TABLE ───────────────────────────────────── -->
      <q-btn
        flat
        dense
        size="sm"
        :icon="showDetail ? 'expand_less' : 'expand_more'"
        :label="showDetail ? 'Sembunyikan Detail' : 'Lihat Detail Kegiatan'"
        class="q-mb-xs text-grey-7"
        @click="showDetail = !showDetail"
      />

      <q-slide-transition>
        <div v-if="showDetail" class="table-wrapper">
          <table class="agro-table">
            <thead>
              <tr>
                <th class="col-type">Jenis Kegiatan</th>
                <th v-for="row in rows" :key="row.name" class="col-bs">
                  {{ $q.screen.lt.sm ? shortName(row.name) : row.name }}
                </th>
                <th>Total</th>
              </tr>
            </thead>

            <tbody>
              <template v-for="(col, ci) in columns" :key="ci">
                <tr v-if="multiPeriod" class="period-header-row">
                  <td :colspan="rows.length + 2">{{ col }}</td>
                </tr>

                <tr v-for="t in activityTypes" :key="t.id">
                  <td class="col-type">
                    {{ $q.screen.lt.sm ? shortTypeName(t.name) : t.name }}
                  </td>
                  <td v-for="row in rows" :key="row.name" class="text-center">
                    <span
                      :class="
                        (row.data[ci]?.type_counts[t.id] ?? 0) > 0
                          ? 'text-primary text-bold'
                          : 'text-grey-5'
                      "
                    >
                      {{ row.data[ci]?.type_counts[t.id] ?? 0 }}
                    </span>
                  </td>
                  <td class="text-center text-bold">
                    {{ colTypeTotals[ci]?.[t.id] ?? 0 }}
                  </td>
                </tr>

                <tr class="period-total-row">
                  <td class="col-type text-bold">Total</td>
                  <td v-for="row in rows" :key="row.name" class="text-center text-bold">
                    {{ row.data[ci]?.total ?? 0 }}
                  </td>
                  <td class="text-center text-bold">{{ columnTotals[ci] }}</td>
                </tr>
              </template>
            </tbody>

            <tfoot v-if="multiPeriod">
              <tr class="footer-row">
                <td class="col-type text-bold">Total Semua</td>
                <td v-for="row in rows" :key="row.name" class="text-center text-bold">
                  {{ row.total }}
                </td>
                <td class="text-center text-bold">{{ grandTotal }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </q-slide-transition>
    </template>
  </div>
</template>

<style scoped>
/* ── Summary stat cards ────────────────────────────────────────────────────── */
.s-card {
  display: flex;
  align-items: center;
  gap: 10px;
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 10px;
  padding: 10px 12px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
}
.s-card__icon {
  flex-shrink: 0;
  width: 36px;
  height: 36px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.s-card__body { min-width: 0; }
.s-card__value {
  font-size: 20px;
  font-weight: 700;
  color: #222;
  line-height: 1.2;
}
.s-card__value--sm { font-size: 15px; }
.s-card__label {
  font-size: 11px;
  color: #888;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* ── Chart card wrapper ────────────────────────────────────────────────────── */
.chart-card {
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 10px;
  padding: 10px 12px 8px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
  height: 100%;
}
.chart-card__title {
  font-size: 12px;
  font-weight: 600;
  color: #555;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
}

/* ── Section title ─────────────────────────────────────────────────────────── */
.section-title {
  font-size: 12px;
  font-weight: 600;
  color: #555;
  display: flex;
  align-items: center;
}

/* ── KPI progress list ─────────────────────────────────────────────────────── */
.kpi-list {
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 10px;
  padding: 8px 12px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
}
.kpi-row {
  display: grid;
  grid-template-columns: 80px 1fr 40px 48px;
  align-items: center;
  gap: 6px;
  padding: 5px 0;
  border-bottom: 1px solid #f0f0f0;
}
@media (min-width: 600px) {
  .kpi-row {
    grid-template-columns: 110px 1fr 50px 60px;
    gap: 8px;
  }
}
.kpi-row:last-child { border-bottom: none; }
.kpi-row--total {
  border-top: 1px solid #ddd;
  padding-top: 6px;
  margin-top: 2px;
}
.kpi-row__name {
  font-size: 12px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.kpi-row__bar { min-width: 0; }
.kpi-row__pct {
  text-align: center;
  font-size: 11px;
  font-weight: 700;
  border-radius: 4px;
  padding: 2px 3px;
}
.kpi-row__sub {
  font-size: 10px;
  text-align: right;
  white-space: nowrap;
}

/* ── KPI badge colors ──────────────────────────────────────────────────────── */
.kpi-badge { border-radius: 4px; }
.kpi-green  { color: #2e7d32; background: #e8f5e9; }
.kpi-yellow { color: #e65100; background: #fff3e0; }
.kpi-red    { color: #c62828; background: #ffebee; }
.kpi-none   { color: #9e9e9e; }

/* ── Detail table ──────────────────────────────────────────────────────────── */
.table-wrapper { overflow-x: auto; }
.agro-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.82rem;
}
.agro-table th,
.agro-table td {
  padding: 4px 8px;
  border: 1px solid #e0e0e0;
}
.agro-table th {
  background: #f5f5f5;
  text-align: center;
  font-weight: 600;
}
.col-type { text-align: left; min-width: 100px; white-space: nowrap; }
.col-bs   { min-width: 55px; max-width: 90px; word-break: break-word; white-space: normal; }
.period-header-row td {
  background: #e3f2fd;
  font-weight: 700;
  font-size: 0.80rem;
  padding: 3px 8px;
  letter-spacing: 0.02em;
}
.period-total-row td { background: #f9fbe7; border-top: 1px solid #c5cae9; }
.footer-row td { background: #fce4ec; border-top: 2px solid #e57373; font-weight: 700; }

/* ── Responsive chart height ───────────────────────────────────────────────── */
.agro-chart {
  height: 200px;
}
@media (min-width: 600px) {
  .agro-chart {
    height: 230px;
  }
}
@media (min-width: 1024px) {
  .agro-chart {
    height: 260px;
  }
}
</style>
