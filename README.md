# ADV CRM Report - Local Development

Aplikasi Advanta CRM yang di-pull dari VPS production (202.10.40.89).

## Setup

```bash
cd adv-vps-current
php artisan serve --host=0.0.0.0 --port=8000
```

## Database

- **Development**: SQLite (`database/database.sqlite`)
- **Production**: MySQL (`shiftech_crm`) di VPS
- Backup VPS: `shiftech_crm_vps.sql`

## Struktur

```
adv-vps-current/           ← Aplikasi utama
├── app/                   ← Source code Laravel
├── database/              ← Migrations & SQLite database
├── public/build/          ← Frontend assets (Vite build)
├── resources/             ← Views & CSS/JS source
├── storage/               ← Session, logs, cache
└── .env                   ← Config lokal (SQLite)
```

## Deployment (ke VPS)

```bash
# Build frontend
npm run build

# Deploy dengan rsync (exclude sensitif files)
rsync -avz --exclude '.env' --exclude 'node_modules' \
  --exclude 'vendor' --exclude 'storage/*' \
  --exclude 'bootstrap/cache' --exclude 'public/uploads' \
  ./ root@202.10.40.89:/var/www/adv/
```

## Notes

- Frontend build: `npm run build` (Vite)
- PHP 8.3.14 (VPS 8.4, installed with `--ignore-platform-reqs`)
- APP_KEY dari VPS sudah di-copy ke `.env` lokal
