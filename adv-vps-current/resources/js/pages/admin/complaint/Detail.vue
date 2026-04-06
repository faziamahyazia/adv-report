<script setup>
import { computed, ref } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import { formatDate } from "@/helpers/datetime";

const page = usePage();
const item = computed(() => page.props.data || {});
const title = computed(() => `Detail Keluhan #${item.value.id || '-'}`);
const selectedImage = ref(null);
const showImageDialog = ref(false);

const mapUrl = computed(() => {
  const lat = item.value.latitude;
  const lng = item.value.longitude;
  if (lat === null || lat === undefined || lng === null || lng === undefined) return "";
  return `https://www.google.com/maps?q=${lat},${lng}`;
});

const severityColor = computed(() => {
  if (item.value.severity === 'high') return 'red';
  if (item.value.severity === 'medium') return 'orange';
  return 'green';
});

const severityIcon = computed(() => {
  if (item.value.severity === 'high') return 'error';
  if (item.value.severity === 'medium') return 'warning';
  return 'check_circle';
});

const statusColor = computed(() => {
  if (item.value.status === 'resolved') return 'positive';
  if (item.value.status === 'open') return 'info';
  if (item.value.status === 'in_progress') return 'warning';
  return 'grey';
});

const statusIcon = computed(() => {
  if (item.value.status === 'resolved') return 'check_circle';
  if (item.value.status === 'open') return 'circle';
  if (item.value.status === 'in_progress') return 'pending';
  return 'help';
});

const viewImage = (img) => {
  selectedImage.value = img;
  showImageDialog.value = true;
};
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>
    <template #left-button>
      <q-btn icon="arrow_back" dense flat color="grey-7" @click="router.get(route('admin.complaint.index'))" />
    </template>
    <template #right-button>
      <q-btn icon="edit" label="Edit" dense color="primary" v-if="$can('admin.complaint.edit')" @click="router.get(route('admin.complaint.edit', item.id))" />
    </template>

    <div class="q-pa-md complaint-detail-page">
      <!-- Header Card dengan Info Utama -->
      <q-card class="header-card gradient-card q-mb-md" flat>
        <q-card-section>
          <div class="row items-center q-col-gutter-md">
            <div class="col-12 col-md-8">
              <div class="row items-center q-gutter-sm q-mb-sm">
                <q-icon :name="severityIcon" :color="severityColor" size="32px" />
                <div>
                  <div class="text-overline text-white-7">Keluhan #{{ item.id }}</div>
                  <div class="text-h5 text-white text-weight-bold">{{ item.title }}</div>
                </div>
              </div>
              <div class="row q-gutter-sm items-center">
                <q-icon name="schedule" size="16px" class="text-white-7" />
                <span class="text-body2 text-white-8">{{ formatDate(item.created_datetime) }}</span>
              </div>
            </div>
            <div class="col-12 col-md-4">
              <div class="row q-col-gutter-sm">
                <div class="col-6">
                  <q-card flat class="status-badge-card bg-white">
                    <q-card-section class="q-pa-sm text-center">
                      <q-icon :name="severityIcon" :color="severityColor" size="24px" />
                      <div class="text-caption text-grey-7 q-mt-xs">Severity</div>
                      <div class="text-subtitle2 text-weight-bold" :class="`text-${severityColor}`">
                        {{ item.severity || '-' }}
                      </div>
                    </q-card-section>
                  </q-card>
                </div>
                <div class="col-6">
                  <q-card flat class="status-badge-card bg-white">
                    <q-card-section class="q-pa-sm text-center">
                      <q-icon :name="statusIcon" :color="statusColor" size="24px" />
                      <div class="text-caption text-grey-7 q-mt-xs">Status</div>
                      <div class="text-subtitle2 text-weight-bold" :class="`text-${statusColor}`">
                        {{ item.status || '-' }}
                      </div>
                    </q-card-section>
                  </q-card>
                </div>
              </div>
            </div>
          </div>
        </q-card-section>
      </q-card>

      <div class="row q-col-gutter-md">
        <!-- Left Column -->
        <div class="col-12 col-lg-8">
          <!-- Informasi Produk -->
          <q-card flat bordered class="info-card q-mb-md">
            <q-card-section>
              <div class="section-title">
                <q-icon name="inventory_2" color="primary" size="20px" class="q-mr-sm" />
                <span class="text-subtitle1 text-weight-medium">Informasi Produk</span>
              </div>
              <q-separator class="q-my-md" />
              <div class="row q-col-gutter-md">
                <div class="col-12 col-sm-6">
                  <div class="info-item">
                    <div class="info-label">
                      <q-icon name="category" size="16px" class="q-mr-xs" />
                      Kategori
                    </div>
                    <div class="info-value">{{ item.category || '-' }}</div>
                  </div>
                </div>
                <div class="col-12 col-sm-6">
                  <div class="info-item">
                    <div class="info-label">
                      <q-icon name="shopping_bag" size="16px" class="q-mr-xs" />
                      Produk
                    </div>
                    <div class="info-value">{{ item.product?.name || item.product_name || '-' }}</div>
                  </div>
                </div>
                <div class="col-12 col-sm-6">
                  <div class="info-item">
                    <div class="info-label">
                      <q-icon name="qr_code" size="16px" class="q-mr-xs" />
                      Batch Number
                    </div>
                    <div class="info-value">{{ item.batch?.batch_number || '-' }}</div>
                  </div>
                </div>
              </div>
            </q-card-section>
          </q-card>

          <!-- Tim & Penanggung Jawab -->
          <q-card flat bordered class="info-card q-mb-md">
            <q-card-section>
              <div class="section-title">
                <q-icon name="people" color="primary" size="20px" class="q-mr-sm" />
                <span class="text-subtitle1 text-weight-medium">Tim & Penanggung Jawab</span>
              </div>
              <q-separator class="q-my-md" />
              <div class="row q-col-gutter-md">
                <div class="col-12 col-sm-6">
                  <div class="info-item">
                    <div class="info-label">
                      <q-icon name="person" size="16px" class="q-mr-xs" />
                      Brand Supporter
                    </div>
                    <div class="info-value">{{ item.bs?.name || '-' }}</div>
                  </div>
                </div>
                <div class="col-12 col-sm-6">
                  <div class="info-item">
                    <div class="info-label">
                      <q-icon name="agriculture" size="16px" class="q-mr-xs" />
                      Agronomis
                    </div>
                    <div class="info-value">{{ item.agronomist?.name || '-' }}</div>
                  </div>
                </div>
              </div>
            </q-card-section>
          </q-card>

          <!-- Lokasi -->
          <q-card flat bordered class="info-card q-mb-md">
            <q-card-section>
              <div class="section-title">
                <q-icon name="place" color="primary" size="20px" class="q-mr-sm" />
                <span class="text-subtitle1 text-weight-medium">Lokasi</span>
              </div>
              <q-separator class="q-my-md" />
              <div class="row q-col-gutter-md">
                <div class="col-12 col-sm-8">
                  <div class="info-item">
                    <div class="info-label">
                      <q-icon name="location_on" size="16px" class="q-mr-xs" />
                      Alamat
                    </div>
                    <div class="info-value">{{ item.location || '-' }}</div>
                  </div>
                </div>
                <div class="col-12 col-sm-4">
                  <div class="info-item">
                    <div class="info-label">
                      <q-icon name="public" size="16px" class="q-mr-xs" />
                      Region
                    </div>
                    <div class="info-value">{{ item.region || '-' }}</div>
                  </div>
                </div>
                <div class="col-12" v-if="mapUrl">
                  <q-btn 
                    outline 
                    color="primary" 
                    icon="map" 
                    label="Lihat di Google Maps" 
                    :href="mapUrl" 
                    target="_blank"
                    class="full-width"
                    size="md"
                  />
                </div>
              </div>
            </q-card-section>
          </q-card>

          <!-- Performance Metrics -->
          <q-card flat bordered class="info-card q-mb-md">
            <q-card-section>
              <div class="section-title">
                <q-icon name="schedule" color="primary" size="20px" class="q-mr-sm" />
                <span class="text-subtitle1 text-weight-medium">Waktu Penanganan</span>
              </div>
              <q-separator class="q-my-md" />
              <div class="row q-col-gutter-md">
                <div class="col-12 col-sm-4">
                  <q-card flat class="metric-card bg-blue-1">
                    <q-card-section class="text-center">
                      <q-icon name="alarm" color="blue" size="32px" />
                      <div class="text-caption text-grey-7 q-mt-sm">SLA</div>
                      <div class="text-h6 text-weight-bold text-blue">{{ item.sla_hours || 0 }}</div>
                      <div class="text-caption text-grey-6">jam</div>
                    </q-card-section>
                  </q-card>
                </div>
                <div class="col-12 col-sm-4">
                  <q-card flat class="metric-card bg-orange-1">
                    <q-card-section class="text-center">
                      <q-icon name="hourglass_top" color="orange" size="32px" />
                      <div class="text-caption text-grey-7 q-mt-sm">Response Time</div>
                      <div class="text-h6 text-weight-bold text-orange">{{ item.response_time_hours || 0 }}</div>
                      <div class="text-caption text-grey-6">jam</div>
                    </q-card-section>
                  </q-card>
                </div>
                <div class="col-12 col-sm-4">
                  <q-card flat class="metric-card bg-green-1">
                    <q-card-section class="text-center">
                      <q-icon name="done_all" color="green" size="32px" />
                      <div class="text-caption text-grey-7 q-mt-sm">Resolution Time</div>
                      <div class="text-h6 text-weight-bold text-green">{{ item.resolution_time_hours || 0 }}</div>
                      <div class="text-caption text-grey-6">jam</div>
                    </q-card-section>
                  </q-card>
                </div>
              </div>
            </q-card-section>
          </q-card>

          <!-- AI Result -->
          <q-card flat bordered class="info-card q-mb-md" v-if="item.ai_result">
            <q-card-section>
              <div class="section-title">
                <q-icon name="psychology" color="purple" size="20px" class="q-mr-sm" />
                <span class="text-subtitle1 text-weight-medium">AI Analysis Result</span>
              </div>
              <q-separator class="q-my-md" />
              <q-card flat class="bg-purple-1">
                <q-card-section>
                  <div class="text-body2" style="white-space: pre-line; line-height: 1.6;">
                    {{ item.ai_result }}
                  </div>
                </q-card-section>
              </q-card>
            </q-card-section>
          </q-card>

          <!-- Description -->
          <q-card flat bordered class="info-card q-mb-md" v-if="item.description">
            <q-card-section>
              <div class="section-title">
                <q-icon name="description" color="primary" size="20px" class="q-mr-sm" />
                <span class="text-subtitle1 text-weight-medium">Deskripsi Keluhan</span>
              </div>
              <q-separator class="q-my-md" />
              <div class="text-body1" style="white-space: pre-line; line-height: 1.7;">
                {{ item.description }}
              </div>
            </q-card-section>
          </q-card>
        </div>

        <!-- Right Column -->
        <div class="col-12 col-lg-4">
          <!-- Photos -->
          <q-card flat bordered class="info-card q-mb-md">
            <q-card-section>
              <div class="section-title">
                <q-icon name="photo_library" color="primary" size="20px" class="q-mr-sm" />
                <span class="text-subtitle1 text-weight-medium">Foto Keluhan</span>
              </div>
              <q-separator class="q-my-md" />
              
              <div v-if="!item.images || item.images.length === 0" class="text-center q-pa-lg">
                <q-icon name="image_not_supported" size="48px" color="grey-5" />
                <div class="text-body2 text-grey-6 q-mt-sm">Tidak ada foto</div>
              </div>

              <div v-else class="row q-col-gutter-sm">
                <div 
                  class="col-6" 
                  v-for="img in item.images || []" 
                  :key="img.id"
                >
                  <q-card flat class="photo-card cursor-pointer" @click="viewImage(img)">
                    <q-img 
                      :src="'/' + img.image_path" 
                      ratio="1" 
                      class="rounded-borders"
                    >
                      <template v-slot:error>
                        <div class="absolute-full flex flex-center bg-grey-3 text-grey-6">
                          <q-icon name="broken_image" size="32px" />
                        </div>
                      </template>
                      <div class="absolute-bottom-right q-pa-xs">
                        <q-icon name="zoom_in" color="white" size="20px" class="photo-zoom-icon" />
                      </div>
                    </q-img>
                  </q-card>
                </div>
              </div>
            </q-card-section>
          </q-card>

          <!-- Timeline Log -->
          <q-card flat bordered class="info-card">
            <q-card-section>
              <div class="section-title">
                <q-icon name="history" color="primary" size="20px" class="q-mr-sm" />
                <span class="text-subtitle1 text-weight-medium">Timeline Aktivitas</span>
              </div>
              <q-separator class="q-my-md" />
              
              <div v-if="!item.logs || item.logs.length === 0" class="text-center q-pa-lg">
                <q-icon name="event_busy" size="48px" color="grey-5" />
                <div class="text-body2 text-grey-6 q-mt-sm">Tidak ada log aktivitas</div>
              </div>

              <q-timeline v-else color="primary" layout="comfortable" class="timeline-custom">
                <q-timeline-entry
                  v-for="log in item.logs || []"
                  :key="log.id"
                  :icon="log.action === 'created' ? 'add_circle' : log.action === 'updated' ? 'edit' : 'check_circle'"
                  :color="log.action === 'created' ? 'blue' : log.action === 'updated' ? 'orange' : 'green'"
                >
                  <template v-slot:title>
                    <div class="text-weight-medium">{{ log.action }}</div>
                  </template>
                  <template v-slot:subtitle>
                    <div class="text-caption">{{ formatDate(log.created_datetime) }}</div>
                  </template>
                  <div class="q-mt-sm">
                    <div class="text-body2 q-mb-xs">
                      <q-icon name="person" size="14px" class="q-mr-xs" />
                      <strong>{{ log.user?.name || '-' }}</strong>
                    </div>
                    <div v-if="log.old_status || log.new_status" class="q-mb-xs">
                      <q-badge v-if="log.old_status" color="grey-6" class="q-mr-xs">{{ log.old_status }}</q-badge>
                      <q-icon v-if="log.old_status && log.new_status" name="arrow_forward" size="xs" class="q-mx-xs" />
                      <q-badge v-if="log.new_status" :color="statusColor">{{ log.new_status }}</q-badge>
                    </div>
                    <div v-if="log.notes" class="text-body2 text-grey-7 q-mt-sm">
                      <q-icon name="note" size="14px" class="q-mr-xs" />
                      {{ log.notes }}
                    </div>
                  </div>
                </q-timeline-entry>
              </q-timeline>
            </q-card-section>
          </q-card>
        </div>
      </div>
    </div>

    <!-- Image Viewer Dialog -->
    <q-dialog v-model="showImageDialog">
      <q-card style="max-width: 90vw; max-height: 90vh">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Foto Keluhan</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>
        <q-card-section class="q-pt-sm">
          <q-img 
            v-if="selectedImage"
            :src="'/' + selectedImage.image_path" 
            fit="contain"
            style="max-height: 70vh"
          >
            <template v-slot:error>
              <div class="absolute-full flex flex-center bg-grey-3 text-grey-6">
                <div class="text-center">
                  <q-icon name="broken_image" size="64px" />
                  <div class="q-mt-md">Gagal memuat gambar</div>
                </div>
              </div>
            </template>
          </q-img>
        </q-card-section>
      </q-card>
    </q-dialog>
  </authenticated-layout>
</template>

<style scoped>
.complaint-detail-page {
  /* Removed max-width for full width */
}

.gradient-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.header-card {
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.1);
}

.status-badge-card {
  border-radius: 8px;
  transition: transform 0.2s;
}

.status-badge-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.info-card {
  border-radius: 8px;
  transition: box-shadow 0.3s;
}

.info-card:hover {
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
}

.section-title {
  display: flex;
  align-items: center;
}

.info-item {
  margin-bottom: 12px;
}

.info-label {
  font-size: 12px;
  color: #757575;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
  font-weight: 500;
}

.info-value {
  font-size: 14px;
  color: #212121;
  font-weight: 500;
}

.metric-card {
  border-radius: 8px;
  transition: transform 0.2s;
}

.metric-card:hover {
  transform: translateY(-4px);
}

.photo-card {
  overflow: hidden;
  border-radius: 8px;
  transition: transform 0.2s, box-shadow 0.2s;
}

.photo-card:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}

.photo-zoom-icon {
  background: rgba(0,0,0,0.5);
  border-radius: 4px;
  padding: 4px;
}

.timeline-custom {
  max-height: 600px;
  overflow-y: auto;
}

.timeline-custom::-webkit-scrollbar {
  width: 6px;
}

.timeline-custom::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

.timeline-custom::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 10px;
}

.timeline-custom::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>
