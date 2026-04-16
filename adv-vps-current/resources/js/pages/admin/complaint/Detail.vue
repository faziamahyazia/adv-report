<script setup>
import { computed, ref, onMounted, onUnmounted } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import { formatDate } from "@/helpers/datetime";

const page = usePage();
const item = computed(() => page.props.data || {});
const title = computed(() => `Detail Keluhan #${item.value.id || '-'}`);
const selectedImage = ref(null);
const selectedImageIndex = ref(0);
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

const viewImage = (img, index) => {
  selectedImage.value = img;
  selectedImageIndex.value = index;
  showImageDialog.value = true;
};

const nextImage = () => {
  if (item.value.images && item.value.images.length > 0) {
    selectedImageIndex.value = (selectedImageIndex.value + 1) % item.value.images.length;
    selectedImage.value = item.value.images[selectedImageIndex.value];
  }
};

const prevImage = () => {
  if (item.value.images && item.value.images.length > 0) {
    selectedImageIndex.value = (selectedImageIndex.value - 1 + item.value.images.length) % item.value.images.length;
    selectedImage.value = item.value.images[selectedImageIndex.value];
  }
};

const handleKeydown = (e) => {
  if (!showImageDialog.value) return;
  if (e.key === 'Escape') {
    showImageDialog.value = false;
  } else if (e.key === 'ArrowRight') {
    nextImage();
  } else if (e.key === 'ArrowLeft') {
    prevImage();
  }
};

onMounted(() => {
  window.addEventListener('keydown', handleKeydown);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
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
      <q-btn icon="edit" label="Edit" unelevated color="primary" v-if="$can('admin.complaint.edit')" @click="router.get(route('admin.complaint.edit', item.id))" />
    </template>

    <!-- Main Content with Full Width Container -->
    <div class="complaint-detail-container">
      <!-- Header Section - Compact Horizontal Layout -->
      <div class="header-section">
        <div class="header-left">
          <q-icon :name="severityIcon" :color="severityColor" size="40px" class="header-icon" />
          <div class="header-info">
            <div class="complaint-id">Keluhan #{{ item.id }}</div>
            <h1 class="complaint-title">{{ item.title }}</h1>
            <div class="complaint-meta">
              <q-icon name="schedule" size="16px" />
              <span>{{ formatDate(item.created_datetime) }}</span>
            </div>
          </div>
        </div>
        <div class="header-right">
          <div class="status-badge">
            <q-icon :name="severityIcon" :color="severityColor" size="20px" />
            <div class="badge-content">
              <div class="badge-label">Severity</div>
              <div class="badge-value" :class="`text-${severityColor}`">{{ item.severity || '-' }}</div>
            </div>
          </div>
          <div class="status-badge">
            <q-icon :name="statusIcon" :color="statusColor" size="20px" />
            <div class="badge-content">
              <div class="badge-label">Status</div>
              <div class="badge-value" :class="`text-${statusColor}`">{{ item.status || '-' }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Grid 3 Kolom: Info Cards + Timeline -->
      <div class="three-col-grid">
        <!-- Row 1: 3 Columns -->
        <div class="grid-row">
          <!-- Informasi Produk -->
          <q-card flat bordered class="grid-card">
            <q-card-section class="card-section">
              <div class="section-header">
                <q-icon name="inventory_2" color="primary" size="20px" />
                <span class="section-title">Informasi Produk</span>
              </div>
              <div class="info-items">
                <div class="info-item">
                  <span class="item-label">Kategori</span>
                  <span class="item-value">{{ item.category || '-' }}</span>
                </div>
                <div class="info-item">
                  <span class="item-label">Produk</span>
                  <span class="item-value">{{ item.product?.name || item.product_name || '-' }}</span>
                </div>
                <div class="info-item">
                  <span class="item-label">Batch Number</span>
                  <span class="item-value">{{ item.batch?.batch_number || '-' }}</span>
                </div>
              </div>
            </q-card-section>
          </q-card>

          <!-- Tim & Penanggung Jawab -->
          <q-card flat bordered class="grid-card">
            <q-card-section class="card-section">
              <div class="section-header">
                <q-icon name="people" color="primary" size="20px" />
                <span class="section-title">Tim & Penanggung Jawab</span>
              </div>
              <div class="info-items">
                <div class="info-item">
                  <span class="item-label">Brand Supporter</span>
                  <span class="item-value">{{ item.bs?.name || '-' }}</span>
                </div>
                <div class="info-item">
                  <span class="item-label">Agronomis</span>
                  <span class="item-value">{{ item.agronomist?.name || '-' }}</span>
                </div>
              </div>
            </q-card-section>
          </q-card>

          <!-- Timeline (Sidebar in Desktop, Row in Mobile) -->
          <q-card flat bordered class="grid-card timeline-card">
            <q-card-section class="card-section">
              <div class="section-header">
                <q-icon name="history" color="primary" size="20px" />
                <span class="section-title">Timeline Aktivitas</span>
              </div>
              
              <div v-if="!item.logs || item.logs.length === 0" class="empty-state-small">
                <q-icon name="event_busy" size="32px" color="grey-5" />
                <div class="empty-text">Tidak ada log</div>
              </div>

              <div v-else class="timeline-container">
                <div 
                  v-for="(log, index) in item.logs || []"
                  :key="log.id"
                  class="timeline-item"
                >
                  <div class="timeline-marker" :class="`marker-${log.action === 'created' ? 'blue' : log.action === 'updated' ? 'orange' : 'green'}`">
                    <q-icon 
                      :name="log.action === 'created' ? 'add_circle' : log.action === 'updated' ? 'edit' : 'check_circle'" 
                      size="16px" 
                      color="white"
                    />
                  </div>
                  <div class="timeline-content">
                    <div class="timeline-title">{{ log.action }}</div>
                    <div class="timeline-date">{{ formatDate(log.created_datetime) }}</div>
                    <div class="timeline-user">
                      <q-icon name="person" size="12px" />
                      {{ log.user?.name || '-' }}
                    </div>
                    <div v-if="log.old_status || log.new_status" class="timeline-status">
                      <q-badge v-if="log.old_status" color="grey-6" class="status-badge-small">{{ log.old_status }}</q-badge>
                      <q-icon v-if="log.old_status && log.new_status" name="arrow_forward" size="10px" class="q-mx-xs" />
                      <q-badge v-if="log.new_status" :color="statusColor" class="status-badge-small">{{ log.new_status }}</q-badge>
                    </div>
                    <div v-if="log.notes" class="timeline-notes">{{ log.notes }}</div>
                  </div>
                  <div v-if="index < item.logs.length - 1" class="timeline-line"></div>
                </div>
              </div>
            </q-card-section>
          </q-card>
        </div>

        <!-- Row 2: Lokasi + Waktu Penanganan (2 cols, span remaining) -->
        <div class="grid-row-2col">
          <!-- Lokasi -->
          <q-card flat bordered class="grid-card">
            <q-card-section class="card-section">
              <div class="section-header">
                <q-icon name="place" color="primary" size="20px" />
                <span class="section-title">Lokasi</span>
              </div>
              <div class="info-items">
                <div class="info-item">
                  <span class="item-label">Alamat</span>
                  <span class="item-value">{{ item.location || '-' }}</span>
                </div>
                <div class="info-item">
                  <span class="item-label">Region</span>
                  <span class="item-value">{{ item.region || '-' }}</span>
                </div>
                <div v-if="mapUrl" class="q-mt-sm">
                  <q-btn 
                    outline 
                    color="primary" 
                    icon="map" 
                    label="Lihat di Maps" 
                    :href="mapUrl" 
                    target="_blank"
                    size="sm"
                    dense
                    class="full-width"
                  />
                </div>
              </div>
            </q-card-section>
          </q-card>

          <!-- Waktu Penanganan -->
          <q-card flat bordered class="grid-card">
            <q-card-section class="card-section">
              <div class="section-header">
                <q-icon name="schedule" color="primary" size="20px" />
                <span class="section-title">Waktu Penanganan</span>
              </div>
              <div class="metrics-compact">
                <div class="metric-compact bg-blue-1">
                  <q-icon name="alarm" color="blue" size="20px" />
                  <div class="metric-text">
                    <div class="metric-label">SLA</div>
                    <div class="metric-value text-blue">{{ item.sla_hours || 0 }}h</div>
                  </div>
                </div>
                <div class="metric-compact bg-orange-1">
                  <q-icon name="hourglass_top" color="orange" size="20px" />
                  <div class="metric-text">
                    <div class="metric-label">Response</div>
                    <div class="metric-value text-orange">{{ item.response_time_hours || 0 }}h</div>
                  </div>
                </div>
                <div class="metric-compact bg-green-1">
                  <q-icon name="done_all" color="green" size="20px" />
                  <div class="metric-text">
                    <div class="metric-label">Resolution</div>
                    <div class="metric-value text-green">{{ item.resolution_time_hours || 0 }}h</div>
                  </div>
                </div>
              </div>
            </q-card-section>
          </q-card>
        </div>
      </div>

      <!-- 3-Column Grid for Additional Sections -->
      <div class="grid-row">
        <!-- AI Result -->
        <q-card v-if="item.ai_result" flat bordered class="grid-card">
          <q-card-section class="card-section">
            <div class="section-header">
              <q-icon name="psychology" color="purple" size="20px" />
              <span class="section-title">AI Analysis Result</span>
            </div>
            <div class="ai-content-compact">{{ item.ai_result }}</div>
          </q-card-section>
        </q-card>

        <!-- Description -->
        <q-card v-if="item.description" flat bordered class="grid-card">
          <q-card-section class="card-section">
            <div class="section-header">
              <q-icon name="description" color="primary" size="20px" />
              <span class="section-title">Deskripsi Keluhan</span>
            </div>
            <div class="description-content-readable">{{ item.description }}</div>
          </q-card-section>
        </q-card>

        <!-- Foto Keluhan -->
        <q-card flat bordered class="grid-card">
          <q-card-section class="card-section">
            <div class="section-header">
              <q-icon name="photo_library" color="primary" size="20px" />
              <span class="section-title">Foto Keluhan</span>
              <span v-if="item.images && item.images.length > 0" class="photo-count">({{ item.images.length }} foto)</span>
            </div>
            
            <div v-if="!item.images || item.images.length === 0" class="empty-state-small">
              <q-icon name="image_not_supported" size="48px" color="grey-5" />
              <div class="empty-text">Tidak ada foto</div>
            </div>

            <div v-else class="gallery-grid-compact">
              <div 
                v-for="(img, index) in item.images || []" 
                :key="img.id"
                class="gallery-item-enhanced"
                @click="viewImage(img, index)"
              >
                <q-img 
                  :src="'/' + img.image_path" 
                  ratio="1"
                  class="gallery-image-enhanced"
                >
                  <template v-slot:error>
                    <div class="absolute-full flex flex-center bg-grey-3">
                      <q-icon name="broken_image" size="32px" color="grey-6" />
                    </div>
                  </template>
                  <div class="image-overlay-enhanced">
                    <q-icon name="zoom_in" size="40px" color="white" />
                  </div>
                </q-img>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Enhanced Lightbox Dialog -->
    <q-dialog 
      v-model="showImageDialog" 
      maximized 
      transition-show="fade" 
      transition-hide="fade"
      class="lightbox-dialog"
    >
      <q-card class="lightbox-card bg-black">
        <q-card-section class="lightbox-header">
          <div class="lightbox-title text-white">
            Foto Keluhan {{ selectedImageIndex + 1 }} / {{ item.images?.length || 0 }}
          </div>
          <q-btn 
            icon="close" 
            flat 
            round 
            dense 
            color="white" 
            v-close-popup 
            class="lightbox-close"
          />
        </q-card-section>
        
        <q-card-section class="lightbox-content">
          <q-img 
            v-if="selectedImage"
            :src="'/' + selectedImage.image_path" 
            fit="contain"
            class="lightbox-image"
          >
            <template v-slot:error>
              <div class="absolute-full flex flex-center bg-grey-9">
                <div class="text-center text-white">
                  <q-icon name="broken_image" size="64px" />
                  <div class="q-mt-md">Gagal memuat gambar</div>
                </div>
              </div>
            </template>
          </q-img>
          
          <!-- Navigation Buttons -->
          <div v-if="item.images && item.images.length > 1" class="lightbox-nav">
            <q-btn 
              round 
              icon="chevron_left" 
              color="white" 
              text-color="black"
              size="lg"
              class="nav-btn nav-btn-left"
              @click="prevImage"
            />
            <q-btn 
              round 
              icon="chevron_right" 
              color="white" 
              text-color="black"
              size="lg"
              class="nav-btn nav-btn-right"
              @click="nextImage"
            />
          </div>
        </q-card-section>
        
        <div class="lightbox-hint text-white text-center q-pb-md">
          <div class="text-caption">Gunakan ← → untuk navigasi, ESC untuk tutup</div>
        </div>
      </q-card>
    </q-dialog>
  </authenticated-layout>
</template>

<style scoped>
/* Container */
.complaint-detail-container {
  max-width: 1600px;
  margin: 0 auto;
  padding: 16px;
}

/* Header Section - Compact Horizontal Layout */
.header-section {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 10px;
  padding: 20px 24px;
  margin-bottom: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.2);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
  flex: 1;
}

.header-icon {
  flex-shrink: 0;
}

.header-info {
  flex: 1;
}

.complaint-id {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.8);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.complaint-title {
  font-size: 24px;
  color: white;
  font-weight: 700;
  margin: 2px 0 6px 0;
  line-height: 1.2;
}

.complaint-meta {
  display: flex;
  align-items: center;
  gap: 6px;
  color: rgba(255, 255, 255, 0.9);
  font-size: 13px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.status-badge {
  background: white;
  border-radius: 8px;
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 130px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
}

.status-badge:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
}

.badge-content {
  flex: 1;
}

.badge-label {
  font-size: 10px;
  color: #757575;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.badge-value {
  font-size: 15px;
  font-weight: 700;
  margin-top: 2px;
  text-transform: capitalize;
}

/* 3 Column Grid Layout */
.three-col-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 16px;
}

.grid-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.grid-row-2col {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

/* Card Styles */
.grid-card,
.section-card {
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
  transition: all 0.2s ease;
  height: 100%;
}

.grid-card:hover,
.section-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  border-color: #1976d2;
}

.card-section {
  padding: 16px;
}

.card-section-compact {
  padding: 16px;
}

/* Section Header */
.section-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding-bottom: 10px;
  border-bottom: 2px solid #f0f0f0;
  margin-bottom: 14px;
}

.section-title {
  font-size: 14px;
  font-weight: 600;
  color: #212121;
}

.photo-count {
  font-size: 12px;
  color: #757575;
  font-weight: 500;
  margin-left: auto;
}

/* Info Items */
.info-items {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.item-label {
  font-size: 11px;
  color: #757575;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.item-value {
  font-size: 14px;
  color: #212121;
  font-weight: 600;
  line-height: 1.4;
}

/* Metrics Compact */
.metrics-compact {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.metric-compact {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 6px;
  transition: transform 0.2s;
}

.metric-compact:hover {
  transform: translateX(4px);
}

.metric-text {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.metric-label {
  font-size: 12px;
  color: #757575;
  font-weight: 600;
}

.metric-value {
  font-size: 16px;
  font-weight: 700;
}

/* AI & Description Content */
.ai-content-compact {
  background: #f3e5f5;
  padding: 12px 14px;
  border-radius: 6px;
  white-space: pre-line;
  line-height: 1.6;
  font-size: 13px;
  color: #4a148c;
}

.description-content-readable {
  background: #f5f5f5;
  padding: 14px 16px;
  border-radius: 6px;
  white-space: pre-line;
  line-height: 1.8;
  font-size: 14px;
  color: #424242;
  max-width: 900px;
}

/* Full Width Sections */
.full-width-sections {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* Gallery Grid - 3 Columns (Desktop) */
.gallery-grid-enhanced {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 14px;
}

/* Gallery Grid Compact (inside 3-col card) */
.gallery-grid-compact {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}

.gallery-item-enhanced {
  position: relative;
  cursor: pointer;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s ease;
  aspect-ratio: 1;
  border: 2px solid transparent;
}

.gallery-item-enhanced:hover {
  transform: scale(1.03);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
  border-color: #1976d2;
}

.gallery-image-enhanced {
  border-radius: 8px;
}

.image-overlay-enhanced {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.gallery-item-enhanced:hover .image-overlay-enhanced {
  opacity: 1;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 40px 20px;
}

.empty-state-small {
  text-align: center;
  padding: 20px;
}

.empty-text {
  font-size: 13px;
  color: #9e9e9e;
  margin-top: 8px;
}

/* Timeline (in Grid Card) */
.timeline-card .timeline-container {
  max-height: 400px;
  overflow-y: auto;
  padding-right: 6px;
}

.timeline-container::-webkit-scrollbar {
  width: 4px;
}

.timeline-container::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

.timeline-container::-webkit-scrollbar-thumb {
  background: #bdbdbd;
  border-radius: 10px;
}

.timeline-item {
  position: relative;
  display: flex;
  gap: 10px;
  padding-bottom: 16px;
}

.timeline-marker {
  flex-shrink: 0;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
}

.marker-blue {
  background: #2196f3;
}

.marker-orange {
  background: #ff9800;
}

.marker-green {
  background: #4caf50;
}

.timeline-content {
  flex: 1;
  padding-top: 1px;
}

.timeline-title {
  font-size: 13px;
  font-weight: 700;
  color: #212121;
  text-transform: capitalize;
  margin-bottom: 3px;
}

.timeline-date {
  font-size: 11px;
  color: #757575;
  margin-bottom: 5px;
}

.timeline-user {
  font-size: 12px;
  color: #424242;
  display: flex;
  align-items: center;
  gap: 4px;
  margin-bottom: 5px;
}

.timeline-status {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-bottom: 5px;
}

.status-badge-small {
  font-size: 9px;
  padding: 2px 6px;
}

.timeline-notes {
  font-size: 12px;
  color: #616161;
  line-height: 1.4;
  margin-top: 5px;
  background: #f5f5f5;
  padding: 6px 8px;
  border-radius: 4px;
}

.timeline-line {
  position: absolute;
  left: 14px;
  top: 30px;
  bottom: 0;
  width: 2px;
  background: #e0e0e0;
}

/* Enhanced Lightbox Styles */
.lightbox-dialog .q-dialog__backdrop {
  background: rgba(0, 0, 0, 0.95);
}

.lightbox-card {
  background: #000;
  box-shadow: none;
}

.lightbox-header {
  padding: 16px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(0, 0, 0, 0.8);
  backdrop-filter: blur(10px);
  position: sticky;
  top: 0;
  z-index: 10;
}

.lightbox-title {
  font-size: 16px;
  font-weight: 600;
}

.lightbox-close {
  margin-left: auto;
}

.lightbox-content {
  padding: 0;
  position: relative;
  min-height: 80vh;
  display: flex;
  align-items: center;
  justify-content: center;
}

.lightbox-image {
  max-height: 85vh;
  width: 100%;
}

.lightbox-nav {
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  transform: translateY(-50%);
  display: flex;
  justify-content: space-between;
  pointer-events: none;
  padding: 0 24px;
}

.nav-btn {
  pointer-events: auto;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  transition: all 0.2s;
}

.nav-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.4);
}

.nav-btn-left {
  margin-right: auto;
}

.nav-btn-right {
  margin-left: auto;
}

.lightbox-hint {
  padding: 12px;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(5px);
}

/* Responsive Design */
@media (max-width: 1200px) {
  .grid-row,
  .grid-row-2col {
    grid-template-columns: repeat(3, 1fr);
  }
  
  .gallery-grid-enhanced {
    grid-template-columns: repeat(3, 1fr);
  }
  
  .gallery-grid-compact {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 992px) {
  .grid-row,
  .grid-row-2col {
    grid-template-columns: 1fr;
  }
  
  .gallery-grid-enhanced {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .gallery-grid-compact {
    grid-template-columns: 1fr;
  }
  
  .header-section {
    flex-direction: column;
    align-items: flex-start;
    padding: 16px;
  }
  
  .header-right {
    width: 100%;
    justify-content: space-between;
  }
  
  .status-badge {
    flex: 1;
  }
}

@media (max-width: 768px) {
  .complaint-detail-container {
    padding: 12px;
  }
  
  .complaint-title {
    font-size: 20px;
  }
  
  .gallery-grid-enhanced {
    grid-template-columns: repeat(2, 1fr);
    gap: 10px;
  }
  
  .gallery-grid-compact {
    grid-template-columns: 1fr;
  }
  
  .header-right {
    flex-direction: column;
    gap: 8px;
  }
  
  .status-badge {
    width: 100%;
  }
  
  .lightbox-nav {
    padding: 0 12px;
  }
}

@media (max-width: 480px) {
  .header-left {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .complaint-title {
    font-size: 18px;
  }
  
  .gallery-grid-enhanced {
    grid-template-columns: 1fr;
  }
  
  .nav-btn {
    transform: scale(0.8);
  }
}
</style>
