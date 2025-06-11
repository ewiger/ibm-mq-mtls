#!/usr/bin/env bash
# Run the MQSC config script against a running IBM MQ container
# Usage: ./run-mqsc.sh [container_name] [mqsc_file]
# Defaults: container_name=ibmmq, mqsc_file=scripts/20-config.mqsc

set -euo pipefail

CONTAINER_NAME="${1:-ibmmq}"
MQSC_FILE="${2:-scripts/20-config.mqsc}"

if ! docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "Error: Container '$CONTAINER_NAME' is not running."
  exit 1
fi

if [ ! -f "$MQSC_FILE" ]; then
  echo "Error: MQSC file '$MQSC_FILE' not found."
  exit 2
fi

echo "Running MQSC script '$MQSC_FILE' in container '$CONTAINER_NAME'..."
docker exec -i "$CONTAINER_NAME" runmqsc QM1 < "$MQSC_FILE"
echo "✅ MQSC script applied."
