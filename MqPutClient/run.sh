#!/bin/bash

# =========================
# Configuration Parameters
# =========================

QUEUE_NAME="Q1"
KEY_REPO="*USER"  # Not a file path – tells MQ to use CurrentUser certificate store
CIPHER_SPEC="TLS_RSA_WITH_AES_256_CBC_SHA256"
HOST="localhost"
PORT=1414
CHANNEL="CERT.SVRCONN"
CERT_LABEL="ibmwebspheremqqm1_client"

# Optional Peer DN
SSL_PEER=""

# Optional: Set to true to enable CRL checking (usually false unless testing cert revocation)
REVOCATION_CHECK=false

# =========================
# Run the Application
# =========================

dotnet build -c Release
if [ $? -ne 0 ]; then
  echo "Build failed. Please check the errors above."
  exit 1
fi

./bin/Release/net8.0/MqPutClient \
  -q "$QUEUE_NAME" \
  -k "$KEY_REPO" \
  -s "$CIPHER_SPEC" \
  -h "$HOST" \
  -p "$PORT" \
  -l "$CHANNEL" \
  -cr "$REVOCATION_CHECK" \
  -dn "$SSL_PEER"
