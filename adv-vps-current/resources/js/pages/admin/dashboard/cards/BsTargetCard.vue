<script setup>
import { usePage } from "@inertiajs/vue3";
import ActivityTable from "@/components/ActivityTable.vue";
import {
  calculateMonthlyActivityProgress,
  calculateQuarterActivityProgress,
} from "@/composables/useCalculateActivityProgress";
import {
  current_month,
  formatNumber,
  getQueryParams,
  getMonthIndexInQuarter,
} from "@/helpers/utils";

const selectedMonth = getQueryParams().month || current_month();
const monthIndex = getMonthIndexInQuarter(selectedMonth);
const monthyProgress = calculateMonthlyActivityProgress(
  usePage().props.data.types,
  monthIndex,
  usePage().props.data.targets,
  usePage().props.data.activities
);
const querterProgress = calculateQuarterActivityProgress(
  usePage().props.data.types,
  usePage().props.data.targets,
  usePage().props.data.activities
);
</script>

<template>
  <div class="bs-wrap">

    <!-- ── Monthly Section ── -->
    <q-card flat bordered class="bs-section-card q-mb-sm">
      <q-card-section class="q-py-sm q-px-sm">
        <div class="bs-progress-header">
          <div class="bs-progress-label">
            <q-icon name="calendar_today" size="14px" color="primary" class="q-mr-xs" />
            Progress Bulanan
          </div>
          <div class="bs-progress-pct text-primary">
            {{ formatNumber(monthyProgress, "id-ID", 2) }}%
          </div>
        </div>
        <q-linear-progress
          :value="monthyProgress / 100"
          size="10px"
          color="primary"
          class="q-mb-sm"
          rounded
          stripe
          animated
        />
        <template v-if="$page.props.data.types.length > 0">
          <div class="table-scroll">
            <ActivityTable
              :types="$page.props.data.types"
              :targets="$page.props.data.targets"
              :plans="$page.props.data.plans"
              :activities="$page.props.data.activities"
              :type="'month' + monthIndex"
            />
          </div>
        </template>
        <template v-else>
          <div class="text-center text-grey-8 q-py-sm">
            <q-icon name="info" size="28px" color="grey-5" />
            <div class="text-caption q-mt-xs">Target belum ditetapkan</div>
          </div>
        </template>
      </q-card-section>
    </q-card>

    <!-- ── Quarterly Section ── -->
    <q-card flat bordered class="bs-section-card">
      <q-card-section class="q-py-sm q-px-sm">
        <div class="bs-progress-header">
          <div class="bs-progress-label">
            <q-icon name="date_range" size="14px" color="teal" class="q-mr-xs" />
            Progress Kwartal
          </div>
          <div class="bs-progress-pct text-teal">
            {{ formatNumber(querterProgress, "id-ID", 2) }}%
          </div>
        </div>
        <q-linear-progress
          :value="querterProgress / 100"
          size="10px"
          color="teal"
          class="q-mb-sm"
          rounded
          stripe
          animated
        />
        <template v-if="$page.props.data.types.length > 0">
          <div class="table-scroll">
            <ActivityTable
              :types="$page.props.data.types"
              :targets="$page.props.data.targets"
              :plans="$page.props.data.plans"
              :activities="$page.props.data.activities"
            />
          </div>
        </template>
        <template v-else>
          <div class="text-center text-grey-8 q-py-sm">
            <q-icon name="info" size="28px" color="grey-5" />
            <div class="text-caption q-mt-xs">Target belum ditetapkan</div>
          </div>
        </template>
      </q-card-section>
    </q-card>

  </div>
</template>

<style scoped>
.bs-wrap {
  width: 100%;
  box-sizing: border-box;
}
.bs-section-card {
  width: 100%;
}
.bs-progress-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}
.bs-progress-label {
  display: flex;
  align-items: center;
  font-size: 13px;
  font-weight: 700;
  color: #424242;
}
.bs-progress-pct {
  font-size: 16px;
  font-weight: 700;
}
.table-scroll {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  width: 100%;
}
</style>
