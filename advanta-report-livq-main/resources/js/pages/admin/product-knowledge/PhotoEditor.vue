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

const form = useForm({
  image: null,
  caption: "",
});

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
    <template #header>
      <div class="row items-center no-wrap">
        <q-btn flat dense round icon="arrow_back" class="q-mr-xs" @click="goGallery" />
        <div class="col-grow" style="min-width:0">
          <div class="text-subtitle1 text-bold ellipsis">Kelola Foto</div>
          <div class="text-caption text-grey-6 ellipsis">{{ product.name }}</div>
        </div>
      </div>
    </template>

    <!-- Upload Card -->
    <q-card flat bordered class="q-ma-sm upload-card">
      <q-card-section class="q-pb-xs">
        <div class="row items-center q-mb-sm">
          <q-icon name="add_a_photo" color="primary" size="20px" class="q-mr-xs" />
          <span class="text-subtitle2 text-bold">Unggah Foto Baru</span>
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
      </q-card-section>
      <q-card-actions class="q-pt-xs q-px-md q-pb-md">
        <q-btn
          unelevated
          color="primary"
          icon="upload"
          label="Simpan Foto"
          :loading="form.processing"
          style="min-width:140px"
          @click="submit"
        />
      </q-card-actions>
    </q-card>

    <!-- Divider + Existing Photos -->
    <div class="q-px-sm q-mt-sm">
      <div class="row items-center q-mb-sm q-mx-xs">
        <q-icon name="collections" size="18px" color="grey-6" class="q-mr-xs" />
        <span class="text-subtitle2 text-bold text-grey-8">
          Foto tersimpan
          <q-badge
            :label="photos.length"
            color="grey-5"
            text-color="grey-9"
            class="q-ml-xs"
          />
        </span>
      </div>

      <div v-if="photos.length === 0" class="text-center text-grey-5 q-py-lg">
        <q-icon name="add_photo_alternate" size="48px" />
        <div class="text-caption q-mt-xs">Belum ada foto. Unggah foto di atas.</div>
      </div>

      <div v-else class="row q-col-gutter-xs">
        <div
          v-for="photo in photos"
          :key="photo.id"
          class="col-6 col-sm-4 col-md-3"
        >
          <div class="pe-item">
            <q-img
              :src="'/' + photo.image_path"
              ratio="1"
              class="pe-img"
              loading="lazy"
            >
              <template #error>
                <div class="absolute-full flex flex-center bg-grey-2">
                  <q-icon name="broken_image" size="32px" color="grey-5" />
                </div>
              </template>
            </q-img>

            <!-- Delete overlay button -->
            <q-btn
              class="pe-del"
              round
              unelevated
              size="sm"
              color="negative"
              icon="delete"
              :loading="deleting === photo.id"
              title="Hapus foto"
              @click="deletePhoto(photo)"
            />

            <!-- Caption -->
            <div v-if="photo.caption" class="pe-caption text-caption text-grey-7 ellipsis q-px-xs q-py-xs">
              {{ photo.caption }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </AuthenticatedLayout>
</template>

<style scoped>
.upload-card {
  border-radius: 10px;
}
/* Photo editor grid items */
.pe-item {
  position: relative;
  border-radius: 8px;
  overflow: hidden;
  background: #f0f0f0;
}
.pe-img {
  display: block;
  border-radius: 8px;
}
.pe-del {
  position: absolute;
  top: 6px;
  right: 6px;
  opacity: 0.9;
  box-shadow: 0 1px 4px rgba(0,0,0,0.3);
}
.pe-caption {
  background: #fafafa;
  border-top: 1px solid #eee;
  font-size: 11px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
