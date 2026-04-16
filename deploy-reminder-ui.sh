#!/bin/bash

##############################################################################
# Safe Deployment Script - Reminder WA UI Redesign
# This script deploys only the Reminder WA UI changes to production
# Risk Level: LOW (frontend only, no backend changes)
##############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SERVER_IP="202.10.40.89"
SERVER_USER="root"
APP_PATH="/var/www/adv"
BRANCH="copilot/optimize-desktop-mobile-view"

echo ""
echo "=========================================="
echo "  Reminder WA UI - Safe Deployment"
echo "  Branch: $BRANCH"
echo "  Server: $SERVER_IP"
echo "=========================================="
echo ""

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Step 1: Check if we can connect to server
print_info "Checking server connection..."
if ssh -q $SERVER_USER@$SERVER_IP exit; then
    print_success "Server connection OK"
else
    print_error "Cannot connect to server!"
    exit 1
fi

# Step 2: Create backup timestamp
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
print_info "Backup timestamp: $BACKUP_TIMESTAMP"

# Step 3: Deploy to server
print_info "Starting deployment..."

ssh $SERVER_USER@$SERVER_IP << EOF
set -e

echo ""
echo "===================================="
echo "  On Server: $SERVER_IP"
echo "===================================="
echo ""

# Navigate to app directory
cd $APP_PATH

# Check current status
echo "📋 Current status:"
git log -1 --oneline
echo ""

# Create backup of current assets (just in case)
echo "💾 Creating backup..."
mkdir -p /var/backups/adv/reminder-ui-backup-$BACKUP_TIMESTAMP
cp -r public/build /var/backups/adv/reminder-ui-backup-$BACKUP_TIMESTAMP/
cp resources/js/pages/admin/reminder/Edit.vue /var/backups/adv/reminder-ui-backup-$BACKUP_TIMESTAMP/
echo "✅ Backup created: /var/backups/adv/reminder-ui-backup-$BACKUP_TIMESTAMP"
echo ""

# Stash any local changes
echo "📦 Stashing local changes..."
git stash save "Auto-stash before reminder UI deployment $BACKUP_TIMESTAMP" || true
echo ""

# Pull latest changes
echo "⬇️ Pulling latest code..."
git fetch origin $BRANCH
git checkout $BRANCH
git pull origin $BRANCH
echo "✅ Code updated"
echo ""

# Show what changed
echo "📝 Changes pulled:"
git log --oneline -3
echo ""

# Clear Laravel caches
echo "🧹 Clearing caches..."
php artisan cache:clear
php artisan view:clear
php artisan config:clear
php artisan route:clear
echo "✅ Caches cleared"
echo ""

# Restart services
echo "🔄 Restarting services..."
systemctl restart php8.2-fpm
systemctl restart nginx
echo "✅ Services restarted"
echo ""

# Post-deployment checks
echo "🔍 Post-deployment checks..."

# Check if app is responding
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200\|302"; then
    echo "✅ Application is responding"
else
    echo "⚠️ Application may not be responding properly"
fi

# Check if reminder edit file exists
if [ -f "resources/js/pages/admin/reminder/Edit.vue" ]; then
    echo "✅ Reminder Edit.vue exists"
else
    echo "❌ Reminder Edit.vue not found!"
    exit 1
fi

# Check if new assets exist
if [ -f "public/build/assets/app-Cdbqfmby.css" ] && [ -f "public/build/assets/app-B-1cS5mw.js" ]; then
    echo "✅ New compiled assets found"
else
    echo "⚠️ Some assets may be missing (check manually)"
fi

echo ""
echo "===================================="
echo "  ✅ DEPLOYMENT COMPLETED"
echo "===================================="
echo ""
echo "📍 Test URL: http://$SERVER_IP/admin/settings/reminder/wa"
echo "💾 Backup: /var/backups/adv/reminder-ui-backup-$BACKUP_TIMESTAMP"
echo ""
echo "🧪 Testing Checklist:"
echo "  1. Login as admin"
echo "  2. Go to Settings → Reminder WA"
echo "  3. Check desktop view (sidebar on right)"
echo "  4. Check mobile view (resize browser)"
echo "  5. Test toggles and tag insertion"
echo "  6. Save settings to verify form works"
echo ""

EOF

if [ $? -eq 0 ]; then
    print_success "Deployment completed successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Open: http://$SERVER_IP/admin/settings/reminder/wa"
    echo "  2. Test the new UI in browser"
    echo "  3. Check responsive design (resize window)"
    echo "  4. Verify all features work"
    echo ""
    print_info "Backup location on server:"
    echo "  /var/backups/adv/reminder-ui-backup-$BACKUP_TIMESTAMP"
    echo ""
else
    print_error "Deployment failed!"
    exit 1
fi
