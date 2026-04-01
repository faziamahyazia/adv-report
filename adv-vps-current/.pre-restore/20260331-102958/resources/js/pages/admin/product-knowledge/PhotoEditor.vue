<script setup>
import { ref } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import { useQuasar } from "quasar";
import AuthenticatedLayout from "@/layouts/AuthenticatedLayout.vue";
import axios from "axios";

const page = usePage();
const $q = useQuasar();

const product = ref(page.props.product);
const photos = ref(page.props.product.photos ?? []);

// ── Multi-file upload ──
const fileInputRef = ref(null);
const selectedFiles = ref([]); // [{file, previewUrl, caption}]
const thumbnailIndex = ref(0);
const uploading = ref(false);
const MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024;

function pickFiles() {
  // Call click directly in user-gesture handler (required by iOS Safari)
  fileInputRef.value.click();
}

function onFilesChange(e) {
  const allFiles = Array.from(e.target.files);
  const oversized = allFiles.filter((file) => file.size > MAX_FILE_SIZE_BYTES);
  const newFiles = allFiles.filter((file) => file.size <= MAX_FILE_SIZE_BYTES);

  if (oversized.length) {
    $q.notify({
      type: "warning",
      message: `${oversized.length} foto dilewati karena ukuran lebih dari 10MB per file.`,
    });
  }

  if (!newFiles.length) return;

  const remaining = 10 - selectedFiles.value.length;
  const toAdd = newFiles.slice(0, remaining);

  toAdd.forEach((file) => {
    selectedFiles.value.push({ file, previewUrl: URL.createObjectURL(file), caption: "" });
  });

  if (newFiles.length > remaining) {
    $q.notify({ type: "warning", message: `Maksimal 10 foto. ${newFiles.length - remaining} foto tidak ditambahkan.` });
  }

  // Reset AFTER processing so same file can be picked again next time
  e.target.value = "";
}

function removeSelected(index) {
  URL.revokeObjectURL(selectedFiles.value[index].previewUrl);
  selectedFiles.value.splice(index, 1);
  if (thumbnailIndex.value >= selectedFiles.value.length) {
    thumbnailIndex.value = Math.max(0, selectedFiles.value.length - 1);
  }
}

async function submit() {
  if (selectedFiles.value.length === 0) {
    $q.notify({ type: "warning", message: "Pilih minimal 1 foto." });
    return;
  }

  uploading.value = true;
  const fd = new FormData();
  selectedFiles.value.forEach((item, i) => {
    fd.append(`images[${i}]`, item.file);
    if (item.caption) fd.append(`captions[${i}]`, item.caption);
  });
  fd.append("thumbnail_index", thumbnailIndex.value);

  try {
    await axios.post(route("admin.product-knowledge.photo-save", product.value.id), fd);
    $q.notify({
      type: "positive",
      message: `${selectedFiles.value.length} foto berhasil diunggah!`,
      timeout: 3000,
    });
    router.get(route("admin.product-knowledge.index"));
  } catch (e) {
    const msg = e.response?.data?.message ?? "Gagal mengunggah foto.";
    $q.notify({ type: "negative", message: msg });
    uploading.value = false;
  }
}

// ── Existing photos ──
const deleting = ref(null);
const settingThumb = ref(null);

async function setThumbnail(photo) {
  settingThumb.value = photo.id;
  try {
    await axios.post(
      route("admin.product-knowledge.set-thumbnail", { id: product.value.id, photoId: photo.id })
    );
    photos.value = [photo, ...photos.value.filter((p) => p.id !== photo.id)];
    $q.notify({ type: "positive", message: "Thumbnail berhasil diubah." });
  } catch {
    $q.notify({ type: "negative", message: "Gagal mengubah thumbnail." });
  } finally {
    settingThumb.value = null;
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
</script>

<template>
  <AuthenticatedLayout :title="'Kelola Foto — ' + product.name">
    <template #title>Product Knowledge</template>
    <template #header>
      <q-toolbar class="filter-bar">
        <q-btn
          flat dense round icon="arrow_back" class="q-mr-xs"
          @click="router.get(route('admin.product-knowledge.index'))"
        />
        <div class="col-grow" style="min-width:0">
          <div class="text-subtitle2 text-bold ellipsis">{{ product.name }}</div>
          <div class="text-caption text-grey-6">Kelola Foto</div>
        </div>
      </q-toolbar>
    </template>

    <!-- Upload section -->
    <div class="pe-section q-ma-sm">
      <div class="pe-section-title">
        <q-icon name="add_a_photo" size="16px" class="q-mr-xs" />
        Unggah Foto Baru
        <span class="pe-count">{{ selectedFiles.length }}/10</span>
      </div>

      <!-- Pick button -->
      <div class="q-mb-sm">
        <q-btn
          unelevated dense
          color="secondary"
          icon="add_photo_alternate"
          label="Pilih Foto"
          :disable="selectedFiles.length >= 10 || uploading"
          @click="pickFiles"
        />
        <span class="q-ml-sm text-caption text-grey-6">Maksimal 10 foto sekaligus, 10MB per foto</span>
        <input
          ref="fileInputRef"
          type="file"
          accept="image/*"
          multiple
          style="display:none"
          @change="onFilesChange"
        />
      </div>

      <!-- Preview grid -->
      <div v-if="selectedFiles.length > 0" class="pe-grid q-mb-sm">
        <div
          v-for="(item, i) in selectedFiles"
          :key="i"
          class="pe-item"
          :class="{ 'pe-item--thumb': i === thumbnailIndex }"
        >
          <q-img :src="item.previewUrl" ratio="1" class="pe-img">
            <template #error>
              <div class="absolute-full flex flex-center bg-grey-2">
                <q-icon name="broken_image" size="28px" color="grey-5" />
              </div>
            </template>
          </q-img>

          <!-- Thumbnail star button -->
          <button
            class="pe-thumb-btn"
            :class="{ 'pe-thumb-btn--active': i === thumbnailIndex }"
            title="Jadikan thumbnail"
            :disabled="uploading"
            @click="thumbnailIndex = i"
          >
            <q-icon :name="i === thumbnailIndex ? 'star' : 'star_outline'" size="14px" />
          </button>

          <!-- Remove button -->
          <button
            class="pe-del"
            title="Hapus dari pilihan"
            :disabled="uploading"
            @click="removeSelected(i)"
          >
            <q-icon name="close" size="14px" />
          </button>

          <!-- Thumbnail badge -->
          <div v-if="i === thumbnailIndex" class="pe-thumb-badge">Thumbnail</div>

          <!-- Caption input -->
          <input
            v-model="item.caption"
            class="pe-caption-input"
            placeholder="Keterangan..."
            :disabled="uploading"
          />
        </div>
      </div>

      <!-- Upload button -->
      <q-btn
        unelevated
        color="dark"
        icon="upload"
        :label="uploading ? 'Mengunggah...' : `Unggah ${selectedFiles.length > 0 ? selectedFiles.length + ' ' : ''}Foto`"
        :loading="uploading"
        :disable="selectedFiles.length === 0"
        style="min-width:140px"
        @click="submit"
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
        <div
          v-for="(photo, idx) in photos"
          :key="photo.id"
          class="pe-item"
          :class="{ 'pe-item--thumb': idx === 0 }"
        >
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

          <!-- Set as thumbnail button -->
          <button
            v-if="idx !== 0"
            class="pe-thumb-btn"
            title="Jadikan thumbnail"
            :disabled="settingThumb === photo.id"
            @click="setThumbnail(photo)"
          >
            <q-spinner v-if="settingThumb === photo.id" size="14px" />
            <q-icon v-else name="star_outline" size="14px" />
          </button>
          <div v-else class="pe-thumb-btn pe-thumb-btn--active pe-thumb-btn--static">
            <q-icon name="star" size="14px" />
          </div>

          <!-- Thumbnail badge for first photo -->
          <div v-if="idx === 0" class="pe-thumb-badge">Thumbnail</div>

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

/* Photo grid */
.pe-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 6px;
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
.pe-item--thumb {
  outline: 2px solid #f9a825;
  outline-offset: -2px;
}
.pe-img {
  display: block;
  width: 100%;
  border-radius: 6px;
}

/* Thumbnail star button (top-left) */
.pe-thumb-btn {
  position: absolute;
  top: 4px;
  left: 4px;
  background: rgba(249,168,37,0.85);
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
.pe-thumb-btn:not(.pe-thumb-btn--active) {
  background: rgba(0,0,0,0.45);
}
.pe-thumb-btn--active { background: rgba(249,168,37,0.9); }
.pe-thumb-btn--static { cursor: default; }
.pe-thumb-btn:hover:not(.pe-thumb-btn--active):not(.pe-thumb-btn--static) {
  background: rgba(249,168,37,0.7);
}
.pe-thumb-btn:disabled { opacity: 0.6; cursor: default; }

/* Thumbnail badge */
.pe-thumb-badge {
  position: absolute;
  bottom: 22px;
  left: 0;
  right: 0;
  background: rgba(249,168,37,0.88);
  color: #fff;
  font-size: 9px;
  font-weight: 700;
  text-align: center;
  padding: 2px 0;
  letter-spacing: 0.5px;
  text-transform: uppercase;
}

/* Delete button (top-right) */
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

/* Caption */
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

/* Caption input (for new uploads) */
.pe-caption-input {
  display: block;
  width: 100%;
  border: none;
  border-top: 1px solid #eee;
  background: #fafafa;
  font-size: 10px;
  color: #555;
  padding: 3px 5px;
  box-sizing: border-box;
  outline: none;
}
.pe-caption-input:focus {
  background: #fff;
  border-top-color: #1976d2;
}
.pe-caption-input::placeholder { color: #bbb; }
.pe-caption-input:disabled { opacity: 0.5; }
</style>
