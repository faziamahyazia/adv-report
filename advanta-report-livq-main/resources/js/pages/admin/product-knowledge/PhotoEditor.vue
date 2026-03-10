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
    ok: { label: "Hapus", color: "negative" },
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
function goIndex() {
  router.get(route("admin.product-knowledge.index"));
}
</script>

<template>
  <AuthenticatedLayout :title="'Kelola Foto — ' + product.name">
    <template #header>
      <div class="row items-center q-gutter-sm">
        <q-btn flat dense round icon="arrow_back" @click="goGallery" />
        <div>
          <div class="text-h6">Kelola Foto</div>
          <div class="text-caption text-grey-6">{{ product.name }}</div>
        </div>
      </div>
    </template>

    <!-- Upload Form -->
    <q-card class="q-ma-sm">
      <q-card-section>
        <div class="text-subtitle1 text-bold q-mb-sm">Unggah Foto Baru</div>
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
      <q-card-actions>
        <q-btn
          color="primary"
          icon="upload"
          label="Simpan Foto"
          :loading="form.processing"
          @click="submit"
        />
      </q-card-actions>
    </q-card>

    <!-- Existing Photos -->
    <div class="q-px-sm q-mt-md">
      <div class="text-subtitle1 text-bold q-mb-sm">
        Foto yang sudah ada ({{ photos.length }})
      </div>

      <div v-if="photos.length === 0" class="text-grey-6 text-center q-py-lg">
        <q-icon name="add_photo_alternate" size="48px" />
        <div>Belum ada foto, silakan unggah foto di atas.</div>
      </div>

      <div v-else class="row q-col-gutter-sm">
        <div
          v-for="photo in photos"
          :key="photo.id"
          class="col-xs-6 col-sm-4 col-md-3"
        >
          <q-card class="photo-item">
            <q-img
              :src="'/' + photo.image_path"
              ratio="1"
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
            <q-card-actions class="q-pa-xs">
              <q-btn
                flat
                dense
                size="sm"
                icon="delete"
                color="negative"
                label="Hapus"
                :loading="deleting === photo.id"
                @click="deletePhoto(photo)"
              />
            </q-card-actions>
          </q-card>
        </div>
      </div>
    </div>
  </AuthenticatedLayout>
</template>

<style scoped>
.photo-item {
  border-radius: 8px;
}
</style>
