#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Script to be mounted and run inside the IBM MQ container to generate server certs
# ---------------------------------------------------------------------------
set -euo pipefail

PW="${CERT_PWD:-password}"
DN_SERVER="${DN_SERVER:-CN=QM1,OU=MQ,O=IBM,C=US}"
KEYS_DIR="/keys"
CERT_LABEL="ibmwebspheremqqm1"

cd "$KEYS_DIR"

if [ ! -f key.kdb ]; then
  echo "Creating server key database..."
  runmqakm -keydb -create -db key.kdb -pw "$PW" -type cms -stash
  runmqakm -cert  -create -db key.kdb -pw "$PW" \
           -label $CERT_LABEL -dn "$DN_SERVER"
  runmqakm -cert  -extract -db key.kdb -pw "$PW" \
           -label $CERT_LABEL -target qm1_cert.arm -format ascii
else
  echo "Server key.kdb already exists – skipping creation."
fi

# Import client signer if provided
if [ -f client_cert.arm ]; then
  echo "Importing client signer cert..."
  runmqakm -cert -add -db key.kdb -pw "$PW" \
           -label $CERT_LABEL -file client_cert.arm -format ascii || true
fi

ls -l "$KEYS_DIR"
echo "✅  Server keystore is ready in $KEYS_DIR"
