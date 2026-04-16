# Buku Agenda Rollback Git - ADV Report

Dokumen ini dipakai sebagai "buku agenda" agar rollback bisa dilakukan cepat, terukur, dan aman.

## 1) Posisi Saat Ini

- Tanggal catat: 2026-04-15
- HEAD saat agenda dibuat: 3c30d38
- Branch aktif: copilot/optimize-desktop-mobile-view

## 2) Titik Rollback Historis (Seed Awal)

Gunakan hash commit berikut jika perlu kembali ke versi tertentu.

| No | Tanggal | Commit | Ringkasan |
|---|---|---|---|
| 1 | 2026-04-06 | 3c30d38 | fix: remove max-width constraint for full width complaint detail |
| 2 | 2026-04-06 | a68c92c | feat: complete redesign of complaint detail page with modern UI |
| 3 | 2026-04-06 | 69f7356 | docs: add deployment script for complaint UI and BS sales fix |
| 4 | 2026-04-06 | 6ec1e68 | feat: optimize complaint detail UI and fix BS sales total display |
| 5 | 2026-04-05 | 2c9c4ce | fix(demplot): Use jumlah_biji_per_pcs instead of seeds_per_tree |
| 6 | 2026-04-05 | 7e0a2f6 | fix(demplot): Remove old method & fix PDF export error 500 |
| 7 | 2026-04-05 | 3e98e45 | feat(demplot): Complete jumlah_tanam & db_germinasi implementation |
| 8 | 2026-04-05 | 0cf840d | feat(demplot): Add jumlah_tanam and db_germinasi fields - Part 1 |
| 9 | 2026-04-05 | 1fb3d36 | fix: Enable autogrow for all template textareas |
| 10 | 2026-04-05 | 051e9df | refactor: Compact & efficient Reminder WA layout |
| 11 | 2026-04-05 | f15a260 | chore: Add quick deploy script |
| 12 | 2026-04-05 | d534977 | docs: Add deployment status and final summary |
| 13 | 2026-04-05 | f45a2b8 | docs: Add copy-paste deployment instructions |
| 14 | 2026-04-05 | 146aefb | feat: Add automated deployment script for reminder UI |
| 15 | 2026-04-05 | 16696c3 | docs: Add deployment guide for reminder WA UI redesign |
| 16 | 2026-04-05 | 16ac670 | build: Compile assets for reminder WA redesign |
| 17 | 2026-04-05 | c3fff17 | feat: Redesign reminder WA UI for better desktop & mobile experience |
| 18 | 2026-04-02 | 09d603d | Improve photo display debugging and mobile tag optimization |
| 19 | 2026-04-02 | cfc09de | Fix harvest photo display and optimize mobile zone labels |

## 3) SOP Harian (Agar Rollback "Ke Mana Saja" Bisa Dilakukan)

Setiap sebelum perubahan besar / sebelum deploy, jalankan:

1. Pastikan berada di folder aplikasi

```bash
cd /workspaces/adv-report/adv-vps-current
```

2. Simpan checkpoint sebagai tag beranotasi

```bash
git tag -a agenda/2026-04-15-01 -m "Checkpoint sebelum perubahan modul sales"
```

3. Kalau mau kirim ke remote

```bash
git push origin agenda/2026-04-15-01
```

4. Catat checkpoint ke tabel agenda (lihat bagian 6)

## 3b) Tag Rollback Siap Pakai (Sudah Dibuat)

- agenda/2026-04-06-stable -> 3c30d38
- agenda/2026-04-05-demplot-fix -> 2c9c4ce
- agenda/2026-04-02-photo-fix -> 09d603d

## 4) Perintah Cepat Rollback

### A. Lihat semua checkpoint agenda

```bash
git tag -l 'agenda/*' --sort=-creatordate
```

### B. Lihat detail checkpoint

```bash
git show --no-patch agenda/2026-04-15-01
```

### C. Coba dulu tanpa mengubah branch (aman)

```bash
git switch --detach agenda/2026-04-15-01
```

### D. Rollback permanen branch aktif ke titik tertentu

```bash
git reset --hard agenda/2026-04-15-01
```

Atau langsung pakai hash commit:

```bash
git reset --hard 3c30d38
```

### E. Ambil 1 file saja dari titik lama

```bash
git checkout 3c30d38 -- resources/js/pages/admin/sale/Index.vue
```

## 5) Checklist Aman Sebelum Rollback Permanen

- Simpan pekerjaan sekarang (commit atau stash)

```bash
git add -A
git stash push -m "backup sebelum rollback"
```

- Cek target rollback benar

```bash
git log --oneline -n 30
```

- Setelah rollback, validasi app

```bash
php artisan optimize:clear
php artisan route:list > /tmp/routes_after_rollback.txt
```

## 6) Template Entri Agenda Baru

Tambahkan baris baru setiap membuat checkpoint:

| Tanggal | Ref (tag/hash) | Tujuan | Dibuat Oleh | Catatan |
|---|---|---|---|---|
| YYYY-MM-DD | agenda/YYYY-MM-DD-xx | mis. sebelum deploy sales | nama | hasil validasi singkat |

## 7) Recovery Jika Salah Rollback

Kalau salah reset, gunakan reflog untuk balik lagi:

```bash
git reflog --date=local -n 20
git reset --hard HEAD@{1}
```

---

Catatan:
- Untuk server production, tetap kombinasikan dengan backup VPS (database + upload + .env) agar rollback penuh tidak hanya kode.
- Dokumen ini fokus pada rollback berbasis Git.
