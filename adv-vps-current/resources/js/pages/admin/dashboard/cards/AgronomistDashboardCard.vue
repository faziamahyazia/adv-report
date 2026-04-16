<script setup>
import { usePage } from "@inertiajs/vue3";
import { computed } from "vue";
import { useQuasar } from "quasar";
import ECharts from "vue-echarts";

const $q = useQuasar();

// ── Data ─────────────────────────────────────────────────────────────────
const data          = computed(() => usePage().props.data ?? {});
const activityTypes = computed(() => data.value.activity_types ?? []);
const rows          = computed(() => data.value.rows ?? []);
const columns       = computed(() => data.value.columns ?? []);
const colTypeTotals = computed(() => data.value.col_type_totals ?? []);
const columnTotals  = computed(() => data.value.column_totals ?? []);
const grandTotal    = computed(() => data.value.grand_total ?? 0);
const periodLabel   = computed(() => data.value.period_label ?? "");
const multiPeriod   = computed(() => columns.value.length > 1);
const summary       = computed(() => data.value.summary ?? null);
const totalBS       = computed(() => rows.value.length);

const COLORS = [
  "#0a3b82", "#00b140", "#f9a800", "#e31c4b", "#a10f56",
  "#1677c8", "#ff5a00", "#008a3d", "#132b50", "#4f5965",
];

function grandTypeTotal(typeId) {
  return colTypeTotals.value.reduce((s, col) => s + (col[typeId] ?? 0), 0);
}

// ── KPI helpers ───────────────────────────────────────────────────────────
function kpiColor(kpi) {
  if (kpi === null) return { text: "#7b8794", bg: "#f3f6fa", bar: "#c7d2de", quasar: "grey" };
  if (kpi >= 100)   return { text: "#008a3d", bg: "#e9f8ef", bar: "#00b140", quasar: "positive" };
  if (kpi >= 75)    return { text: "#ff5a00", bg: "#fff3e7", bar: "#f9a800", quasar: "warning" };
  return               { text: "#a10f56", bg: "#ffeaf2", bar: "#e31c4b", quasar: "negative" };
}

const bestKpi = computed(() => {
  if (!summary.value) return null;
  const valid = summary.value.rows.filter(r => r.kpi !== null);
  return valid.length ? valid.reduce((b, r) => r.kpi > b.kpi ? r : b) : null;
});

const avgActivity = computed(() =>
  totalBS.value > 0 ? (grandTotal.value / totalBS.value).toFixed(1) : "0"
);

// ── Responsive breakpoints ────────────────────────────────────────────────
const isMobile = computed(() => $q.screen.lt.sm);

// ── Inline grid styles (inline always wins over Quasar CSS class) ─────────
const statGrid = computed(() => ({
  display: "grid",
  gridTemplateColumns: "repeat(2, 1fr)",
  gap: "10px",
}));

const chartGrid = computed(() => ({
  display: "grid",
  gridTemplateColumns: isMobile.value ? "1fr" : "1fr 1fr",
  gap: "12px",
}));

const kpiGrid = computed(() => ({
  display: "grid",
  gridTemplateColumns: isMobile.value ? "repeat(2, 1fr)" : "repeat(3, 1fr)",
  gap: "10px",
}));

// ── Donut chart ────────────────────────────────────────────────────────────
const donutOption = computed(() => ({
  backgroundColor: "transparent",
  tooltip: { trigger: "item", formatter: "{b}: <b>{c}</b> ({d}%)" },
  legend: { show: false },
  series: [{
    type: "pie",
    radius: ["45%", "72%"],
    center: ["50%", "50%"],
    avoidLabelOverlap: true,
    itemStyle: { borderRadius: 4, borderColor: "#fff", borderWidth: 2 },
    data: activityTypes.value.map((t, i) => ({
      name: t.name,
      value: grandTypeTotal(t.id),
      itemStyle: { color: COLORS[i % COLORS.length] },
    })),
    label: { show: false },
    emphasis: {
      label: { show: true, fontSize: 13, fontWeight: "bold" },
      scaleSize: 5,
    },
  }],
}));

// ── Helper: sum a type's count across all periods for one BS row ──────────
function rowTypeTotal(row, typeId) {
  return row.data.reduce((s, d) => s + (d.type_counts?.[typeId] ?? 0), 0);
}

// ── Stacked horizontal bar per BS (per-type breakdown) ────────────────────
const barBsOption = computed(() => {
  const bsNames = rows.value.map(r => r.name.split(" ")[0]);
  const types   = activityTypes.value;

  return {
    backgroundColor: "transparent",
    grid: { left: 60, right: 52, top: 8, bottom: 8, containLabel: false },

    tooltip: {
      trigger: "axis",
      axisPointer: { type: "shadow" },
      confine: true,
      formatter(params) {
        const rowIdx  = params[0]?.dataIndex ?? 0;
        const rowName = rows.value[rowIdx]?.name ?? params[0]?.axisValue ?? "";
        const total   = rows.value[rowIdx]?.total ?? 0;

        let html = `<div style="font-size:13px;font-weight:700;color:#132b50;margin-bottom:6px">
                      ${rowName}
                    </div>`;

        params.forEach(p => {
          if ((p.value ?? 0) <= 0) return;
          html += `<div style="display:flex;align-items:center;gap:8px;padding:2px 0;font-size:12px">
                     <span style="display:inline-block;width:9px;height:9px;border-radius:50%;
                                  background:${p.color};flex-shrink:0"></span>
                     <span style="flex:1;min-width:80px;color:#4f5965">${p.seriesName}</span>
                     <span style="font-weight:700;color:#132b50">${p.value}</span>
                   </div>`;
        });

        html += `<div style="border-top:1px solid #e8eff8;margin-top:6px;padding-top:5px;
                              font-size:12px;font-weight:700;color:#132b50">
                   Total &nbsp;<span style="font-size:15px">${total}</span>
                 </div>`;
        return html;
      },
    },

    xAxis: {
      type: "value",
      axisLabel: { fontSize: 9, color: "#7b8794" },
      splitLine: { lineStyle: { color: "#e8eff8" } },
      axisLine: { show: false },
    },
    yAxis: {
      type: "category",
      data: bsNames,
      axisLabel: { fontSize: 10, fontWeight: "600", color: "#4f5965",
                   overflow: "truncate", width: 54 },
      axisTick: { show: false },
      axisLine: { show: false },
    },

    series: types.map((t, i) => ({
      name: t.name,
      type: "bar",
      stack: "total",
      barMaxWidth: 22,
      barMinHeight: 2,
      itemStyle: { color: COLORS[i % COLORS.length] },
      data: rows.value.map(r => rowTypeTotal(r, t.id)),
      emphasis: { focus: "series" },
      // Show total label only at the end of the last segment
      label: i === types.length - 1 ? {
        show: true,
        position: "right",
        fontSize: 10,
        fontWeight: "700",
        color: "#4f5965",
        formatter: p => rows.value[p.dataIndex]?.total ?? "",
      } : { show: false },
    })),
  };
});

// ── Per-period achievement (for multi-period views) ───────────────────────
const periodAchievement = computed(() => {
  if (!multiPeriod.value || !grandTotal.value) return [];
  const maxTotal = Math.max(...columnTotals.value, 1);
  return columns.value.map((col, ci) => {
    const total = columnTotals.value[ci] ?? 0;
    return {
      label:    col,
      total,
      pct:      grandTotal.value > 0 ? Math.round(total / grandTotal.value * 100) : 0,
      barWidth: total / maxTotal,
    };
  });
});

// ── Abbreviate name for compact table headers ──────────────────────────────
function tableHeaderName(name) {
  return name.split(" ")[0].substring(0, 6);
}

// ── Abbreviate activity type name for narrow table cells ──────────────────
function shortTypeName(name) {
  if (name.length <= 12) return name;
  return name.split(" ").map(w => w.substring(0, 4)).join(" ");
}

// ── Stacked trend bar ──────────────────────────────────────────────────────
const trendOption = computed(() => {
  if (!multiPeriod.value || !rows.value.length) return null;
  return {
    backgroundColor: "transparent",
    tooltip: { trigger: "axis", axisPointer: { type: "shadow" } },
    legend: {
      bottom: 0,
      textStyle: { fontSize: 9, color: "#4f5965" },
      itemWidth: 10, itemHeight: 7,
    },
    grid: { left: 36, right: 12, top: 8, bottom: 40, containLabel: true },
    xAxis: {
      type: "category",
      data: columns.value,
      axisLabel: { fontSize: 9, interval: 0, rotate: 30, color: "#7b8794" },
      axisLine: { lineStyle: { color: "#d5dfec" } },
    },
    yAxis: {
      type: "value",
      axisLabel: { fontSize: 9, color: "#7b8794" },
      splitLine: { lineStyle: { color: "#e8eff8" } },
    },
    series: rows.value.map((bs, i) => ({
      name: bs.name.split(" ")[0],
      type: "bar",
      stack: "total",
      barMaxWidth: 40,
      itemStyle: { color: COLORS[i % COLORS.length] },
      data: bs.data.map(d => d.total),
      label: { show: false },
    })),
  };
});
</script>

<template>
  <div class="dash">

    <!-- ── EMPTY STATE ── -->
    <div v-if="rows.length === 0" class="empty-state">
      <q-icon name="group" size="52px" color="grey-4" />
      <div class="empty-title">Tidak ada BS yang terdaftar</div>
      <div class="empty-sub">BS belum ditambahkan di bawah Anda.</div>
    </div>

    <template v-else>

      <!-- ════════════════════════════════════════
           HERO BANNER
           ════════════════════════════════════════ -->
      <div class="hero">
        <div class="hero-meta">
          <q-icon name="calendar_month" size="12px" />
          <span>{{ periodLabel || "Periode aktif" }}</span>
          <span class="hero-sep">·</span>
          <span>{{ totalBS }} BS aktif</span>
        </div>
        <div class="hero-total">{{ grandTotal }}</div>
        <div class="hero-label">Total Kegiatan</div>
        <div class="hero-avg">
          Rata-rata <b>{{ avgActivity }}</b> keg/BS
          <span v-if="bestKpi" class="hero-best">
            · KPI Terbaik
            <b>{{ bestKpi.kpi }}%</b>
            ({{ bestKpi.name.split(" ")[0] }})
          </span>
        </div>
      </div>

      <!-- ════════════════════════════════════════
           STAT CARDS
           ════════════════════════════════════════ -->
      <div :style="statGrid" class="section-gap">

        <div class="stat-card">
          <div class="stat-icon" style="background:#e8eff8">
            <q-icon name="event_available" color="primary" size="18px" />
          </div>
          <div class="stat-body">
            <div class="stat-val text-primary">{{ grandTotal }}</div>
            <div class="stat-lbl">Total Kegiatan</div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon" style="background:#e9f8ef">
            <q-icon name="people" color="secondary" size="18px" />
          </div>
          <div class="stat-body">
            <div class="stat-val text-secondary">{{ totalBS }}</div>
            <div class="stat-lbl">Jumlah BS</div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon" style="background:#fff3e7">
            <q-icon name="insights" color="accent" size="18px" />
          </div>
          <div class="stat-body">
            <div class="stat-val text-accent">{{ avgActivity }}</div>
            <div class="stat-lbl">Rata-rata / BS</div>
          </div>
        </div>

        <div class="stat-card" :style="bestKpi ? `background:${kpiColor(bestKpi.kpi).bg}` : ''">
          <div class="stat-icon" :style="`background:${bestKpi ? kpiColor(bestKpi.kpi).bg : '#f5f5f5'}`">
            <q-icon name="star" :color="bestKpi ? kpiColor(bestKpi.kpi).quasar : 'grey-4'" size="18px" />
          </div>
          <div class="stat-body" style="min-width:0">
            <div class="stat-val" :style="`color:${bestKpi ? kpiColor(bestKpi.kpi).text : '#bdbdbd'}`">
              {{ bestKpi ? bestKpi.kpi + "%" : "–" }}
            </div>
            <div class="stat-lbl ellipsis">
              {{ bestKpi ? bestKpi.name.split(" ")[0] : "KPI Terbaik" }}
            </div>
          </div>
        </div>

      </div>

      <!-- ════════════════════════════════════════
           CHARTS: Donut + Bar
           ════════════════════════════════════════ -->
      <div :style="chartGrid" class="section-gap">

        <!-- Donut -->
        <div class="card">
          <div class="card-head">
            <span class="card-accent" style="background:#0a3b82"></span>
            <span class="card-title">Per Jenis Aktivitas</span>
          </div>
          <div class="card-body">
            <!-- Chart centered -->
            <div class="donut-wrap">
              <ECharts :option="donutOption" autoresize style="height:160px;width:100%" />
            </div>
            <!-- Legend grid -->
            <div class="legend-grid">
              <div v-for="(t, i) in activityTypes" :key="t.id" class="legend-item">
                <span class="ldot" :style="`background:${COLORS[i % COLORS.length]}`"></span>
                <span class="lname">{{ t.name }}</span>
                <span class="lval" :style="`color:${COLORS[i % COLORS.length]}`">
                  {{ grandTypeTotal(t.id) }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Bar per BS -->
        <div class="card">
          <div class="card-head">
            <span class="card-accent" style="background:#00b140"></span>
            <span class="card-title">Kegiatan per BS</span>
          </div>
          <div class="card-body chart-body">
            <ECharts
              :option="barBsOption"
              autoresize
              :style="`height:${Math.max(rows.length * 36 + 20, 120)}px;width:100%;display:block`"
            />
          </div>
        </div>

      </div>

      <!-- ════════════════════════════════════════
           TREND (multi-period)
           ════════════════════════════════════════ -->
      <div v-if="multiPeriod && trendOption" class="card section-gap">
        <div class="card-head">
          <span class="card-accent" style="background:#a10f56"></span>
          <span class="card-title">Tren Kegiatan per Periode</span>
        </div>
        <div class="card-body chart-body">
          <ECharts :option="trendOption" autoresize style="height:200px;width:100%;display:block" />
        </div>
      </div>

      <!-- ════════════════════════════════════════
           PENCAPAIAN PER PERIODE
           (visible di quarter / fiscal_year view)
           ════════════════════════════════════════ -->
      <template v-if="periodAchievement.length">
        <div class="sect-head section-gap">
          <q-icon name="trending_up" color="primary" size="16px" />
          <span>Pencapaian per Periode</span>
        </div>
        <div class="card section-gap">
          <div class="card-body">
            <div v-for="p in periodAchievement" :key="p.label" class="period-row">
              <div class="period-label">{{ p.label }}</div>
              <div class="period-bar-wrap">
                <div class="period-bar" :style="`width:${Math.round(p.barWidth * 100)}%`"></div>
              </div>
              <div class="period-meta">
                <span class="period-total">{{ p.total }}</span>
                <span class="period-pct">{{ p.pct }}%</span>
              </div>
            </div>
          </div>
        </div>
      </template>

      <!-- ════════════════════════════════════════
           KPI PER BS
           ════════════════════════════════════════ -->
      <template v-if="summary">

        <div class="sect-head section-gap">
          <q-icon name="emoji_events" color="accent" size="16px" />
          <span>KPI per BS</span>
        </div>

        <div :style="kpiGrid" class="section-gap">
          <div
            v-for="row in summary.rows"
            :key="row.name"
            class="kpi-card"
            :style="`border-top:3px solid ${kpiColor(row.kpi).bar}`"
          >
            <!-- Name + KPI % -->
            <div class="kpi-top">
              <div class="kpi-name ellipsis">{{ row.name }}</div>
              <div class="kpi-pct" :style="`color:${kpiColor(row.kpi).text}`">
                {{ row.kpi !== null ? row.kpi + "%" : "–" }}
              </div>
            </div>

            <!-- Progress -->
            <q-linear-progress
              :value="row.kpi !== null ? Math.min(row.kpi / 100, 1.5) : 0"
              :color="kpiColor(row.kpi).quasar"
              track-color="grey-3"
              rounded
              style="height:5px;margin:5px 0 6px"
            />

            <!-- A / T -->
            <div class="kpi-at-row">
              <span class="kpi-at-item">
                <span class="kpi-at-lbl">Aktual</span>
                <span class="kpi-at-val">{{ row.total_actual }}</span>
              </span>
              <span class="kpi-divider"></span>
              <span class="kpi-at-item">
                <span class="kpi-at-lbl">Target</span>
                <span class="kpi-at-val">{{ row.total_target }}</span>
              </span>
            </div>

            <!-- Per type -->
            <div class="kpi-types">
              <div v-for="(t, i) in activityTypes" :key="t.id" class="kpi-type">
                <span class="ldot sm" :style="`background:${COLORS[i % COLORS.length]}`"></span>
                <span class="kpi-type-name ellipsis">{{ t.name }}</span>
                <span class="kpi-type-val">{{ row.type_actuals[t.id] ?? 0 }}</span>
              </div>
            </div>

          </div>
        </div>

        <!-- Team summary bar -->
        <div class="team-summary" :style="`border-left:4px solid ${kpiColor(summary.totals.kpi).bar}`">
          <div class="team-row">
            <div class="team-item">
              <div class="team-lbl">Total Aktual</div>
              <div class="team-val text-primary">{{ summary.totals.total_actual }}</div>
            </div>
            <div class="team-divider"></div>
            <div class="team-item">
              <div class="team-lbl">Total Target</div>
              <div class="team-val text-grey-7">{{ summary.totals.total_target }}</div>
            </div>
            <div class="team-divider"></div>
            <div class="team-item">
              <div class="team-lbl">KPI Tim</div>
              <div class="team-val" :style="`color:${kpiColor(summary.totals.kpi).text}`">
                {{ summary.totals.kpi !== null ? summary.totals.kpi + "%" : "–" }}
              </div>
            </div>
          </div>
          <q-linear-progress
            :value="summary.totals.kpi !== null ? Math.min(summary.totals.kpi / 100, 1.5) : 0"
            :color="kpiColor(summary.totals.kpi).quasar"
            track-color="grey-3"
            rounded
            style="height:7px;margin-top:10px;border-radius:4px"
          />
        </div>

      </template>

      <!-- ════════════════════════════════════════
           DETAIL TABLE (collapsible, auto-fit)
           ════════════════════════════════════════ -->
      <div class="section-gap">
        <q-expansion-item
          label="Tabel Detail Kegiatan"
          icon="table_chart"
          header-class="text-subtitle2 text-bold q-px-none"
          dense
        >
          <table class="agro-table q-mt-xs">
            <colgroup>
              <col style="width:32%" />
              <!-- remaining columns get equal share of 68% -->
            </colgroup>
            <thead>
              <tr>
                <th class="col-type">Jenis Kegiatan</th>
                <th v-for="row in rows" :key="row.name" class="col-bs">
                  {{ tableHeaderName(row.name) }}
                </th>
                <th class="col-tot">∑</th>
              </tr>
            </thead>
            <tbody>
              <template v-for="(col, ci) in columns" :key="ci">
                <tr v-if="multiPeriod" class="period-header-row">
                  <td :colspan="rows.length + 2">{{ col }}</td>
                </tr>
                <tr v-for="(t, ti) in activityTypes" :key="t.id">
                  <td class="col-type">
                    <span class="type-dot" :style="`background:${COLORS[ti % COLORS.length]}`"></span>
                    {{ shortTypeName(t.name) }}
                  </td>
                  <td v-for="row in rows" :key="row.name" class="col-num">
                    <span :class="(row.data[ci]?.type_counts[t.id] ?? 0) > 0 ? 'cell-active' : 'cell-zero'">
                      {{ row.data[ci]?.type_counts[t.id] ?? 0 }}
                    </span>
                  </td>
                  <td class="col-num text-bold">{{ colTypeTotals[ci]?.[t.id] ?? 0 }}</td>
                </tr>
                <tr class="period-total-row">
                  <td class="col-type text-bold">Total</td>
                  <td v-for="row in rows" :key="row.name" class="col-num text-bold">
                    {{ row.data[ci]?.total ?? 0 }}
                  </td>
                  <td class="col-num text-bold">{{ columnTotals[ci] }}</td>
                </tr>
              </template>
            </tbody>
            <tfoot v-if="multiPeriod">
              <tr class="footer-row">
                <td class="col-type text-bold">Total Semua</td>
                <td v-for="row in rows" :key="row.name" class="col-num text-bold">{{ row.total }}</td>
                <td class="col-num text-bold">{{ grandTotal }}</td>
              </tr>
            </tfoot>
          </table>
        </q-expansion-item>
      </div>

    </template>
  </div>
</template>

<style scoped>
/* ════════════════════════════════════════
   ROOT — stop ALL horizontal overflow
   ════════════════════════════════════════ */
.dash {
  width: 100%;
  max-width: 100%;
  overflow-x: hidden;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  gap: 0;
}

.section-gap { margin-bottom: 12px; }

/* ════════════════════════════════════════
   EMPTY
   ════════════════════════════════════════ */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 48px 0;
  gap: 8px;
  color: #7b8794;
}
.empty-title { font-size: 15px; font-weight: 600; color: #4f5965; }
.empty-sub   { font-size: 12px; }

/* ════════════════════════════════════════
   HERO BANNER
   ════════════════════════════════════════ */
.hero {
  background: linear-gradient(135deg, #132b50 0%, #0a3b82 60%, #1677c8 100%);
  border-radius: 12px;
  padding: 16px 18px 14px;
  color: #fff;
  margin-bottom: 12px;
}
.hero-meta {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 11px;
  opacity: 0.85;
  flex-wrap: wrap;
  margin-bottom: 6px;
}
.hero-sep { opacity: 0.5; }
.hero-total {
  font-size: 2.6rem;
  font-weight: 800;
  line-height: 1;
  letter-spacing: -1px;
}
.hero-label {
  font-size: 12px;
  opacity: 0.8;
  margin-top: 2px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.hero-avg {
  font-size: 11px;
  opacity: 0.8;
  margin-top: 6px;
}
.hero-best { opacity: 0.9; }

/* ════════════════════════════════════════
   STAT CARDS
   ════════════════════════════════════════ */
.stat-card {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 1px 6px rgba(0,0,0,0.08);
  padding: 12px 10px;
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
  overflow: hidden;
}
.stat-icon {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.stat-body {
  min-width: 0;
  flex: 1;
}
.stat-val {
  font-size: 1.35rem;
  font-weight: 800;
  line-height: 1.1;
}
.stat-lbl {
  font-size: 10px;
  color: #7b8794;
  margin-top: 1px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* ════════════════════════════════════════
   CARDS
   ════════════════════════════════════════ */
.card {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 1px 6px rgba(0,0,0,0.07);
  overflow: hidden;
  min-width: 0;
}
.card-head {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  border-bottom: 1px solid #f0f0f0;
}
.card-accent {
  width: 3px;
  height: 16px;
  border-radius: 2px;
  flex-shrink: 0;
}
.card-title {
  font-size: 13px;
  font-weight: 700;
  color: #132b50;
}
.card-body {
  padding: 10px 12px;
}
.chart-body {
  padding: 8px;
  overflow: hidden;
  min-width: 0;
}

/* ════════════════════════════════════════
   DONUT
   ════════════════════════════════════════ */
.donut-wrap {
  width: 100%;
  overflow: hidden;
  min-width: 0;
}
.legend-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 5px 8px;
  margin-top: 8px;
}
.legend-item {
  display: flex;
  align-items: center;
  gap: 5px;
  min-width: 0;
  overflow: hidden;
}
.ldot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}
.ldot.sm {
  width: 6px;
  height: 6px;
}
.lname {
  font-size: 10px;
  color: #4f5965;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
  min-width: 0;
}
.lval {
  font-size: 11px;
  font-weight: 700;
  flex-shrink: 0;
}

/* ════════════════════════════════════════
   SECTION HEADER
   ════════════════════════════════════════ */
.sect-head {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  font-weight: 700;
  color: #132b50;
}

/* ════════════════════════════════════════
   KPI PER BS
   ════════════════════════════════════════ */
.kpi-card {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 1px 5px rgba(0,0,0,0.07);
  padding: 10px 10px 8px;
  min-width: 0;
  overflow: hidden;
}
.kpi-top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 4px;
  margin-bottom: 2px;
  min-width: 0;
}
.kpi-name {
  font-size: 11px;
  font-weight: 700;
  color: #132b50;
  flex: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.kpi-pct {
  font-size: 1.25rem;
  font-weight: 800;
  line-height: 1;
  flex-shrink: 0;
}
.kpi-at-row {
  display: flex;
  align-items: center;
  gap: 0;
  background: #f3f6fa;
  border-radius: 6px;
  padding: 4px 6px;
  margin-bottom: 6px;
}
.kpi-at-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.kpi-at-lbl  { font-size: 9px; color: #7b8794; }
.kpi-at-val  { font-size: 12px; font-weight: 700; color: #132b50; }
.kpi-divider { width: 1px; height: 28px; background: #d5dfec; flex-shrink: 0; }
.kpi-types   { display: flex; flex-direction: column; gap: 3px; margin-top: 4px; }
.kpi-type {
  display: flex;
  align-items: center;
  gap: 4px;
  min-width: 0;
}
.kpi-type-name {
  font-size: 10px;
  color: #7b8794;
  flex: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.kpi-type-val {
  font-size: 10px;
  font-weight: 700;
  color: #132b50;
  flex-shrink: 0;
}

/* ════════════════════════════════════════
   KPI TEAM SUMMARY
   ════════════════════════════════════════ */
.team-summary {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 1px 5px rgba(0,0,0,0.07);
  padding: 14px 16px;
  margin-top: 10px;
}
.team-row {
  display: flex;
  align-items: center;
}
.team-item {
  flex: 1;
  text-align: center;
}
.team-lbl { font-size: 10px; color: #7b8794; margin-bottom: 2px; }
.team-val  { font-size: 1.2rem; font-weight: 800; }
.team-divider {
  width: 1px;
  height: 36px;
  background: #dfe7f2;
  flex-shrink: 0;
}

/* ════════════════════════════════════════
   PENCAPAIAN PER PERIODE
   ════════════════════════════════════════ */
.period-row {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 5px 0;
  border-bottom: 1px solid #e8eff8;
}
.period-row:last-child { border-bottom: none; }

.period-label {
  font-size: 11px;
  font-weight: 600;
  color: #4f5965;
  flex: 0 0 80px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.period-bar-wrap {
  flex: 1;
  height: 8px;
  background: #e8eff8;
  border-radius: 4px;
  overflow: hidden;
  min-width: 0;
}
.period-bar {
  height: 100%;
  background: linear-gradient(90deg, #0a3b82 0%, #1677c8 100%);
  border-radius: 4px;
  transition: width 0.4s ease;
  min-width: 4px;
}
.period-meta {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  flex: 0 0 46px;
}
.period-total {
  font-size: 12px;
  font-weight: 700;
  color: #0a3b82;
  line-height: 1.2;
}
.period-pct {
  font-size: 10px;
  color: #7b8794;
  line-height: 1.2;
}

/* ════════════════════════════════════════
   DETAIL TABLE — auto-fit, no x-scroll
   ════════════════════════════════════════ */
.agro-table {
  width: 100%;
  table-layout: fixed;
  border-collapse: collapse;
  font-size: 0.72rem;
}
.agro-table th,
.agro-table td {
  padding: 4px 3px;
  border: 1px solid #dfe7f2;
  overflow: hidden;
}
.agro-table th {
  background: #f3f6fa;
  text-align: center;
  font-weight: 600;
  color: #4f5965;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.col-type {
  text-align: left;
  width: 32%;
  word-break: break-word;
  overflow-wrap: break-word;
  font-size: 0.7rem;
}
.col-bs   { text-align: center; }
.col-tot  { text-align: center; background: #f7f9fc !important; font-weight: 700; }
.col-num  { text-align: center; }
.type-dot {
  display: inline-block;
  width: 6px; height: 6px;
  border-radius: 50%;
  margin-right: 3px;
  vertical-align: middle;
  flex-shrink: 0;
}
.cell-active { color: #0a3b82; font-weight: 700; }
.cell-zero   { color: #b0bcc9; }
.period-header-row td { background: #e8eff8; font-weight: 700; padding: 3px 4px; font-size: 0.7rem; }
.period-total-row td  { background: #ecf9f0; border-top: 1px solid #b8e0c7; }
.footer-row td        { background: #ffeaf2; border-top: 2px solid #e31c4b; font-weight: 700; }
</style>
