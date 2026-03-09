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
</script>

<template>
  <div>
    <div class="text-caption text-grey-6 q-mb-sm">{{ periodLabel }}</div>

    <div v-if="rows.length === 0" class="text-center text-grey-7 q-py-lg">
      <q-icon name="group" size="32px" class="q-mb-sm" />
      <div>Tidak ada BS yang terdaftar di bawah Anda.</div>
    </div>

    <div v-else class="table-wrapper">
      <table class="agro-table">
        <thead>
          <!-- Row 1: period headers (span over all type sub-columns + total) -->
          <tr>
            <th class="col-name" rowspan="2">Nama BS</th>
            <th
              v-for="col in columns"
              :key="col"
              :colspan="activityTypes.length + 1"
            >
              {{ col }}
            </th>
            <th rowspan="2">Total</th>
          </tr>
          <!-- Row 2: activity type sub-headers per period -->
          <tr>
            <template v-for="col in columns" :key="col">
              <th v-for="t in activityTypes" :key="t.id">{{ t.name }}</th>
              <th>Jml</th>
            </template>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.name">
            <td class="col-name">{{ row.name }}</td>
            <template v-for="(period, i) in row.data" :key="i">
              <td v-for="t in activityTypes" :key="t.id" class="text-center">
                <span
                  :class="
                    (period.type_counts[t.id] ?? 0) > 0
                      ? 'text-primary text-bold'
                      : 'text-grey-5'
                  "
                >
                  {{ period.type_counts[t.id] ?? 0 }}
                </span>
              </td>
              <td class="text-center text-bold">{{ period.total }}</td>
            </template>
            <td class="text-center text-bold">{{ row.total }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="footer-row">
            <td class="col-name text-bold">Total</td>
            <template v-for="(typeTotals, i) in colTypeTotals" :key="i">
              <td v-for="t in activityTypes" :key="t.id" class="text-center text-bold">
                {{ typeTotals[t.id] ?? 0 }}
              </td>
              <td class="text-center text-bold">{{ columnTotals[i] }}</td>
            </template>
            <td class="text-center text-bold">{{ grandTotal }}</td>
          </tr>
        </tfoot>
      </table>
    </div>
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
  white-space: nowrap;
}
.agro-table th {
  background: #f5f5f5;
  text-align: center;
  font-weight: 600;
}
.agro-table th.col-name,
.agro-table td.col-name {
  text-align: left;
  min-width: 140px;
}
.footer-row td {
  background: #fafafa;
  border-top: 2px solid #bdbdbd;
}
</style>
