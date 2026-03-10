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

// Touch swipe
let touchStartX = 0;
function onTouchStart(e) { touchStartX = e.touches[0].clientX; }
function onTouchEnd(e) {
  const dx = e.changedTouches[0].clientX - touchStartX;
  if (Math.abs(dx) > 50) dx < 0 ? next() : prev();
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
          flat dense round
          icon="edit"
          color="grey-7"
          title="Kelola Foto"
          class="q-ml-xs"
          @click="goEditor"
        />
      </div>
    </template>

    <!-- Empty state -->
    <div v-if="photos.length === 0" class="q-pa-xl text-center text-grey-5">
      <q-icon name="add_photo_alternate" size="64px" />
      <div class="text-subtitle2 text-grey-6 q-mt-sm">Belum ada foto.</div>
      <q-btn
        v-if="canEdit"
        flat color="grey-7"
        icon="upload" label="Unggah Foto"
        class="q-mt-md"
        @click="goEditor"
      />
    </div>

    <!-- Photo grid -->
    <div v-else class="gal-grid">
      <div
        v-for="(photo, index) in photos"
        :key="photo.id"
        class="gal-item cursor-pointer"
        @click="openLightbox(index)"
      >
        <q-img
          :src="'/' + photo.image_path"
          ratio="1"
          loading="lazy"
          class="gal-img"
        >
          <template #error>
            <div class="absolute-full flex flex-center bg-grey-2">
              <q-icon name="broken_image" size="32px" color="grey-5" />
            </div>
          </template>
          <div v-if="photo.caption" class="gal-caption absolute-bottom">
            {{ photo.caption }}
          </div>
        </q-img>
      </div>
    </div>

    <!-- Lightbox -->
    <q-dialog v-model="lightboxOpen" maximized transition-show="fade" transition-hide="fade">
      <div
        class="lb-wrap"
        @click.self="lightboxOpen = false"
        @touchstart="onTouchStart"
        @touchend="onTouchEnd"
      >
        <button class="lb-close" @click="lightboxOpen = false">
          <q-icon name="close" size="22px" />
        </button>

        <q-img
          :src="'/' + photos[lightboxIndex].image_path"
          fit="contain"
          class="lb-img"
          @click.stop
        />

        <div class="lb-bar">
          <span v-if="photos[lightboxIndex].caption" class="lb-caption">
            {{ photos[lightboxIndex].caption }}
          </span>
          <span class="lb-counter">{{ lightboxIndex + 1 }} / {{ photos.length }}</span>
        </div>

        <template v-if="photos.length > 1">
          <button class="lb-nav lb-prev" @click="prev">
            <q-icon name="chevron_left" size="28px" />
          </button>
          <button class="lb-nav lb-next" @click="next">
            <q-icon name="chevron_right" size="28px" />
          </button>
        </template>
      </div>
    </q-dialog>
  </AuthenticatedLayout>
</template>

<style scoped>
/* Photo grid — CSS Grid, no overflow */
.gal-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 4px;
  padding: 6px;
  box-sizing: border-box;
}
@media (min-width: 600px) {
  .gal-grid { grid-template-columns: repeat(4, 1fr); gap: 6px; }
}
@media (min-width: 960px) {
  .gal-grid { grid-template-columns: repeat(6, 1fr); gap: 8px; }
}

.gal-item {
  border-radius: 5px;
  overflow: hidden;
}
.gal-img {
  display: block;
  width: 100%;
  border-radius: 5px;
  transition: opacity 0.15s;
}
.gal-item:hover .gal-img {
  opacity: 0.85;
}
.gal-caption {
  background: linear-gradient(transparent, rgba(0,0,0,0.55));
  color: #fff;
  font-size: 10px;
  padding: 5px 6px 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Lightbox */
.lb-wrap {
  position: relative;
  width: 100%;
  height: 100%;
  background: #111;
  display: flex;
  align-items: center;
  justify-content: center;
}
.lb-img {
  width: 100%;
  height: calc(100dvh - 56px);
  max-width: 100vw;
}
.lb-close {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 10;
  background: rgba(0,0,0,0.45);
  border: none;
  border-radius: 50%;
  width: 36px;
  height: 36px;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}
.lb-bar {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(0,0,0,0.5);
  padding: 7px 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}
.lb-caption { color: #eee; font-size: 12px; }
.lb-counter { color: rgba(255,255,255,0.5); font-size: 11px; }

.lb-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(0,0,0,0.4);
  border: none;
  border-radius: 50%;
  width: 44px;
  height: 44px;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 10;
}
.lb-nav:hover { background: rgba(0,0,0,0.65); }
.lb-prev { left: 8px; }
.lb-next { right: 8px; }
</style>
