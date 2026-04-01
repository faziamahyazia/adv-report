<script setup>
import { router, usePage } from "@inertiajs/vue3";
import { computed } from "vue";
import { formatDate } from "@/helpers/datetime";
import { formatNumber } from "@/helpers/utils";

const page = usePage();
const title = "Detail Penjualan";
const sale = computed(() => page.props.data || {});

const saleStatusLabel = computed(() =>
  sale.value.status === "released" ? "Released" : "Pending (PO)"
);
const saleStatusColor = computed(() =>
  sale.value.status === "released" ? "positive" : "warning"
);
const totalItems = computed(() => (sale.value.items || []).length);
const totalQty = computed(() =>
  (sale.value.items || []).reduce((s, i) => s + Number(i.quantity || 0), 0)
);
</script>

<template>
  <i-head :title="title" />
  <authenticated-layout>
    <template #title>{{ title }}</template>

    <template #left-button>
      <q-btn
        icon="arrow_back"
        dense
        color="grey-7"
        flat
        rounded
        @click="router.get(route('admin.sale.index'))"
      />
    </template>

    <template #right-button>
      <q-btn
        v-if="$can('admin.sale.edit')"
        icon="edit"
        dense
        color="primary"
        @click="router.get(route('admin.sale.edit', { id: sale.id }))"
      />
    </template>

    <div class="detail-page">

      <!-- ── Total Banner ── -->
      <div class="sale-total-banner q-mb-md">
        <div class="sale-total-banner-body">
          <div class="sale-total-left">
            <div class="sale-total-badges">
              <q-badge :color="saleStatusColor" class="sale-badge">{{ saleStatusLabel }}</q-badge>
              <q-badge
                outline
                :color="sale.sale_type === 'retailer' ? 'grey-7' : 'blue-8'"
                class="sale-badge q-ml-xs"
              >
                {{ sale.sale_type === "retailer" ? "Retailer" : "Distributor" }}
              </q-badge>
            </div>
            <div class="sale-total-distributor">{{ sale.distributor?.name || "-" }}</div>
            <div class="sale-total-meta">
              <span>{{ formatDate(sale.date) }}</span>
              <span class="meta-dot">·</span>
              <span>{{ totalItems }} produk</span>
              <span class="meta-dot">·</span>
              <span>{{ formatNumber(totalQty, "id-ID", 0) }} unit</span>
            </div>
          </div>
          <div class="sale-total-right">
            <div class="sale-total-label">Total Penjualan</div>
            <div class="sale-total-amount">Rp {{ formatNumber(sale.total_amount) }}</div>
          </div>
        </div>
      </div>

      <!-- ── Info card ── -->
      <q-card square flat bordered class="q-mb-md full-width">
        <q-card-section>
          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-6 col-md-4">
              <div class="kv-label">Tanggal</div>
              <div class="kv-value">{{ formatDate(sale.date) }}</div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="kv-label">Jenis Penjualan</div>
              <div class="kv-value">{{ sale.sale_type === "retailer" ? "Retailer (keluar stok)" : "Distributor (masuk stok)" }}</div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="kv-label">Distributor</div>
              <div class="kv-value">{{ sale.distributor?.name || "-" }}</div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="kv-label">R1/R2</div>
              <div class="kv-value">{{ sale.retailer?.name || "-" }}</div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="kv-label">Provinsi</div>
              <div class="kv-value">{{ sale.province?.name || "-" }}</div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="kv-label">Kabupaten/Kota</div>
              <div class="kv-value">{{ sale.district?.name || "-" }}</div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="kv-label">Desa/Kelurahan</div>
              <div class="kv-value">{{ sale.village?.name || "-" }}</div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="kv-label">Dibuat oleh</div>
              <div class="kv-value">{{ sale.created_by_user?.name || "-" }}</div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="kv-label">Diubah oleh</div>
              <div class="kv-value">{{ sale.updated_by_user?.name || "-" }}</div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="kv-label">Release oleh</div>
              <div class="kv-value">{{ sale.released_by_user?.name || "-" }}</div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="kv-label">Waktu Release</div>
              <div class="kv-value">{{ sale.released_datetime ? formatDate(sale.released_datetime) : "-" }}</div>
            </div>
            <div class="col-12">
              <div class="kv-label">Catatan</div>
              <div class="kv-value" style="white-space: pre-wrap">{{ sale.notes || "-" }}</div>
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- ── Items card ── -->
      <q-card square flat bordered class="q-mb-md full-width">
        <q-card-section>
          <div class="text-subtitle1 text-weight-bold q-mb-sm">Item Penjualan</div>
          <div class="table-scroll-wrap">
            <table class="detail-table">
              <thead>
                <tr>
                  <th class="col-product">Produk</th>
                  <th class="col-num">Qty</th>
                  <th class="col-lot">No. Lot</th>
                  <th class="col-unit">Satuan</th>
                  <th class="col-num">Harga (Rp)</th>
                  <th class="col-num">Subtotal (Rp)</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in sale.items || []" :key="item.id">
                  <td>{{ item.product?.name || "-" }}</td>
                  <td class="text-right">{{ formatNumber(item.quantity, "id-ID", 2) }}</td>
                  <td>{{ item.lot_number || "-" }}</td>
                  <td>{{ item.unit || "-" }}</td>
                  <td class="text-right">{{ formatNumber(item.price) }}</td>
                  <td class="text-right text-weight-medium">{{ formatNumber(item.subtotal) }}</td>
                </tr>
                <tr v-if="!(sale.items || []).length">
                  <td colspan="6" class="text-center text-grey-5">Belum ada item</td>
                </tr>
              </tbody>
              <tfoot v-if="(sale.items || []).length">
                <tr>
                  <td colspan="5" class="text-right text-weight-semibold">Total</td>
                  <td class="text-right total-cell">Rp {{ formatNumber(sale.total_amount) }}</td>
                </tr>
              </tfoot>
            </table>
          </div>
        </q-card-section>
      </q-card>

    </div>
  </authenticated-layout>
</template>

<style scoped>
/* ── Page Container ── */
.detail-page {
  padding: 12px;
}

@media (min-width: 768px) {
  .detail-page { padding: 18px; }
}

/* ── Total Banner ── */
.sale-total-banner {
  background: linear-gradient(135deg, #1a7340 0%, #22a35a 100%);
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(34, 163, 90, 0.25);
}

.sale-total-banner-body {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 18px;
  gap: 12px;
  flex-wrap: wrap;
}

.sale-total-left {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
  flex: 1;
}

.sale-total-badges {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin-bottom: 2px;
}

.sale-badge {
  font-size: 11px;
  padding: 2px 8px;
}

.sale-total-distributor {
  font-size: 16px;
  font-weight: 700;
  color: #fff;
  line-height: 1.3;
  word-break: break-word;
}

.sale-total-meta {
  font-size: 12px;
  color: rgba(255,255,255,0.75);
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  align-items: center;
}

.meta-dot { opacity: 0.5; }

.sale-total-right {
  text-align: right;
  flex-shrink: 0;
}

.sale-total-label {
  font-size: 11px;
  color: rgba(255,255,255,0.7);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 2px;
}

.sale-total-amount {
  font-size: 22px;
  font-weight: 800;
  color: #fff;
  white-space: nowrap;
  line-height: 1.1;
}

@media (min-width: 600px) {
  .sale-total-banner-body { padding: 18px 24px; }
  .sale-total-distributor { font-size: 20px; }
  .sale-total-amount { font-size: 28px; }
}

/* ── KV items (used inside Quasar col) ── */
.kv-label {
  font-size: 11px;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  margin-bottom: 2px;
}

.kv-value {
  font-size: 14px;
  color: #0f172a;
  font-weight: 500;
}

/* ── Item table ── */
.table-scroll-wrap {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.detail-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
  min-width: 500px;
}

.detail-table th,
.detail-table td {
  padding: 8px 10px;
  border: 1px solid #e2e8f0;
  vertical-align: middle;
}

.detail-table thead tr { background: #f8fafc; }

.detail-table thead th {
  font-size: 11px;
  font-weight: 600;
  color: #475569;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  white-space: nowrap;
}

.detail-table tbody tr:hover { background: #f8fafc; }

.detail-table tfoot td {
  background: #f1f5f9;
  border-top: 2px solid #cbd5e1;
}

.total-cell {
  font-size: 13.5px;
  font-weight: 700;
  color: #1a7340;
}

.col-product { min-width: 140px; }
.col-num { width: 100px; text-align: right; }
.col-lot { min-width: 90px; }
.col-unit { width: 65px; }
</style>
