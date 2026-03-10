<script setup>
import { ref } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import AuthenticatedLayout from "@/layouts/AuthenticatedLayout.vue";

const page = usePage();
const product = page.props.product;
const photos = product.photos ?? [];

const canEdit = page.props.auth?.user?.role === "admin";

// Lightbox
const lightboxOpen = ref(false);
const lightboxIndex = ref(0);

function openLightbox(index) {
  lightboxIndex.value = index;
  lightboxOpen.value = true;
}
function prev() {
  lightboxIndex.value = (lightboxIndex.value - 1 + photos.length) % photos.length;
}
function next() {
  lightboxIndex.value = (lightboxIndex.value + 1) % photos.length;
}

// Touch swipe for mobile lightbox
let touchStartX = 0;
function onTouchStart(e) {
  touchStartX = e.touches[0].clientX;
}
function onTouchEnd(e) {
  const dx = e.changedTouches[0].clientX - touchStartX;
  if (Math.abs(dx) > 50) {
    dx < 0 ? next() : prev();
  }
}

function goEditor() {
  router.get(route("admin.product-knowledge.photo-editor", product.id));
}
function goIndex() {
  router.get(route("admin.product-knowledge.index"));
}
</script>

<template>
  <AuthenticatedLayout :title="product.name + ' — Foto'">
    <template #header>
      <div class="row items-center no-wrap">
        <q-btn flat dense round icon="arrow_back" class="q-mr-xs" @click="goIndex" />
        <div class="col-grow" style="min-width:0">
          <div class="text-subtitle1 text-bold ellipsis">{{ product.name }}</div>
          <div class="text-caption text-grey-6 ellipsis">
            {{ product.category?.name }}
            <span v-if="photos.length" class="q-ml-xs">· {{ photos.length }} foto</span>
          </div>
        </div>
        <q-btn
          v-if="canEdit"
          flat
          dense
          round
          icon="edit"
          color="primary"
          title="Kelola Foto"
          class="q-ml-xs"
          @click="goEditor"
        />
      </div>
    </template>

    <!-- Empty state -->
    <div v-if="photos.length === 0" class="q-pa-xl text-center text-grey-5">
      <q-icon name="add_photo_alternate" size="72px" class="q-mb-md" />
      <div class="text-subtitle1 text-grey-6">Belum ada foto untuk varietas ini.</div>
      <q-btn
        v-if="canEdit"
        color="primary"
        icon="upload"
        label="Unggah Foto"
        unelevated
        class="q-mt-lg"
        @click="goEditor"
      />
    </div>

    <!-- Photo masonry-style grid -->
    <div v-else class="q-pa-sm row q-col-gutter-xs">
      <div
        v-for="(photo, index) in photos"
        :key="photo.id"
        class="col-6 col-sm-4 col-md-3 col-lg-2"
      >
        <div class="gal-item cursor-pointer" @click="openLightbox(index)">
          <q-img
            :src="'/' + photo.image_path"
            ratio="1"
            class="gal-img"
            loading="lazy"
          >
            <template #error>
              <div class="absolute-full flex flex-center bg-grey-2">
                <q-icon name="broken_image" size="36px" color="grey-5" />
              </div>
            </template>

            <!-- Caption overlay on hover -->
            <div v-if="photo.caption" class="gal-caption absolute-bottom">
              {{ photo.caption }}
            </div>
          </q-img>
        </div>
      </div>
    </div>

    <!-- Lightbox dialog -->
    <q-dialog v-model="lightboxOpen" maximized transition-show="fade" transition-hide="fade">
      <div
        class="lb-container"
        @click.self="lightboxOpen = false"
        @touchstart="onTouchStart"
        @touchend="onTouchEnd"
      >
        <!-- Close -->
        <q-btn
          round flat color="white" icon="close"
          class="lb-close"
          @click="lightboxOpen = false"
        />

        <!-- Image -->
        <q-img
          :src="'/' + photos[lightboxIndex].image_path"
          fit="contain"
          class="lb-img"
          @click.stop
        />

        <!-- Caption + counter bar -->
        <div class="lb-bottom">
          <div v-if="photos[lightboxIndex].caption" class="lb-caption">
            {{ photos[lightboxIndex].caption }}
          </div>
          <div class="lb-counter">{{ lightboxIndex + 1 }} / {{ photos.length }}</div>
        </div>

        <!-- Nav buttons -->
        <template v-if="photos.length > 1">
          <q-btn
            round unelevated color="black" text-color="white"
            icon="chevron_left"
            class="lb-prev"
            @click="prev"
          />
          <q-btn
            round unelevated color="black" text-color="white"
            icon="chevron_right"
            class="lb-next"
            @click="next"
          />
        </template>
      </div>
    </q-dialog>
  </AuthenticatedLayout>
</template>

<style scoped>
/* Gallery grid */
.gal-item {
  border-radius: 6px;
  overflow: hidden;
  transition: transform 0.15s;
}
.gal-item:hover {
  transform: scale(1.02);
}
.gal-img {
  display: block;
  border-radius: 6px;
}
.gal-caption {
  background: linear-gradient(transparent, rgba(0,0,0,0.6));
  color: #fff;
  font-size: 11px;
  padding: 6px 8px 5px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Lightbox */
.lb-container {
  position: relative;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.93);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.lb-close {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 20;
  background: rgba(0,0,0,0.4) !important;
}
.lb-img {
  width: 100%;
  height: calc(100vh - 70px);
  max-width: 100vw;
}
.lb-bottom {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(0,0,0,0.55);
  padding: 8px 16px;
  text-align: center;
}
.lb-caption {
  color: #fff;
  font-size: 13px;
  margin-bottom: 2px;
}
.lb-counter {
  color: rgba(255,255,255,0.65);
  font-size: 11px;
}
.lb-prev {
  position: absolute;
  left: 8px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 20;
  background: rgba(0,0,0,0.5) !important;
}
.lb-next {
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 20;
  background: rgba(0,0,0,0.5) !important;
}

/* Mobile: make nav buttons bigger and move to bottom area */
@media (max-width: 600px) {
  .lb-prev { left: 4px; }
  .lb-next { right: 4px; }
}
</style>
