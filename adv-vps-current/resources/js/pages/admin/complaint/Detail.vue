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

    <div class="q-pa-md">
      <q-card flat bordered>
        <q-card-section class="row q-col-gutter-md">
          <!-- Left Column - Main Info -->
          <div class="col-12 col-md-7">
            <!-- Header -->
            <div class="q-mb-lg">
              <div class="text-h5 text-weight-medium">{{ item.title }}</div>
              <div class="text-body2 text-grey-7 q-mt-xs">{{ formatDate(item.created_datetime) }}</div>
            </div>

            <!-- Basic Info Section -->
            <div class="q-mb-md">
              <div class="text-subtitle2 text-grey-8 q-mb-sm">Informasi Dasar</div>
              <q-separator class="q-mb-sm" />
              <div class="row q-col-gutter-sm">
                <div class="col-6 col-sm-4">
                  <div class="text-caption text-grey-7">Kategori</div>
                  <div class="text-body2">{{ item.category || '-' }}</div>
                </div>
                <div class="col-6 col-sm-4">
                  <div class="text-caption text-grey-7">Severity</div>
                  <div class="text-body2">
                    <q-badge :color="item.severity === 'high' ? 'red' : item.severity === 'medium' ? 'orange' : 'green'">
                      {{ item.severity || '-' }}
                    </q-badge>
                  </div>
                </div>
                <div class="col-6 col-sm-4">
                  <div class="text-caption text-grey-7">Status</div>
                  <div class="text-body2">
                    <q-badge :color="item.status === 'resolved' ? 'green' : item.status === 'open' ? 'blue' : 'grey'">
                      {{ item.status || '-' }}
                    </q-badge>
                  </div>
                </div>
              </div>
            </div>

            <!-- Product & Team Info -->
            <div class="q-mb-md">
              <div class="text-subtitle2 text-grey-8 q-mb-sm">Produk & Tim</div>
              <q-separator class="q-mb-sm" />
              <div class="row q-col-gutter-sm">
                <div class="col-6">
                  <div class="text-caption text-grey-7">Produk</div>
                  <div class="text-body2">{{ item.product?.name || item.product_name || '-' }}</div>
                </div>
                <div class="col-6">
                  <div class="text-caption text-grey-7">Batch</div>
                  <div class="text-body2">{{ item.batch?.batch_number || '-' }}</div>
                </div>
                <div class="col-6">
                  <div class="text-caption text-grey-7">BS</div>
                  <div class="text-body2">{{ item.bs?.name || '-' }}</div>
                </div>
                <div class="col-6">
                  <div class="text-caption text-grey-7">Agronomis</div>
                  <div class="text-body2">{{ item.agronomist?.name || '-' }}</div>
                </div>
              </div>
            </div>

            <!-- Location Info -->
            <div class="q-mb-md">
              <div class="text-subtitle2 text-grey-8 q-mb-sm">Lokasi</div>
              <q-separator class="q-mb-sm" />
              <div class="row q-col-gutter-sm">
                <div class="col-12">
                  <div class="text-caption text-grey-7">Lokasi</div>
                  <div class="text-body2">{{ item.location || '-' }}</div>
                </div>
                <div class="col-6">
                  <div class="text-caption text-grey-7">Region</div>
                  <div class="text-body2">{{ item.region || '-' }}</div>
                </div>
              </div>
            </div>

            <!-- Performance Metrics -->
            <div class="q-mb-md">
              <div class="text-subtitle2 text-grey-8 q-mb-sm">Waktu Penanganan</div>
              <q-separator class="q-mb-sm" />
              <div class="row q-col-gutter-sm">
                <div class="col-4">
                  <div class="text-caption text-grey-7">SLA</div>
                  <div class="text-body2 text-weight-medium">{{ item.sla_hours || 0 }} jam</div>
                </div>
                <div class="col-4">
                  <div class="text-caption text-grey-7">Response Time</div>
                  <div class="text-body2 text-weight-medium">{{ item.response_time_hours || 0 }} jam</div>
                </div>
                <div class="col-4">
                  <div class="text-caption text-grey-7">Resolution Time</div>
                  <div class="text-body2 text-weight-medium">{{ item.resolution_time_hours || 0 }} jam</div>
                </div>
              </div>
            </div>

            <!-- AI Result -->
            <div class="q-mb-md" v-if="item.ai_result">
              <div class="text-subtitle2 text-grey-8 q-mb-sm">AI Result</div>
              <q-separator class="q-mb-sm" />
              <q-card flat bordered class="bg-blue-1">
                <q-card-section>
                  <div class="text-body2" style="white-space: pre-line">{{ item.ai_result }}</div>
                </q-card-section>
              </q-card>
            </div>

            <!-- Description -->
            <div class="q-mb-md" v-if="item.description">
              <div class="text-subtitle2 text-grey-8 q-mb-sm">Deskripsi</div>
              <q-separator class="q-mb-sm" />
              <div class="text-body2" style="white-space: pre-line">{{ item.description }}</div>
            </div>
          </div>

          <!-- Right Column - Media & Map -->
          <div class="col-12 col-md-5">
            <!-- Map -->
            <q-card flat bordered class="q-mb-md" v-if="mapUrl">
              <q-card-section>
                <div class="text-subtitle2 q-mb-sm">Lokasi Peta</div>
                <div class="text-caption text-grey-7 q-mb-sm">
                  <div>Lat: {{ item.latitude }}</div>
                  <div>Lng: {{ item.longitude }}</div>
                </div>
                <q-btn 
                  outline 
                  color="primary" 
                  icon="map" 
                  label="Buka di Google Maps" 
                  :href="mapUrl" 
                  target="_blank"
                  class="full-width" 
                />
              </q-card-section>
            </q-card>

            <!-- Photos -->
            <q-card flat bordered>
              <q-card-section>
                <div class="text-subtitle2 q-mb-md">Foto Keluhan</div>
                <div v-if="!item.images || item.images.length === 0" class="text-grey-6 text-center q-pa-md">
                  Tidak ada foto
                </div>
                <div v-else class="row q-col-gutter-sm">
                  <div 
                    class="col-6 col-sm-4" 
                    v-for="img in item.images || []" 
                    :key="img.id"
                  >
                    <q-img 
                      :src="'/' + img.image_path" 
                      ratio="1" 
                      style="border-radius: 8px; cursor: pointer"
                      class="shadow-2"
                    >
                      <template v-slot:error>
                        <div class="absolute-full flex flex-center bg-grey-3 text-grey-6">
                          <q-icon name="broken_image" size="32px" />
                        </div>
                      </template>
                    </q-img>
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </div>
        </q-card-section>
      </q-card>

      <!-- Timeline Log -->
      <q-card flat bordered class="q-mt-md">
        <q-card-section>
          <div class="text-h6 q-mb-md">Timeline Log</div>
          <q-separator class="q-mb-md" />
          
          <div v-if="!item.logs || item.logs.length === 0" class="text-grey-6 text-center q-pa-md">
            Tidak ada log aktivitas
          </div>

          <q-timeline v-else color="primary" layout="comfortable">
            <q-timeline-entry
              v-for="log in item.logs || []"
              :key="log.id"
              :title="log.action"
              :subtitle="formatDate(log.created_datetime)"
            >
              <div class="q-mt-xs">
                <div class="row q-col-gutter-sm">
                  <div class="col-12 col-sm-6">
                    <div class="text-caption text-grey-7">User</div>
                    <div class="text-body2">{{ log.user?.name || '-' }}</div>
                  </div>
                  <div class="col-12 col-sm-6" v-if="log.old_status || log.new_status">
                    <div class="text-caption text-grey-7">Perubahan Status</div>
                    <div class="text-body2">
                      <q-badge v-if="log.old_status" color="grey">{{ log.old_status }}</q-badge>
                      <q-icon v-if="log.old_status && log.new_status" name="arrow_forward" size="xs" class="q-mx-xs" />
                      <q-badge v-if="log.new_status" color="primary">{{ log.new_status }}</q-badge>
                    </div>
                  </div>
                  <div class="col-12" v-if="log.notes">
                    <div class="text-caption text-grey-7">Catatan</div>
                    <div class="text-body2">{{ log.notes }}</div>
                  </div>
                </div>
              </div>
            </q-timeline-entry>
          </q-timeline>
        </q-card-section>
      </q-card>
    </div>
  </authenticated-layout>
</template>
