<script setup>
import axios from "axios";
import { router, usePage } from "@inertiajs/vue3";
import { computed, ref } from "vue";
import { formatNumber, plantAge, wa_send_url } from "@/helpers/utils";
import ImageViewer from "@/components/ImageViewer.vue";
import { Notify } from "quasar";
const page = usePage();
const showViewer = ref(false);
const coverImageFile = ref(null);
const savingCover = ref(false);

const coverImagePath = computed(() => page.props.data.image_path || page.props.data.latest_visit_image_path || null);

const canChangeCoverPhoto = computed(() => {
  const role = page.props.auth?.user?.role;
  if (role === 'admin') return true;
  if (role === 'bs') return Number(page.props.auth?.user?.id) === Number(page.props.data.user_id);
  if (role === 'agronomist') return Number(page.props.auth?.user?.id) === Number(page.props.data.user?.parent_id);
  return false;
});

const submitCoverPhoto = async (source, visitId = null) => {
  if (!canChangeCoverPhoto.value) return;

  if (source === 'upload' && !coverImageFile.value) {
    Notify.create({ color: 'warning', message: 'Pilih foto dari galeri terlebih dahulu.' });
    return;
  }

  savingCover.value = true;
  try {
    const formData = new FormData();
    formData.append('source', source);
    if (visitId) formData.append('visit_id', String(visitId));
    if (source === 'upload' && coverImageFile.value) {
      formData.append('image', coverImageFile.value);
    }

    const response = await axios.post(route('admin.demo-plot.cover-photo', { id: page.props.data.id }), formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });

    Notify.create({ color: 'positive', message: response.data?.message || 'Foto depan berhasil diperbarui.' });
    coverImageFile.value = null;
    router.reload({ only: ['data'] });
  } catch (error) {
    Notify.create({
      color: 'negative',
      message: error?.response?.data?.message || error?.response?.data?.errors?.image?.[0] || error?.response?.data?.errors?.visit_id?.[0] || 'Gagal memperbarui foto depan.',
    });
  } finally {
    savingCover.value = false;
  }
};

const onCoverFileChange = (event) => {
  const file = event?.target?.files?.[0];
  coverImageFile.value = file || null;
};
</script>

<template>
  <table class="detail">
    <tbody>
      <tr>
        <td style="width: 100px">BS</td>
        <td>:</td>
        <td>
          <template v-if="page.props.data.user">
            <my-link
              :href="
                route('admin.user.detail', { id: page.props.data.user.id })
              "
            >
              {{
                page.props.data.user.name +
                " - " +
                page.props.data.user.username
              }}
            </my-link>
          </template>
          <template v-else> - </template>
        </td>
      </tr>
      <tr>
        <td>Varietas</td>
        <td>:</td>
        <td>{{ page.props.data.product.name }}</td>
      </tr>
      <tr>
        <td>Tgl Tanam</td>
        <td>:</td>
        <td>
          {{ $dayjs(page.props.data.plant_date).fromNow() }} -
          {{ $dayjs(page.props.data.plant_date).format("DD MMMM YYYY") }}
          <template v-if="page.props.data.active">
            <br />
            ({{ plantAge(page.props.data.plant_date) }} hari)
          </template>
        </td>
      </tr>
      <tr>
        <td>Pemilik</td>
        <td>:</td>
        <td>{{ page.props.data.owner_name }}</td>
      </tr>
      <tr>
        <td>No Telepon</td>
        <td>:</td>
        <td>
          <a
            v-if="page.props.data.owner_name"
            target="_blank"
            :href="wa_send_url(page.props.data.owner_phone)"
          >
            {{ page.props.data.owner_phone }}
          </a>
        </td>
      </tr>
      <tr>
        <td>Lokasi</td>
        <td>:</td>
        <td>{{ page.props.data.field_location }}</td>
      </tr>
      <tr>
        <td>Populasi</td>
        <td>:</td>
        <td>{{ formatNumber(page.props.data.population) }} pohon</td>
      </tr>
      <tr>
        <td>Biji per pcs</td>
        <td>:</td>
        <td>{{ page.props.data.product?.jumlah_biji_per_pcs ? formatNumber(page.props.data.product.jumlah_biji_per_pcs) : '-' }}</td>
      </tr>
      <tr>
        <td>Status Terkini</td>
        <td>:</td>
        <td>
          {{
            $CONSTANTS.DEMO_PLOT_PLANT_STATUSES[page.props.data.plant_status]
          }}
        </td>
      </tr>
      <tr>
        <td>Last Visit</td>
        <td>:</td>
        <td>
          <template v-if="page.props.data.last_visit">
            {{ $dayjs(page.props.data.last_visit).format("D MMMM YYYY") }}<br />
            {{ $dayjs(page.props.data.last_visit).fromNow() }}
          </template>
          <template v-else>
            <span>Belum pernah</span>
          </template>
          <!-- <br>
          <q-btn label="Buat Kunjungan" color="secondary" size="sm" icon="add"
            @click="router.get(route('admin.demo-plot-visit.add', { demo_plot_id: page.props.data.id }))" /> -->
        </td>
      </tr>
      <tr>
        <td>Status</td>
        <td>:</td>
        <td>{{ page.props.data.active ? "Aktif" : "Tidak Aktif" }}</td>
      </tr>
      <tr>
        <td>Catatan</td>
        <td>:</td>
        <td>{{ page.props.data.notes ? page.props.data.notes : "" }}</td>
      </tr>
      <template v-if="coverImagePath">
        <tr>
          <td colspan="3" class="bg-white">
            <div class="q-mt-md">
              Foto Depan Demo Plot:<br />
              <q-img
                :src="`/${coverImagePath}`"
                class="q-mt-none"
                style="max-width: 500px"
                :style="{ border: '1px solid #ddd' }"
                @click="showViewer = true"
              />
              <div v-if="canChangeCoverPhoto" class="q-mt-sm q-gutter-sm">
                <input
                  type="file"
                  accept="image/*"
                  class="q-mb-sm"
                  @change="onCoverFileChange"
                />
                <div class="row q-gutter-sm">
                  <q-btn
                    color="primary"
                    size="sm"
                    icon="photo_library"
                    label="Set dari Galeri"
                    :loading="savingCover"
                    @click="submitCoverPhoto('upload')"
                  />
                  <q-btn
                    color="secondary"
                    size="sm"
                    icon="restart_alt"
                    label="Kembali ke Default"
                    :loading="savingCover"
                    @click="submitCoverPhoto('reset')"
                  />
                </div>
              </div>
            </div>
          </td>
        </tr>
      </template>
      <template v-if="page.props.data.latlong">
        <tr>
          <td colspan="3" class="bg-white">
            <div class="q-mt-md">
              Lokasi:<br />
              {{ page.props.data.latlong }}<br />
              <div style="max-width: 500px">
                <iframe
                  :src="`https://www.google.com/maps?q=${encodeURIComponent(
                    page.props.data.latlong
                  )}&output=embed`"
                  width="100%"
                  height="300"
                  style="border: 1px solid #ddd; margin-top: 10px"
                  allowfullscreen
                  loading="lazy"
                  referrerpolicy="no-referrer-when-downgrade"
                ></iframe>
              </div>
            </div>
          </td>
        </tr>
      </template>
      <tr>
        <td colspan="3" class="bg-white">
          <div class="text-bold text-grey-8 q-mt-md">Informasi Rekaman</div>
        </td>
      </tr>
      <tr>
        <td style="width: 100px">ID</td>
        <td style="width: 1px">:</td>
        <td>#{{ page.props.data.id }}</td>
      </tr>
      <tr v-if="page.props.data.created_datetime">
        <td>Dibuat</td>
        <td>:</td>
        <td>
          {{ $dayjs(page.props.data.created_datetime).fromNow() }} -
          {{
            $dayjs(page.props.data.created_datetime).format(
              "DD MMMM YY HH:mm:ss"
            )
          }}
          <template v-if="page.props.data.created_by_user">
            oleh
            <my-link
              :href="
                route('admin.user.detail', {
                  id: page.props.data.created_by_user.id,
                })
              "
            >
              {{ page.props.data.created_by_user.username }}
            </my-link>
          </template>
        </td>
      </tr>
      <tr v-if="page.props.data.updated_datetime">
        <td>Diperbarui</td>
        <td>:</td>
        <td>
          {{ $dayjs(page.props.data.updated_datetime).fromNow() }} -
          {{
            $dayjs(page.props.data.updated_datetime).format(
              "DD MMMM YY HH:mm:ss"
            )
          }}
          <template v-if="page.props.data.updated_by_user">
            oleh
            <my-link
              :href="
                route('admin.user.detail', {
                  id: page.props.data.updated_by_user.id,
                })
              "
            >
              {{ page.props.data.updated_by_user.username }}
            </my-link>
          </template>
        </td>
      </tr>
    </tbody>
  </table>

  <ImageViewer
    v-model="showViewer"
    :imageUrl="`/${coverImagePath}`"
  />
</template>
