#!/usr/bin/env bash
# Open an interactive shell in the running IBM MQ container
# Usage: ./run-mq-shell.sh [container_name]
# Default: container_name=ibmmq

set -euo pipefail

CONTAINER_NAME="${1:-ibmmq}"

if ! docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "Error: Container '$CONTAINER_NAME' is not running."
  exit 1
fi

echo "Attaching to container '$CONTAINER_NAME'..."
docker exec -it "$CONTAINER_NAME" bash
