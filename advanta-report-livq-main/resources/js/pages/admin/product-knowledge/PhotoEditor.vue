<script setup>
import { ref } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import { useQuasar } from "quasar";
import AuthenticatedLayout from "@/layouts/AuthenticatedLayout.vue";
import axios from "axios";

const page = usePage();
const $q = useQuasar();

const product = ref(page.props.product);
// sort by sort_order so index 0 = current thumbnail
const photos = ref(
  [...(page.props.product.photos ?? [])].sort((a, b) => a.sort_order - b.sort_order)
);

const fileInput = ref(null);
const selectedFiles = ref([]);
const previews = ref([]);
const uploading = ref(false);
const deleting = ref(null);
const settingThumb = ref(null);

const MAX_FILES = 10;

function openPicker() {
  fileInput.value.click();
}

function onFilesSelected(event) {
  const incoming = Array.from(event.target.files);
  event.target.value = "";

  const available = MAX_FILES - selectedFiles.value.length;
  if (available <= 0) {
    $q.notify({ type: "warning", message: `Maksimal ${MAX_FILES} foto sekaligus.` });
    return;
  }

  const toAdd = incoming.slice(0, available);
  if (incoming.length > available) {
    $q.notify({ type: "warning", message: `Hanya ${available} foto yang ditambahkan (maks ${MAX_FILES}).` });
  }

  toAdd.forEach((f) => {
    selectedFiles.value.push(f);
    previews.value.push(URL.createObjectURL(f));
  });
}

function removeFile(i) {
  URL.revokeObjectURL(previews.value[i]);
  selectedFiles.value.splice(i, 1);
  previews.value.splice(i, 1);
}

function clearAll() {
  previews.value.forEach((url) => URL.revokeObjectURL(url));
  selectedFiles.value = [];
  previews.value = [];
}

async function upload() {
  if (!selectedFiles.value.length) {
    $q.notify({ type: "warning", message: "Pilih minimal satu foto terlebih dahulu." });
    return;
  }

  uploading.value = true;
  const fd = new FormData();
  selectedFiles.value.forEach((f) => fd.append("images[]", f));

  try {
    const res = await axios.post(
      route("admin.product-knowledge.photo-save", product.value.id),
      fd
    );
    $q.notify({
      type: "positive",
      icon: "check_circle",
      message: res.data.message ?? `${selectedFiles.value.length} foto berhasil diunggah!`,
      timeout: 3000,
    });
    router.get(route("admin.product-knowledge.index"));
  } catch (err) {
    const errors = err?.response?.data?.errors;
    let msg = "Gagal mengunggah foto.";
    if (errors) msg = Object.values(errors).flat().join(", ");
    else if (err?.response?.data?.message) msg = err.response.data.message;
    $q.notify({ type: "negative", message: msg });
  } finally {
    uploading.value = false;
  }
}

async function deletePhoto(photo) {
  $q.dialog({
    title: "Hapus Foto",
    message: "Yakin ingin menghapus foto ini?",
    ok: { label: "Hapus", color: "negative", unelevated: true },
    cancel: { label: "Batal", flat: true },
  }).onOk(async () => {
    deleting.value = photo.id;
    try {
      await axios.post(route("admin.product-knowledge.photo-delete", photo.id));
      photos.value = photos.value.filter((p) => p.id !== photo.id);
      $q.notify({ type: "positive", message: "Foto telah dihapus." });
    } catch {
      $q.notify({ type: "negative", message: "Gagal menghapus foto." });
    } finally {
      deleting.value = null;
    }
  });
}

async function setThumbnail(photo) {
  settingThumb.value = photo.id;
  try {
    await axios.post(route("admin.product-knowledge.photo-set-thumbnail", photo.id));
    // Move selected photo to index 0 in local array
    photos.value = [
      photo,
      ...photos.value.filter((p) => p.id !== photo.id),
    ];
    $q.notify({ type: "positive", icon: "star", message: "Thumbnail berhasil diubah." });
  } catch {
    $q.notify({ type: "negative", message: "Gagal mengubah thumbnail." });
  } finally {
    settingThumb.value = null;
  }
}

function goBack() {
  router.get(route("admin.product-knowledge.gallery", product.value.id));
}
</script>

<template>
  <AuthenticatedLayout>
    <template #title>Product Knowledge</template>
    <template #header>
      <q-toolbar class="filter-bar">
        <q-btn flat dense round icon="arrow_back" class="q-mr-xs" @click="goBack" />
        <div class="col-grow" style="min-width:0">
          <div class="text-subtitle2 text-bold ellipsis">{{ product.name }}</div>
          <div class="text-caption text-grey-6">Unggah Foto</div>
        </div>
      </q-toolbar>
    </template>

    <!-- Upload section -->
    <div class="pe-section q-ma-sm">
      <div class="pe-section-title">
        <q-icon name="add_a_photo" size="16px" class="q-mr-xs" />
        Pilih Foto (maks {{ MAX_FILES }} sekaligus)
      </div>

      <input
        ref="fileInput"
        type="file"
        accept="image/*"
        multiple
        style="display:none"
        @change="onFilesSelected"
      />

      <!-- Action buttons -->
      <div class="row items-center q-gutter-sm q-mb-sm">
        <q-btn
          unelevated
          color="dark"
          icon="add_a_photo"
          size="sm"
          :label="selectedFiles.length ? `Tambah Foto (${selectedFiles.length}/${MAX_FILES})` : 'Pilih Foto'"
          :disable="selectedFiles.length >= MAX_FILES || uploading"
          @click="openPicker"
        />
        <q-btn
          v-if="selectedFiles.length"
          flat
          size="sm"
          icon="clear_all"
          label="Hapus Semua"
          color="grey-7"
          :disable="uploading"
          @click="clearAll"
        />
      </div>

      <!-- Preview grid of selected files -->
      <div v-if="selectedFiles.length" class="pe-grid q-mb-sm">
        <div v-for="(src, i) in previews" :key="i" class="pe-item">
          <img :src="src" class="pe-preview-img" />
          <button class="pe-del" :disabled="uploading" @click="removeFile(i)">
            <q-icon name="close" size="14px" />
          </button>
          <div class="pe-caption">{{ selectedFiles[i].name }}</div>
        </div>
      </div>

      <!-- Empty state -->
      <div v-else class="text-center text-grey-5 q-py-md">
        <q-icon name="add_photo_alternate" size="36px" />
        <div class="text-caption q-mt-xs">Belum ada foto dipilih</div>
      </div>

      <!-- Upload button -->
      <q-btn
        v-if="selectedFiles.length"
        unelevated
        color="dark"
        icon="cloud_upload"
        :label="`Upload ${selectedFiles.length} Foto`"
        :loading="uploading"
        class="full-width q-mt-xs"
        @click="upload"
      />
    </div>

    <q-separator class="q-mx-sm" />

    <!-- Existing photos -->
    <div class="q-ma-sm">
      <div class="pe-section-title q-mb-sm">
        <q-icon name="collections" size="16px" class="q-mr-xs" />
        Foto Tersimpan
        <span class="pe-count">{{ photos.length }}</span>
      </div>

      <div v-if="photos.length === 0" class="text-center text-grey-5 q-py-lg">
        <q-icon name="add_photo_alternate" size="40px" />
        <div class="text-caption q-mt-xs">Belum ada foto.</div>
      </div>

      <div v-else class="pe-grid">
        <div v-for="(photo, idx) in photos" :key="photo.id" class="pe-item">
          <q-img
            :src="'/' + photo.image_path"
            ratio="1"
            loading="lazy"
            class="pe-img"
          >
            <template #error>
              <div class="absolute-full flex flex-center bg-grey-2">
                <q-icon name="broken_image" size="28px" color="grey-5" />
              </div>
            </template>
          </q-img>

          <!-- Thumbnail badge (first photo) -->
          <div v-if="idx === 0" class="pe-thumb-badge">
            <q-icon name="star" size="10px" /> Cover
          </div>

          <!-- Set as thumbnail button (non-first photos) -->
          <button
            v-else
            class="pe-set-thumb"
            :disabled="settingThumb === photo.id"
            title="Jadikan thumbnail"
            @click="setThumbnail(photo)"
          >
            <q-spinner v-if="settingThumb === photo.id" size="10px" />
            <q-icon v-else name="star_outline" size="10px" />
            Cover
          </button>

          <!-- Delete button -->
          <button
            class="pe-del"
            title="Hapus foto"
            :disabled="deleting === photo.id"
            @click="deletePhoto(photo)"
          >
            <q-spinner v-if="deleting === photo.id" size="14px" />
            <q-icon v-else name="delete" size="14px" />
          </button>

          <div v-if="photo.caption" class="pe-caption">{{ photo.caption }}</div>
        </div>
      </div>
    </div>
  </AuthenticatedLayout>
</template>

<style scoped>
.pe-section {
  background: #fff;
  border: 1px solid #eee;
  border-radius: 8px;
  padding: 12px;
}
.pe-section-title {
  display: flex;
  align-items: center;
  font-size: 13px;
  font-weight: 600;
  color: #444;
  margin-bottom: 10px;
}
.pe-count {
  margin-left: 6px;
  background: #eee;
  color: #555;
  font-size: 11px;
  padding: 1px 7px;
  border-radius: 10px;
}

/* Photo grid — CSS Grid */
.pe-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 6px;
  box-sizing: border-box;
}
@media (min-width: 600px) {
  .pe-grid { grid-template-columns: repeat(4, 1fr); }
}
@media (min-width: 960px) {
  .pe-grid { grid-template-columns: repeat(6, 1fr); }
}

.pe-item {
  position: relative;
  border-radius: 6px;
  overflow: hidden;
  background: #f5f5f5;
}
.pe-img {
  display: block;
  width: 100%;
  border-radius: 6px;
}
/* Preview image before upload (native <img>) */
.pe-preview-img {
  display: block;
  width: 100%;
  aspect-ratio: 1;
  object-fit: cover;
  border-radius: 6px;
}
.pe-del {
  position: absolute;
  top: 4px;
  right: 4px;
  background: rgba(211,47,47,0.85);
  border: none;
  border-radius: 50%;
  width: 26px;
  height: 26px;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  padding: 0;
}
.pe-del:hover { background: rgba(211,47,47,1); }
.pe-del:disabled { opacity: 0.6; cursor: default; }

/* Thumbnail cover badge */
.pe-thumb-badge {
  position: absolute;
  top: 4px;
  left: 4px;
  background: rgba(255,152,0,0.92);
  border-radius: 4px;
  padding: 2px 6px;
  font-size: 10px;
  font-weight: 700;
  color: #fff;
  display: flex;
  align-items: center;
  gap: 3px;
  pointer-events: none;
}

/* Set as cover button */
.pe-set-thumb {
  position: absolute;
  top: 4px;
  left: 4px;
  background: rgba(33,33,33,0.65);
  border: none;
  border-radius: 4px;
  padding: 2px 6px;
  font-size: 10px;
  color: #fff;
  display: flex;
  align-items: center;
  gap: 3px;
  cursor: pointer;
  transition: background 0.15s;
}
.pe-set-thumb:hover { background: rgba(255,152,0,0.92); }
.pe-set-thumb:disabled { opacity: 0.6; cursor: default; }
.pe-caption {
  background: rgba(0,0,0,0.04);
  border-top: 1px solid #eee;
  font-size: 10px;
  color: #555;
  padding: 3px 5px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
