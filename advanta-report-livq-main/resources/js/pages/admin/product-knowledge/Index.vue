<script setup>
import { ref, reactive, watch, onMounted } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import AuthenticatedLayout from "@/layouts/AuthenticatedLayout.vue";
import axios from "axios";

const page = usePage();
const categories = page.props.categories ?? [];

const filter = reactive({ search: "", category_id: "all" });
const products = ref([]);
const loading = ref(false);

const categoryOptions = [
  { value: "all", label: "Semua Kategori" },
  ...categories.map((c) => ({ value: c.id, label: c.name })),
];

async function fetchProducts() {
  loading.value = true;
  try {
    const res = await axios.get(route("admin.product-knowledge.data"), {
      params: { filter },
    });
    products.value = res.data;
  } finally {
    loading.value = false;
  }
}

onMounted(fetchProducts);

let debounceTimer;
watch(filter, () => {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(fetchProducts, 300);
});

function goGallery(product) {
  router.get(route("admin.product-knowledge.gallery", product.id));
}

function goEditor(product) {
  router.get(route("admin.product-knowledge.photo-editor", product.id));
}

const canEdit = page.props.auth?.user?.role === "admin";
</script>

<template>
  <AuthenticatedLayout title="Product Knowledge">
    <template #header>
      <div class="text-h6">Product Knowledge</div>
    </template>

    <!-- Filter bar -->
    <div class="q-pa-sm row q-col-gutter-sm items-center">
      <div class="col-xs-12 col-sm-5 col-md-4">
        <q-input
          v-model="filter.search"
          dense
          outlined
          placeholder="Cari varietas..."
          clearable
          bg-color="white"
        >
          <template #prepend><q-icon name="search" /></template>
        </q-input>
      </div>
      <div class="col-xs-12 col-sm-5 col-md-4">
        <q-select
          v-model="filter.category_id"
          :options="categoryOptions"
          option-value="value"
          option-label="label"
          emit-value
          map-options
          dense
          outlined
          bg-color="white"
        />
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="q-pa-lg text-center">
      <q-spinner size="40px" color="primary" />
    </div>

    <!-- Empty state -->
    <div v-else-if="products.length === 0" class="q-pa-lg text-center text-grey-6">
      <q-icon name="photo_library" size="48px" class="q-mb-sm" />
      <div>Tidak ada varietas ditemukan.</div>
    </div>

    <!-- Card grid -->
    <div v-else class="q-pa-sm row q-col-gutter-sm">
      <div
        v-for="product in products"
        :key="product.id"
        class="col-xs-6 col-sm-4 col-md-3 col-lg-2"
      >
        <q-card class="pk-card cursor-pointer full-height" @click="goGallery(product)">
          <!-- Thumbnail -->
          <q-img
            v-if="product.photos && product.photos.length > 0"
            :src="'/' + product.photos[0].image_path"
            ratio="1"
            class="card-thumb"
          >
            <template #error>
              <div class="absolute-full flex flex-center bg-grey-2">
                <q-icon name="broken_image" size="40px" color="grey-5" />
              </div>
            </template>
          </q-img>
          <div v-else class="card-thumb-placeholder flex flex-center bg-grey-2">
            <q-icon name="add_photo_alternate" size="40px" color="grey-5" />
          </div>

          <q-card-section class="q-pa-sm">
            <div class="text-subtitle2 ellipsis">{{ product.name }}</div>
            <div class="text-caption text-grey-6 ellipsis">{{ product.category?.name }}</div>
            <div class="text-caption text-grey-7">
              <q-icon name="photo" size="14px" /> {{ product.photos_count }} foto
            </div>
          </q-card-section>

          <q-card-actions v-if="canEdit" class="q-pa-xs" @click.stop>
            <q-btn
              flat
              dense
              size="sm"
              icon="edit"
              color="primary"
              label="Kelola Foto"
              @click="goEditor(product)"
            />
          </q-card-actions>
        </q-card>
      </div>
    </div>
  </AuthenticatedLayout>
</template>

<style scoped>
.pk-card {
  border-radius: 8px;
  transition: box-shadow 0.2s;
}
.pk-card:hover {
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}
.card-thumb {
  border-radius: 8px 8px 0 0;
}
.card-thumb-placeholder {
  height: 150px;
  border-radius: 8px 8px 0 0;
}
</style>
