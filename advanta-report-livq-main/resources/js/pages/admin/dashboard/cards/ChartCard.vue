<template>
  <div class="row q-col-gutter-sm">
    <!-- Interaksi vs Closing vs Client Baru -->
    <div class="col-12 col-lg-6 card-container">
      <q-card square bordered class="no-shadow bg-white chart-wrap">
        <q-card-section class="q-pa-sm">
          <div class="chart-label">Interaksi, Closing & Client Baru</div>
          <ECharts :option="chartInteractionClosingCustomer" autoresize class="chart-el" />
        </q-card-section>
      </q-card>
    </div>

    <!-- Pendapatan -->
    <div class="col-12 col-lg-6 card-container">
      <q-card square bordered class="no-shadow bg-white chart-wrap">
        <q-card-section class="q-pa-sm">
          <div class="chart-label">Pendapatan</div>
          <ECharts :option="chartRevenue" autoresize class="chart-el" />
        </q-card-section>
      </q-card>
    </div>

    <!-- Donut Chart Status Interaksi -->
    <div class="col-12 col-sm-6 col-lg-4 card-container">
      <q-card square bordered class="no-shadow bg-white chart-wrap">
        <q-card-section class="q-pa-sm">
          <div class="chart-label">Status Interaksi</div>
          <ECharts :option="interactions_chart_data" autoresize class="chart-el" />
        </q-card-section>
      </q-card>
    </div>

    <!-- Top 5 Sales Interaksi -->
    <div class="col-12 col-sm-6 col-lg-4 card-container">
      <q-card square bordered class="no-shadow bg-white chart-wrap">
        <q-card-section class="q-pa-sm">
          <div class="chart-label">Top 5 Sales Interaksi</div>
          <ECharts :option="chartTopInteraction" autoresize class="chart-el" />
        </q-card-section>
      </q-card>
    </div>

    <!-- Top 5 Sales Closing -->
    <div class="col-12 col-sm-12 col-lg-4 card-container">
      <q-card square bordered class="no-shadow bg-white chart-wrap">
        <q-card-section class="q-pa-sm">
          <div class="chart-label">Top 5 Sales Closing</div>
          <ECharts :option="chartTopClosing" autoresize class="chart-el" />
        </q-card-section>
      </q-card>
    </div>
  </div>
</template>

<script setup>
import { usePage } from '@inertiajs/vue3';
import ECharts from 'vue-echarts';
const page = usePage();

const sharedGrid = { containLabel: true, left: 8, right: 8, bottom: 8, top: 8 };
const sharedAxisLine = { lineStyle: { color: '#ccc', type: 'dashed' } };
const sharedAxisLabel = { fontSize: 11 };

const chartInteractionClosingCustomer = {
  tooltip: { trigger: 'axis', textStyle: { fontSize: 12 } },
  legend: { top: 4, textStyle: { fontSize: 11 }, itemWidth: 12, itemHeight: 12, data: ['Interaksi', 'Closing', 'Client Baru'] },
  grid: { ...sharedGrid, top: 36 },
  xAxis: {
    type: 'category',
    data: page.props.chart_data.labels,
    axisLine: sharedAxisLine,
    axisTick: { alignWithLabel: true, lineStyle: { color: '#ccc', type: 'dashed' } },
    axisLabel: { ...sharedAxisLabel, interval: 0, rotate: (page.props.chart_data.labels ?? []).length > 6 ? 30 : 0 },
  },
  yAxis: {
    type: 'value',
    axisLine: sharedAxisLine,
    axisLabel: { fontSize: 10 },
    splitLine: { lineStyle: { type: 'dashed', color: '#eee' } },
    minInterval: 1,
  },
  series: [
    { name: 'Interaksi', type: 'line', smooth: true, data: page.props.chart_data.count_interactions, lineStyle: { color: '#007bff' }, itemStyle: { color: '#007bff' } },
    { name: 'Closing', type: 'line', smooth: true, data: page.props.chart_data.count_closings, lineStyle: { color: '#28a745' }, itemStyle: { color: '#28a745' } },
    { name: 'Client Baru', type: 'line', smooth: true, data: page.props.chart_data.count_new_customers, lineStyle: { color: '#dc3545' }, itemStyle: { color: '#dc3545' } },
  ],
};

const chartRevenue = {
  tooltip: { trigger: 'axis', textStyle: { fontSize: 12 } },
  legend: { top: 4, textStyle: { fontSize: 11 }, itemWidth: 12, itemHeight: 12, data: ['Total Closing (Rp)'] },
  grid: { ...sharedGrid, top: 36 },
  xAxis: {
    type: 'category',
    data: page.props.chart_data.labels,
    axisLine: sharedAxisLine,
    axisTick: { alignWithLabel: true, lineStyle: { color: '#ccc', type: 'dashed' } },
    axisLabel: { ...sharedAxisLabel, interval: 0, rotate: (page.props.chart_data.labels ?? []).length > 6 ? 30 : 0 },
  },
  yAxis: {
    type: 'value',
    axisLine: sharedAxisLine,
    axisLabel: { fontSize: 10 },
    splitLine: { lineStyle: { type: 'dashed', color: '#eee' } },
  },
  series: [
    {
      name: 'Total Closing (Rp)',
      type: 'bar',
      data: page.props.chart_data.total_closings,
      itemStyle: { color: '#007bff' },
    },
  ],
};

const interactions_chart_data = {
  tooltip: { trigger: 'item', textStyle: { fontSize: 11 } },
  legend: { orient: 'vertical', left: 'left', textStyle: { color: '#444', fontSize: 11 }, itemWidth: 10, itemHeight: 10 },
  series: [
    {
      name: 'Status',
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['60%', '55%'],
      data: page.props.chart_data.interactions,
      label: { fontSize: 10, formatter: '{b}\n{c}' },
      labelLine: { length: 8, length2: 6 },
      emphasis: { itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0,0,0,0.5)' } },
    },
  ],
};

const chartTopInteraction = {
  tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' }, textStyle: { fontSize: 11 } },
  grid: { ...sharedGrid, top: 8, left: 12, right: 12 },
  xAxis: { type: 'value', axisLabel: { fontSize: 10 }, minInterval: 1 },
  yAxis: {
    type: 'category',
    inverse: true,
    data: page.props.chart_data.top_interactions.labels,
    axisLabel: { fontSize: 11 },
  },
  series: [
    {
      name: 'Interaksi',
      type: 'bar',
      data: page.props.chart_data.top_interactions.data,
      itemStyle: { color: '#17a2b8' },
      label: { show: true, position: 'right', fontSize: 10 },
    },
  ],
};

const chartTopClosing = {
  tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' }, textStyle: { fontSize: 11 } },
  grid: { ...sharedGrid, top: 8, left: 12, right: 12 },
  xAxis: { type: 'value', axisLabel: { fontSize: 10 }, minInterval: 1 },
  yAxis: {
    type: 'category',
    inverse: true,
    data: page.props.chart_data.top_sales_closings.labels,
    axisLabel: { fontSize: 11 },
  },
  series: [
    {
      name: 'Closing',
      type: 'bar',
      data: page.props.chart_data.top_sales_closings.data,
      itemStyle: { color: '#ffc107' },
      label: { show: true, position: 'right', fontSize: 10 },
    },
  ],
};
</script>

<style scoped>
.chart-wrap {
  width: 100%;
  height: 100%;
}
.chart-label {
  font-size: 12px;
  font-weight: 600;
  color: #555;
  margin-bottom: 4px;
}
/* Mobile: shorter chart to save vertical space */
.chart-el {
  height: 220px;
}
@media (min-width: 600px) {
  .chart-el {
    height: 260px;
  }
}
@media (min-width: 1024px) {
  .chart-el {
    height: 280px;
  }
}
</style>
