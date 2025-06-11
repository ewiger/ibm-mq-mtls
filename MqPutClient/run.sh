#!/bin/bash

# =========================
# Configuration Parameters
# =========================

QUEUE_NAME="Q1"
export CERT_P12="$(pwd)/../mq-certs/clientkey.p12"
KEY_REPO="*USER"  # Not a file path – tells MQ to use CurrentUser certificate store
# KEY_REPO="$CERT_P12"  # Path to the PKCS#12 file containing the client certificate and private key
CIPHER_SPEC="TLS_RSA_WITH_AES_256_CBC_SHA256"
HOST="localhost"
PORT=1414
CHANNEL="CERT.SVRCONN"
CERT_LABEL="ibmwebspheremqqm1_client"

# Optional Peer DN
SSL_PEER="CN=QM1,OU=MQ,O=IBM,C=US"

# Optional: Set to true to enable CRL checking (usually false unless testing cert revocation)
REVOCATION_CHECK=false

# =========================
# Run the Application
# =========================

# Managed .NET MQ client tracing (important for amqmdnetstd.dll)
export AMQ_MQTRACE_ON=1                         # Native library trace (C layer)
export AMQ_MQTRACE_PATH="$(pwd)/mq_traces"
export MQDOTNET_TRACE_ON=1                      # .NET tracing
export MQTRACELEVEL=2                           # Verbose
export MQTRACEPATH="$(pwd)/mq_traces"           # Optional override

export MQCERTLABL=ibmwebspheremqqm1_client

mkdir -p "$AMQ_MQTRACE_PATH"

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
