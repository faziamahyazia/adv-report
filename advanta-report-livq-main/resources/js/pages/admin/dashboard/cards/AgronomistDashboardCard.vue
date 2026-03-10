<script setup>
import { usePage } from "@inertiajs/vue3";
import { computed } from "vue";

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

function kpiClass(kpi) {
  if (kpi === null || kpi === undefined) return "kpi-none";
  if (kpi >= 100) return "kpi-green";
  if (kpi >= 75) return "kpi-yellow";
  return "kpi-red";
}
</script>

<template>
  <div>
    <div class="text-caption text-grey-6 q-mb-sm">{{ periodLabel }}</div>

    <div v-if="rows.length === 0" class="text-center text-grey-7 q-py-lg">
      <q-icon name="group" size="32px" class="q-mb-sm" />
      <div>Tidak ada BS yang terdaftar di bawah Anda.</div>
    </div>

    <template v-else>
      <!-- ===== TABEL DETAIL ===== -->
      <div class="table-wrapper">
        <table class="agro-table">
          <thead>
            <tr>
              <th class="col-type">Jenis Kegiatan</th>
              <th v-for="row in rows" :key="row.name" class="col-bs">
                {{ row.name }}
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
                <td class="col-type">{{ t.name }}</td>
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

      <!-- ===== RINGKASAN KPI (hanya kwartal & tahun fiskal) ===== -->
      <template v-if="summary">
        <div class="text-subtitle2 text-bold q-mt-lg q-mb-sm">
          Ringkasan KPI
        </div>
        <div class="table-wrapper">
          <table class="agro-table summary-table">
            <thead>
              <tr>
                <th class="col-type">Nama BS</th>
                <th v-for="t in activityTypes" :key="t.id">{{ t.name }}</th>
                <th>Aktual</th>
                <th>Target</th>
                <th>KPI%</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in summary.rows" :key="row.name">
                <td class="col-type">{{ row.name }}</td>
                <td v-for="t in activityTypes" :key="t.id" class="text-center">
                  <span :class="(row.type_actuals[t.id] ?? 0) > 0 ? 'text-primary' : 'text-grey-5'">
                    {{ row.type_actuals[t.id] ?? 0 }}
                  </span>
                </td>
                <td class="text-center text-bold">{{ row.total_actual }}</td>
                <td class="text-center text-grey-7">{{ row.total_target }}</td>
                <td class="text-center text-bold kpi-badge" :class="kpiClass(row.kpi)">
                  {{ row.kpi !== null ? row.kpi + "%" : "-" }}
                </td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="footer-row">
                <td class="col-type text-bold">Total</td>
                <td v-for="t in activityTypes" :key="t.id" class="text-center text-bold">
                  {{ summary.totals.type_actuals[t.id] ?? 0 }}
                </td>
                <td class="text-center text-bold">{{ summary.totals.total_actual }}</td>
                <td class="text-center text-bold">{{ summary.totals.total_target }}</td>
                <td class="text-center text-bold kpi-badge" :class="kpiClass(summary.totals.kpi)">
                  {{ summary.totals.kpi !== null ? summary.totals.kpi + "%" : "-" }}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
      </template>
    </template>
  </div>
</template>

<style scoped>
.table-wrapper {
  overflow-x: auto;
}
.agro-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.85rem;
}
.agro-table th,
.agro-table td {
  padding: 5px 10px;
  border: 1px solid #e0e0e0;
}
.agro-table th {
  background: #f5f5f5;
  text-align: center;
  font-weight: 600;
}
.col-type {
  text-align: left;
  min-width: 110px;
  white-space: nowrap;
}
.col-bs {
  min-width: 80px;
  max-width: 120px;
  word-break: break-word;
  white-space: normal;
}
.period-header-row td {
  background: #e3f2fd;
  font-weight: 700;
  font-size: 0.82rem;
  padding: 4px 10px;
  letter-spacing: 0.02em;
}
.period-total-row td {
  background: #f9fbe7;
  border-top: 1px solid #c5cae9;
}
.footer-row td {
  background: #fce4ec;
  border-top: 2px solid #e57373;
  font-weight: 700;
}

/* KPI badges */
.kpi-badge {
  font-size: 0.82rem;
  font-weight: 700;
  border-radius: 3px;
}
.kpi-green  { color: #2e7d32; background: #e8f5e9; }
.kpi-yellow { color: #e65100; background: #fff3e0; }
.kpi-red    { color: #c62828; background: #ffebee; }
.kpi-none   { color: #9e9e9e; }
</style>
