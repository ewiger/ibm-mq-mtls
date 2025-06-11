#!/bin/bash
set -euo pipefail
# List certificates in mq-certs directory

WORK_DIR="$(pwd)/mq-certs"
CERT_PWD="${CERT_PWD:-password}"

# === Ensure MQ tools are in PATH ===
MQ_PATHS="/opt/mqm/bin:/opt/mqm/samp/bin"
if [[ ":$PATH:" != *":/opt/mqm/bin:"* ]] || [[ ":$PATH:" != *":/opt/mqm/samp/bin:"* ]]; then
  export PATH="$MQ_PATHS:$PATH"
fi

# === Check if mq-certs directory exists ===

if [ ! -d "$WORK_DIR" ]; then
  echo "Error: mq-certs directory does not exist. Please run gen-keys.sh first."
  exit 1
fi

# === List all KDB files and certs in mq-certs directory ===
for kdb in "$WORK_DIR"/*.kdb; do
  echo "\n=== Listing certificates in: $kdb ==="
  runmqakm -cert -list -db "$kdb" -pw "$CERT_PWD"

  if [[ "$kdb" == *"clientkey.kdb" ]]; then
    echo "\n=== Details for client certificate ==="
    runmqakm -cert -details -db "$kdb" -pw "$CERT_PWD" -label "ibmwebspheremqqm1_client"
  fi
  if [[ "$kdb" == *"serverkey.kdb" ]]; then
    echo "\n=== Details for server certificate ==="
    runmqakm -cert -details -db "$kdb" -pw "$CERT_PWD" -label "ibmwebspheremqqm1_server"
  fi
done