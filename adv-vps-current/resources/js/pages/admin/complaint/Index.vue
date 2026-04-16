<script setup>
import { computed, onMounted, reactive, ref, watch } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import { useQuasar, Notify, Dialog } from "quasar";
import axios from "axios";
import { formatDate } from "@/helpers/datetime";
import { create_year_options, create_month_options } from "@/helpers/utils";
import { usePageStorage } from "@/helpers/usePageStorage";
import useTableHeight from "@/composables/useTableHeight";

const page = usePage();
const $q = useQuasar();
const storage = usePageStorage("complaint-index");

const title = "Keluhan";
const showFilter = ref(storage.get("show-filter", true));
const loading = ref(false);
const rows = ref([]);
const tableRef = ref(null);
const filterToolbarRef = ref(null);
const previewImage = ref(null);
const previewImages = ref([]);
const previewIndex = ref(0);
const previewOpen = ref(false);
const tableHeight = useTableHeight(filterToolbarRef);

const filter = reactive(storage.get("filter", {
  search: "",
  status: "all",
  product_id: "all",
  bs_id: page.props.auth.user.role === "bs" ? page.props.auth.user.id : "all",
  year: "all",
  month: "all",
}));

const pagination = ref(storage.get("pagination", {
  page: 1,
  rowsPerPage: 15,
  rowsNumber: 0,
  sortBy: "id",
  descending: true,
}));

const statusOptions = [
  { value: "all", label: "Semua Status" },
  { value: "open", label: "Open" },
  { value: "in_progress", label: "In Progress" },
  { value: "resolved", label: "Resolved" },
  { value: "closed", label: "Closed" },
];

const severityOptions = [
  { value: "all", label: "Semua Severity" },
  { value: "low", label: "Low" },
  { value: "medium", label: "Medium" },
  { value: "high", label: "High" },
];

const categoryOptions = [
  { value: "all", label: "Semua Kategori" },
  { value: "rebah_semai", label: "Rebah Semai" },
  { value: "pertumbuhan_lambat", label: "Pertumbuhan Lambat" },
  { value: "keseragaman_jelek", label: "Keseragaman Jelek" },
  { value: "vigor_jelek", label: "Vigor Jelek" },
  { value: "daya_tumbuh_rendah", label: "Daya Tumbuh Rendah" },
  { value: "bulai", label: "Bulai" },
  { value: "busuk_batang", label: "Busuk Batang" },
  { value: "other", label: "Lainnya" },
];
const productOptions = computed(() => [
  { value: "all", label: "Semua Produk" },
  ...(page.props.products || []).map((p) => ({ value: p.id, label: p.name })),
]);

const bsOptions = computed(() => [
  { value: "all", label: "Semua BS" },
  ...(page.props.bs_users || []).map((u) => ({ value: u.id, label: `${u.name} (${u.username})` })),
]);

const yearNow = new Date().getFullYear();
const yearOptions = [{ value: "all", label: "Semua Tahun" }, ...create_year_options(yearNow - 2, yearNow + 1)];
const monthOptions = [{ value: "all", label: "Semua Bulan" }, ...create_month_options()];

const canRespond = computed(() => ["admin", "agronomist"].includes(page.props.auth.user.role));
const canManage = computed(() => ["admin", "agronomist"].includes(page.props.auth.user.role));
const isMobile = computed(() => $q.screen.lt.md);

const columns = [
  { name: "id", label: "#", field: "id", align: "left", sortable: true, style: "width: 48px" },
  { name: "created_datetime", label: "Tanggal", field: "created_datetime", align: "left", sortable: true },
  { name: "no_lot", label: "No Lot", field: "no_lot", align: "left" },
  { name: "title", label: "Keluhan", field: "title", align: "left" },
  { name: "reporter_name", label: "Petani / Bandar", field: "reporter_name", align: "left" },
  { name: "product", label: "Produk", field: "product", align: "left" },
  { name: "status", label: "Status", field: "status", align: "left" },
  { name: "bs", label: "BS", field: "bs", align: "left" },
  { name: "action", align: "right" },
];

const computedColumns = computed(() => {
  if ($q.screen.gt.sm) return columns;
  return columns.filter((c) => ["created_datetime", "action"].includes(c.name));
});

const statusColor = (status) => {
  if (status === "resolved" || status === "closed") return "positive";
  if (status === "in_progress") return "warning";
  return "grey-7";
};

const thumbnailUrl = (row) => {
  const imagePath = row?.images?.[0]?.image_path;
  if (!imagePath) return null;
  if (typeof imagePath === "string" && /^https?:\/\//i.test(imagePath)) {
    return imagePath;
  }
  return imagePath.startsWith("/") ? imagePath : `/${imagePath}`;
};

const imageUrls = (row) => {
  return (row?.images || [])
    .map((item) => item?.image_path)
    .filter(Boolean)
    .map((imagePath) => {
      if (typeof imagePath === "string" && /^https?:\/\//i.test(imagePath)) {
        return imagePath;
      }
      return imagePath.startsWith("/") ? imagePath : `/${imagePath}`;
    });
};

const imageCount = (row) => imageUrls(row).length;

const openPreview = (row) => {
  const urls = imageUrls(row);
  if (!urls.length) return;
  previewImages.value = urls;
  previewIndex.value = 0;
  previewImage.value = urls[0];
  previewOpen.value = true;
};

const showPreviewAt = (index) => {
  const target = previewImages.value[index] || null;
  if (!target) return;
  previewIndex.value = index;
  previewImage.value = target;
};

const showPrevImage = () => {
  if (previewIndex.value <= 0) return;
  showPreviewAt(previewIndex.value - 1);
};

const showNextImage = () => {
  if (previewIndex.value >= previewImages.value.length - 1) return;
  showPreviewAt(previewIndex.value + 1);
};

const severityColor = (severity) => {
  if (severity === "high") return "negative";
  if (severity === "medium") return "warning";
  return "primary";
};

const fetchItems = async (props = null) => {
  const source = props ? props.pagination : pagination.value;
  loading.value = true;
  try {
    const response = await axios.get(route("admin.complaint.data"), {
      params: {
        page: source.page,
        per_page: source.rowsPerPage,
        order_by: source.sortBy || "id",
        order_type: source.descending ? "desc" : "asc",
        filter,
      },
    });

    rows.value = response.data.data || [];
    pagination.value.page = response.data.current_page;
    pagination.value.rowsPerPage = response.data.per_page;
    pagination.value.rowsNumber = response.data.total;
    if (props) {
      pagination.value.sortBy = source.sortBy;
      pagination.value.descending = source.descending;
    }
  } finally {
    loading.value = false;
  }
};

const onFilterChange = () => {
  pagination.value.page = 1;
  fetchItems();
};

const respond = (row, status) => {
  Dialog.create({
    title: "Update Status Keluhan",
    message: `Ubah status keluhan #${row.id} menjadi ${status}?`,
    cancel: true,
    persistent: true,
  }).onOk(async () => {
    try {
      const res = await axios.post(route("admin.complaint.respond", row.id), { status });
      Notify.create({ color: "positive", message: res.data?.message || "Status diperbarui" });
      fetchItems();
    } catch (error) {
      Notify.create({ color: "negative", message: error?.response?.data?.message || "Gagal update status" });
    }
  });
};

const deleteItem = (row) => {
  Dialog.create({
    title: "Hapus Keluhan",
    message: `Hapus keluhan #${row.id}?`,
    cancel: true,
    persistent: true,
  }).onOk(async () => {
    try {
      const res = await axios.post(route("admin.complaint.delete", row.id));
      Notify.create({ color: "positive", message: res.data?.message || "Berhasil dihapus" });
      fetchItems();
    } catch (error) {
      Notify.create({ color: "negative", message: error?.response?.data?.message || "Gagal menghapus" });
    }
  });
};

onMounted(fetchItems);

watch(filter, () => storage.set("filter", filter), { deep: true });
watch(showFilter, () => storage.set("show-filter", showFilter.value));
watch(pagination, () => storage.set("pagination", pagination.value), { deep: true });
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>

    <template #right-button>
      <q-btn icon="add" dense color="primary" v-if="$can('admin.complaint.add')" @click="router.get(route('admin.complaint.add'))" />
      <q-btn class="q-ml-sm" icon="insights" dense color="primary" v-if="$can('admin.complaint.analytics')" @click="router.get(route('admin.complaint.analytics'))" />
      <q-btn class="q-ml-sm" icon="file_download" dense color="grey" v-if="$can('admin.complaint.export')" :href="route('admin.complaint.export', { filter })" />
      <q-btn class="q-ml-sm" :icon="showFilter ? 'filter_alt_off' : 'filter_alt'" color="grey" dense @click="showFilter = !showFilter" />
    </template>

    <template #header v-if="showFilter">
      <q-toolbar class="filter-bar" ref="filterToolbarRef">
        <div class="row q-col-gutter-xs items-center q-pa-sm full-width">
          <q-select class="custom-select col-xs-6 col-sm-2" outlined dense map-options emit-value
            v-model="filter.status" :options="statusOptions" label="Status"
            @update:model-value="onFilterChange" />
          <q-select class="custom-select col-xs-6 col-sm-2" outlined dense map-options emit-value
            v-model="filter.product_id" :options="productOptions" label="Produk"
            @update:model-value="onFilterChange" />
          <q-select class="custom-select col-xs-6 col-sm-2" outlined dense map-options emit-value
            v-model="filter.year" :options="yearOptions" label="Tahun"
            @update:model-value="onFilterChange" />
          <q-select class="custom-select col-xs-6 col-sm-2" outlined dense map-options emit-value
            v-model="filter.month" :options="monthOptions" label="Bulan"
            @update:model-value="onFilterChange" />
          <q-select class="custom-select col-xs-12 col-sm-2" outlined dense map-options emit-value
            v-model="filter.bs_id" :options="bsOptions" label="BS"
            v-if="$page.props.auth.user.role !== 'bs'"
            @update:model-value="onFilterChange" />
          <q-input class="col" outlined dense debounce="300" v-model="filter.search"
            placeholder="Cari keluhan / petani / bandar" clearable>
            <template #append><q-icon name="search" /></template>
          </q-input>
        </div>
      </q-toolbar>
    </template>

    <div class="q-pa-sm">
      <q-table
        ref="tableRef"
        :style="{ height: tableHeight }"
        class="full-height-table complaint-table"
        flat bordered square
        row-key="id"
        virtual-scroll
        :grid="isMobile"
        :hide-header="isMobile"
        v-model:pagination="pagination"
        :loading="loading"
        :columns="columns"
        :rows="rows"
        :rows-per-page-options="[10, 15, 25, 50]"
        @request="fetchItems"
        binary-state-sort
      >
        <template #loading><q-inner-loading showing color="primary" /></template>

        <!-- Mobile card -->
        <template #item="props">
          <div class="col-12 mobile-card-wrap">
            <q-card flat bordered class="complaint-card cursor-pointer"
              @click="router.get(route('admin.complaint.detail', props.row.id))">
              <q-card-section class="q-pa-sm">
                <div class="row items-start justify-between no-wrap q-mb-xs">
                  <div class="col ellipsis">
                    <span class="text-caption text-grey-6 q-mr-xs">#{{ props.row.id }}</span>
                    <span class="text-weight-bold">{{ props.row.title }}</span>
                  </div>
                  <q-badge class="q-ml-sm flex-shrink-0" :color="statusColor(props.row.status)">
                    {{ props.row.status }}
                  </q-badge>
                </div>
                <div class="card-body-row">
                  <div v-if="thumbnailUrl(props.row)" class="thumb-wrap" @click.stop="openPreview(props.row)">
                    <q-img
                      :src="thumbnailUrl(props.row)"
                      class="thumb-img"
                      fit="cover"
                      spinner-color="primary"
                    />
                    <div v-if="imageCount(props.row) > 1" class="thumb-count">+{{ imageCount(props.row) - 1 }}</div>
                  </div>
                  <div class="info-grid">
                  <div class="info-row">
                    <span class="ilabel">No Lot</span>
                    <span class="ivalue fw-bold">{{ props.row.batch?.batch_number || '-' }}</span>
                  </div>
                  <div class="info-row">
                    <span class="ilabel">Petani/Bandar</span>
                    <span class="ivalue">{{ props.row.reporter_name || '-' }}</span>
                  </div>
                  <div class="info-row">
                    <span class="ilabel">Produk</span>
                    <span class="ivalue">{{ props.row.product?.name || props.row.product_name || '-' }}</span>
                  </div>
                  <div class="info-row">
                    <span class="ilabel">BS</span>
                    <span class="ivalue">{{ props.row.bs?.name || '-' }}</span>
                    <span class="text-caption text-grey-6 q-ml-auto">{{ formatDate(props.row.created_datetime) }}</span>
                  </div>
                  </div>
                </div>
              </q-card-section>
              <q-separator />
              <q-card-actions class="q-pa-xs q-gutter-xs" @click.stop>
                <q-btn flat dense icon="edit" size="sm"
                  v-if="canManage"
                  @click="router.get(route('admin.complaint.edit', props.row.id))" />
                <q-btn flat dense icon="check_circle" size="sm" color="positive"
                  v-if="canRespond" @click="respond(props.row, 'resolved')" />
                <q-btn flat dense icon="autorenew" size="sm" color="warning"
                  v-if="canRespond" @click="respond(props.row, 'in_progress')" />
                <q-btn flat dense icon="delete_forever" size="sm" color="negative"
                  v-if="canManage" @click="deleteItem(props.row)" />
              </q-card-actions>
            </q-card>
          </div>
        </template>

        <!-- Desktop row -->
        <template #body="props">
          <q-tr :props="props" class="cursor-pointer"
            @click="router.get(route('admin.complaint.detail', props.row.id))">
            <q-td key="id" :props="props" class="text-caption text-grey-6">#{{ props.row.id }}</q-td>
            <q-td key="created_datetime" :props="props" style="white-space:nowrap">
              {{ formatDate(props.row.created_datetime) }}
            </q-td>
            <q-td key="no_lot" :props="props">
              <b>{{ props.row.batch?.batch_number || '-' }}</b>
            </q-td>
            <q-td key="title" :props="props">
              <div class="desktop-title-cell">
                <div v-if="thumbnailUrl(props.row)" class="desktop-thumb-wrap" @click.stop="openPreview(props.row)">
                  <q-img :src="thumbnailUrl(props.row)" class="desktop-thumb" fit="cover" spinner-color="primary" />
                  <div v-if="imageCount(props.row) > 1" class="desktop-thumb-count">{{ imageCount(props.row) }}</div>
                </div>
                <div class="desktop-title-text">{{ props.row.title }}</div>
              </div>
            </q-td>
            <q-td key="reporter_name" :props="props">{{ props.row.reporter_name || '-' }}</q-td>
            <q-td key="product" :props="props">
              {{ props.row.product?.name || props.row.product_name || '-' }}
            </q-td>
            <q-td key="status" :props="props">
              <q-badge :color="statusColor(props.row.status)">{{ props.row.status }}</q-badge>
            </q-td>
            <q-td key="bs" :props="props">{{ props.row.bs?.name || '-' }}</q-td>
            <q-td key="action" :props="props" @click.stop>
              <q-btn flat dense icon="edit" size="sm"
                v-if="canManage"
                @click="router.get(route('admin.complaint.edit', props.row.id))" />
              <q-btn flat dense icon="check_circle" size="sm" color="positive"
                v-if="canRespond" @click="respond(props.row, 'resolved')" />
              <q-btn flat dense icon="autorenew" size="sm" color="warning"
                v-if="canRespond" @click="respond(props.row, 'in_progress')" />
              <q-btn flat dense icon="delete_forever" size="sm" color="negative"
                v-if="canManage" @click="deleteItem(props.row)" />
            </q-td>
          </q-tr>
        </template>
      </q-table>
    </div>

    <q-dialog v-model="previewOpen" maximized @hide="previewImage = null; previewImages = []; previewIndex = 0">
      <q-card class="preview-card bg-black text-white">
        <q-card-actions align="right" class="preview-actions">
          <div class="preview-counter" v-if="previewImages.length > 1">{{ previewIndex + 1 }} / {{ previewImages.length }}</div>
          <q-space />
          <q-btn flat round dense icon="close" color="white" v-close-popup />
        </q-card-actions>
        <q-card-section class="preview-body">
          <q-btn
            v-if="previewImages.length > 1"
            flat round dense icon="chevron_left" color="white"
            class="preview-nav preview-nav-left"
            :disable="previewIndex === 0"
            @click="showPrevImage"
          />
          <q-img v-if="previewImage" :src="previewImage" fit="contain" class="preview-img" />
          <q-btn
            v-if="previewImages.length > 1"
            flat round dense icon="chevron_right" color="white"
            class="preview-nav preview-nav-right"
            :disable="previewIndex === previewImages.length - 1"
            @click="showNextImage"
          />
        </q-card-section>
      </q-card>
    </q-dialog>
  </authenticated-layout>
</template>

<style scoped>
.mobile-card-wrap {
  padding: 4px 0;
}

.complaint-card {
  width: 100%;
  margin: 0;
  border-radius: 10px;
}

.complaint-table :deep(.q-table__grid-content) {
  padding: 0;
}

.complaint-table :deep(.q-table__grid-item) {
  width: 100%;
}

.info-grid {
  display: flex;
  flex-direction: column;
  gap: 3px;
  min-width: 0;
  flex: 1;
}

.card-body-row {
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.thumb-wrap {
  position: relative;
  cursor: zoom-in;
}

.thumb-img {
  width: 76px;
  height: 76px;
  min-width: 76px;
  border-radius: 8px;
  overflow: hidden;
}

.thumb-count {
  position: absolute;
  right: 6px;
  bottom: 6px;
  background: rgba(17, 24, 39, 0.78);
  color: #fff;
  border-radius: 999px;
  padding: 2px 6px;
  font-size: 10px;
  line-height: 1.2;
}

.desktop-title-cell {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

.desktop-thumb-wrap {
  position: relative;
  flex-shrink: 0;
  cursor: zoom-in;
}

.desktop-thumb {
  width: 42px;
  height: 42px;
  border-radius: 8px;
  overflow: hidden;
}

.desktop-thumb-count {
  position: absolute;
  right: -4px;
  top: -4px;
  min-width: 18px;
  height: 18px;
  padding: 0 4px;
  border-radius: 999px;
  background: #1f2937;
  color: #fff;
  font-size: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.desktop-title-text {
  min-width: 0;
  word-break: break-word;
}

.preview-card {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.preview-actions {
  padding: 10px;
}

.preview-counter {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.9);
}

.preview-body {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 12px;
  position: relative;
}

.preview-img {
  width: 100%;
  height: 100%;
}

.preview-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  z-index: 2;
  background: rgba(17, 24, 39, 0.45);
}

.preview-nav-left {
  left: 12px;
}

.preview-nav-right {
  right: 12px;
}

.info-row {
  display: flex;
  align-items: baseline;
  font-size: 12px;
  gap: 4px;
}

.ilabel {
  min-width: 90px;
  color: #6b7280;
  flex-shrink: 0;
  font-size: 11px;
}

.ivalue {
  color: #111827;
  word-break: break-word;
}

.fw-bold {
  font-weight: 700;
}
</style>
