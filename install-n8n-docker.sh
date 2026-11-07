#!/usr/bin/env bash
set -Eeuo pipefail

CONTAINER_NAME="n8n"
DATA_VOLUME="n8n_data"
PORT="${N8N_PORT:-5678}"
TIMEZONE="${TZ:-Asia/Ho_Chi_Minh}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required to install n8n." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker is installed but its daemon is not available." >&2
  exit 1
fi

if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  if [[ "$(docker inspect --format '{{.State.Running}}' "$CONTAINER_NAME")" != "true" ]]; then
    docker start "$CONTAINER_NAME" >/dev/null
  fi
  echo "Existing n8n container is running."
else
  docker volume create "$DATA_VOLUME" >/dev/null
  docker run --detach \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    --publish "${PORT}:5678" \
    --env "TZ=${TIMEZONE}" \
    --env "GENERIC_TIMEZONE=${TIMEZONE}" \
    --volume "${DATA_VOLUME}:/home/node/.n8n" \
    docker.n8n.io/n8nio/n8n:latest
fi

echo "n8n is starting at http://localhost:${PORT}"
echo "Persistent data volume: ${DATA_VOLUME}"
