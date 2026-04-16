# Fix: Foto Hasil Panen Tidak Tampil

## Masalah
Foto yang di-upload di **Input Data Hasil Panen** tidak tampil di **Product Knowledge → Hasil Panen**, termasuk thumbnail.

## Penyebab
Folder `/public/uploads/` tidak ada di server, sehingga foto tidak bisa disimpan. Folder ini tidak ada karena:
1. Folder `uploads` di-ignore oleh git (untuk keamanan)
2. Tidak ada struktur folder yang di-commit ke repository
3. Folder tidak otomatis dibuat saat deployment

## Solusi

### 1. Perubahan Code (Sudah Selesai ✅)
- ✅ Menambahkan file `.gitkeep` di folder `public/uploads/`
- ✅ Update `.gitignore` untuk mengizinkan `.gitkeep`
- ✅ Menambahkan dokumentasi deployment lengkap

### 2. Deployment ke Server (PERLU DILAKUKAN)

**Untuk server development/staging/production, jalankan:**

```bash
# 1. Pull kode terbaru
cd /var/www/adv
git pull origin main

# 2. Pastikan folder uploads ada dan punya permission yang benar
mkdir -p public/uploads
chown -R www-data:www-data public/uploads
chmod -R 755 public/uploads

# 3. Verifikasi folder sudah ada
ls -ld public/uploads/
# Output harus: drwxr-xr-x www-data www-data

# 4. Test write permission
touch public/uploads/test.txt && rm public/uploads/test.txt
# Harus berhasil tanpa error
```

### 3. Verifikasi Fix Berhasil

1. Login sebagai user BS
2. Buka menu **Master Data → Hasil Panen**
3. Upload foto panen (JPG/PNG, max 10MB)
4. Submit form
5. Buka menu **Master Data → Product Knowledge**
6. Klik tab **Hasil Panen**
7. **Foto harus tampil** di card dan detail view

### 4. Troubleshooting

**Jika foto masih tidak muncul:**

```bash
# Cek apakah file foto ada di folder
ls -lah /var/www/adv/public/uploads/harvest_*

# Cek data di database
sqlite3 /var/www/adv/database/database.sqlite "SELECT * FROM product_harvest_result_photos LIMIT 5;"

# Cek log error
tail -f /var/www/adv/storage/logs/laravel.log
```

**Jika error "Permission denied":**

```bash
# Fix ownership
chown -R www-data:www-data /var/www/adv/public/uploads
chown -R www-data:www-data /var/www/adv/storage

# Fix permissions
chmod -R 755 /var/www/adv/public/uploads
chmod -R 755 /var/www/adv/storage
```

## File yang Diubah

1. **`.gitignore`** - Update untuk allow `.gitkeep` file
2. **`public/uploads/.gitkeep`** - Baru, memastikan folder struktur ada di git
3. **`DEPLOYMENT_CHECKLIST.md`** - Baru, dokumentasi deployment lengkap

## Deployment Script

Untuk memudahkan, gunakan script deployment otomatis:

```bash
#!/bin/bash
# File: /var/www/adv/deploy.sh

cd /var/www/adv
git pull origin main

# Ensure uploads folder
mkdir -p public/uploads
chown -R www-data:www-data public/uploads storage bootstrap/cache
chmod -R 755 public/uploads storage bootstrap/cache

# Run migrations
php artisan migrate --force

# Clear cache
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Restart services
sudo systemctl restart php8.2-fpm
sudo systemctl reload nginx

echo "✅ Deployment complete!"
echo "Please test photo upload functionality"
```

Simpan script di server, lalu jalankan:

```bash
chmod +x /var/www/adv/deploy.sh
./deploy.sh
```

## Status
- [x] Code fix committed
- [ ] Deployed to development server
- [ ] Tested photo upload
- [ ] Deployed to production server (202.10.40.89)
- [ ] Verified in production

## Referensi
- **Testing Guide:** `TESTING_HARVEST_FEATURE.md` (Case 4: Photo Upload)
- **Deployment Guide:** `DEPLOYMENT_CHECKLIST.md` (Section 4: File Permissions)
- **Controller:** `app/Http/Controllers/Admin/HarvestResultController.php` (line 353-374: storeHarvestPhotos)
- **API Endpoint:** `app/Http/Controllers/Admin/ProductKnowledgeController.php` (line 173-261: harvestData)

---

**Dibuat:** 2026-04-01  
**Issue:** Foto hasil panen tidak tampil di Product Knowledge  
**Fix:** Ensure uploads folder exists with proper permissions
