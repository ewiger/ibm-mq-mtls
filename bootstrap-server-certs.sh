#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Build or update the *server* TLS keystore in ./server-certs
# Produces:
#   key.kdb / key.sth          – QM1 private key + stash
#   qm1_cert.arm               – public certificate to give to clients
# Optionally imports ./server-certs/client_cert.arm if present.
# ---------------------------------------------------------------------------
set -euo pipefail

IMAGE="${IMAGE:-ibmcom/mq:latest}"
CERT_DIR="${CERT_DIR:-$(pwd)/server-certs}"
PW="${CERT_PWD:-password}"
DN_SERVER="${DN_SERVER:-CN=QM1,OU=MQ,O=IBM,C=US}"

mkdir -p "$CERT_DIR"
chmod 0777 "$CERT_DIR"

set -x

# Run the script inside the container, mounting the script and the output folder

docker run --rm -e LICENSE=accept --entrypoint bash \
  -v "$CERT_DIR:/keys" \
  -v "$(pwd)/scripts/server-certs-inside.sh:/server-certs-inside.sh" \
  "$IMAGE" /server-certs-inside.sh

ls -l "$CERT_DIR"
echo "✅  Server keystore is ready in $CERT_DIR"
