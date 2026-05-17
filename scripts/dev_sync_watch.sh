#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
if [[ -f "${PROJECT_ROOT}/.env" ]]; then
  set -a
  source "${PROJECT_ROOT}/.env"
  set +a
fi

SYNC_ONCE_SCRIPT="${SCRIPT_DIR}/dev_sync_once.sh"

if [[ ! -x "${SYNC_ONCE_SCRIPT}" ]]; then
  echo "[sync-watch] missing executable: ${SYNC_ONCE_SCRIPT}" >&2
  exit 1
fi

WATCH_DIR="${WATCH_DIR:-${PROJECT_ROOT}}"
SLEEP_SECONDS="${SLEEP_SECONDS:-2}"

echo "[sync-watch] watching: ${WATCH_DIR}"

# Initial sync
"${SYNC_ONCE_SCRIPT}"

if command -v fswatch >/dev/null 2>&1; then
  echo "[sync-watch] mode: fswatch"
  fswatch -o \
    --exclude '.*/\\.git/.*' \
    --exclude '.*/\\.venv/.*' \
    --exclude '.*/__pycache__/.*' \
    --exclude '.*/\\.idea/.*' \
    "${WATCH_DIR}" | while read -r _; do
      "${SYNC_ONCE_SCRIPT}"
    done
elif command -v inotifywait >/dev/null 2>&1; then
  echo "[sync-watch] mode: inotifywait"
  while inotifywait -r -e modify,create,delete,move \
    --exclude '(^|/)\\.git/|(^|/)\\.venv/|(^|/)__pycache__/|(^|/)\\.idea/' \
    "${WATCH_DIR}" >/dev/null 2>&1; do
    "${SYNC_ONCE_SCRIPT}"
  done
else
  echo "[sync-watch] mode: polling (every ${SLEEP_SECONDS}s)"
  while true; do
    "${SYNC_ONCE_SCRIPT}"
    sleep "${SLEEP_SECONDS}"
  done
fi
