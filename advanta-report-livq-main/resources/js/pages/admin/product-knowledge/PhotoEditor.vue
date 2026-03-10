<script setup>
import { ref } from "vue";
import { router, useForm, usePage } from "@inertiajs/vue3";
import { useQuasar } from "quasar";
import { handleSubmit } from "@/helpers/client-req-handler";
import ImageUpload from "@/components/ImageUpload.vue";
import AuthenticatedLayout from "@/layouts/AuthenticatedLayout.vue";
import axios from "axios";

const page = usePage();
const $q = useQuasar();

const product = ref(page.props.product);
const photos = ref(page.props.product.photos ?? []);

const form = useForm({ image: null, caption: "" });

function submit() {
  if (!form.image) {
    $q.notify({ type: "warning", message: "Pilih foto terlebih dahulu." });
    return;
  }
  handleSubmit({
    form,
    forceFormData: true,
    url: route("admin.product-knowledge.photo-save", product.value.id),
  });
}

const deleting = ref(null);

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

function goGallery() {
  router.get(route("admin.product-knowledge.gallery", product.value.id));
}
</script>

<template>
  <AuthenticatedLayout :title="'Kelola Foto — ' + product.name">
    <template #title>Product Knowledge</template>
    <template #header>
      <q-toolbar class="filter-bar">
        <q-btn flat dense round icon="arrow_back" class="q-mr-xs" @click="goGallery" />
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
      </div>
      <ImageUpload
        v-model="form.image"
        label="Pilih Foto:"
        :error="!!form.errors.image"
        :error-message="form.errors.image"
      />
      <q-input
        v-model="form.caption"
        label="Keterangan (opsional)"
        outlined
        dense
        class="q-mt-sm"
        :error="!!form.errors.caption"
        :error-message="form.errors.caption"
      />
      <div class="q-mt-sm">
        <q-btn
          unelevated
          color="dark"
          icon="upload"
          label="Simpan Foto"
          :loading="form.processing"
          style="min-width:130px"
          @click="submit"
        />
      </div>
    </div>

    <!-- Divider -->
    <q-separator class="q-mx-sm" />

    <!-- Existing photos -->
    <div class="q-ma-sm">
      <div class="pe-section-title q-mb-sm">
        <q-icon name="collections" size="16px" class="q-mr-xs" />
        Foto tersimpan
        <span class="pe-count">{{ photos.length }}</span>
      </div>

      <div v-if="photos.length === 0" class="text-center text-grey-5 q-py-lg">
        <q-icon name="add_photo_alternate" size="40px" />
        <div class="text-caption q-mt-xs">Belum ada foto.</div>
      </div>

      <div v-else class="pe-grid">
        <div
          v-for="photo in photos"
          :key="photo.id"
          class="pe-item"
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

          <!-- Delete button overlay -->
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
