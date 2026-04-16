<script setup>
import { router } from "@inertiajs/vue3";
</script>

<template>
  <q-page class="flex flex-center">
    <div class="text-center">
      <q-icon name="history" size="64px" color="grey-4" />
      <div class="text-h6 text-grey-6 q-mt-md">Riwayat Kunjungan Demo Plot</div>
      <div class="text-body2 text-grey-5 q-mt-sm">
        Akses riwayat kunjungan melalui halaman detail Demo Plot.
      </div>
      <q-btn
        class="q-mt-lg"
        color="primary"
        label="Ke Halaman Demo Plot"
        icon="agriculture"
        unelevated
        @click="router.get(route('admin.demo-plot.index'))"
      />
    </div>
  </q-page>
</template>
