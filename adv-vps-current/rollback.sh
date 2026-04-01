#!/bin/bash
#
# ROLLBACK SCRIPT - ADV CRM
# Rollback to previous deployment state
#
# Usage: ./rollback.sh <backup_timestamp>
# Example: ./rollback.sh 20260401_103000
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_TIMESTAMP="$1"
APP_DIR="/var/www/adv"
BACKUP_DIR="/var/backups/adv"

if [ -z "$BACKUP_TIMESTAMP" ]; then
    echo -e "${RED}❌ Error: Backup timestamp required${NC}"
    echo ""
    echo "Usage: $0 <backup_timestamp>"
    echo ""
    echo "Available backups:"
    ls -lh "$BACKUP_DIR" 2>/dev/null | grep backup_ || echo "  No backups found"
    exit 1
fi

BACKUP_PREFIX="${BACKUP_DIR}/backup_${BACKUP_TIMESTAMP}"

echo -e "${YELLOW}==================================${NC}"
echo -e "${YELLOW}  ADV CRM - Rollback${NC}"
echo -e "${YELLOW}  Backup: ${BACKUP_TIMESTAMP}${NC}"
echo -e "${YELLOW}==================================${NC}\n"

# Check if we're root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Please run as root or with sudo${NC}"
    exit 1
fi

# Check if backup exists
if [ ! -f "${BACKUP_PREFIX}_git_commit.txt" ]; then
    echo -e "${RED}❌ Backup not found: ${BACKUP_PREFIX}_git_commit.txt${NC}"
    echo ""
    echo "Available backups:"
    ls -lh "$BACKUP_DIR" | grep backup_
    exit 1
fi

# Read target commit
TARGET_COMMIT=$(cat "${BACKUP_PREFIX}_git_commit.txt")
CURRENT_COMMIT=$(cd "$APP_DIR" && git rev-parse HEAD)

echo -e "${BLUE}Rollback Plan:${NC}"
echo "  Current commit:  $CURRENT_COMMIT"
echo "  Target commit:   $TARGET_COMMIT"
echo "  Backup location: ${BACKUP_PREFIX}*"
echo ""

# Confirm rollback
read -p "$(echo -e ${YELLOW}Continue with rollback? [yes/no]:${NC}) " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}Rollback cancelled${NC}"
    exit 0
fi

cd "$APP_DIR"

echo ""
echo -e "${YELLOW}[1/6] Reverting git to previous commit...${NC}"
git reset --hard "$TARGET_COMMIT"
echo -e "${GREEN}✅ Git reverted${NC}\n"

echo -e "${YELLOW}[2/6] Restoring database...${NC}"
if [ -f "${BACKUP_PREFIX}_database.sqlite" ]; then
    cp "${BACKUP_PREFIX}_database.sqlite" database/database.sqlite
    chown www-data:www-data database/database.sqlite
    chmod 664 database/database.sqlite
    echo -e "${GREEN}✅ Database restored${NC}"
else
    echo -e "${YELLOW}⚠️  Database backup not found, skipping${NC}"
fi
echo ""

echo -e "${YELLOW}[3/6] Restoring .env...${NC}"
if [ -f "${BACKUP_PREFIX}_env" ]; then
    cp "${BACKUP_PREFIX}_env" .env
    chown www-data:www-data .env
    chmod 644 .env
    echo -e "${GREEN}✅ .env restored${NC}"
else
    echo -e "${YELLOW}⚠️  .env backup not found, skipping${NC}"
fi
echo ""

echo -e "${YELLOW}[4/6] Restoring uploads folder...${NC}"
if [ -f "${BACKUP_PREFIX}_uploads.tar.gz" ]; then
    rm -rf public/uploads
    mkdir -p public/uploads
    tar -xzf "${BACKUP_PREFIX}_uploads.tar.gz" -C .
    chown -R www-data:www-data public/uploads
    chmod -R 755 public/uploads
    echo -e "${GREEN}✅ Uploads folder restored${NC}"
else
    echo -e "${YELLOW}⚠️  Uploads backup not found, ensuring folder exists${NC}"
    mkdir -p public/uploads
    chown -R www-data:www-data public/uploads
    chmod -R 755 public/uploads
fi
echo ""

echo -e "${YELLOW}[5/6] Clearing caches...${NC}"
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
echo -e "${GREEN}✅ Caches cleared${NC}\n"

echo -e "${YELLOW}[6/6] Restarting services...${NC}"
systemctl restart php8.2-fpm || systemctl restart php8.1-fpm || systemctl restart php-fpm
systemctl reload nginx
echo -e "${GREEN}✅ Services restarted${NC}\n"

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}  ✅ ROLLBACK COMPLETED${NC}"
echo -e "${GREEN}==================================${NC}\n"

echo -e "${BLUE}Rollback Summary:${NC}"
echo "  → Reverted from: $CURRENT_COMMIT"
echo "  → Reverted to:   $TARGET_COMMIT"
echo "  → Backup used:   ${BACKUP_PREFIX}*"
echo "  → Completed at:  $(date)"
echo ""

echo -e "${YELLOW}Verification:${NC}"
echo "  → Check application: curl http://localhost"
echo "  → Check logs: tail -f storage/logs/laravel.log"
echo ""
