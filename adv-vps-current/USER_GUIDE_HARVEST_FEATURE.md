# Panduan Pengguna: Fitur Input Data Hasil Panen 🌱

**Versi**: 1.0  
**Tanggal**: April 2026  
**Untuk**: BS (Bresales) Field Agent  

---

## 📚 Daftar Isi

1. [Ringkasan Fitur](#ringkasan-fitur)
2. [Akses Menu](#akses-menu)
3. [Mengisi Form Input](#mengisi-form-input)
4. [Mengunggah Foto](#mengunggah-foto)
5. [Melihat Hasil Panen](#melihat-hasil-panen)
6. [Bantuan & Troubleshooting](#bantuan--troubleshooting)

---

## 📖 Ringkasan Fitur

**Hasil Panen** adalah fitur untuk mencatat data panen produk di lapangan secara detail. Fitur ini membantu:

✅ Mencatat informasi panen lengkap (tanggal, kuantitas, kualitas)  
✅ Mendokumentasikan dengan foto  
✅ Melacak produktivitas lahan  
✅ Menampilkan ringkasan hasil panen untuk analisis  

**Siapa yang bisa input?** Hanya akun dengan role **BS (Bresales)**  
**Siapa yang bisa lihat?** Semua role bisa melihat hasil panen di Product Knowledge  

---

## 🚀 Akses Menu

### Langkah 1: Login ke Aplikasi
- Buka `https://adv.shiftech.co.id` (atau IP VPS: 202.10.40.89)
- Login dengan akun BS Anda
- Pastikan role Anda adalah **BS (Bresales)**

### Langkah 2: Buka Menu Hasil Panen
1. Di sidebar sebelah kiri, cari section **Master Data**
2. Klik **Hasil Panen** dengan icon 🌾
3. Akan membuka halaman form input

💡 **Tips**: Jika tidak melihat menu "Hasil Panen", berarti akun Anda bukan BS atau belum login. Hub admin.

---

## ✏️ Mengisi Form Input

### Data Dasar Panen

#### 1️⃣ Produk (Wajib) 🌱
- **Tipe**: Dropdown pilihan
- **Contoh**: LILAC 22 F1, MADU 59 F1, ANARA 81 F1
- **Cara**: Klik dropdown → pilih varietas → tekan Enter/click
- **🔴 Wajib diisi** sebelum submit

#### 2️⃣ Nama Petani (Opsional)
- **Tipe**: Text input
- **Contoh**: Bapak Sutrisno, Ibu Siti, Pak Joko
- **Kegunaan**: Melacak siapa pemilik lahan panen ini
- **Tips**: Gunakan nama lengkap untuk identifikasi mudah

#### 3️⃣ Luas Lahan (Opsional) 📐
- **Tipe**: Angka (meter persegi)
- **Contoh**: 500, 1000, 2500
- **Kegunaan**: Menghitung produktivitas (kg/m²)
- **Tips**: Catat luas area yang sebenarnya dipanen

---

### Data Tanggal & Umur Tanaman

#### 4️⃣ Tanggal Panen (Wajib) 📅
- **Tipe**: Date picker (kalender)
- **Format**: YYYY-MM-DD (otomatis)
- **Cara**: 
  1. Klik field tanggal
  2. Pilih tanggal di kalender
  3. Atau ketik manual: 2026-04-01
- **🔴 Wajib diisi** sebelum submit
- **Tips**: Pastikan tanggal akurat untuk tracking

#### 5️⃣ Umur Tanaman (Opsional) 📊
- **Tipe**: Angka (hari)
- **Contoh**: 45, 65, 90
- **Kegunaan**: Tracking umur panen vs target umur
- **Tips**: Hitung dari tanggal tanam - tanggal panen

---

### Data Hasil Panen

#### 6️⃣ Jumlah Panen (Wajib) 📦
- **Tipe**: Angka desimal
- **Contoh**: 250.5, 1000, 50.25
- **🔴 Wajib diisi** sebelum submit
- **Tips**: Gunakan desimal jika ada: 250.5 kg bukan 251 kg

#### 7️⃣ Satuan (Wajib) ⚖️
- **Tipe**: Dropdown pilihan
- **Opsi**:
  - **kg** = kilogram (untuk hasil berat)
  - **pcs** = piece/buah (untuk hasil per satuan)
- **Contoh Penggunaan**:
  - Tomat: 250 kg (satuan kg)
  - Mentimun: 1200 pcs (satuan pcs)
- **🔴 Wajib dipilih** sebelum submit
- **Tips**: Pilih sesuai kondisi hasil panen

#### 8️⃣ Total Buah/Satuan (Opsional) 🍅
- **Tipe**: Angka (jumlah buah)
- **Contoh**: 1000, 500, 2000
- **Kegunaan**: Menghitung hasil per buah
- **Tips**: Penting untuk analisis produktivitas per buah
- **Cara hitung**: Hitung manual buah yang panen

#### 9️⃣ Hasil Per Buah (Auto-Calculate) ✨
- **Tipe**: Angka (otomatis terisi)
- **Formula**: = Jumlah Panen ÷ Total Buah
- **Contoh**: 250.5 kg ÷ 1002 buah = 0.25 kg/buah
- **📌 Tidak perlu input manual** - terhitung otomatis
- **Tips**: Jika ingin manual, bisa di-override

---

### Data Frekuensi Panen

#### 🔟 Beberapa Kali Panen (Opsional) 🔄
- **Tipe**: Checkbox (centang/tidak)
- **Kegunaan**: Tandai jika tanaman dipanen berkali-kali
- **Contoh Produk Berkali Panen**:
  - ✅ Tomat - bisa panen 5-10 kali per musim
  - ✅ Mentimun - bisa panen setiap 2-3 hari
  - ❌ Cabai - panen bertahap tapi dihitung 1x
- **Tips**: Centang jika akan input data panen berikutnya dari tanaman sama

---

### Data Lokasi

#### 1️⃣1️⃣ Lokasi / Blok Lahan (Opsional) 📍
- **Tipe**: Text input
- **Contoh**: Blok A Utara, Blok B Timur, Lahan Pak Joko - Blok 3
- **Kegunaan**: Memudahkan tracking blok/area tertentu
- **Tips**: Gunakan kode/nama yang konsisten di seluruh tim

#### 1️⃣2️⃣ Catatan Umum (Opsional) 📝
- **Tipe**: Text input
- **Contoh**: 
  - "Cuaca cerah, tanah lembab optimal"
  - "Serangan hama minimal, pengendalian berhasil"
  - "Persiapan untuk panen kedua minggu depan"
- **Tips**: Singkat dan informatif

---

### Data Kualitas Produk

#### 1️⃣3️⃣ Kelebihan / Keunggulan Panen (Opsional) ⭐
- **Tipe**: Textarea (multi-line text)
- **Contoh**:
  - "Hasil melimpah melebihi target"
  - "Ukuran seragam, warna merah cerah"
  - "Tidak ada kerusakan signifikan"
- **Tips**: Fokus pada hal POSITIF dari panen ini

#### 1️⃣4️⃣ Kelemahan / Masalah Panen (Opsional) ⚠️
- **Tipe**: Textarea (multi-line text)
- **Contoh**:
  - "Beberapa buah cacat/busuk ~5%"
  - "Serangan hama kuning pada 10% tanaman"
  - "Kelembaban tinggi menyebabkan cracking"
- **Tips**: Lapor agar tim dapat belajar untuk panen berikutnya

---

## 📸 Mengunggah Foto

#### 1️⃣5️⃣ Foto Panen (Opsional) 📷
- **Format**: JPG atau PNG
- **Ukuran Maksimal**: 10 MB (10,000 KB)
- **Tips Foto Bagus**:
  - Ambil foto hasil panen di lapangan
  - Pastikan pencahayaan baik dan jelas terlihat
  - Sertakan konteks (petani, lahan, hasil)

**Cara Upload:**
1. Klik button **Pilih File** pada field "Foto Panen"
2. Pilih foto dari galeri/file explorer
3. Preview foto akan muncul di bawah field
4. Jika ingin ganti, klik **Hapus Foto** lalu upload ulang

**Apa yang terjadi:**
- Foto akan otomatis dikompres (resize ke 1600x1600 pixel)
- Disimpan di server dengan nama unik
- Format JPG quality 82% (optimal size vs quality)

---

## 📊 Summary / Ringkasan Otomatis

**Sebelum submit**, lihat preview di bagian **"Ringkasan Hasil"** (area biru):

```
📊 Ringkasan Hasil
─────────────────────
Produktivitas: 0.50 kg/m²
Per Buah: 0.25 kg/buah
Status: Beberapa kali panen
```

**Arti Summary:**
- **Produktivitas** = Berapa kg hasil per m² lahan
- **Per Buah** = Berapa kg hasil per buah (untuk analisis kualitas)
- **Status** = Apakah ini panen berkali-kali atau sekali

---

## 🔘 Submit Form

**Tombol Aksi:**
1. **Simpan Data Hasil Panen** (biru) → Submit dan simpan ke database
2. **Reset** (abu-abu) → Kosongkan semua field dan mulai ulang

**Sebelum Click Submit:**
- ✅ Pastikan semua field *wajib* sudah diisi:
  - Produk
  - Tanggal Panen  
  - Jumlah Panen
  - Satuan (kg/pcs)
- ✅ Foto sudah di-upload (jika ingin)
- ✅ Data sudah akurat

**Setelah Click Submit:**
- Tombol akan berubah menjadi "Menyimpan..." (gray)
- Tunggu hingga selesai (2-5 detik)
- Jika berhasil → akan muncul popup "Data hasil panen berhasil disimpan!"
- Form otomatis kosong dan siap input berikutnya

---

## 👁️ Melihat Hasil Panen

**Untuk semua role** (BS, Admin, Agronomist, ASM):

1. Buka sidebar → **Master Data** → **Product Knowledge**
2. Klik tab **Hasil Panen** (ikon 🌾)
3. Akan melihat kartu-kartu hasil panen dengan info:

### Card Informasi Hasil Panen

```
┌─────────────────────────────────┐
│  LILAC 22 F1                    │  ← Nama Produk
│  Nama Petani: Bapak Sutrisno   │  ← Petani (baru)
│  Diinput oleh: Fatkhrokman      │  ← Siapa input
│  Waktu input: 01 Apr 2026 03:34 │  ← Kapan input
│                                 │
│  📅 Tanggal Panen: 30 Mar 2026  │
│  📊 Umur Panen: 65 hari         │
│  📐 Luas Lahan: 500 m²          │  ← Baru
│  🔄 Beberapa kali panen         │  ← Indicator
│  🎁 Total Hasil: 250.5 kg       │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 📈 Ringkasan Hasil (BARU) │  │
│  ├───────────────────────────┤  │
│  │ Produktivitas: 0.50 kg/m² │  │ ← Baru!
│  │ Per Buah: 0.25 kg/buah    │  │ ← Baru!
│  └───────────────────────────┘  │
│                                 │
│  ⭐ Kelebihan:                  │
│  Hasil melimpah, ukuran seragam │
│                                 │
│  ⚠️ Kelemahan:                  │
│  Beberapa buah cacat            │
│                                 │
│  📝 Catatan:                    │
│  Kondisi cuaca cerah...         │
│  📍 Lokasi: Blok A Utara        │
│                                 │
│  [PHOTO]                        │
└─────────────────────────────────┘
```

### Cari Berdasarkan

**Search Box** (pencarian):
- Cari nama petani: "Sutrisno", "Bapak"
- Cari produk: "LILAC", "MADU"
- Cari yang input: "Fatkhrokman"
- Cari kualitas: "Melimpah", "Cacat"

**Filter Dropdown**:
- Semua Varietas (all)
- LILAC 22 F1
- MADU 59 F1
- Desa Produk lainnya

---

## ❓ Bantuan & Troubleshooting

### ❌ Masalah: Tombol "Hasil Panen" di sidebar tidak muncul

**Penyebab Umum:**
1. Akun Anda bukan BS
2. Belum logout-login setelah role diubah
3. Browser cache belum di-clear

**Solusi:**
1. ✔️ Verifikasi role: Hubungi admin untuk ensure Anda BS
2. ✔️ Logout → Tutup browser → Login ulang
3. ✔️ Clear cache: Ctrl+Shift+Delete → Clear browsing data

---

### ❌ Masalah: Form "Hasil Per Buah" tidak auto-calculate

**Penyebab:**
- Total Buah atau Jumlah Panen belum diisi

**Solusi:**
1. Pastikan field berikut ada nilai:
   - Jumlah Panen (contoh: 250.5)
   - Total Buah/Satuan (contoh: 1002)
2. Tunggu 1 detik, field akan update otomatis
3. Jika masih tidak muncul, refresh browser (F5)

---

### ❌ Masalah: Foto tidak bisa upload

**Penyebab Umum:**
1. File terlalu besar (> 10 MB)
2. Format bukan JPG/PNG
3. Storage penuh

**Solusi:**
1. Kompres foto sebelum upload:
   - Gunakan aplikasi compress (TinyJPG, Compressor, dll)
   - Target: 5-8 MB
2. Pastikan format: JPG atau PNG (bukan BMP, WEBP, dll)
3. Hub admin jika storage penuh

---

### ❌ Masalah: Form tidak bisa submit / tombol gray

**Penyebab:**
- Ada field wajib yang belum diisi

**Solusi:**
1. Cek pesan error (biasanya merah)
2. Isi semua field dengan asterisk (*):
   - ✔️ Produk *
   - ✔️ Tanggal Panen *
   - ✔️ Jumlah Panen *
   - ✔️ Satuan *
3. Kelima field WAJIB ada isinya baru bisa submit

---

### ❌ Masalah: Data tidak muncul di "Hasil Panen" tab

**Penyebab:**
1. Data belum sync (server belum menerima)
2. Filter/Search menyembunyikan data

**Solusi:**
1. Refresh page: F5
2. Tunggu 2-3 detik setelah submit
3. Kosongkan search/filter (default ke "Semua")
4. Check di tab lain lalu kembali

---

### ❌ Masalah: Produktivitas menunjukkan angka aneh

**Penyebab:**
- Luas Lahan atau Hasil Panen kosong

**Solusi:**
1. Pastikan kedua field ada nilai:
   - Luas Lahan (m²)
   - Jumlah Panen (kg/pcs)
2. Rumus: Jumlah Panen ÷ Luas Lahan = Produktivitas
3. Contoh: 250.5 ÷ 500 = 0.501 kg/m²

---

### ✅ Semuanya berjalan lancar - Excellent! 🎉

Jika tidak ada masalah, artinya sistem bekerja dengan baik!

**Tips Penggunaan Optimal:**
- Input data panen sambil masih di lapangan (data fresh)
- Foto hasil panen tidak blur dan representative
- Isi semua detail untuk analisis mendalam
- Upload ke sistem segera setelah panen (jangan lupa)

---

## 📞 Hubungi Admin

**Jika masalah tidak teratasi:**
- 📧 Email: admin@shiftech.co.id
- 📱 WA/Telp: [nomor admin]
- 🏢 Datang ke kantor dengan struk/bukti error

**Laporan yang helpful:**
1. Deskripsi masalah detail
2. Tangkapan layar (screenshot) error
3. Waktu masalah terjadi
4. Detail akun (nama user, role)

---

## 📚 Referensi Cepat

| Item | Format | Contoh | Wajib? |
|------|--------|--------|--------|
| Produk | Dropdown | LILAC 22 F1 | ✅ Ya |
| Nama Petani | Text | Bapak Sutrisno | ❌ Tidak |
| Luas Lahan | Angka (m²) | 500 | ❌ Tidak |
| Tanggal Panen | Date | 2026-04-01 | ✅ Ya |
| Umur Tanaman | Angka (hari) | 65 | ❌ Tidak |
| Jumlah Panen | Desimal | 250.5 | ✅ Ya |
| Satuan | Dropdown | kg / pcs | ✅ Ya |
| Total Buah | Angka | 1002 | ❌ Tidak |
| Per Buah | Auto-calc | 0.25 | ❌ (Auto) |
| Lokasi | Text | Blok A | ❌ Tidak |
| Catatan | Text | Cuaca cerah | ❌ Tidak |
| Kelebihan | Textarea | Melimpah | ❌ Tidak |
| Kelemahan | Textarea | Ada cacat | ❌ Tidak |
| Foto | JPG/PNG max 10MB | [image] | ❌ Tidak |
| Berkali Panen | Checkbox | ☑️ / ☐ | ❌ Tidak |

---

## 🎓 Kesimpulan

✅ **Anda sudah siap menggunakan fitur Hasil Panen!**

Ringkas:
1. Buka menu "Hasil Panen" di sidebar
2. Isi form dengan data panen
3. Upload foto (jika ada)
4. Submit
5. Lihat hasil di Product Knowledge → Hasil Panen tab

**Selamat input data hasil panen! Terima kasih atas dedikasi Anda.** 🌱✨

---

**Versi Dokumen**: 1.0  
**Terakhir Diperbarui**: April 2026  
**Untuk Feedback**: Hubungi development team  
