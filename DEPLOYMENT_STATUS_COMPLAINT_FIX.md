# 🚀 Deployment Ready - Complaint UI & BS Sales Total Fix

## Status: ✅ READY TO DEPLOY

### Commit Information
- **Branch:** `copilot/optimize-desktop-mobile-view`
- **Latest Commit:** `6ec1e68 - feat: optimize complaint detail UI and fix BS sales total display`
- **Files Changed:** 17 files (491 insertions, 262 deletions)
- **Frontend Built:** ✅ Yes (app-D-M0VjCs.js)

---

## 📋 Changes Summary

### 1. ✨ Complaint Intelligence Detail UI Optimization
**File:** `resources/js/pages/admin/complaint/Detail.vue`

**Improvements:**
- ✅ Better spacing and padding (md instead of sm)
- ✅ Organized layout with clear sections:
  - Informasi Dasar (Kategori, Severity, Status)
  - Produk & Tim (Produk, Batch, BS, Agronomis)
  - Lokasi (Lokasi, Region)
  - Waktu Penanganan (SLA, Response, Resolution Time)
- ✅ Color badges for Severity (red/orange/green) and Status (green/blue/grey)
- ✅ AI Result in highlighted card with blue background
- ✅ Photo grid optimized: 3 columns desktop, 2 columns mobile
- ✅ Timeline replaced from table to q-timeline component
- ✅ Better responsive behavior
- ✅ Error handling for broken images

### 2. 🔧 BS Sales Total Calculation Fix
**File:** `app/Http/Controllers/Admin/SaleController.php`

**Problem Fixed:**
- Filter was too strict: excluded sales if `total_amount = 0` (checking both price AND quantity)
- This caused BS sales with `price=0` to be excluded from totals
- Result: BS users and Agronomists saw `Rp 0` even when they had sales

**Solution:**
```php
// BEFORE: Excluded if price=0 OR quantity=0
whereExists(... havingRaw('SUM(quantity * price) > 0'))

// AFTER: Only exclude if quantity=0 (allow price=0)
whereExists(... where('quantity', '>', 0))
```

**Benefits:**
- ✅ BS users now see their correct sales totals
- ✅ Agronomists can see BS sales under them
- ✅ Total calculation still uses fallback: `quantity * COALESCE(sale_price, product_price_1, product_price_2, 0)`
- ✅ Admin/Agronomist totals still correctly exclude BS to avoid double counting

---

## 🚀 Deployment Instructions

### Option 1: Using GitHub (Recommended)

**Step 1: Push to GitHub** (requires authentication)
```bash
cd /workspaces/adv-report
git push origin copilot/optimize-desktop-mobile-view
```

**Step 2: Deploy on Server**
```bash
# SSH to server
ssh root@202.10.40.89

# Run deployment script
bash < <(curl -s https://raw.githubusercontent.com/faziamahyazia/adv-report/copilot/optimize-desktop-mobile-view/DEPLOY_COMPLAINT_BS_FIX.sh)
```

### Option 2: Manual Deployment (Copy-Paste)

**Step 1: SSH to Server**
```bash
ssh root@202.10.40.89
```

**Step 2: Copy & Paste These Commands**
```bash
cd /var/www/adv

# Create backup
BACKUP_TS=$(date +%Y%m%d_%H%M%S)
mkdir -p /var/backups/adv/complaint-bs-fix-$BACKUP_TS
cp -r public/build /var/backups/adv/complaint-bs-fix-$BACKUP_TS/
cp app/Http/Controllers/Admin/SaleController.php /var/backups/adv/complaint-bs-fix-$BACKUP_TS/
cp resources/js/pages/admin/complaint/Detail.vue /var/backups/adv/complaint-bs-fix-$BACKUP_TS/
cp database/database.sqlite /var/backups/adv/complaint-bs-fix-$BACKUP_TS/database.sqlite
git rev-parse HEAD > /var/backups/adv/complaint-bs-fix-$BACKUP_TS/commit_before.txt
echo "✅ Backup: /var/backups/adv/complaint-bs-fix-$BACKUP_TS"

# Pull latest code
git stash
git fetch origin copilot/optimize-desktop-mobile-view
git checkout copilot/optimize-desktop-mobile-view
git pull origin copilot/optimize-desktop-mobile-view

# Show what changed
git log -1 --oneline

# Clear caches
php artisan cache:clear
php artisan view:clear
php artisan config:clear
php artisan route:clear

# Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Fix permissions
chown -R www-data:www-data storage bootstrap/cache public/uploads public/build
chmod -R 775 storage bootstrap/cache public/uploads

# Restart services
systemctl restart php8.2-fpm nginx
sleep 2

# Test
curl -I http://localhost | head -1

echo "✅ DEPLOYMENT COMPLETE!"
```

---

## 🧪 Testing Checklist

### Test 1: Complaint Detail UI
- [ ] Open: http://202.10.40.89/admin/complaints/detail/25
- [ ] Verify: Better layout with sections
- [ ] Verify: Severity badge shows color (red/orange/green)
- [ ] Verify: Status badge shows color (green/blue/grey)
- [ ] Verify: AI Result in blue card
- [ ] Verify: Photos display in grid (2-3 columns)
- [ ] Verify: Timeline shows as q-timeline (not table)
- [ ] Verify: Mobile view is responsive

### Test 2: BS Sales Total
- [ ] Login as BS user (e.g., Fatkhrokman or Rifki Faisal)
- [ ] Open: http://202.10.40.89/admin/sale
- [ ] Verify: "Total Nilai" shows actual amount (not Rp 0)
- [ ] Verify: "Total Qty" shows actual quantity (not 0)
- [ ] Verify: "Ringkasan per R1/R2" shows data

### Test 3: Agronomist View
- [ ] Login as Agronomist (Agus Herdianto)
- [ ] Open: http://202.10.40.89/admin/sale
- [ ] Verify: Can see BS sales from their team
- [ ] Verify: Totals are not zero
- [ ] Verify: "Ringkasan per Distributor" shows correct data

### Test 4: Application Health
- [ ] No errors in: `tail -f /var/www/adv/storage/logs/laravel.log`
- [ ] Application responds: `curl http://localhost` returns 200
- [ ] All menus accessible
- [ ] No broken images or 404 errors

---

## 🔄 Rollback Procedure (If Needed)

```bash
ssh root@202.10.40.89
cd /var/www/adv

# Find your backup (look for latest complaint-bs-fix-*)
ls -lt /var/backups/adv/

# Rollback (replace YYYYMMDD_HHMMSS with your backup timestamp)
BACKUP_TS=YYYYMMDD_HHMMSS
git reset --hard $(cat /var/backups/adv/complaint-bs-fix-$BACKUP_TS/commit_before.txt)
cp /var/backups/adv/complaint-bs-fix-$BACKUP_TS/database.sqlite database/database.sqlite
cp -r /var/backups/adv/complaint-bs-fix-$BACKUP_TS/public/build public/
php artisan cache:clear
systemctl restart php8.2-fpm nginx

echo "✅ Rollback complete"
```

---

## 📊 Success Criteria

Deployment is successful when ALL of these are true:

- [x] Code committed locally
- [x] Frontend built (app-D-M0VjCs.js exists)
- [ ] Code pushed to GitHub
- [ ] Deployment script executed on server
- [ ] Application responds with HTTP 200
- [ ] Complaint detail page shows improved UI
- [ ] BS users see correct sales totals (not 0)
- [ ] Agronomists see BS sales totals
- [ ] No errors in Laravel logs
- [ ] Mobile view works correctly

---

## 📞 Support

**If issues occur:**
1. Check logs: `tail -f /var/www/adv/storage/logs/laravel.log`
2. Check error logs: `tail -f /var/log/nginx/error.log`
3. Verify services: `systemctl status php8.2-fpm nginx`
4. Rollback if critical issues found

**Contact:**
- Developer: GitHub Copilot CLI
- Repository: https://github.com/faziamahyazia/adv-report

---

**Prepared:** 2026-04-06  
**Risk Level:** 🟢 LOW (UI improvements + query optimization)  
**Estimated Duration:** 10-15 minutes  
**Rollback Available:** ✅ Yes (automated backup)
