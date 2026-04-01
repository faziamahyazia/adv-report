<script setup>
import BsTargetCard from "./cards/BsTargetCard.vue";
import AgronomistDashboardCard from "./cards/AgronomistDashboardCard.vue";
import { router, usePage } from "@inertiajs/vue3";
import { useQuasar } from "quasar";
import { reactive, ref, computed } from "vue";
import {
  create_month_options,
  current_month,
  current_quarter,
  current_year,
  getQueryParams,
} from "@/helpers/utils";

const query = getQueryParams();
const currentYear = current_year();
const currentMonth = current_month();
const currentQuarter = current_quarter();
// Fiscal year starts in April; Jan-Mar belong to previous fiscal year
const currentFiscalYear = currentMonth <= 3 ? currentYear - 1 : currentYear;
const userRole = usePage().props.auth.user.role;
const $q = useQuasar();
const title = "Dashboard";
const showFilter = ref(true);

const filter = reactive({
  year: Number(query.year ?? currentFiscalYear),
  month: Number(query.month ?? currentMonth),
  view_type: query.view_type ?? "month",
  quarter: Number(query.quarter ?? currentQuarter),
});

const years = [
  ...Array.from({ length: 4 }, (_, i) => {
    const year = currentFiscalYear - 2 + i;
    return { value: year, label: String(year) + " / " + String(year + 1) };
  }),
];

const months = create_month_options();

const quarterOptions = [
  { value: 1, label: "Q1 (Apr-Jun)" },
  { value: 2, label: "Q2 (Jul-Sep)" },
  { value: 3, label: "Q3 (Okt-Des)" },
  { value: 4, label: "Q4 (Jan-Mar)" },
];

const viewTypeOptions = computed(() => [
  { value: "month",       label: $q.screen.xs ? "Bulanan"  : "Per Bulan" },
  { value: "quarter",     label: $q.screen.xs ? "Kwartal"  : "Per Kwartal" },
  { value: "fiscal_year", label: $q.screen.xs ? "Fiskal"   : "Tahun Fiskal" },
]);

const onFilterChange = () => {
  router.visit(route("admin.dashboard", filter));
};
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>
    <template #right-button>
      <q-btn
        class="q-ml-sm"
        :icon="!showFilter ? 'filter_alt' : 'filter_alt_off'"
        color="grey"
        dense
        @click="showFilter = !showFilter"
      />
    </template>

    <template #header v-if="showFilter">
      <q-toolbar class="filter-bar">
        <div class="filter-wrap">

          <!-- Tabs: view type — agronomist / asm / admin -->
          <div v-if="['agronomist','asm','admin'].includes(userRole)" class="filter-tabs">
            <q-btn-toggle
              v-model="filter.view_type"
              :options="viewTypeOptions"
              size="sm"
              dense
              toggle-color="primary"
              color="white"
              text-color="grey-8"
              unelevated
              spread
              @update:model-value="onFilterChange"
            />
          </div>

          <!-- Selects row -->
          <div class="filter-selects">
            <!-- Tahun -->
            <q-select
              class="filter-sel"
              v-model="filter.year"
              :options="years"
              label="Tahun"
              dense
              emit-value
              map-options
              outlined
              @update:model-value="onFilterChange"
            />

            <!-- Bulan — BS selalu tampil, agronomist/asm/admin hanya mode 'month' -->
            <q-select
              v-if="userRole === 'bs' || (['agronomist','asm','admin'].includes(userRole) && filter.view_type === 'month')"
              class="filter-sel"
              v-model="filter.month"
              :options="months"
              label="Bulan"
              dense
              emit-value
              map-options
              outlined
              @update:model-value="onFilterChange"
            />

            <!-- Kwartal — agronomist/asm/admin mode 'quarter' -->
            <q-select
              v-if="['agronomist','asm','admin'].includes(userRole) && filter.view_type === 'quarter'"
              class="filter-sel"
              v-model="filter.quarter"
              :options="quarterOptions"
              label="Kwartal"
              dense
              emit-value
              map-options
              outlined
              @update:model-value="onFilterChange"
            />
          </div>
        </div>
      </q-toolbar>
    </template>

    <!-- BS Dashboard -->
    <div class="dash-wrap" v-if="userRole === 'bs'">
      <BsTargetCard />
    </div>

    <!-- Agronomist Dashboard -->
    <div class="dash-wrap" v-if="userRole === 'agronomist'">
      <AgronomistDashboardCard />
    </div>

    <!-- Admin Dashboard -->
    <div class="dash-wrap" v-if="userRole === 'admin'">
      <AgronomistDashboardCard />
    </div>

    <!-- ASM Dashboard -->
    <div class="dash-wrap" v-if="userRole === 'asm'">
      <AgronomistDashboardCard />
    </div>
  </authenticated-layout>
</template>

<style scoped>
/* ── Filter bar ─── */
.filter-wrap {
  width: 100%;
  padding: 8px 0;
  box-sizing: border-box;
}
.filter-tabs {
  width: 100%;
  margin-bottom: 8px;
}
.filter-selects {
  display: flex;
  flex-direction: row;
  gap: 8px;
  width: 100%;
}
.filter-sel {
  flex: 1;
  min-width: 0;
}

/* ── Dash wrapper ─── */
.dash-wrap {
  padding: 12px;
  overflow-x: hidden;
  box-sizing: border-box;
  width: 100%;
  max-width: 100%;
  contain: inline-size;
}
</style>
