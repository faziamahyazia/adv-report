<template>
  <div class="row q-col-gutter-sm">
    <!-- Interaksi vs Closing vs Client Baru -->
    <div class="col-lg-6 col-md-12 card-container">
      <q-card square bordered class="no-shadow bg-white">
        <q-card-section class="q-pa-none">
          <ECharts :option="chartInteractionClosingCustomer" class="q-mt-md" :resizable="true" autoresize
            style="height: 250px" />
        </q-card-section>
      </q-card>
    </div>

    <!-- Closing -->
    <div class="col-lg-6 col-md-12 card-container">
      <q-card square bordered class="no-shadow bg-white">
        <q-card-section class="q-pa-none">
          <ECharts :option="chartRevenue" autoresize style="height: 250px;" />
        </q-card-section>
      </q-card>
    </div>

    <!-- Donut Chart Status Interaksi -->
    <div class="col-lg-4 col-md-6 col-sm-12 card-container">
      <q-card square bordered class="no-shadow bg-white">
        <q-card-section class="q-pa-none">
          <ECharts :option="interactions_chart_data" autoresize style="height: 250px" />
        </q-card-section>
      </q-card>
    </div>

    <!-- Top 5 Sales Interaksi -->
    <div class="col-lg-4 col-md-6 col-sm-12 card-container">
      <q-card square bordered class="no-shadow bg-white">
        <q-card-section class="q-pa-none">
          <ECharts :option="chartTopInteraction" autoresize style="height: 250px" />
        </q-card-section>
      </q-card>
    </div>

    <!-- Top 5 Sales Closing -->
    <div class="col-lg-4 col-md-12 col-sm-12 card-container">
      <q-card square bordered class="no-shadow bg-white">
        <q-card-section class="q-pa-none">
          <ECharts :option="chartTopClosing" autoresize style="height: 250px" />
        </q-card-section>
      </q-card>
    </div>
  </div>
</template>

<script setup>
import { usePage } from '@inertiajs/vue3';
import ECharts from 'vue-echarts';
import * as echarts from 'echarts';
const page = usePage();

const AXIS_COLOR = '#4f5965';
const GRID_COLOR = '#d5dfec';
const TITLE_COLOR = '#132b50';
const SERIES = {
  blue: '#0a3b82',
  green: '#00b140',
  red: '#e31c4b',
  magenta: '#a10f56',
  gold: '#f9a800',
};

const chartInteractionClosingCustomer = {
  title: { text: 'Interaksi, Closing, Client Baru', left: 'center', textStyle: { color: TITLE_COLOR } },
  tooltip: { show: true },
  legend: { top: '10%', data: ['Interaksi', 'Closing', 'Client Baru'] },
  grid: { containLabel: true, left: '5px', bottom: '5px', right: '5px' },
  xAxis: {
    type: 'category',
    data: page.props.chart_data.labels,
    axisLine: { lineStyle: { color: AXIS_COLOR, type: 'dashed' } },
    axisTick: { alignWithLabel: true, lineStyle: { color: GRID_COLOR, type: 'dashed' } },
    axisLabel: { show: true }
  },
  yAxis: {
    type: 'value',
    axisLine: { lineStyle: { color: AXIS_COLOR, type: 'dashed' } },
    splitLine: { lineStyle: { type: 'dashed', color: GRID_COLOR } }
  },
  series: [
    { name: 'Interaksi', type: 'line', smooth: true, data: page.props.chart_data.count_interactions, lineStyle: { color: SERIES.blue }, itemStyle: { color: SERIES.blue } },
    { name: 'Closing', type: 'line', smooth: true, data: page.props.chart_data.count_closings, lineStyle: { color: SERIES.green }, itemStyle: { color: SERIES.green } },
    { name: 'Client Baru', type: 'line', smooth: true, data: page.props.chart_data.count_new_customers, lineStyle: { color: SERIES.red }, itemStyle: { color: SERIES.red } },
  ]
};

const chartRevenue = {
  title: { text: 'Pendapatan', left: 'center', textStyle: { color: TITLE_COLOR } },
  tooltip: { show: true },
  legend: { top: '10%', data: ['Total Closing (Rp)'] },
  grid: { containLabel: true, left: '5px', bottom: '5px', right: '5px' },
  xAxis: {
    type: 'category',
    data: page.props.chart_data.labels,
    axisLine: { lineStyle: { color: AXIS_COLOR, type: 'dashed' } },
    axisTick: { alignWithLabel: true, lineStyle: { color: GRID_COLOR, type: 'dashed' } },
    axisLabel: { show: true }
  },
  yAxis: {
    type: 'value',
    axisLine: { lineStyle: { color: AXIS_COLOR, type: 'dashed' } },
    splitLine: { lineStyle: { type: 'dashed', color: GRID_COLOR } }
  },
  series: [
    {
      name: 'Total Closing (Rp)',
      type: 'bar',
      data: page.props.chart_data.total_closings,
      itemStyle: { color: SERIES.blue }
    }
  ]
};

const interactions_chart_data = {
  title: { text: 'Status Interaksi', left: 'center', textStyle: { color: TITLE_COLOR } },
  tooltip: { trigger: 'item' },
  legend: {
    orient: 'vertical',
    left: 'left',
    textStyle: { color: TITLE_COLOR }
  },
  series: [
    {
      name: 'Status',
      type: 'pie',
      radius: '50%',
      data: page.props.chart_data.interactions,
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      }
    }
  ]
};

const chartTopInteraction = {
  title: { text: 'Top 5 Sales Interaksi', left: 'center', textStyle: { color: TITLE_COLOR } },
  tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
  xAxis: { type: 'value' },
  yAxis: {
    type: 'category',
    inverse: true,
    data: page.props.chart_data.top_interactions.labels
  },
  series: [
    {
      name: 'Interaksi',
      type: 'bar',
      data: page.props.chart_data.top_interactions.data,
      itemStyle: { color: SERIES.magenta }
    }
  ]
};

const chartTopClosing = {
  title: { text: 'Top 5 Sales Closing', left: 'center', textStyle: { color: TITLE_COLOR } },
  tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
  xAxis: { type: 'value' },
  yAxis: {
    type: 'category',
    inverse: true,
    data: page.props.chart_data.top_sales_closings.labels,
  },
  series: [
    {
      name: 'Closing',
      type: 'bar',
      data: page.props.chart_data.top_sales_closings.data,
      itemStyle: { color: SERIES.gold }
    }
  ]
};
</script>

<style scoped>
.q-card {
  width: 100%;
}

@media (max-width: 992px) {
  .card-container {
    width: 100% !important;
  }
}
</style>
