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
function goEditor(product, e) {
  e.stopPropagation();
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
    <div class="pk-filter">
      <q-input
        v-model="filter.search"
        dense
        outlined
        placeholder="Cari varietas..."
        clearable
        bg-color="white"
        style="max-width:260px"
      >
        <template #prepend><q-icon name="search" size="18px" /></template>
      </q-input>
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
        style="min-width:130px; max-width:180px"
      />
    </div>

    <!-- Loading skeletons -->
    <div v-if="loading" class="pk-grid">
      <div v-for="n in 12" :key="n" class="pk-skeleton">
        <q-skeleton square style="aspect-ratio:1/1; width:100%" />
        <q-skeleton type="text" width="70%" class="q-mt-xs q-mx-xs" />
      </div>
    </div>

    <!-- Empty state -->
    <div v-else-if="products.length === 0" class="q-pa-xl text-center text-grey-5">
      <q-icon name="photo_library" size="56px" />
      <div class="text-subtitle2 q-mt-sm text-grey-6">Tidak ada varietas ditemukan.</div>
    </div>

    <!-- Grid -->
    <div v-else class="pk-grid">
      <div
        v-for="product in products"
        :key="product.id"
        class="pk-item cursor-pointer"
        @click="goGallery(product)"
      >
        <!-- Square thumbnail -->
        <div class="pk-thumb">
          <q-img
            v-if="product.photos && product.photos.length > 0"
            :src="'/' + product.photos[0].image_path"
            ratio="1"
            loading="lazy"
            class="pk-img"
          >
            <template #error>
              <div class="absolute-full flex flex-center bg-grey-2">
                <q-icon name="image_not_supported" size="28px" color="grey-5" />
              </div>
            </template>
          </q-img>
          <div v-else class="pk-no-photo flex flex-center bg-grey-2">
            <q-icon name="add_photo_alternate" size="28px" color="grey-5" />
          </div>

          <!-- Photo count badge -->
          <span v-if="product.photos_count > 0" class="pk-badge">
            {{ product.photos_count }}
          </span>

          <!-- Admin edit icon -->
          <button
            v-if="canEdit"
            class="pk-edit-btn"
            title="Kelola Foto"
            @click="goEditor(product, $event)"
          >
            <q-icon name="edit" size="14px" />
          </button>
        </div>

        <!-- Label -->
        <div class="pk-label">{{ product.name }}</div>
      </div>
    </div>
  </AuthenticatedLayout>
</template>

<style scoped>
.pk-filter {
  display: flex;
  gap: 8px;
  flex-wrap: nowrap;
  padding: 8px;
  background: #f8f8f8;
  border-bottom: 1px solid #eee;
  overflow: hidden;
}

/* CSS Grid — no negative margins, no horizontal overflow */
.pk-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 6px;
  padding: 8px;
  box-sizing: border-box;
}
@media (min-width: 600px) {
  .pk-grid { grid-template-columns: repeat(4, 1fr); gap: 8px; }
}
@media (min-width: 960px) {
  .pk-grid { grid-template-columns: repeat(6, 1fr); gap: 10px; }
}

.pk-skeleton {
  display: flex;
  flex-direction: column;
}

.pk-item {
  display: flex;
  flex-direction: column;
}
.pk-item:hover .pk-img {
  opacity: 0.88;
}

.pk-thumb {
  position: relative;
  overflow: hidden;
  border-radius: 6px;
  background: #f0f0f0;
}
.pk-img {
  display: block;
  width: 100%;
  border-radius: 6px;
  transition: opacity 0.15s;
}
.pk-no-photo {
  aspect-ratio: 1 / 1;
  border-radius: 6px;
}

.pk-badge {
  position: absolute;
  bottom: 4px;
  left: 4px;
  background: rgba(0,0,0,0.5);
  color: #fff;
  font-size: 10px;
  padding: 1px 5px;
  border-radius: 8px;
  line-height: 1.6;
  pointer-events: none;
}
.pk-edit-btn {
  position: absolute;
  top: 4px;
  right: 4px;
  width: 24px;
  height: 24px;
  border: none;
  border-radius: 50%;
  background: rgba(255,255,255,0.85);
  color: #444;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  padding: 0;
  box-shadow: 0 1px 3px rgba(0,0,0,0.2);
}
.pk-edit-btn:hover {
  background: #fff;
}

.pk-label {
  font-size: 11px;
  color: #333;
  padding: 3px 2px 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.3;
}
</style>
