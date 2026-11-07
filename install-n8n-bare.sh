#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${SCRIPT_DIR}/n8n"
PORT="${N8N_PORT:-6789}"
PID_FILE="${INSTALL_DIR}/n8n.pid"
LOG_FILE="${INSTALL_DIR}/n8n.log"

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "Node.js and npm are required to install n8n." >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [[ ! -f package.json ]]; then
  npm init -y
fi

npm install n8n

if [[ -f "$PID_FILE" ]]; then
  PID="$(<"$PID_FILE")"
  if [[ "$PID" =~ ^[0-9]+$ ]] && kill -0 "$PID" 2>/dev/null; then
    echo "n8n is already running (PID ${PID}) at http://localhost:${PORT}"
    exit 0
  fi
  rm -f "$PID_FILE"
fi

nohup env N8N_PORT="$PORT" "${INSTALL_DIR}/node_modules/.bin/n8n" start \
  >"$LOG_FILE" 2>&1 </dev/null &
echo "$!" > "$PID_FILE"

echo "n8n is starting at http://localhost:${PORT}"
echo "Package directory: ${INSTALL_DIR}"
echo "Log file: ${LOG_FILE}"
