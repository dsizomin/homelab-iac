#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
DUMP_DIR="/srv/data/_prebackup_dumps"
mkdir -p "$DUMP_DIR"

timestamp="$(date +%F_%H-%M-%S)"

echo "[prebackup] Starting database dumps..."
for database in authentik paperless; do
  if docker ps --format '{{.Names}}' | grep -q "^${database}-db$"; then
    echo "[prebackup] Dumping database: $database..."
    docker exec "${database}-db" pg_dumpall -U "$database" >"$DUMP_DIR/${database}_${timestamp}.sql"
  else
    echo "[prebackup] Skipping database: $database (container not found)"
  fi
done
echo "[prebackup] Database dumps completed."

echo "[prebackup] Cleaning up old database dumps..."
# Keep only N most recent dumps to avoid growth
ls -1t "$DUMP_DIR"/*.sql 2>/dev/null | tail -n +8 | xargs -r rm -f
echo "[prebackup] Old database dumps cleaned up."

echo "[backup] Starting restic backup..."
sops exec-env "${SCRIPT_DIR}/secrets.env" "restic backup \
  /srv/data \
  --exclude-file ${SCRIPT_DIR}/excludes.txt \
  --tag docker,apps,homelab"
echo "[backup] Restic backup completed."

echo "[prune] Starting restic prune..."
sops exec-env "$SCRIPT_DIR/secrets.env" 'restic forget \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 12 \
  --prune'
echo "[prune] Restic prune completed."

echo "[check] Starting restic integrity check..."
sops exec-env "$SCRIPT_DIR/secrets.env" 'restic check --read-data-subset=1/20'
echo "[check] Restic integrity check completed."
echo "[backup.sh] All tasks completed successfully."
