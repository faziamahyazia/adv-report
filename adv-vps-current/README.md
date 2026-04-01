# Advanta Report

## Manage VPS Data

Project ini menyediakan script helper untuk audit file deploy, uploads, log, dan ukuran tabel database di VPS.

## Integrasi WhatsApp Fonte

Fitur WA yang tersedia:
- Notifikasi ke owner saat BS input penjualan baru.
- Reminder otomatis setiap Jumat ke semua user role BS yang aktif.

### Konfigurasi

Atur di `.env`:

```env
FONTE_ENABLED=true
FONTE_TOKEN=isi_token_fonte
FONTE_ENDPOINT=https://api.fonnte.com/send
FONTE_OWNER_PHONE=628xxxx
FONTE_BS_WEEKLY_REMINDER_TIME=08:00
```

Catatan:
- Nomor WA BS diambil dari field `users.whatsapp_number`.
- Jika `whatsapp_number` kosong, sistem fallback ke `username` jika formatnya nomor.

### Menjalankan scheduler

Pastikan cron Laravel aktif:

```bash
* * * * * php /path/proyek/artisan schedule:run >> /dev/null 2>&1
```

Uji manual reminder:

```bash
php artisan wa:remind-bs-weekly
```

## Deploy Aman (foto tidak hilang)

Gunakan script `deploy-safe.sh` untuk deploy ke VPS tanpa menghapus file upload user.

```bash
chmod +x deploy-safe.sh
./deploy-safe.sh
```

Script ini otomatis:
- build frontend di lokal,
- safety check `rsync --dry-run` dulu dan **batal otomatis** jika terdeteksi delete path kritikal,
- rsync dengan `--delete` tapi **exclude** `public/uploads`,
- menjaga `.env`, `bootstrap/cache/*.php`, dan file runtime `storage/framework` tetap aman,
- refresh permission runtime (`storage`, `bootstrap/cache`, `public/uploads`) dan cache Laravel.

Daftar exclude deploy disimpan di file `.deploy-rsync-excludes` agar konsisten dan tidak kelupaan.

### Mode validasi (tanpa deploy)

```bash
DRY_RUN=1 ./deploy-safe.sh
```

Mode ini menjalankan safety check + build lokal, lalu berhenti sebelum rsync aktual ke VPS.

### File

- `manage-vps.sh`

### Pakai di VPS

```bash
chmod +x manage-vps.sh

# Audit filesystem aplikasi
APP_PATH=/var/www/adv ./manage-vps.sh audit

# Audit database (MySQL/MariaDB)
DB_NAME=nama_database DB_USER=root ./manage-vps.sh db-audit

# Preview cleanup (dry-run, belum menghapus)
./manage-vps.sh cleanup

# Eksekusi cleanup
./manage-vps.sh cleanup --apply
```

Catatan:
- Default script aman karena `cleanup` berjalan dalam mode preview jika tanpa `--apply`.
- Ubah parameter lewat environment variable seperti `LOG_RETENTION_DAYS`, `BACKUP_RETENTION_DAYS`, dan `BACKUP_PATH`.

### Mode Web App (lebih gampang)

Setelah aplikasi ini di-deploy ke VPS (dan file `manage-vps.sh` ikut ada di root project), login sebagai admin lalu buka menu:

- `Admin > Settings > Database`

Di halaman tersebut sudah ada tombol:

- `Audit File & Foto`
- `Audit Tabel Database`
- `Preview Cleanup` / `Cleanup Sekarang`

Output perintah ditampilkan langsung di layar sehingga tidak perlu SSH untuk audit rutin.
