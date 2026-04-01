#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${APP_PATH:-/var/www/adv}"
BACKUP_PATH="${BACKUP_PATH:-/root/deploy-backups}"
LOG_RETENTION_DAYS="${LOG_RETENTION_DAYS:-14}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"
LARGE_FILE_SIZE_MB="${LARGE_FILE_SIZE_MB:-100}"
TOP_N="${TOP_N:-30}"

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-}"
DB_NAME="${DB_NAME:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

msg() {
  echo -e "${BLUE}==>${NC} $*"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $*"
}

ok() {
  echo -e "${GREEN}[OK]${NC} $*"
}

err() {
  echo -e "${RED}[ERR]${NC} $*" >&2
}

usage() {
  cat <<'EOF'
Manage VPS data untuk aplikasi Laravel (audit & cleanup aman).

Penggunaan:
  ./manage-vps.sh audit
  ./manage-vps.sh db-audit --db-name nama_db [--db-user root] [--db-pass '***']
  ./manage-vps.sh cleanup [--apply]
  ./manage-vps.sh help

Perintah:
  audit      Audit filesystem: disk usage, folder besar, file besar, log/upload size.
  db-audit   Audit database MySQL/MariaDB: ukuran tabel & jumlah baris tabel besar.
  cleanup    Bersihkan log/backup lama. Default DRY-RUN, pakai --apply untuk eksekusi.

Environment variable (opsional):
  APP_PATH=/var/www/adv
  BACKUP_PATH=/root/deploy-backups
  LOG_RETENTION_DAYS=14
  BACKUP_RETENTION_DAYS=30
  LARGE_FILE_SIZE_MB=100
  TOP_N=30
  DB_HOST=127.0.0.1
  DB_PORT=3306
  DB_USER=root
  DB_PASS=
  DB_NAME=

Contoh:
  APP_PATH=/var/www/adv ./manage-vps.sh audit
  DB_NAME=advanta DB_USER=root ./manage-vps.sh db-audit
  ./manage-vps.sh cleanup --apply
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Perintah '$1' tidak ditemukan."
    exit 1
  fi
}

parse_db_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --db-host)
        DB_HOST="$2"; shift 2 ;;
      --db-port)
        DB_PORT="$2"; shift 2 ;;
      --db-user)
        DB_USER="$2"; shift 2 ;;
      --db-pass)
        DB_PASS="$2"; shift 2 ;;
      --db-name)
        DB_NAME="$2"; shift 2 ;;
      *)
        err "Argumen tidak dikenal untuk db-audit: $1"
        usage
        exit 1 ;;
    esac
  done
}

audit_fs() {
  require_cmd df
  require_cmd du
  require_cmd find
  require_cmd sort

  msg "Audit disk usage partisi"
  df -h

  if [[ ! -d "$APP_PATH" ]]; then
    err "APP_PATH tidak ditemukan: $APP_PATH"
    exit 1
  fi

  msg "Top folder terbesar di $APP_PATH"
  du -h --max-depth=2 "$APP_PATH" 2>/dev/null | sort -h | tail -n "$TOP_N"

  msg "Top file > ${LARGE_FILE_SIZE_MB}MB di $APP_PATH"
  find "$APP_PATH" -type f -size +"${LARGE_FILE_SIZE_MB}"M -printf "%s %p\n" 2>/dev/null | sort -nr | head -n "$TOP_N"

  if [[ -d "$APP_PATH/storage/logs" ]]; then
    msg "Ukuran log Laravel"
    du -h --max-depth=1 "$APP_PATH/storage/logs" 2>/dev/null | sort -h | tail -n "$TOP_N"
  fi

  if [[ -d "$APP_PATH/public/uploads" ]]; then
    msg "Ukuran uploads"
    du -h --max-depth=2 "$APP_PATH/public/uploads" 2>/dev/null | sort -h | tail -n "$TOP_N"
  fi

  ok "Audit filesystem selesai."
}

mysql_exec() {
  local query="$1"
  if [[ -n "$DB_PASS" ]]; then
    MYSQL_PWD="$DB_PASS" mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -N -e "$query"
  else
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -N -e "$query"
  fi
}

audit_db() {
  require_cmd mysql

  if [[ -z "$DB_NAME" ]]; then
    err "DB_NAME belum diisi. Gunakan --db-name atau env DB_NAME."
    exit 1
  fi

  msg "Audit database: $DB_NAME"

  msg "Ukuran database total (MB)"
  mysql_exec "SELECT table_schema, ROUND(SUM(data_length+index_length)/1024/1024,2) AS size_mb FROM information_schema.tables WHERE table_schema='${DB_NAME}' GROUP BY table_schema;"

  msg "Top 30 tabel terbesar"
  mysql_exec "SELECT table_name, ROUND((data_length+index_length)/1024/1024,2) AS size_mb, table_rows FROM information_schema.tables WHERE table_schema='${DB_NAME}' ORDER BY (data_length+index_length) DESC LIMIT 30;"

  ok "Audit database selesai."
}

cleanup_data() {
  require_cmd find

  local mode="dry-run"
  if [[ "${1:-}" == "--apply" ]]; then
    mode="apply"
  elif [[ -n "${1:-}" ]]; then
    err "Argumen tidak dikenal untuk cleanup: $1"
    usage
    exit 1
  fi

  if [[ ! -d "$APP_PATH" ]]; then
    err "APP_PATH tidak ditemukan: $APP_PATH"
    exit 1
  fi

  msg "Mode cleanup: $mode"
  warn "Target log lama: $APP_PATH/storage/logs/*.log (>${LOG_RETENTION_DAYS} hari)"
  warn "Target backup lama: $BACKUP_PATH/*.tar.gz|*.zip|*.sql|*.sql.gz (>${BACKUP_RETENTION_DAYS} hari)"

  if [[ "$mode" == "dry-run" ]]; then
    msg "Preview file log yang akan dihapus"
    find "$APP_PATH/storage/logs" -type f -name "*.log" -mtime +"$LOG_RETENTION_DAYS" -print 2>/dev/null || true

    msg "Preview file backup yang akan dihapus"
    if [[ -d "$BACKUP_PATH" ]]; then
      find "$BACKUP_PATH" -type f \( -name "*.tar.gz" -o -name "*.zip" -o -name "*.sql" -o -name "*.sql.gz" \) -mtime +"$BACKUP_RETENTION_DAYS" -print 2>/dev/null || true
    else
      warn "BACKUP_PATH tidak ditemukan: $BACKUP_PATH"
    fi

    warn "Ini hanya preview. Jalankan './manage-vps.sh cleanup --apply' untuk eksekusi."
    return
  fi

  msg "Menghapus log lama"
  find "$APP_PATH/storage/logs" -type f -name "*.log" -mtime +"$LOG_RETENTION_DAYS" -delete 2>/dev/null || true

  if [[ -d "$BACKUP_PATH" ]]; then
    msg "Menghapus backup lama"
    find "$BACKUP_PATH" -type f \( -name "*.tar.gz" -o -name "*.zip" -o -name "*.sql" -o -name "*.sql.gz" \) -mtime +"$BACKUP_RETENTION_DAYS" -delete 2>/dev/null || true
  else
    warn "BACKUP_PATH tidak ditemukan: $BACKUP_PATH"
  fi

  ok "Cleanup selesai."
}

main() {
  local cmd="${1:-help}"
  shift || true

  case "$cmd" in
    audit)
      audit_fs "$@"
      ;;
    db-audit)
      parse_db_args "$@"
      audit_db
      ;;
    cleanup)
      cleanup_data "$@"
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      err "Perintah tidak dikenal: $cmd"
      usage
      exit 1
      ;;
  esac
}

main "$@"
