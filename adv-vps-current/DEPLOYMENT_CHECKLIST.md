# Deployment Checklist

## Pre-Deployment Steps

### 1. Environment Configuration
- [ ] Copy `.env.example` to `.env`
- [ ] Set `APP_KEY` (run `php artisan key:generate`)
- [ ] Configure database settings
- [ ] Set correct `APP_URL`

### 2. Dependencies
```bash
composer install --no-dev --optimize-autoloader
npm install
npm run build
```

### 3. Database Migration
```bash
php artisan migrate --force
```

### 4. File Permissions & Folders ⚠️ IMPORTANT

**Critical: Create uploads folder and set permissions**

```bash
# Create uploads folder if it doesn't exist
mkdir -p public/uploads

# Set proper ownership (replace www-data with your web server user)
chown -R www-data:www-data public/uploads
chown -R www-data:www-data storage
chown -R www-data:www-data bootstrap/cache

# Set proper permissions
chmod -R 755 public/uploads
chmod -R 755 storage
chmod -R 755 bootstrap/cache
```

**Why this is important:**
- `public/uploads/` is where harvest photos and product images are stored
- Without proper permissions, users cannot upload photos
- The folder is ignored by git (`.gitignore`) so it must be created manually on deployment

### 5. Optimize Laravel
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 6. Verify Uploads Folder
```bash
# Check folder exists and has correct permissions
ls -ld public/uploads/
# Should show: drwxr-xr-x www-data www-data

# Test write permission
touch public/uploads/test.txt && rm public/uploads/test.txt
# Should succeed without errors
```

---

## Post-Deployment Verification

### 1. Photo Upload Test (Critical)

**Test Harvest Photo Upload:**
1. Login as BS user
2. Go to Master Data → Hasil Panen
3. Fill form and upload a photo (JPG/PNG, max 10MB)
4. Submit form
5. Verify:
   - [ ] File uploaded to `public/uploads/harvest_*.jpg`
   - [ ] Database record created in `product_harvest_result_photos`
   - [ ] Photo displays in Product Knowledge → Hasil Panen tab

**If photos don't upload:**
```bash
# Check folder permissions
ls -ld public/uploads/

# Check folder ownership
stat public/uploads/

# Check web server error logs
tail -f /var/log/nginx/error.log
# OR
tail -f /var/log/apache2/error.log

# Check Laravel logs
tail -f storage/logs/laravel.log
```

### 2. Product Knowledge Photo Test
1. Go to Master Data → Product Knowledge
2. Edit a product
3. Upload product photos
4. Verify photos display in gallery

### 3. Application Health Checks
- [ ] Homepage loads without errors
- [ ] All menu items accessible
- [ ] No 404 or 500 errors in browser console
- [ ] Database queries working

---

## Common Issues & Solutions

### Issue: "Unable to write file" error when uploading
**Cause:** Uploads folder doesn't exist or has wrong permissions  
**Solution:**
```bash
mkdir -p public/uploads
chown -R www-data:www-data public/uploads
chmod -R 755 public/uploads
```

### Issue: Photos uploaded but not displaying
**Cause 1:** Database table `product_harvest_result_photos` not migrated  
**Solution:**
```bash
php artisan migrate --force
```

**Cause 2:** Files saved but path not normalized correctly  
**Solution:** Check `ProductKnowledgeController@harvestData()` line 232-236 for path normalization

**Cause 3:** Symlink not created for storage  
**Solution:**
```bash
php artisan storage:link
```

### Issue: 500 Error after deployment
**Cause:** Cache not cleared or permissions issue  
**Solution:**
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
chmod -R 755 storage bootstrap/cache
```

---

## VPS Production Deployment (202.10.40.89)

### Full Deployment Script

```bash
#!/bin/bash
# Deploy to Production VPS

echo "Starting deployment..."

# Navigate to app directory
cd /var/www/adv

# Pull latest code
git pull origin main

# Install dependencies
composer install --no-dev --optimize-autoloader
npm install
npm run build

# Ensure uploads folder exists with correct permissions
mkdir -p public/uploads
chown -R www-data:www-data public/uploads
chown -R www-data:www-data storage
chown -R www-data:www-data bootstrap/cache
chmod -R 755 public/uploads
chmod -R 755 storage
chmod -R 755 bootstrap/cache

# Run migrations
php artisan migrate --force

# Clear and rebuild cache
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Restart services
sudo systemctl restart php8.2-fpm
sudo systemctl reload nginx

echo "Deployment complete!"
echo "Testing uploads folder..."
ls -ld public/uploads/

echo "Verify photo upload works in the application!"
```

### Save and use deployment script:
```bash
# Save script
nano /var/www/adv/deploy.sh

# Make executable
chmod +x /var/www/adv/deploy.sh

# Run deployment
./deploy.sh
```

---

## Rollback Procedure

If deployment fails:

```bash
# Revert to previous commit
git reset --hard HEAD~1

# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Restart services
sudo systemctl restart php8.2-fpm
sudo systemctl reload nginx
```

---

## Monitoring & Maintenance

### Check Uploads Folder Size
```bash
du -sh public/uploads/
```

### Clean Old Test Uploads (if needed)
```bash
# List files older than 30 days
find public/uploads/ -type f -mtime +30 -ls

# Delete files older than 30 days (use with caution!)
# find public/uploads/ -type f -mtime +30 -delete
```

### Monitor Logs
```bash
# Laravel application logs
tail -f storage/logs/laravel.log

# Web server error logs
tail -f /var/log/nginx/error.log
```

---

**Last Updated:** 2026-04-01  
**Maintainer:** Development Team
