#!/bin/bash

##############################################################################
# SAFE DEPLOYMENT - Copy & Paste Commands
# Deploy Reminder WA UI Redesign
##############################################################################

cat << 'INSTRUCTIONS'

╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║          🚀 SAFE DEPLOYMENT - REMINDER WA UI                   ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

📋 DEPLOYMENT SUMMARY:
  - Feature: Redesigned Reminder WA settings page
  - Risk Level: 🟢 LOW (Frontend only, no backend changes)
  - Files Changed: 1 Vue component + compiled assets
  - Rollback: Available (automatic backup)
  - Duration: ~5 minutes

════════════════════════════════════════════════════════════════

STEP 1: CONNECT TO SERVER
════════════════════════════════════════════════════════════════

Run this command in your terminal:

    ssh root@202.10.40.89

════════════════════════════════════════════════════════════════

STEP 2: DEPLOY (Copy & Paste All Commands Below)
════════════════════════════════════════════════════════════════

# Navigate to app directory
cd /var/www/adv

# Create backup timestamp
BACKUP_TS=$(date +%Y%m%d_%H%M%S)
echo "📅 Backup timestamp: $BACKUP_TS"

# Create backup directory
mkdir -p /var/backups/adv/reminder-ui-$BACKUP_TS

# Backup current files
echo "💾 Creating backup..."
cp -r public/build /var/backups/adv/reminder-ui-$BACKUP_TS/
cp resources/js/pages/admin/reminder/Edit.vue /var/backups/adv/reminder-ui-$BACKUP_TS/
echo "✅ Backup created at: /var/backups/adv/reminder-ui-$BACKUP_TS"

# Show current status
echo ""
echo "📋 Current status:"
git log -1 --oneline
git status --short

# Stash local changes
echo ""
echo "📦 Stashing local changes..."
git stash save "Auto-stash before reminder UI deployment $BACKUP_TS"

# Pull latest code
echo ""
echo "⬇️ Pulling latest changes..."
git fetch origin copilot/optimize-desktop-mobile-view
git checkout copilot/optimize-desktop-mobile-view
git pull origin copilot/optimize-desktop-mobile-view

# Show what was pulled
echo ""
echo "📝 Latest changes:"
git log --oneline -5

# Clear caches
echo ""
echo "🧹 Clearing caches..."
php artisan cache:clear
php artisan view:clear
php artisan config:clear
php artisan route:clear

# Restart services
echo ""
echo "🔄 Restarting services..."
systemctl restart php8.2-fpm
systemctl restart nginx

# Verify deployment
echo ""
echo "🔍 Verifying deployment..."
curl -I http://localhost | head -1

# Check files exist
echo ""
echo "📂 Checking files..."
ls -lh resources/js/pages/admin/reminder/Edit.vue
ls -lh public/build/assets/app-*.css | tail -2
ls -lh public/build/assets/app-*.js | tail -2

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  ✅ DEPLOYMENT COMPLETED!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "💾 Backup: /var/backups/adv/reminder-ui-$BACKUP_TS"
echo "📍 Test URL: http://202.10.40.89/admin/settings/reminder/wa"
echo ""

════════════════════════════════════════════════════════════════

STEP 3: TESTING CHECKLIST
════════════════════════════════════════════════════════════════

Open in browser: http://202.10.40.89/admin/settings/reminder/wa

Desktop Testing (1920x1080):
  ☐ Page loads without errors
  ☐ Modern card design visible
  ☐ Sidebar on the right side
  ☐ Monthly reminders in 2 columns
  ☐ Toggle switches work
  ☐ Click tag → inserts into template
  ☐ Save button works

Mobile Testing (375px width):
  ☐ Resize browser to mobile size
  ☐ Cards stack vertically
  ☐ Sidebar moves to bottom
  ☐ Buttons are full-width
  ☐ All content readable

Functional Testing:
  ☐ Toggle ON → template field appears
  ☐ Toggle OFF → template field hides
  ☐ Click textarea → becomes active
  ☐ Click tag → inserts into active field
  ☐ Save form → no errors
  ☐ Check browser console → no errors

════════════════════════════════════════════════════════════════

ROLLBACK (Only if needed)
════════════════════════════════════════════════════════════════

If deployment causes issues, run this on server:

# Find your backup timestamp from above
BACKUP_TS="<your_timestamp_here>"

# Restore files
cp -r /var/backups/adv/reminder-ui-$BACKUP_TS/build/* public/build/
cp /var/backups/adv/reminder-ui-$BACKUP_TS/Edit.vue resources/js/pages/admin/reminder/

# Clear cache
php artisan cache:clear
systemctl restart php8.2-fpm nginx

echo "✅ Rolled back to previous version"

════════════════════════════════════════════════════════════════

TROUBLESHOOTING
════════════════════════════════════════════════════════════════

Issue: Page shows old UI
Solution: Clear browser cache (Ctrl+Shift+R)

Issue: 404 on assets
Solution: 
  ls -la public/build/assets/app-*
  cat public/build/manifest.json

Issue: Tags not inserting
Solution: 
  - Click template field first
  - Then click tag
  - Check browser console (F12)

Issue: App not responding
Solution:
  systemctl status php8.2-fpm nginx
  tail -50 /var/www/adv/storage/logs/laravel.log

════════════════════════════════════════════════════════════════

📞 SUPPORT INFO
════════════════════════════════════════════════════════════════

Documentation:
  - DEPLOYMENT_REMINDER_UI.md (detailed guide)
  - DEPLOYMENT_RUNBOOK.md (general procedures)

Log Files:
  - Application: /var/www/adv/storage/logs/laravel.log
  - Nginx: /var/log/nginx/error.log
  - PHP-FPM: /var/log/php8.2-fpm.log

════════════════════════════════════════════════════════════════

INSTRUCTIONS

echo ""
echo "✅ Ready to deploy!"
echo ""
echo "Copy the commands in STEP 2 and paste them on the server."
echo ""
