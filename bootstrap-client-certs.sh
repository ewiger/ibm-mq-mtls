#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Build or update the *client* TLS keystore in ./client-certs
# Produces:
#   clientkey.kdb / clientkey.sth – client private key + stash
#   client_cert.arm               – public certificate to give to the server
# Optionally imports ./client-certs/qm1_cert.arm if present.
# ---------------------------------------------------------------------------
set -euo pipefail

IMAGE="${IMAGE:-ibmcom/mq:latest}"
CERT_DIR="${CERT_DIR:-$(pwd)/client-certs}"
PW="${CERT_PWD:-password}"
DN_CLIENT="${DN_CLIENT:-CN=Client,OU=MQ,O=IBM,C=US}"

mkdir -p "$CERT_DIR"
chmod 0777 "$CERT_DIR"

docker run --rm -e LICENSE=accept --entrypoint bash \
  -v "$CERT_DIR:/keys" \
  -v "$(pwd)/scripts/client-certs-inside.sh:/client-certs-inside.sh" \
  "$IMAGE" /client-certs-inside.sh

ls -l "$CERT_DIR"
echo "✅  Client keystore is ready in $CERT_DIR"
