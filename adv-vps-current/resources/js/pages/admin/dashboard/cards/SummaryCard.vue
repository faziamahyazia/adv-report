<script setup>
import { formatNumber } from '@/helpers/utils';
import StatCard from './StatCard.vue';
</script>

<template>
  <div class="row">
    <q-card class="bg-transparent no-shadow no-border col" bordered>
      <q-card-section class="q-pa-none">
        <div class="row q-col-gutter-sm ">
          <StatCard :count="formatNumber($page.props.data.active_customer_count)" label="Client Aktif" icon="info"
            :bg-color="'#0a3b82'" :side-color="'#132b50'"
            :to="route('admin.user.index', { status: 'active' })" wrapper-class="col-md-4 col-sm-6 col-xs-12" />
          <StatCard :count="formatNumber($page.props.data.active_sales_count)" label="Sales Aktif" icon="info"
            :bg-color="'#e31c4b'" :side-color="'#a10f56'" :to="route('admin.user.index', { status: 'active' })"
            wrapper-class="col-md-4 col-sm-6 col-xs-12" />
          <StatCard :count="formatNumber($page.props.data.active_service_count)" label="Layanan Aktif" icon="info"
            :bg-color="'#00b140'" :side-color="'#008a3d'" :to="route('admin.service.index', { status: 'active' })"
            wrapper-class="col-md-4 col-sm-6 col-xs-12" />
        </div>
        <div class="row q-col-gutter-sm q-pt-sm">
          <StatCard :count="formatNumber($page.props.data.active_interaction_plan_count)" label="Plan Interaksi"
            icon="info" :to="route('admin.interaction.index', { status: 'planned' })"
            wrapper-class="col-md-4 col-sm-6 col-xs-12" :bg-color="'#f9a800'" :side-color="'#ff5a00'" />
          <StatCard :count="formatNumber($page.props.data.active_customer_service_count)" label="Layanan Client Aktif"
            icon="info" :bg-color="'#a10f56'" :side-color="'#7b0d45'"
            :to="route('admin.user.index', { status: 'active' })" wrapper-class="col-md-4 col-sm-6 col-xs-12" />
          <StatCard :count="formatNumber($page.props.data.active_user_count)" label="Pengguna Aktif" icon="info"
            :bg-color="'#1677c8'" :side-color="'#0a3b82'" :to="route('admin.user.index', { status: 'active' })"
            wrapper-class="col-md-4 col-sm-6 col-xs-12" />
        </div>
      </q-card-section>
    </q-card>
  </div>
</template>
