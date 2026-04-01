#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# deploy-safe.sh — Build lokal → rsync ke VPS → artisan di VPS
# Tidak ada build di VPS. Semua yang perlu dibuild diselesaikan di lokal dulu.
# ─────────────────────────────────────────────────────────────────────────────

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
REMOTE_USER="${REMOTE_USER:-root}"
REMOTE_HOST="${REMOTE_HOST:-202.10.40.89}"
REMOTE_PATH="${REMOTE_PATH:-/var/www/adv}"
REMOTE_PASSWORD="${REMOTE_PASSWORD:-Agis1989}"
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=15"
EXCLUDE_FILE="$APP_DIR/.deploy-rsync-excludes"
DRY_RUN="${DRY_RUN:-0}"
VERIFY_UPLOADS="${VERIFY_UPLOADS:-1}"

before_upload_count=""
after_upload_count=""

# Pastikan sshpass tersedia
if ! command -v sshpass &>/dev/null; then
  echo "[ERROR] sshpass tidak ditemukan. Install dulu: sudo apt-get install sshpass"
  exit 1
fi

# ── Cek exclude wajib ─────────────────────────────────────────────────────────
required_excludes=(
  ".env"
  "bootstrap/cache/*.php"
  "public/uploads"
  "storage/framework/sessions"
  "storage/framework/views"
  "storage/logs"
)

for item in "${required_excludes[@]}"; do
  if ! grep -Fxq "$item" "$EXCLUDE_FILE"; then
    echo "[ERROR] Exclude wajib '$item' tidak ada di $EXCLUDE_FILE"
    echo "Deploy dibatalkan untuk melindungi data runtime/upload VPS."
    exit 1
  fi
done

# ── Build lokal ───────────────────────────────────────────────────────────────
if [[ "${SKIP_BUILD:-0}" != "1" ]]; then
  echo ""
  echo "==> [1/4] Build frontend lokal (vite build)"
  cd "$APP_DIR"
  npm run build
  echo "[OK] Build berhasil → public/build/"
else
  echo "==> [1/4] Build dilewati (SKIP_BUILD=1)"
fi

# ── Dry-run rsync ─────────────────────────────────────────────────────────────
echo ""
echo "==> [2/4] Safety check — dry-run rsync"
dryrun_file="$(mktemp)"
SSHPASS="$REMOTE_PASSWORD" sshpass -e rsync -az --delete --dry-run \
  --exclude-from "$EXCLUDE_FILE" \
  -e "ssh $SSH_OPTS" \
  "$APP_DIR/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}" \
  > "$dryrun_file" 2>&1

# Cek apakah akan menghapus path kritikal
if grep -Eq '^\*deleting (public/uploads|storage/framework/sessions|storage/framework/views|storage/logs|\.env|bootstrap/cache/.*\.php)' "$dryrun_file"; then
  echo "[ERROR] Dry-run mendeteksi penghapusan path kritikal. Deploy dibatalkan!"
  grep -E '^\*deleting (public/uploads|storage/framework/sessions|storage/framework/views|storage/logs|\.env|bootstrap/cache/.*\.php)' "$dryrun_file"
  rm -f "$dryrun_file"
  exit 1
fi

total_delete="$(grep -c '^\*deleting ' "$dryrun_file" || true)"
total_transfer="$(grep -c '^>' "$dryrun_file" || true)"
echo "[OK] Dry-run aman — transfer: $total_transfer file, delete: $total_delete file"
rm -f "$dryrun_file"

# ── Snapshot jumlah upload sebelum deploy ─────────────────────────────────────
if [[ "$VERIFY_UPLOADS" == "1" ]]; then
  echo ""
  echo "==> [2b/4] Snapshot upload sebelum deploy"
  before_upload_count="$(SSHPASS="$REMOTE_PASSWORD" sshpass -e ssh $SSH_OPTS "${REMOTE_USER}@${REMOTE_HOST}" "if [ -d '${REMOTE_PATH}/public/uploads' ]; then find '${REMOTE_PATH}/public/uploads' -type f | wc -l; else echo 0; fi" | tr -d '[:space:]')"
  echo "[INFO] File upload sebelum deploy: ${before_upload_count}"
fi

if [[ "$DRY_RUN" == "1" ]]; then
  echo "[OK] DRY_RUN=1 — berhenti setelah safety check."
  exit 0
fi

# ── Rsync lokal → VPS ─────────────────────────────────────────────────────────
echo ""
echo "==> [3/4] Rsync ke VPS ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
SSHPASS="$REMOTE_PASSWORD" sshpass -e rsync -az --delete \
  --exclude-from "$EXCLUDE_FILE" \
  -e "ssh $SSH_OPTS" \
  "$APP_DIR/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
echo "[OK] Rsync selesai"

# ── Post-deploy di VPS ────────────────────────────────────────────────────────
echo ""
echo "==> [4/4] Post-deploy di VPS (migrate + cache)"
SSHPASS="$REMOTE_PASSWORD" sshpass -e ssh $SSH_OPTS "${REMOTE_USER}@${REMOTE_HOST}" bash <<ENDSSH
  set -e
  cd "${REMOTE_PATH}"

  echo "  → Fix permission runtime"
  chown -R www-data:www-data storage bootstrap/cache public/uploads 2>/dev/null || true
  find storage bootstrap/cache public/uploads -type d -exec chmod 775 {} \; 2>/dev/null || true
  find storage bootstrap/cache public/uploads -type f -exec chmod 664 {} \; 2>/dev/null || true

  echo "  → php artisan migrate --force"
  php artisan migrate --force

  echo "  → Bersihkan & rebuild cache Laravel"
  php artisan optimize:clear
  php artisan config:cache
  php artisan route:cache

  echo "  → Restart PHP-FPM (jika ada)"
  systemctl reload php8.3-fpm 2>/dev/null || \
  systemctl reload php8.2-fpm 2>/dev/null || \
  systemctl reload php-fpm 2>/dev/null || \
  true

  echo "[VPS] Post-deploy selesai"
ENDSSH

# ── Verifikasi jumlah upload sesudah deploy ───────────────────────────────────
if [[ "$VERIFY_UPLOADS" == "1" ]]; then
  echo ""
  echo "==> [4b/4] Verifikasi upload sesudah deploy"
  after_upload_count="$(SSHPASS="$REMOTE_PASSWORD" sshpass -e ssh $SSH_OPTS "${REMOTE_USER}@${REMOTE_HOST}" "if [ -d '${REMOTE_PATH}/public/uploads' ]; then find '${REMOTE_PATH}/public/uploads' -type f | wc -l; else echo 0; fi" | tr -d '[:space:]')"
  echo "[INFO] File upload sesudah deploy: ${after_upload_count}"

  if [[ -z "$before_upload_count" || -z "$after_upload_count" ]]; then
    echo "[ERROR] Gagal membaca jumlah file upload untuk verifikasi."
    exit 1
  fi

  if (( after_upload_count < before_upload_count )); then
    echo "[ERROR] Jumlah file upload berkurang setelah deploy (${before_upload_count} -> ${after_upload_count}). Deploy dianggap gagal untuk melindungi data foto."
    exit 1
  fi

  echo "[OK] Verifikasi upload aman (${before_upload_count} -> ${after_upload_count})"
fi

echo ""
echo "==========================================="
echo " Deploy selesai. Build dilakukan di LOKAL."
echo " VPS tidak menjalankan npm/node."
if [[ "$VERIFY_UPLOADS" == "1" ]]; then
  echo " Verifikasi upload aktif (VERIFY_UPLOADS=1)."
fi
echo "==========================================="

