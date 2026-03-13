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
const monthlyProgress = calculateMonthlyActivityProgress(
  usePage().props.data.types,
  monthIndex,
  usePage().props.data.targets,
  usePage().props.data.activities
);
const quarterProgress = calculateQuarterActivityProgress(
  usePage().props.data.types,
  usePage().props.data.targets,
  usePage().props.data.activities
);
</script>

<template>
  <div class="row">
    <q-card class="bg-transparent no-shadow no-border col" bordered>
      <q-card-section class="q-pa-none">
        <div class="row q-py-sm">
          <div class="col-12">
            <div class="progress-label text-bold">
              Progress Bulanan:
              {{ formatNumber(monthlyProgress, "id-ID", 2) }}%
            </div>
            <div class="q-mb-sm">
              <q-linear-progress
                :value="monthlyProgress / 100"
                size="10px"
                color="primary"
                class="q-mt-xs"
                rounded
                stripe
                animated
              />
            </div>
            <template v-if="$page.props.data.types.length > 0">
              <ActivityTable
                :types="$page.props.data.types"
                :targets="$page.props.data.targets"
                :plans="$page.props.data.plans"
                :activities="$page.props.data.activities"
                :type="'month' + monthIndex"
              />
            </template>
            <template v-else>
              <div class="text-center text-grey-8">
                <q-icon name="info" size="32px" />
                <p class="text-subtitle1">Target belum ditetapkan</p>
              </div>
            </template>
          </div>
        </div>
        <div class="row q-py-sm q-mt-sm">
          <div class="col-12">
            <div class="progress-label text-bold">
              Progress Kwartal:
              {{ formatNumber(quarterProgress, "id-ID", 2) }}%
            </div>
            <div class="q-mb-sm">
              <q-linear-progress
                :value="quarterProgress / 100"
                size="10px"
                color="primary"
                class="q-mt-xs"
                rounded
                stripe
                animated
              />
            </div>
            <template v-if="$page.props.data.types.length > 0">
              <ActivityTable
                :types="$page.props.data.types"
                :targets="$page.props.data.targets"
                :plans="$page.props.data.plans"
                :activities="$page.props.data.activities"
              />
            </template>
            <template v-else>
              <div class="text-center text-grey-8">
                <q-icon name="info" size="32px" />
                <p class="text-subtitle1">Target belum ditetapkan</p>
              </div>
            </template>
          </div>
        </div>
      </q-card-section>
    </q-card>
  </div>
</template>
<style scoped>
.progress-label {
  font-size: 13px;
  margin-bottom: 4px;
}
@media (min-width: 600px) {
  .progress-label {
    font-size: 14px;
  }
}
</style>
