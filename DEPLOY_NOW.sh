#!/bin/bash
# Quick Deploy Command - Copy & Paste ke Server
# ============================================

cat << 'COMMANDS'

════════════════════════════════════════════════════════════════
                    🚀 SAFE DEPLOY COMMANDS
        Copy semua command di bawah ini ke server
════════════════════════════════════════════════════════════════

cd /var/www/adv
BACKUP_TS=$(date +%Y%m%d_%H%M%S)
mkdir -p /var/backups/adv/reminder-ui-$BACKUP_TS
cp -r public/build /var/backups/adv/reminder-ui-$BACKUP_TS/
cp resources/js/pages/admin/reminder/Edit.vue /var/backups/adv/reminder-ui-$BACKUP_TS/
echo "✅ Backup: /var/backups/adv/reminder-ui-$BACKUP_TS"
git stash
git fetch origin copilot/optimize-desktop-mobile-view
git checkout copilot/optimize-desktop-mobile-view
git pull origin copilot/optimize-desktop-mobile-view
php artisan cache:clear
php artisan view:clear
php artisan config:clear
systemctl restart php8.2-fpm nginx
curl -I http://localhost | head -1
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  ✅ DEPLOYMENT COMPLETE!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "💾 Backup: /var/backups/adv/reminder-ui-$BACKUP_TS"
echo "📍 Test: http://202.10.40.89/admin/settings/reminder/wa"
echo ""

COMMANDS
