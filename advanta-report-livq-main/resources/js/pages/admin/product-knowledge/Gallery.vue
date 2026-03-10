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
      <div class="row items-center q-gutter-sm">
        <q-btn flat dense round icon="arrow_back" @click="goIndex" />
        <div>
          <div class="text-h6">{{ product.name }}</div>
          <div class="text-caption text-grey-6">{{ product.category?.name }}</div>
        </div>
      </div>
    </template>

    <!-- Empty state -->
    <div v-if="photos.length === 0" class="q-pa-xl text-center text-grey-6">
      <q-icon name="add_photo_alternate" size="64px" class="q-mb-md" />
      <div class="text-subtitle1">Belum ada foto untuk varietas ini.</div>
      <q-btn
        v-if="canEdit"
        color="primary"
        icon="upload"
        label="Unggah Foto"
        class="q-mt-md"
        @click="goEditor"
      />
    </div>

    <!-- Photo grid -->
    <div v-else class="q-pa-sm row q-col-gutter-sm">
      <div
        v-for="(photo, index) in photos"
        :key="photo.id"
        class="col-xs-6 col-sm-4 col-md-3 col-lg-2"
      >
        <q-card class="photo-card cursor-pointer" @click="openLightbox(index)">
          <q-img
            :src="'/' + photo.image_path"
            ratio="1"
            class="photo-thumb"
          >
            <template #error>
              <div class="absolute-full flex flex-center bg-grey-2">
                <q-icon name="broken_image" size="40px" color="grey-5" />
              </div>
            </template>
          </q-img>
          <div v-if="photo.caption" class="text-caption q-pa-xs text-grey-7 ellipsis">
            {{ photo.caption }}
          </div>
        </q-card>
      </div>
    </div>

    <!-- Lightbox -->
    <q-dialog v-model="lightboxOpen" maximized>
      <div class="lightbox-container" @click.self="lightboxOpen = false">
        <q-btn
          round
          flat
          color="white"
          icon="close"
          class="lightbox-close"
          @click="lightboxOpen = false"
        />
        <q-btn
          v-if="photos.length > 1"
          round
          flat
          color="white"
          icon="chevron_left"
          class="lightbox-prev"
          @click="prev"
        />
        <q-img
          :src="'/' + photos[lightboxIndex].image_path"
          fit="contain"
          class="lightbox-img"
        />
        <div v-if="photos[lightboxIndex].caption" class="lightbox-caption">
          {{ photos[lightboxIndex].caption }}
        </div>
        <div class="lightbox-counter text-white">
          {{ lightboxIndex + 1 }} / {{ photos.length }}
        </div>
        <q-btn
          v-if="photos.length > 1"
          round
          flat
          color="white"
          icon="chevron_right"
          class="lightbox-next"
          @click="next"
        />
      </div>
    </q-dialog>

    <!-- Admin FAB -->
    <q-page-sticky v-if="canEdit" position="bottom-right" :offset="[18, 18]">
      <q-btn
        fab
        icon="edit"
        color="primary"
        title="Kelola Foto"
        @click="goEditor"
      />
    </q-page-sticky>
  </AuthenticatedLayout>
</template>

<style scoped>
.photo-card {
  border-radius: 8px;
  transition: box-shadow 0.2s;
}
.photo-card:hover {
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}
.photo-thumb {
  border-radius: 8px 8px 0 0;
}
.lightbox-container {
  position: relative;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.92);
  display: flex;
  align-items: center;
  justify-content: center;
}
.lightbox-img {
  max-width: 90vw;
  max-height: 88vh;
  width: auto;
  height: auto;
}
.lightbox-close {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 10;
}
.lightbox-prev {
  position: absolute;
  left: 10px;
  z-index: 10;
}
.lightbox-next {
  position: absolute;
  right: 10px;
  z-index: 10;
}
.lightbox-caption {
  position: absolute;
  bottom: 40px;
  left: 50%;
  transform: translateX(-50%);
  color: #fff;
  background: rgba(0,0,0,0.5);
  padding: 4px 16px;
  border-radius: 4px;
  font-size: 0.9rem;
  max-width: 80vw;
  text-align: center;
}
.lightbox-counter {
  position: absolute;
  bottom: 14px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 0.8rem;
  opacity: 0.7;
}
</style>
