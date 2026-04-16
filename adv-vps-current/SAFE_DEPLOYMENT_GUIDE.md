# 🚀 Safe Deployment Guide

## Quick Start

```bash
# 1. SSH to server
ssh root@202.10.40.89

# 2. Navigate to app
cd /var/www/adv

# 3. Download deployment script
git pull origin main

# 4. Run safe deployment
chmod +x safe-deploy.sh
./safe-deploy.sh
```

## What This Deployment Fixes

**Issue:** Foto hasil panen tidak tampil di Product Knowledge  
**Root Cause:** Folder `/public/uploads` tidak ada  
**Solution:** Script akan otomatis membuat folder dengan permission yang benar

---

## Pre-Deployment Checklist

- [ ] Backup current state (auto by script)
- [ ] Notify team about deployment
- [ ] Check server disk space: `df -h`
- [ ] Check current application status
- [ ] Plan rollback if needed

---

## Deployment Steps (Detailed)

### Step 1: Connect to Server

```bash
ssh root@202.10.40.89
```

### Step 2: Check Current State

```bash
cd /var/www/adv

# Check current commit
git log -1 --oneline

# Check uploads folder (should not exist or empty)
ls -ld public/uploads/ 2>&1

# Check application is running
curl -I http://localhost
```

### Step 3: Run Safe Deployment

```bash
# Make script executable
chmod +x safe-deploy.sh

# Run deployment (with automatic backup)
./safe-deploy.sh
```

**Script will:**
1. ✅ Create backup (database, .env, uploads)
2. ✅ Stash local changes
3. ✅ Pull latest code from git
4. ✅ Install dependencies (composer, npm)
5. ✅ **Create and configure /public/uploads folder**
6. ✅ Run database migrations
7. ✅ Clear and rebuild caches
8. ✅ Restart services (php-fpm, nginx)
9. ✅ Verify deployment success

### Step 4: Test Photo Upload

```bash
# After deployment, test immediately:

# 1. Check uploads folder exists
ls -ld /var/www/adv/public/uploads/
# Should show: drwxr-xr-x www-data www-data

# 2. Test write permission
touch /var/www/adv/public/uploads/test.txt && rm /var/www/adv/public/uploads/test.txt
# Should succeed without error

# 3. Monitor logs during testing
tail -f /var/www/adv/storage/logs/laravel.log
```

### Step 5: Manual Testing in Browser

1. **Login** as BS user
2. Go to **Master Data → Hasil Panen**
3. **Upload** a test photo (JPG/PNG)
4. **Submit** form
5. Check **Product Knowledge → Hasil Panen** tab
6. **Verify:** Photo appears in card and detail view

---

## Rollback (If Needed)

If deployment fails or causes issues:

```bash
cd /var/www/adv

# List available backups
ls -lh /var/backups/adv/

# Rollback to specific backup
chmod +x rollback.sh
./rollback.sh 20260401_103000  # Use your backup timestamp
```

**Rollback will:**
- Revert git to previous commit
- Restore database
- Restore .env
- Restore uploads folder
- Clear caches
- Restart services

---

## Monitoring After Deployment

### Check Application Health

```bash
# Application responding?
curl -I http://localhost

# Check PHP-FPM status
systemctl status php8.2-fpm

# Check Nginx status
systemctl status nginx

# Check error logs
tail -100 /var/log/nginx/error.log
tail -100 /var/www/adv/storage/logs/laravel.log
```

### Monitor Upload Activity

```bash
# Watch uploads folder for new files
watch -n 2 'ls -lth /var/www/adv/public/uploads/ | head -20'

# Check database for photo records
sqlite3 /var/www/adv/database/database.sqlite "
  SELECT COUNT(*) as total_photos 
  FROM product_harvest_result_photos;
"
```

---

## Troubleshooting

### Issue: Script permission denied

```bash
chmod +x safe-deploy.sh
# Try again
./safe-deploy.sh
```

### Issue: Git pull fails (merge conflict)

```bash
# Stash changes
git stash

# Pull again
git pull origin main

# If still fails, hard reset (caution!)
git reset --hard origin/main
```

### Issue: Composer install fails

```bash
# Clear composer cache
composer clear-cache

# Try again
composer install --no-dev --optimize-autoloader
```

### Issue: Uploads folder still not writable

```bash
# Manually fix permissions
mkdir -p /var/www/adv/public/uploads
chown -R www-data:www-data /var/www/adv/public/uploads
chmod -R 755 /var/www/adv/public/uploads

# Verify
ls -ld /var/www/adv/public/uploads/
touch /var/www/adv/public/uploads/test.txt && rm /var/www/adv/public/uploads/test.txt
```

### Issue: Photos still don't appear after deployment

**Check 1: Files being saved?**
```bash
ls -lth /var/www/adv/public/uploads/harvest_*
```

**Check 2: Database records created?**
```bash
sqlite3 /var/www/adv/database/database.sqlite "
  SELECT * FROM product_harvest_result_photos 
  ORDER BY id DESC LIMIT 5;
"
```

**Check 3: Path normalization?**
```bash
# Check Laravel logs for path errors
grep -i "upload\|photo\|image" /var/www/adv/storage/logs/laravel.log | tail -20
```

---

## Post-Deployment Verification Checklist

- [ ] Application homepage loads without errors
- [ ] BS user can access Hasil Panen form
- [ ] Photo upload works (file saved to disk)
- [ ] Photo appears in Product Knowledge tab
- [ ] Thumbnails display correctly
- [ ] No errors in Laravel logs
- [ ] No errors in Nginx logs
- [ ] Service worker updated (check browser console)

---

## Emergency Contacts

**If deployment fails:**
1. Check logs first: `tail -f /var/www/adv/storage/logs/laravel.log`
2. Try rollback: `./rollback.sh <backup_timestamp>`
3. Contact development team

**Critical Issues:**
- Application down: Check nginx/php-fpm status
- Database locked: Check file permissions
- Upload fails: Check folder ownership and permissions

---

## Deployment Log

After each deployment, document:

```
Date: _____________
Deployed by: _____________
Backup location: _____________
Deployment result: [ ] Success  [ ] Failed  [ ] Rolled back
Issues encountered: _____________
Resolution: _____________
```

---

## Script Files

- **`safe-deploy.sh`** - Main deployment script with backup
- **`rollback.sh`** - Rollback to previous state
- **`DEPLOYMENT_CHECKLIST.md`** - Detailed deployment guide
- **`FIX_FOTO_HASIL_PANEN.md`** - Issue documentation

---

**Last Updated:** 2026-04-01  
**Safe Deployment Ready:** ✅ Yes  
**Rollback Available:** ✅ Yes
