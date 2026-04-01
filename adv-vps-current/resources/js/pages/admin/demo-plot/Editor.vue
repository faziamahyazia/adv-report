<script setup>
import { useForm, usePage } from "@inertiajs/vue3";
import { handleSubmit } from "@/helpers/client-req-handler";
import { scrollToFirstErrorField } from "@/helpers/utils";
import DatePicker from "@/components/DatePicker.vue";
import dayjs from "dayjs";
import { ref, onMounted, computed, watch } from "vue";
import LocaleNumberInput from "@/components/LocaleNumberInput.vue";

const page = usePage();
const title = (!!page.props.data.id ? "Edit" : "Tambah") + " Demo Plot";
// const plant_statuses = Object.entries(
//   window.CONSTANTS.DEMO_PLOT_PLANT_STATUSES
// ).map(([value, label]) => ({
//   label,
//   value,
// }));

const users = page.props.users.map((user) => ({
  value: user.id,
  label: `${user.name} (${user.username})`,
}));

const products = page.props.products.map((product) => ({
  value: product.id,
  label: `${product.name}`,
  jumlah_biji_per_pcs: Number(product.jumlah_biji_per_pcs || 0),
}));

const existingPopulation = Number(page.props.data.population || 0);
const existingSeedPerPcs = Number(
  page.props.products.find((p) => Number(p.id) === Number(page.props.data.product_id))
    ?.jumlah_biji_per_pcs || 0
);
const estimatedPcs = existingSeedPerPcs > 0 ? Math.ceil(existingPopulation / existingSeedPerPcs) : null;

const form = useForm({
  id: page.props.data.id,
  user_id: page.props.data.user_id ? Number(page.props.data.user_id) : null,
  product_id: page.props.data.product_id
    ? Number(page.props.data.product_id)
    : null,
  owner_name: page.props.data.owner_name,
  owner_phone: page.props.data.owner_phone,
  field_location: page.props.data.field_location,
  population_pcs: estimatedPcs,
  population: page.props.data.population,
  plant_date: dayjs(page.props.data.plant_date).format("YYYY-MM-DD"),
  // plant_status: page.props.data.plant_status,
  notes: page.props.data.notes,
  active: !!page.props.data.active,
  latlong: page.props.data.latlong,
  image_path: page.props.data.image_path,
  image: null,
});

const selectedProduct = computed(() => {
  return products.find((item) => Number(item.value) === Number(form.product_id || 0));
});

const seedPerPcs = computed(() => Number(selectedProduct.value?.jumlah_biji_per_pcs || 0));

const estimatedPopulation = computed(() => {
  const pcs = Number(form.population_pcs || 0);
  if (pcs <= 0 || seedPerPcs.value <= 0) {
    return 0;
  }
  return pcs * seedPerPcs.value;
});

watch(
  () => form.population_pcs,
  () => {
    form.population = estimatedPopulation.value;
  }
);

watch(
  () => form.product_id,
  () => {
    form.population = estimatedPopulation.value;
  }
);

const submit = () =>
  handleSubmit({
    form,
    forceFormData: true,
    url: route("admin.demo-plot.save"),
  });

const fileInput = ref(null);
const imagePreview = ref("");

function triggerInput() {
  fileInput.value.click();
}

function onFileChange(event) {
  const file = event.target.files[0];
  if (file) {
    form.image = file;
    imagePreview.value = URL.createObjectURL(file);
  }
}

function updateLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        form.latlong = `${position.coords.latitude},${position.coords.longitude}`;
      },
      (error) => {
        alert("Gagal mendapatkan lokasi: " + error.message);
      }
    );
  } else {
    alert("Geolocation tidak didukung browser ini.");
  }
}

onMounted(() => {
  // if (!form.id) {
  //   updateLocation();
  // }

  if (form.image_path) {
    imagePreview.value = `/${form.image_path}`;
  }
});

function clearImage() {
  form.image = null;
  form.image_path = null;
  imagePreview.value = null;
  fileInput.value.value = null;
}

function removeLocation() {
  form.latlong = null;
}
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>
    <q-page class="row justify-center">
      <div class="col col-md-6 q-pa-sm">
        <q-form
          class="row"
          @submit.prevent="submit"
          @validation-error="scrollToFirstErrorField"
        >
          <q-card square flat bordered class="col">
            <q-inner-loading :showing="form.processing">
              <q-spinner size="50px" color="primary" />
            </q-inner-loading>
            <q-card-section class="q-pt-md">
              <input type="hidden" name="id" v-model="form.id" />
              <input
                type="hidden"
                name="image_path"
                v-model="form.image_path"
              />
              <q-select
                v-if="$page.props.auth.user.role == 'admin'"
                v-model="form.user_id"
                label="BS"
                :options="users"
                map-options
                emit-value
                :error="!!form.errors.user_id"
                :disable="form.processing"
                :error-message="form.errors.user_id"
                hide-bottom-space
              />
              <q-select
                v-model="form.product_id"
                label="Varietas"
                :options="products"
                map-options
                emit-value
                :error="!!form.errors.product_id"
                :disable="form.processing"
                :error-message="form.errors.product_id"
                hide-bottom-space
              />
              <date-picker
                v-model="form.plant_date"
                label="Tanggal Tanam"
                :error="!!form.errors.plant_date"
                :disable="form.processing"
                :error-message="form.errors.plant_date"
                hide-bottom-space
              />
              <q-input
                v-model.trim="form.owner_name"
                type="text"
                label="Pemilik Lahan"
                lazy-rules
                :disable="form.processing"
                :error="!!form.errors.owner_name"
                :error-message="form.errors.owner_name"
                :rules="[
                  (val) =>
                    (val && val.length > 0) || 'Pemilik lahan harus diisi.',
                ]"
                hide-bottom-space
              />
              <q-input
                v-model.trim="form.owner_phone"
                type="text"
                label="No Telepon Pemilik"
                lazy-rules
                :disable="form.processing"
                :error="!!form.errors.owner_phone"
                :error-message="form.errors.owner_phone"
                hide-bottom-space
              />
              <q-input
                v-model.trim="form.field_location"
                type="text"
                label="Lokasi"
                lazy-rules
                :disable="form.processing"
                :error="!!form.errors.field_location"
                :error-message="form.errors.field_location"
                :rules="[
                  (val) => (val && val.length > 0) || 'Lokasi harus diisi.',
                ]"
                hide-bottom-space
              />
              <LocaleNumberInput
                v-model.trim="form.population_pcs"
                type="text"
                label="Jumlah Tanam (pcs)"
                lazy-rules
                :disable="form.processing"
                :error="!!form.errors.population_pcs"
                :error-message="form.errors.population_pcs"
                :rules="[
                  (val) => !!val || 'Jumlah tanam (pcs) harus diisi.',
                  (val) => {
                    const number = parseInt(String(val).replace(/\D/g, ''), 10);
                    return number > 0 || 'Jumlah tanam (pcs) harus lebih dari 0.';
                  },
                ]"
                hide-bottom-space
              />
              <q-banner
                rounded
                class="bg-blue-1 text-blue-9 q-mt-sm"
                v-if="form.product_id"
              >
                <div class="text-caption">
                  Konversi otomatis: 1 pcs = <b>{{ seedPerPcs || 0 }}</b> biji.
                  <span v-if="seedPerPcs > 0">
                    Estimasi populasi: <b>{{ estimatedPopulation }}</b> pohon.
                  </span>
                </div>
              </q-banner>
              <q-input
                class="q-mt-sm"
                outlined
                dense
                disable
                :model-value="estimatedPopulation > 0 ? estimatedPopulation : '-'"
                label="Estimasi Populasi (pohon)"
              />
              <q-input
                v-model.trim="form.notes"
                type="textarea"
                autogrow
                counter
                maxlength="255"
                label="Catatan"
                lazy-rules
                :disable="form.processing"
                :error="!!form.errors.notes"
                :error-message="form.errors.notes"
                hide-bottom-space
              />
              <div style="margin-left: -10px">
                <q-checkbox
                  class="full-width q-pl-none"
                  v-model="form.active"
                  :disable="form.processing"
                  label="Demplot Aktif"
                />
              </div>
              <div class="q-pt-md">
                <div class="text-subtitle2 text-bold text-grey-9">
                  Foto:
                  <span class="text-negative" v-if="form.errors.image">{{
                    form.errors.image
                  }}</span>
                </div>
                <q-btn
                  label="Ambil Foto"
                  size="sm"
                  @click="triggerInput"
                  color="secondary"
                  icon="add_a_photo"
                  :disable="form.processing"
                />
                <!-- Tombol buang -->
                <q-btn
                  class="q-ml-sm"
                  size="sm"
                  icon="close"
                  label="Buang"
                  :disable="form.processing || !imagePreview"
                  color="red"
                  @click="clearImage"
                />
                <input
                  type="file"
                  ref="fileInput"
                  accept="image/*"
                  style="display: none"
                  @change="onFileChange"
                />
                <div>
                  <q-img
                    v-if="imagePreview"
                    :src="imagePreview"
                    class="q-mt-md"
                    style="max-width: 500px"
                    :style="{ border: '1px solid #ddd' }"
                  >
                    <template v-slot:error>
                      <div class="text-negative text-center q-pa-md">
                        Gambar tidak tersedia
                      </div>
                    </template>
                  </q-img>
                </div>
              </div>
              <div class="q-my-md">
                <div>
                  <span class="text-subtitle2 text-bold text-grey-9"
                    >Koordinat:</span
                  >
                  <span class="q-mr-sm">
                    <template v-if="form.latlong" class="q-mt-sm">
                      ({{ form.latlong.split(",")[0] }},
                      {{ form.latlong.split(",")[1] }})
                    </template>
                    <template v-else> Belum tersedia </template>
                  </span>
                </div>
                <div>
                  <q-btn
                    size="sm"
                    label="Perbarui Lokasi"
                    color="secondary"
                    :disable="form.processing"
                    @click="updateLocation()"
                  />
                  <q-btn
                    size="sm"
                    icon="delete"
                    label="Hapus Lokasi"
                    color="red-9"
                    :disable="!form.latlong || form.processing"
                    class="q-ml-sm"
                    @click="removeLocation()"
                  />
                </div>
              </div>
            </q-card-section>
            <q-card-section class="q-gutter-sm">
              <q-btn
                icon="save"
                type="submit"
                label="Simpan"
                color="primary"
                :disable="form.processing"
              />
              <q-btn
                icon="cancel"
                label="Batal"
                :disable="form.processing"
                @click="$goBack()"
              />
            </q-card-section>
          </q-card>
        </q-form>
      </div>
    </q-page>
  </authenticated-layout>
</template>
