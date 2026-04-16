#!/bin/bash
# Safe Deploy - Complaint UI & BS Sales Total Fix
# ================================================
# Instructions:
# 1. SSH to server: ssh root@202.10.40.89
# 2. Copy & paste all commands below into terminal

cat << 'DEPLOY_COMMANDS'

════════════════════════════════════════════════════════════════
        🚀 DEPLOY: Complaint UI & BS Sales Total Fix
════════════════════════════════════════════════════════════════

cd /var/www/adv

# Create backup
BACKUP_TS=$(date +%Y%m%d_%H%M%S)
mkdir -p /var/backups/adv/complaint-bs-fix-$BACKUP_TS

echo "📦 Creating backup..."
cp -r public/build /var/backups/adv/complaint-bs-fix-$BACKUP_TS/
cp app/Http/Controllers/Admin/SaleController.php /var/backups/adv/complaint-bs-fix-$BACKUP_TS/
cp resources/js/pages/admin/complaint/Detail.vue /var/backups/adv/complaint-bs-fix-$BACKUP_TS/
cp database/database.sqlite /var/backups/adv/complaint-bs-fix-$BACKUP_TS/database.sqlite
git rev-parse HEAD > /var/backups/adv/complaint-bs-fix-$BACKUP_TS/commit_before.txt

echo "✅ Backup created: /var/backups/adv/complaint-bs-fix-$BACKUP_TS"
echo ""

# Stash local changes
echo "💾 Stashing local changes..."
git stash
echo ""

# Fetch and pull latest code
echo "⬇️  Pulling latest code..."
git fetch origin copilot/optimize-desktop-mobile-view
git checkout copilot/optimize-desktop-mobile-view
git pull origin copilot/optimize-desktop-mobile-view
echo ""

# Show what changed
echo "📝 Latest commit:"
git log -1 --oneline
echo ""

# Clear caches
echo "🧹 Clearing caches..."
php artisan cache:clear
php artisan view:clear
php artisan config:clear
php artisan route:clear
echo ""

# Optimize
echo "⚡ Optimizing..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
echo ""

# Fix permissions
echo "🔐 Fixing permissions..."
chown -R www-data:www-data storage bootstrap/cache public/uploads public/build
chmod -R 775 storage bootstrap/cache public/uploads
echo ""

# Restart services
echo "🔄 Restarting services..."
systemctl restart php8.2-fpm
systemctl restart nginx
sleep 2
echo ""

# Test deployment
echo "🧪 Testing deployment..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Application is responding (HTTP $HTTP_STATUS)"
else
    echo "⚠️  Warning: HTTP status is $HTTP_STATUS"
fi
echo ""

echo "════════════════════════════════════════════════════════════════"
echo "  ✅ DEPLOYMENT COMPLETED!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📋 Changes Deployed:"
echo "  1. ✨ Optimized Complaint Detail UI"
echo "     - Better layout with sections and separators"
echo "     - Color badges for Severity and Status"
echo "     - Improved photo grid (3 cols → 2 cols mobile)"
echo "     - Timeline replaced with q-timeline component"
echo ""
echo "  2. 🔧 Fixed BS Sales Total Calculation"
echo "     - BS users now see their correct totals"
echo "     - Agronomists can see BS sales"
echo "     - Removed overly strict price filter"
echo ""
echo "💾 Backup Location:"
echo "   /var/backups/adv/complaint-bs-fix-$BACKUP_TS"
echo ""
echo "📍 Testing URLs:"
echo "   Complaint Detail: http://202.10.40.89/admin/complaints/detail/25"
echo "   Sales (BS user):  http://202.10.40.89/admin/sale"
echo ""
echo "🔍 Monitor Logs:"
echo "   tail -f /var/www/adv/storage/logs/laravel.log"
echo ""
echo "🔄 Rollback (if needed):"
echo "   cd /var/www/adv"
echo "   git reset --hard \$(cat /var/backups/adv/complaint-bs-fix-$BACKUP_TS/commit_before.txt)"
echo "   cp /var/backups/adv/complaint-bs-fix-$BACKUP_TS/database.sqlite database/database.sqlite"
echo "   php artisan cache:clear && systemctl restart php8.2-fpm nginx"
echo ""

DEPLOY_COMMANDS
