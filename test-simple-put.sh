#!/bin/bash
set -euo pipefail

WORKDIR="$(pwd)"
# Keystore base name *inside* the container (no .kdb / .sth extension)
SSLKEY_BASENAME="${WORKDIR}/mq-certs/clientkey"

# Where the JSON CCDT will live *inside* the container
CCDT_PATH="${WORKDIR}/client_ccdt.json"
##############################################################################

# === Ensure MQ tools are in PATH ===
MQ_PATHS="/opt/mqm/bin:/opt/mqm/samp/bin"
if [[ ":$PATH:" != *":/opt/mqm/bin:"* ]] || [[ ":$PATH:" != *":/opt/mqm/samp/bin:"* ]]; then
  export PATH="$MQ_PATHS:$PATH"
fi

export LICENSE=accept
export MQSSLKEYR="${SSLKEY_BASENAME}"
export MQCCDTURL="file://${CCDT_PATH}"

# Mount certs and CCDT locally if not already in place
# Ensure mq-certs and mq-ccdt are in the correct locations

echo "🚀  Putting a test message over mTLS …"

# strmqtrc -t api -p amqsputc
echo "foo" | amqsputc Q1 ""   # "" = use QM name from CCDT
# dspmqtrc /var/mqm/trace/AMQ*.TRC > trace_output.txt

echo "🎉  Done — if no errors appeared, the message reached Q1 securely."
