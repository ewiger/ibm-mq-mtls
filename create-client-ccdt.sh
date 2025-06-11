#!/bin/bash
set -e

# Configuration
TMPQM="TMPQM"
CCDT_TARGET_DIR="./ccdt"
CHANNEL_NAME="CERT.SVRCONN_CLNT"
QMNAME="QM1"
CONNAME="ibmmq(1414)"
SSLCIPH="TLS_RSA_WITH_AES_256_CBC_SHA256"

echo "🔧 Creating temporary queue manager: $TMPQM"
strmqm $TMPQM

echo "📡 Defining CLNTCONN channel: $CHANNEL_NAME"
runmqsc $TMPQM <<EOF
DEFINE CHANNEL(${CHANNEL_NAME}) CHLTYPE(CLNTCONN) +
  QMNAME(${QMNAME}) +
  CONNAME('${CONNAME}') +
  SSLCIPH('${SSLCIPH}') REPLACE
EOF

echo "🧹 Shutting down temporary queue manager: $TMPQM"
endmqm -w $TMPQM

# Copy out the CCDT
CCDT_SOURCE="/var/mqm/qmgrs/${TMPQM}/@ipcc/AMQCLCHL.TAB"

echo "📁 Copying CCDT from ${CCDT_SOURCE}"
mkdir -p "${CCDT_TARGET_DIR}"
cp "${CCDT_SOURCE}" "${CCDT_TARGET_DIR}/AMQCLCHL.TAB"

echo "✅ CCDT is ready at: ${CCDT_TARGET_DIR}/AMQCLCHL.TAB"
echo "   Use it with:"
echo "     export MQCHLLIB=${CCDT_TARGET_DIR}"
echo "     export MQCHLTAB=AMQCLCHL.TAB"
