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

REMOTE_SYNC_DIR="${REMOTE_SYNC_DIR:-/data00/dev/${USER}/nano-vllm-sync}"
MODEL_DIR="${MODEL_DIR:-/data00/models}"
IMAGE="${IMAGE:-ai-insight-cr-cn-beijing.cr.volces.com/container/warjiang/nano-vllm:main}"

read -r -d '' REMOTE_CMD <<'RCMD' || true
set -euo pipefail
mkdir -p "${REMOTE_SYNC_DIR}"

docker run --rm -it \
  -v "${REMOTE_SYNC_DIR}:/workspace/nano-vllm" \
  -v "${MODEL_DIR}:/workspace/models:ro" \
  --gpus all \
  "${IMAGE}" \
  bash -lc 'cd /workspace/nano-vllm && pip install -e . && exec bash'
RCMD

echo "[run-remote] host:   ${REMOTE_TARGET}"
echo "[run-remote] mount:  ${REMOTE_SYNC_DIR} -> /workspace/nano-vllm"
echo "[run-remote] models: ${MODEL_DIR} -> /workspace/models (ro)"

ssh -t "${REMOTE_TARGET}" \
  "REMOTE_SYNC_DIR='${REMOTE_SYNC_DIR}' MODEL_DIR='${MODEL_DIR}' IMAGE='${IMAGE}' bash -lc ${REMOTE_CMD@Q}"
