<script setup>
import { computed } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import { formatDate } from "@/helpers/datetime";

const page = usePage();
const item = computed(() => page.props.data || {});
const title = computed(() => `Detail Keluhan #${item.value.id || '-'}`);

const mapUrl = computed(() => {
  const lat = item.value.latitude;
  const lng = item.value.longitude;
  if (lat === null || lat === undefined || lng === null || lng === undefined) return "";
  return `https://www.google.com/maps?q=${lat},${lng}`;
});
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>
    <template #left-button>
      <q-btn icon="arrow_back" dense flat color="grey-7" @click="router.get(route('admin.complaint.index'))" />
    </template>
    <template #right-button>
      <q-btn icon="edit" dense color="primary" v-if="$can('admin.complaint.edit')" @click="router.get(route('admin.complaint.edit', item.id))" />
    </template>

    <div class="q-pa-sm">
      <q-card flat bordered>
        <q-card-section class="row q-col-gutter-md">
          <div class="col-12 col-md-7">
            <div class="text-h6">{{ item.title }}</div>
            <div class="text-caption text-grey-7 q-mb-md">{{ formatDate(item.created_datetime) }}</div>
            <div><b>Kategori:</b> {{ item.category }}</div>
            <div><b>Severity:</b> {{ item.severity }}</div>
            <div><b>Status:</b> {{ item.status }}</div>
            <div><b>Produk:</b> {{ item.product?.name || item.product_name || '-' }}</div>
            <div><b>Batch:</b> {{ item.batch?.batch_number || '-' }}</div>
            <div><b>BS:</b> {{ item.bs?.name || '-' }}</div>
            <div><b>Agronomis:</b> {{ item.agronomist?.name || '-' }}</div>
            <div><b>Lokasi:</b> {{ item.location || '-' }}</div>
            <div><b>Region:</b> {{ item.region || '-' }}</div>
            <div><b>SLA:</b> {{ item.sla_hours || 0 }} jam</div>
            <div><b>Response Time:</b> {{ item.response_time_hours || 0 }} jam</div>
            <div><b>Resolution Time:</b> {{ item.resolution_time_hours || 0 }} jam</div>
            <div class="q-mt-sm"><b>AI Result:</b></div>
            <div class="text-body2" style="white-space: pre-line">{{ item.ai_result || '-' }}</div>
            <div class="q-mt-sm"><b>Deskripsi:</b></div>
            <div class="text-body2" style="white-space: pre-line">{{ item.description || '-' }}</div>
          </div>

          <div class="col-12 col-md-5">
            <q-card flat bordered class="q-mb-sm" v-if="mapUrl">
              <q-card-section>
                <div class="text-subtitle2">Map Point</div>
                <div class="text-caption text-grey-7">Lat: {{ item.latitude }} | Lng: {{ item.longitude }}</div>
                <q-btn class="q-mt-sm" flat color="primary" icon="map" label="Buka di Google Maps" :href="mapUrl" target="_blank" />
              </q-card-section>
            </q-card>

            <q-card flat bordered>
              <q-card-section>
                <div class="text-subtitle2">Foto Keluhan</div>
                <div class="row q-col-gutter-sm q-mt-sm">
                  <div class="col-6" v-for="img in item.images || []" :key="img.id">
                    <q-img :src="'/' + img.image_path" ratio="1" style="border-radius: 8px" />
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>
        </q-card-section>
      </q-card>

      <q-card flat bordered class="q-mt-sm">
        <q-card-section>
          <div class="text-subtitle2">Timeline Log</div>
          <q-markup-table flat dense separator="cell" class="q-mt-sm">
            <thead>
              <tr>
                <th>Waktu</th>
                <th>User</th>
                <th>Aksi</th>
                <th>Status</th>
                <th>Catatan</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="log in item.logs || []" :key="log.id">
                <td>{{ formatDate(log.created_datetime) }}</td>
                <td>{{ log.user?.name || '-' }}</td>
                <td>{{ log.action }}</td>
                <td>{{ log.old_status || '-' }} → {{ log.new_status || '-' }}</td>
                <td>{{ log.notes || '-' }}</td>
              </tr>
            </tbody>
          </q-markup-table>
        </q-card-section>
      </q-card>
    </div>
  </authenticated-layout>
</template>
