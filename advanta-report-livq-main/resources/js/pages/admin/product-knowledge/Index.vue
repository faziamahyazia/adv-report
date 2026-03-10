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
    <div class="pk-filter-bar q-pa-sm row q-col-gutter-xs">
      <div class="col-7 col-sm-5 col-md-4">
        <q-input
          v-model="filter.search"
          dense
          outlined
          placeholder="Cari varietas..."
          clearable
          bg-color="white"
        >
          <template #prepend><q-icon name="search" size="18px" /></template>
        </q-input>
      </div>
      <div class="col-5 col-sm-4 col-md-3">
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

    <!-- Loading skeletons -->
    <div v-if="loading" class="q-pa-sm row q-col-gutter-sm">
      <div
        v-for="n in 8"
        :key="n"
        class="col-6 col-sm-4 col-md-3 col-lg-2"
      >
        <q-card flat bordered class="pk-card">
          <q-skeleton height="140px" square />
          <q-card-section class="q-pa-xs q-pt-sm">
            <q-skeleton type="text" width="70%" />
            <q-skeleton type="text" width="50%" class="q-mt-xs" />
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Empty state -->
    <div v-else-if="products.length === 0" class="q-pa-xl text-center text-grey-6">
      <q-icon name="photo_library" size="56px" class="q-mb-sm" />
      <div class="text-subtitle2">Tidak ada varietas ditemukan.</div>
    </div>

    <!-- Card grid -->
    <div v-else class="q-pa-sm row q-col-gutter-sm">
      <div
        v-for="product in products"
        :key="product.id"
        class="col-6 col-sm-4 col-md-3 col-lg-2"
      >
        <q-card
          flat
          bordered
          class="pk-card cursor-pointer"
          @click="goGallery(product)"
        >
          <!-- Thumbnail with overlay -->
          <div class="thumb-wrap">
            <q-img
              v-if="product.photos && product.photos.length > 0"
              :src="'/' + product.photos[0].image_path"
              ratio="1"
              class="thumb-img"
              loading="lazy"
            >
              <template #error>
                <div class="absolute-full flex flex-center bg-grey-2">
                  <q-icon name="image_not_supported" size="32px" color="grey-5" />
                </div>
              </template>
            </q-img>
            <div v-else class="thumb-placeholder flex flex-center bg-grey-2">
              <q-icon name="add_photo_alternate" size="36px" color="grey-5" />
            </div>

            <!-- Photo count badge -->
            <div class="photo-badge">
              <q-icon name="image" size="12px" />
              {{ product.photos_count }}
            </div>

            <!-- Admin edit button overlay -->
            <q-btn
              v-if="canEdit"
              class="edit-overlay"
              round
              unelevated
              size="sm"
              color="white"
              text-color="primary"
              icon="edit"
              title="Kelola Foto"
              @click="goEditor(product, $event)"
            />
          </div>

          <!-- Info -->
          <q-card-section class="q-pa-xs q-pt-sm">
            <div class="text-caption text-bold ellipsis pk-name">{{ product.name }}</div>
            <div class="text-caption text-grey-6 ellipsis" style="font-size:11px">
              {{ product.category?.name ?? "—" }}
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </AuthenticatedLayout>
</template>

<style scoped>
.pk-filter-bar {
  background: #f5f7fa;
  border-bottom: 1px solid #e8eaed;
}
.pk-card {
  border-radius: 10px;
  transition: box-shadow 0.18s, transform 0.18s;
  overflow: hidden;
}
.pk-card:hover {
  box-shadow: 0 4px 18px rgba(0,0,0,0.13);
  transform: translateY(-2px);
}
.thumb-wrap {
  position: relative;
  overflow: hidden;
}
.thumb-img {
  display: block;
}
.thumb-placeholder {
  height: 130px;
}
.photo-badge {
  position: absolute;
  bottom: 6px;
  left: 6px;
  background: rgba(0,0,0,0.55);
  color: #fff;
  font-size: 11px;
  padding: 2px 7px 2px 5px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  gap: 3px;
  line-height: 1;
}
.edit-overlay {
  position: absolute;
  top: 5px;
  right: 5px;
  opacity: 0.9;
  box-shadow: 0 1px 4px rgba(0,0,0,0.25);
}
.pk-name {
  font-size: 12px;
  line-height: 1.3;
}
</style>
