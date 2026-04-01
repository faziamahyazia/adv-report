<template>
  <Layout>
    <Head title="Input Data Hasil Panen" />

    <div class="container mx-auto px-4 py-6">
      <!-- Header -->
      <div class="mb-6">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Input Data Hasil Panen</h1>
        <p class="text-gray-600">Catat hasil panen produk anda dengan detail lokasi, kuantitas, dan kualitas</p>
      </div>

      <!-- Form Card -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <form @submit.prevent="submitHarvest" class="space-y-6">
          <!-- Row 1: Product & Farmer Name -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Produk <span class="text-red-500">*</span>
              </label>
              <select
                v-model="form.product_id"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Pilih Produk</option>
                <option v-for="product in products" :key="product.id" :value="product.id">
                  {{ product.name }}
                </option>
              </select>
              <p v-if="errors.product_id" class="mt-1 text-sm text-red-500">{{ errors.product_id }}</p>
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Nama Petani
              </label>
              <input
                v-model="form.farmer_name"
                type="text"
                placeholder="Nama petani / pemilik lahan"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p v-if="errors.farmer_name" class="mt-1 text-sm text-red-500">{{ errors.farmer_name }}</p>
            </div>
          </div>

          <!-- Row 2: Land Area & Harvest Date -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Luas Lahan (m²)
              </label>
              <input
                v-model.number="form.land_area"
                type="number"
                step="0.01"
                min="0"
                placeholder="Contoh: 500"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p v-if="errors.land_area" class="mt-1 text-sm text-red-500">{{ errors.land_area }}</p>
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Tanggal Panen <span class="text-red-500">*</span>
              </label>
              <input
                v-model="form.harvest_date"
                type="date"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p v-if="errors.harvest_date" class="mt-1 text-sm text-red-500">{{ errors.harvest_date }}</p>
            </div>
          </div>

          <!-- Row 3: Harvest Age & Multiple Harvest -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Umur Tanaman (hari)
              </label>
              <input
                v-model.number="form.harvest_age_days"
                type="number"
                min="1"
                max="999"
                placeholder="Contoh: 65"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p v-if="errors.harvest_age_days" class="mt-1 text-sm text-red-500">{{ errors.harvest_age_days }}</p>
            </div>

            <div class="flex items-end">
              <label class="flex items-center space-x-2 cursor-pointer">
                <input
                  v-model="form.is_multiple_harvest"
                  type="checkbox"
                  class="w-5 h-5 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                />
                <span class="text-sm font-semibold text-gray-700">Beberapa Kali Panen</span>
              </label>
            </div>
          </div>

          <!-- Row 4: Harvest Quantity & Unit -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Jumlah Panen <span class="text-red-500">*</span>
              </label>
              <input
                v-model.number="form.harvest_quantity"
                type="number"
                step="0.01"
                min="0"
                required
                placeholder="Contoh: 250"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p v-if="errors.harvest_quantity" class="mt-1 text-sm text-red-500">{{ errors.harvest_quantity }}</p>
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Satuan <span class="text-red-500">*</span>
              </label>
              <select
                v-model="form.harvest_unit"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Pilih Satuan</option>
                <option value="kg">kg</option>
                <option value="pcs">pcs</option>
              </select>
              <p v-if="errors.harvest_unit" class="mt-1 text-sm text-red-500">{{ errors.harvest_unit }}</p>
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Total Buah/Satuan
              </label>
              <input
                v-model.number="form.total_pieces"
                type="number"
                step="1"
                min="0"
                placeholder="Contoh: 1000"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p v-if="errors.total_pieces" class="mt-1 text-sm text-red-500">{{ errors.total_pieces }}</p>
            </div>
          </div>

          <!-- Per Piece Quantity -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">
              Hasil Per Buah/Satuan ({{ form.harvest_unit || 'kg' }})
            </label>
            <input
              v-model.number="form.per_piece_quantity"
              type="number"
              step="0.01"
              min="0"
              placeholder="Secara otomatis terhitung atau masukkan manual"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <p class="mt-1 text-xs text-gray-500">
              <span v-if="form.total_pieces && form.harvest_quantity && form.harvest_unit">
                Estimasi: {{ (form.harvest_quantity / form.total_pieces).toFixed(4) }} {{ form.harvest_unit }} per buah
              </span>
              <span v-else>Isi jumlah panen dan total buah untuk estimasi otomatis</span>
            </p>
            <p v-if="errors.per_piece_quantity" class="mt-1 text-sm text-red-500">{{ errors.per_piece_quantity }}</p>
          </div>

          <!-- Row 5: Location & Notes -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Lokasi / Blok Lahan
              </label>
              <input
                v-model="form.location"
                type="text"
                placeholder="Contoh: Blok A Timur"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p v-if="errors.location" class="mt-1 text-sm text-red-500">{{ errors.location }}</p>
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Catatan Umum
              </label>
              <input
                v-model="form.notes"
                type="text"
                placeholder="Catatan singkat tentang panen ini"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p v-if="errors.notes" class="mt-1 text-sm text-red-500">{{ errors.notes }}</p>
            </div>
          </div>

          <!-- Strengths & Weaknesses -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Kelebihan / Keunggulan Panen
              </label>
              <textarea
                v-model="form.strengths"
                rows="3"
                placeholder="Cth: Hasil melimpah, ukuran seragam, warna merah merah..."
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
              />
              <p v-if="errors.strengths" class="mt-1 text-sm text-red-500">{{ errors.strengths }}</p>
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Kelemahan / Masalah Panen
              </label>
              <textarea
                v-model="form.weaknesses"
                rows="3"
                placeholder="Cth: Beberapa buah cacat, serangan hama minimal, kelembaban tinggi..."
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
              />
              <p v-if="errors.weaknesses" class="mt-1 text-sm text-red-500">{{ errors.weaknesses }}</p>
            </div>
          </div>

          <!-- Photo Upload -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">
              Foto Panen
            </label>
            <div v-if="form.photo" class="mb-4">
              <img :src="form.photo" alt="Preview" class="h-48 w-48 object-cover rounded-lg border border-gray-300" />
              <button
                type="button"
                @click="form.photo = null; photoInput = null"
                class="mt-2 px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
              >
                Hapus Foto
              </button>
            </div>
            <input
              v-show="!form.photo"
              type="file"
              ref="photoInput"
              accept="image/*"
              @change="handlePhotoChange"
              class="block w-full px-4 py-2 border border-gray-300 rounded-lg cursor-pointer focus:outline-none"
            />
            <p class="mt-1 text-xs text-gray-500">Format: JPG, PNG. Maksimal: 10MB</p>
            <p v-if="errors.photo" class="mt-1 text-sm text-red-500">{{ errors.photo }}</p>
          </div>

          <!-- Summary Info -->
          <div v-if="form.harvest_quantity && form.land_area" class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <h3 class="text-sm font-semibold text-blue-900 mb-2">Ringkasan Hasil</h3>
            <div class="space-y-1 text-sm text-blue-800">
              <p v-if="form.land_area">
                <strong>Produktivitas:</strong> {{ (form.harvest_quantity / form.land_area).toFixed(2) }} {{ form.harvest_unit }}/m²
              </p>
              <p v-if="form.total_pieces && form.harvest_quantity">
                <strong>Per Buah:</strong> {{ (form.harvest_quantity / form.total_pieces).toFixed(4) }} {{ form.harvest_unit }}/buah
              </p>
              <p v-if="form.is_multiple_harvest">
                <strong>Status:</strong> Beberapa kali panen
              </p>
            </div>
          </div>

          <!-- Submit Button -->
          <div class="flex gap-4 pt-6 border-t border-gray-200">
            <button
              type="submit"
              :disabled="submitting"
              class="flex-1 bg-blue-600 text-white font-semibold py-3 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 transition"
            >
              <span v-if="!submitting">Simpan Data Hasil Panen</span>
              <span v-else>Menyimpan...</span>
            </button>
            <button
              type="button"
              @click="resetForm"
              class="px-6 bg-gray-300 text-gray-700 font-semibold py-3 rounded-lg hover:bg-gray-400 transition"
            >
              Reset
            </button>
          </div>
        </form>
      </div>
    </div>
  </Layout>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue';
import { Head, useForm } from '@inertiajs/vue3';
import Layout from '@/layouts/AuthenticatedLayout.vue';

const photoInput = ref(null);
const submitting = ref(false);
const products = ref([]);
const errors = ref({});

const form = ref({
  product_id: null,
  farmer_name: '',
  land_area: null,
  harvest_date: '',
  harvest_age_days: null,
  harvest_quantity: null,
  harvest_unit: 'kg',
  total_pieces: null,
  per_piece_quantity: null,
  is_multiple_harvest: false,
  location: '',
  strengths: '',
  weaknesses: '',
  notes: '',
  photo: null,
  photoFile: null,
});

onMounted(() => {
  fetchProducts();
});

const fetchProducts = async () => {
  try {
    const response = await fetch(route('admin.product-knowledge.data'));
    if (response.ok) {
      const data = await response.json();
      products.value = data;
    }
  } catch (error) {
    console.error('Failed to fetch products:', error);
  }
};

const handlePhotoChange = (e) => {
  const file = e.target.files[0];
  if (file) {
    form.value.photoFile = file;
    const reader = new FileReader();
    reader.onload = (event) => {
      form.value.photo = event.target.result;
    };
    reader.readAsDataURL(file);
  }
};

const resetForm = () => {
  form.value = {
    product_id: null,
    farmer_name: '',
    land_area: null,
    harvest_date: '',
    harvest_age_days: null,
    harvest_quantity: null,
    harvest_unit: 'kg',
    total_pieces: null,
    per_piece_quantity: null,
    is_multiple_harvest: false,
    location: '',
    strengths: '',
    weaknesses: '',
    notes: '',
    photo: null,
    photoFile: null,
  };
  errors.value = {};
  if (photoInput.value) {
    photoInput.value.value = '';
  }
};

const submitHarvest = async () => {
  submitting.value = true;
  errors.value = {};

  try {
    const formData = new FormData();
    formData.append('product_id', form.value.product_id);
    formData.append('farmer_name', form.value.farmer_name || '');
    formData.append('land_area', form.value.land_area || '');
    formData.append('harvest_date', form.value.harvest_date);
    formData.append('harvest_age_days', form.value.harvest_age_days || '');
    formData.append('harvest_quantity', form.value.harvest_quantity || '');
    formData.append('harvest_unit', form.value.harvest_unit);
    formData.append('total_pieces', form.value.total_pieces || '');
    formData.append('per_piece_quantity', form.value.per_piece_quantity || '');
    formData.append('is_multiple_harvest', form.value.is_multiple_harvest ? 1 : 0);
    formData.append('location', form.value.location || '');
    formData.append('strengths', form.value.strengths || '');
    formData.append('weaknesses', form.value.weaknesses || '');
    formData.append('notes', form.value.notes || '');

    if (form.value.photoFile) {
      formData.append('photo', form.value.photoFile);
    }

    const response = await fetch(route('admin.harvest-result.store'), {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.content,
      },
    });

    const data = await response.json();

    if (!response.ok) {
      if (data.errors) {
        errors.value = data.errors;
      } else {
        alert(data.message || 'Gagal menyimpan data hasil panen.');
      }
    } else {
      alert('Data hasil panen berhasil disimpan!');
      resetForm();
    }
  } catch (error) {
    console.error('Error submitting harvest data:', error);
    alert('Terjadi kesalahan saat menyimpan data.');
  } finally {
    submitting.value = false;
  }
};
</script>
