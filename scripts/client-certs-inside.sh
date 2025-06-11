#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Script to be mounted and run inside the IBM MQ container to generate client certs
# ---------------------------------------------------------------------------
set -euo pipefail

PW="${CERT_PWD:-password}"
DN_CLIENT="${DN_CLIENT:-CN=Client,OU=MQ,O=IBM,C=US}"
KEYS_DIR="/keys"
CERT_LABEL="ibmwebspheremqqm1"

cd "$KEYS_DIR"

if [ ! -f clientkey.kdb ]; then
  echo "Creating client key database..."
  runmqakm -keydb -create -db clientkey.kdb -pw "$PW" -type cms -stash
  runmqakm -cert  -create -db clientkey.kdb -pw "$PW" \
           -label $CERT_LABEL -dn "$DN_CLIENT"
  runmqakm -cert  -extract -db clientkey.kdb -pw "$PW" \
           -label $CERT_LABEL -target client_cert.arm -format ascii
else
  echo "Client clientkey.kdb already exists - skipping creation."
fi

# Import server signer if provided
if [ -f qm1_cert.arm ]; then
  echo "Importing server signer cert..."
  runmqakm -cert -add -db clientkey.kdb -pw "$PW" \
           -label $CERT_LABEL -file qm1_cert.arm -format ascii || true
fi

ls -l "$KEYS_DIR"
echo "✅  Client keystore is ready in $KEYS_DIR"
