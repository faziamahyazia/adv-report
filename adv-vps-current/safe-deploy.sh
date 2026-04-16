#!/bin/bash
#
# SAFE DEPLOYMENT SCRIPT - ADV CRM
# Fixes: Harvest photo upload issue (missing /public/uploads folder)
#
# Usage: ./safe-deploy.sh [production|staging]
# Default: production (202.10.40.89)
#

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="${1:-production}"
APP_DIR="/var/www/adv"
BACKUP_DIR="/var/backups/adv"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/backup_${TIMESTAMP}"

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}  ADV CRM - Safe Deployment${NC}"
echo -e "${BLUE}  Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}  Timestamp: ${TIMESTAMP}${NC}"
echo -e "${BLUE}==================================${NC}\n"

# Safety checks
echo -e "${YELLOW}[1/10] Running pre-deployment safety checks...${NC}"

# Check if we're root or have sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Please run as root or with sudo${NC}"
    exit 1
fi

# Check if app directory exists
if [ ! -d "$APP_DIR" ]; then
    echo -e "${RED}❌ Application directory not found: $APP_DIR${NC}"
    exit 1
fi

# Check if git repo
cd "$APP_DIR"
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Not a git repository: $APP_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Safety checks passed${NC}\n"

# Create backup
echo -e "${YELLOW}[2/10] Creating backup...${NC}"
mkdir -p "$BACKUP_DIR"

# Backup database
if [ -f "database/database.sqlite" ]; then
    echo "  → Backing up database..."
    cp database/database.sqlite "${BACKUP_PATH}_database.sqlite"
    echo -e "${GREEN}    ✅ Database backed up${NC}"
fi

# Backup .env
if [ -f ".env" ]; then
    echo "  → Backing up .env..."
    cp .env "${BACKUP_PATH}_env"
    echo -e "${GREEN}    ✅ .env backed up${NC}"
fi

# Backup uploads folder if exists
if [ -d "public/uploads" ]; then
    echo "  → Backing up uploads folder..."
    tar -czf "${BACKUP_PATH}_uploads.tar.gz" public/uploads/
    echo -e "${GREEN}    ✅ Uploads folder backed up${NC}"
fi

# Save current git commit
CURRENT_COMMIT=$(git rev-parse HEAD)
echo "$CURRENT_COMMIT" > "${BACKUP_PATH}_git_commit.txt"
echo -e "${GREEN}✅ Backup created: ${BACKUP_PATH}*${NC}\n"

# Show current status
echo -e "${YELLOW}[3/10] Current repository status...${NC}"
echo "  Current commit: $(git rev-parse --short HEAD)"
echo "  Current branch: $(git branch --show-current)"
git status --short
echo ""

# Prompt for confirmation
echo -e "${YELLOW}[4/10] Deployment confirmation${NC}"
read -p "  → Continue with deployment? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}❌ Deployment cancelled by user${NC}"
    exit 0
fi
echo ""

# Stash any local changes
echo -e "${YELLOW}[5/10] Stashing local changes (if any)...${NC}"
git stash
echo -e "${GREEN}✅ Local changes stashed${NC}\n"

# Pull latest changes
echo -e "${YELLOW}[6/10] Pulling latest changes from Git...${NC}"
git fetch origin
git pull origin main || {
    echo -e "${RED}❌ Git pull failed!${NC}"
    echo -e "${YELLOW}Rolling back...${NC}"
    git reset --hard "$CURRENT_COMMIT"
    exit 1
}
echo -e "${GREEN}✅ Code updated successfully${NC}\n"

# Install/update dependencies
echo -e "${YELLOW}[7/10] Installing dependencies...${NC}"
echo "  → Composer install..."
composer install --no-dev --optimize-autoloader --no-interaction || {
    echo -e "${RED}❌ Composer install failed!${NC}"
    exit 1
}
echo "  → NPM install..."
npm install --silent || {
    echo -e "${RED}❌ NPM install failed!${NC}"
    exit 1
}
echo "  → NPM build..."
npm run build || {
    echo -e "${RED}❌ NPM build failed!${NC}"
    exit 1
}
echo -e "${GREEN}✅ Dependencies installed${NC}\n"

# Critical: Ensure uploads folder exists
echo -e "${YELLOW}[8/10] Setting up uploads folder (CRITICAL FIX)...${NC}"
mkdir -p public/uploads
chown -R www-data:www-data public/uploads
chmod -R 755 public/uploads

# Also fix storage and cache permissions
chown -R www-data:www-data storage
chown -R www-data:www-data bootstrap/cache
chmod -R 755 storage
chmod -R 755 bootstrap/cache

# Test uploads folder is writable
touch public/uploads/deploy_test_${TIMESTAMP}.txt && rm public/uploads/deploy_test_${TIMESTAMP}.txt || {
    echo -e "${RED}❌ Uploads folder is not writable!${NC}"
    exit 1
}

echo "  → Uploads folder: $(ls -ld public/uploads/ | awk '{print $1, $3, $4}')"
echo -e "${GREEN}✅ Uploads folder configured correctly${NC}\n"

# Run migrations
echo -e "${YELLOW}[9/10] Running database migrations...${NC}"
php artisan migrate --force || {
    echo -e "${RED}❌ Migration failed!${NC}"
    echo -e "${YELLOW}Check database/database.sqlite permissions${NC}"
    exit 1
}
echo -e "${GREEN}✅ Migrations completed${NC}\n"

# Clear and optimize caches
echo -e "${YELLOW}[10/10] Optimizing application...${NC}"
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Rebuild optimized caches
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo -e "${GREEN}✅ Caches optimized${NC}\n"

# Restart services
echo -e "${YELLOW}Restarting services...${NC}"
systemctl restart php8.2-fpm || systemctl restart php8.1-fpm || systemctl restart php-fpm
systemctl reload nginx

echo -e "${GREEN}✅ Services restarted${NC}\n"

# Post-deployment verification
echo -e "${YELLOW}Running post-deployment checks...${NC}"

# Check if app is responding
if curl -f -s -o /dev/null http://localhost; then
    echo -e "${GREEN}✅ Application is responding${NC}"
else
    echo -e "${RED}❌ Application is not responding!${NC}"
    echo -e "${YELLOW}Consider rollback${NC}"
fi

# Check uploads folder
if [ -d "public/uploads" ] && [ -w "public/uploads" ]; then
    echo -e "${GREEN}✅ Uploads folder exists and writable${NC}"
else
    echo -e "${RED}❌ Uploads folder issue detected${NC}"
fi

# Check database
if [ -f "database/database.sqlite" ] && [ -r "database/database.sqlite" ]; then
    echo -e "${GREEN}✅ Database accessible${NC}"
else
    echo -e "${RED}❌ Database not accessible${NC}"
fi

echo ""
echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}  ✅ DEPLOYMENT COMPLETED${NC}"
echo -e "${GREEN}==================================${NC}\n"

echo -e "${BLUE}Deployment Summary:${NC}"
echo "  → Previous commit: $CURRENT_COMMIT"
echo "  → Current commit:  $(git rev-parse HEAD)"
echo "  → Backup location: ${BACKUP_PATH}*"
echo "  → Deployed at:     $(date)"
echo ""

echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Test photo upload: Login as BS → Hasil Panen → Upload photo"
echo "  2. Verify display: Product Knowledge → Hasil Panen tab → Check photos visible"
echo "  3. Monitor logs: tail -f storage/logs/laravel.log"
echo ""

echo -e "${YELLOW}Rollback Instructions (if needed):${NC}"
echo "  cd $APP_DIR"
echo "  git reset --hard $CURRENT_COMMIT"
echo "  cp ${BACKUP_PATH}_database.sqlite database/database.sqlite"
echo "  cp ${BACKUP_PATH}_env .env"
echo "  php artisan cache:clear && systemctl restart php8.2-fpm nginx"
echo ""

echo -e "${GREEN}Deployment log saved to: /var/log/adv-deploy-${TIMESTAMP}.log${NC}"

# Save deployment log
{
    echo "Deployment completed at: $(date)"
    echo "Previous commit: $CURRENT_COMMIT"
    echo "Current commit: $(git rev-parse HEAD)"
    echo "Backup location: ${BACKUP_PATH}*"
    echo "Deployed by: $(whoami)"
} > "/var/log/adv-deploy-${TIMESTAMP}.log"

echo ""
echo -e "${GREEN}🎉 Deployment successful!${NC}"
