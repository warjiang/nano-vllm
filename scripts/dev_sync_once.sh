#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
if [[ -f "${PROJECT_ROOT}/.env" ]]; then
  set -a
  source "${PROJECT_ROOT}/.env"
  set +a
fi

REMOTE_HOST="${REMOTE_HOST:-dafe-gpu1}"
REMOTE_USER="${REMOTE_USER:-}"
REMOTE_TARGET="${REMOTE_HOST}"
if [[ -n "${REMOTE_USER}" ]]; then
  REMOTE_TARGET="${REMOTE_USER}@${REMOTE_HOST}"
fi

LOCAL_DIR="${LOCAL_DIR:-${PROJECT_ROOT}}"
REMOTE_SYNC_DIR="${REMOTE_SYNC_DIR:-/data00/dev/${USER}/nano-vllm-sync}"

echo "[sync-once] local:  ${LOCAL_DIR}"
echo "[sync-once] remote: ${REMOTE_TARGET}:${REMOTE_SYNC_DIR}"

ssh "${REMOTE_TARGET}" "mkdir -p '${REMOTE_SYNC_DIR}'"

rsync -az --delete \
  --exclude '.git' \
  --exclude '.venv' \
  --exclude '__pycache__' \
  --exclude '*.pyc' \
  --exclude '.idea' \
  "${LOCAL_DIR}/" "${REMOTE_TARGET}:${REMOTE_SYNC_DIR}/"

echo "[sync-once] done"
