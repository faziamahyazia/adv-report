<script setup>
import axios from "axios";
import { computed, onMounted, reactive, ref } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import { handleDelete, handleFetchItems } from "@/helpers/client-req-handler";
import { getQueryParams } from "@/helpers/utils";
import { Notify, useQuasar } from "quasar";
import dayjs from "dayjs";
import useTableHeight from "@/composables/useTableHeight";

const $q = useQuasar();
const rows = ref([]);
const loading = ref(true);
const page = usePage();
const tableRef = ref(null);
const filterToolbarRef = ref(null);
const tableHeight = useTableHeight(filterToolbarRef, 165);
const filter = reactive({
  ...getQueryParams(),
});

const pagination = ref({
  page: 1,
  rowsPerPage: 10,
  rowsNumber: 10,
  sortBy: "visit_date",
  descending: true,
});

const PLANT_STATUS_COLORS = {
  not_yet_planted: "grey",
  not_yet_evaluated: "grey",
  satisfactory: "green",
  unsatisfactory: "red",
  failed: "black",
  completed: "blue",
};

const columns = [
  {
    name: "visit_date",
    label: "Tanggal",
    field: "visit_date",
    align: "left",
    sortable: true,
  },
  { name: "user", label: "BS", field: "user", align: "left" },
  { name: "status", label: "Status", field: "status", align: "left" },
  { name: "notes", label: "Catatan", field: "notes", align: "left" },
  { name: "action", align: "right" },
];

onMounted(() => fetchItems());

const deleteItem = (row) =>
  handleDelete({
    message: `Hapus kunjungan #${row.id} - ${dayjs(row.visit_date).format(
      "D MMMM YYYY"
    )}?`,
    url: route("admin.demo-plot-visit.delete", row.id),
    fetchItemsCallback: fetchItems,
    loading,
  });

const fetchItems = (props = null) =>
  handleFetchItems({
    pagination,
    filter,
    props,
    rows,
    url: route("admin.demo-plot-visit.data", {
      demo_plot_id: page.props.data.id,
    }),
    loading,
    tableRef,
  });

const onRowClicked = (row) =>
  router.get(route("admin.demo-plot-visit.detail", { id: row.id }));

const canSetCover = computed(() => {
  const role = page.props.auth?.user?.role;
  if (role === 'admin') return true;
  if (role === 'bs') return Number(page.props.auth?.user?.id) === Number(page.props.data.user_id);
  if (role === 'agronomist') return Number(page.props.auth?.user?.id) === Number(page.props.data.user?.parent_id);
  return false;
});

const setAsCoverPhoto = async (row) => {
  if (!row?.image_path || !canSetCover.value) return;

  try {
    const response = await axios.post(route('admin.demo-plot.cover-photo', { id: page.props.data.id }), {
      source: 'visit',
      visit_id: row.id,
    });

    Notify.create({ color: 'positive', message: response.data?.message || 'Foto depan berhasil diperbarui.' });
    router.reload({ only: ['data'] });
  } catch (error) {
    Notify.create({
      color: 'negative',
      message: error?.response?.data?.message || error?.response?.data?.errors?.visit_id?.[0] || 'Gagal memperbarui foto depan.',
    });
  }
};

const computedColumns = computed(() =>
  $q.screen.gt.sm
    ? columns
    : columns.filter((col) => ["visit_date", "action"].includes(col.name))
);
</script>

<template>
  <div class="q-pa-none">
    <div class="q-pa-sm">
      <q-btn
        label="Tambah&nbsp;&nbsp;"
        color="primary"
        size="sm"
        icon="add"
        dense
        v-if="$can('admin.demo-plot-visit.add')"
        @click="
          router.get(
            route('admin.demo-plot-visit.add', {
              demo_plot_id: page.props.data.id,
            })
          )
        "
      />
    </div>
    <q-table
      ref="tableRef"
      :style="{ height: tableHeight }"
      class="full-height-table"
      flat
      bordered
      square
      color="primary"
      row-key="id"
      virtual-scroll
      v-model:pagination="pagination"
      :filter="filter.search"
      :loading="loading"
      :columns="computedColumns"
      :rows="rows"
      :rows-per-page-options="[10, 25, 50]"
      @request="fetchItems"
      binary-state-sort
    >
      <template v-slot:loading>
        <q-inner-loading showing color="red" />
      </template>

      <template v-slot:no-data="{ icon, message, filter }">
        <div class="full-width row flex-center text-grey-8 q-gutter-sm">
          <span>
            {{ message }}
            {{ filter ? " with term " + filter : "" }}
          </span>
        </div>
      </template>

      <template v-slot:body="props">
        <q-tr
          :props="props"
          :class="props.row.active == 'inactive' ? 'bg-red-1' : ''"
          class="cursor-pointer"
          @click="onRowClicked(props.row)"
        >
          <q-td key="visit_date" :props="props" class="wrap-column">
            <div v-if="!$q.screen.lt.md" class="row items-start q-gutter-sm">
              <q-img
                v-if="props.row.image_path"
                :src="`/${props.row.image_path}`"
                style="width: 64px; height: 64px; border: 1px solid #ddd"
                spinner-color="grey"
                fit="cover"
                class="rounded-borders"
              />
              <div class="column">
                {{ $dayjs(props.row.visit_date).format("D MMMM YYYY") }}
                <div class="text-caption text-italic text-grey-8">
                  {{ $dayjs(props.row.visit_date).fromNow() }}
                </div>
              </div>
            </div>
            <div v-else>
              <template v-if="$q.screen.lt.md">
                <q-icon class="mobile-demo-icon" name="history" />
              </template>
              {{ $dayjs(props.row.visit_date).format("D MMMM YYYY") }}
              <div class="text-caption text-italic text-grey-8">
                {{ $dayjs(props.row.visit_date).fromNow() }}
              </div>
            </div>
            <template v-if="$q.screen.lt.md">
              <q-img
                v-if="props.row.image_path"
                :src="`/${props.row.image_path}`"
                style="border: 1px solid #ddd; max-height: 150px"
                spinner-color="grey"
                fit="scale-down"
                class="rounded-borders bg-light-green-2"
              />
              <div class="text-subtitle2">
                <q-icon class="mobile-demo-icon" name="person" /> {{ props.row.user.name }} -
                {{ props.row.user.username }}
              </div>
              <div>
                <q-badge :color="PLANT_STATUS_COLORS[props.row.plant_status]">
                  {{
                    $CONSTANTS.DEMO_PLOT_PLANT_STATUSES[props.row.plant_status]
                  }}
                </q-badge>
              </div>
              <div
                v-if="props.row.notes"
                style="
                  white-space: pre-wrap;
                  word-break: break-word;
                  overflow-wrap: break-word;
                "
              >
                <q-icon class="mobile-demo-icon" name="notes" /> {{ props.row.notes }}
              </div>
            </template>
          </q-td>
          <q-td key="user" :props="props">
            {{ props.row.user.name }}
          </q-td>
          <q-td key="status" :props="props">
            <q-badge :color="PLANT_STATUS_COLORS[props.row.plant_status]">
              {{ $CONSTANTS.DEMO_PLOT_PLANT_STATUSES[props.row.plant_status] }}
            </q-badge>
          </q-td>
          <q-td key="notes" :props="props">
            <div
              v-if="props.row.notes"
              style="
                white-space: pre-wrap;
                word-break: break-word;
                overflow-wrap: break-word;
              "
            >
              {{
                props.row.notes.length > 100
                  ? props.row.notes.slice(0, 100) + "..."
                  : props.row.notes
              }}
            </div>
          </q-td>
          <q-td key="action" :props="props">
            <div
              class="flex justify-end"
              v-if="
                $can('admin.demo-plot-visit.edit') ||
                $can('admin.demo-plot-visit.delete')
              "
            >
              <q-btn
                icon="more_vert"
                dense
                flat
                style="height: 40px; width: 30px"
                @click.stop
              >
                <q-menu
                  anchor="bottom right"
                  self="top right"
                  transition-show="scale"
                  transition-hide="scale"
                >
                  <q-list style="width: 200px">
                    <q-item
                      v-if="canSetCover && props.row.image_path"
                      clickable
                      v-ripple
                      v-close-popup
                      @click.stop="setAsCoverPhoto(props.row)"
                    >
                      <q-item-section avatar>
                        <q-icon name="image" />
                      </q-item-section>
                      <q-item-section>Jadikan Foto Depan</q-item-section>
                    </q-item>
                    <q-item
                      v-if="$can('admin.demo-plot-visit.edit')"
                      clickable
                      v-ripple
                      v-close-popup
                      @click.stop="
                        router.get(
                          route('admin.demo-plot-visit.edit', props.row.id)
                        )
                      "
                    >
                      <q-item-section avatar>
                        <q-icon name="edit" />
                      </q-item-section>
                      <q-item-section icon="edit">Edit</q-item-section>
                    </q-item>
                    <q-item
                      v-if="$can('admin.demo-plot-visit.delete')"
                      @click.stop="deleteItem(props.row)"
                      clickable
                      v-ripple
                      v-close-popup
                    >
                      <q-item-section avatar>
                        <q-icon name="delete_forever" />
                      </q-item-section>
                      <q-item-section>Hapus</q-item-section>
                    </q-item>
                  </q-list>
                </q-menu>
              </q-btn>
            </div>
          </q-td>
        </q-tr>
      </template>
    </q-table>
  </div>
</template>
