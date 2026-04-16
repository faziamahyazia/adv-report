# 📋 Deployment Runbook - Harvest Photo Fix

## Executive Summary

**Issue:** Harvest photos not displaying in Product Knowledge menu  
**Fix:** Ensure `/public/uploads` folder exists with correct permissions  
**Deployment:** Safe automated deployment with backup and rollback  
**Risk Level:** 🟢 LOW (folder creation only, no code logic changes)

---

## 🚀 Ready to Deploy

### Commits Ready for Production:

```
cd2fb10 - Add safe deployment scripts with backup and rollback
ba1ecac - Add documentation and rebuild assets for upload fix
fc87a96 - Fix: Ensure uploads folder exists for harvest photos
```

### Files Changed:

| File | Change | Purpose |
|------|--------|---------|
| `.gitignore` | Modified | Allow `.gitkeep` in uploads folder |
| `public/uploads/.gitkeep` | New | Maintain folder structure in git |
| `DEPLOYMENT_CHECKLIST.md` | New | Deployment procedures |
| `safe-deploy.sh` | New | Automated safe deployment |
| `rollback.sh` | New | Quick rollback script |
| `SAFE_DEPLOYMENT_GUIDE.md` | New | Step-by-step guide |
| `FIX_FOTO_HASIL_PANEN.md` | New | Issue documentation |

---

## ⚡ Quick Deploy (TL;DR)

```bash
# 1. SSH to server
ssh root@202.10.40.89

# 2. Run deployment
cd /var/www/adv
git pull origin main
chmod +x safe-deploy.sh
./safe-deploy.sh

# 3. Test immediately
# - Login as BS user
# - Upload photo in Hasil Panen
# - Check display in Product Knowledge
```

---

## 📝 Step-by-Step Deployment

### STEP 1: Pre-Deployment (5 minutes)

```bash
# Connect to server
ssh root@202.10.40.89

# Check current state
cd /var/www/adv
git status
git log -1 --oneline

# Check disk space
df -h

# Check if app is running
curl -I http://localhost
```

**Expected:**
- Git repo clean
- 5+ GB disk space available
- Application responding with HTTP 200

---

### STEP 2: Pull Latest Code (2 minutes)

```bash
cd /var/www/adv

# Pull deployment scripts and fixes
git pull origin main
```

**Expected output:**
```
Updating f3123b5..cd2fb10
Fast-forward
 .gitignore                      |   3 +-
 DEPLOYMENT_CHECKLIST.md         | 271 +++
 FIX_FOTO_HASIL_PANEN.md        | 123 ++
 SAFE_DEPLOYMENT_GUIDE.md        | 238 +++
 public/uploads/.gitkeep         |   4 +
 safe-deploy.sh                  | 281 ++++
 rollback.sh                     | 147 ++
```

---

### STEP 3: Run Safe Deployment (10 minutes)

```bash
# Make script executable
chmod +x safe-deploy.sh

# Run deployment
./safe-deploy.sh
```

**Script will show:**
```
==================================
  ADV CRM - Safe Deployment
  Environment: production
  Timestamp: 20260401_103000
==================================

[1/10] Running pre-deployment safety checks...
✅ Safety checks passed

[2/10] Creating backup...
  → Backing up database...
    ✅ Database backed up
  → Backing up .env...
    ✅ .env backed up
✅ Backup created: /var/backups/adv/backup_20260401_103000*

[3/10] Current repository status...
  Current commit: f3123b5
  Current branch: main

[4/10] Deployment confirmation
  → Continue with deployment? (yes/no):
```

**Type:** `yes` and press Enter

**Script continues:**
```
[5/10] Stashing local changes...
✅ Local changes stashed

[6/10] Pulling latest changes from Git...
✅ Code updated successfully

[7/10] Installing dependencies...
  → Composer install...
  → NPM install...
  → NPM build...
✅ Dependencies installed

[8/10] Setting up uploads folder (CRITICAL FIX)...
  → Uploads folder: drwxr-xr-x www-data www-data
✅ Uploads folder configured correctly

[9/10] Running database migrations...
✅ Migrations completed

[10/10] Optimizing application...
✅ Caches optimized

Restarting services...
✅ Services restarted

Running post-deployment checks...
✅ Application is responding
✅ Uploads folder exists and writable
✅ Database accessible

==================================
  ✅ DEPLOYMENT COMPLETED
==================================
```

**Save backup timestamp shown (e.g., `20260401_103000`)**

---

### STEP 4: Immediate Testing (5 minutes)

#### Test 1: Uploads Folder

```bash
# Check folder exists
ls -ld /var/www/adv/public/uploads/
# Expected: drwxr-xr-x www-data www-data

# Test write permission
touch /var/www/adv/public/uploads/test.txt && \
rm /var/www/adv/public/uploads/test.txt
# Expected: No errors
```

#### Test 2: Application Health

```bash
# Check app responds
curl -I http://localhost
# Expected: HTTP/1.1 200 OK

# Check logs (should be clean)
tail -20 /var/www/adv/storage/logs/laravel.log
# Expected: No errors
```

#### Test 3: Photo Upload (Browser)

1. Open browser: `http://202.10.40.89`
2. Login as **BS user** (Fatkhrokman)
3. Go to **Master Data → Hasil Panen**
4. Fill form:
   - Produk: Any product
   - Tanggal Panen: Today
   - Jumlah Panen: 100
   - Upload a test photo (JPG/PNG)
5. Click **Simpan**
6. Go to **Master Data → Product Knowledge**
7. Click **Hasil Panen** tab
8. **✅ Verify:** Photo appears in card

#### Test 4: Verify File Saved

```bash
# Check file was saved to disk
ls -lth /var/www/adv/public/uploads/harvest_*
# Expected: See newly uploaded file

# Check database record
sqlite3 /var/www/adv/database/database.sqlite \
  "SELECT id, image_path FROM product_harvest_result_photos ORDER BY id DESC LIMIT 1;"
# Expected: Shows path like: uploads/harvest_1711965432_0_abc123.jpg
```

---

### STEP 5: Monitor (15 minutes)

Keep monitoring for issues:

```bash
# Watch logs
tail -f /var/www/adv/storage/logs/laravel.log

# In another terminal, watch uploads folder
watch -n 5 'ls -lth /var/www/adv/public/uploads/ | head -10'
```

**Monitor for:**
- No errors in logs
- Photo uploads successful
- Display working in browser
- No 500 errors
- No permission denied errors

---

## 🔄 Rollback Procedure (If Needed)

**Only if deployment caused issues!**

```bash
cd /var/www/adv

# List backups
ls -lh /var/backups/adv/

# Rollback using backup timestamp from Step 3
chmod +x rollback.sh
./rollback.sh 20260401_103000

# Verify rollback
curl -I http://localhost
git log -1 --oneline
```

**Rollback will:**
- Revert code to previous commit
- Restore database backup
- Restore .env backup
- Restore uploads folder
- Clear caches and restart services

---

## ✅ Deployment Checklist

**Pre-Deployment:**
- [x] Code committed and pushed
- [x] Deployment scripts ready
- [x] Documentation complete
- [ ] Team notified
- [ ] Backup plan confirmed

**During Deployment:**
- [ ] SSH connected to server
- [ ] Current state checked
- [ ] Safe deployment script executed
- [ ] Backup timestamp saved
- [ ] Script completed successfully

**Post-Deployment:**
- [ ] Uploads folder exists and writable
- [ ] Application responding (HTTP 200)
- [ ] Test photo upload successful
- [ ] Photo displays in Product Knowledge
- [ ] No errors in logs
- [ ] Team notified of completion

**Sign-off:**
```
Deployed by: _________________
Date/Time: ___________________
Backup ID: ___________________
Result: [ ] Success  [ ] Rolled Back
```

---

## 📞 Emergency Procedures

### If Application Goes Down

```bash
# Quick health check
systemctl status nginx
systemctl status php8.2-fpm

# Restart services
systemctl restart php8.2-fpm nginx

# Check logs
tail -50 /var/log/nginx/error.log
tail -50 /var/www/adv/storage/logs/laravel.log
```

### If Rollback Needed

```bash
cd /var/www/adv
./rollback.sh <backup_timestamp>
```

### If Rollback Script Fails

```bash
# Manual rollback
cd /var/www/adv
git reset --hard <previous_commit>
cp /var/backups/adv/backup_*_database.sqlite database/database.sqlite
php artisan cache:clear
systemctl restart php8.2-fpm nginx
```

---

## 📊 Success Criteria

✅ **Deployment Successful** when ALL of these are true:

1. Script completes without errors
2. `/public/uploads` folder exists with `www-data:www-data` ownership
3. Folder has `755` permissions
4. Test file can be written and deleted
5. Application responds with HTTP 200
6. BS user can upload photo
7. Photo file saved to disk (`harvest_*.jpg`)
8. Database record created in `product_harvest_result_photos`
9. Photo displays in Product Knowledge tab
10. No errors in Laravel logs

---

## 📚 References

- **Deployment Guide:** `SAFE_DEPLOYMENT_GUIDE.md`
- **Issue Documentation:** `FIX_FOTO_HASIL_PANEN.md`
- **Testing Guide:** `TESTING_HARVEST_FEATURE.md`
- **General Checklist:** `DEPLOYMENT_CHECKLIST.md`

---

**Prepared:** 2026-04-01  
**Deployment Window:** Anytime (low-risk change)  
**Estimated Duration:** 25 minutes  
**Rollback Available:** Yes (automated)  
**Risk Level:** 🟢 LOW
