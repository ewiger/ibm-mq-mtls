#!/bin/bash
# Create CLNTCONN Channel and CCDT
set -e

echo "Defining CLNTCONN channel..."

runmqsc <<EOF
DEFINE CHANNEL(CERT.SVRCONN_CLNT) CHLTYPE(CLNTCONN) +
  CONNAME('${IBMMQHOST}(1414)') +
  SSLCIPH('TLS_RSA_WITH_AES_256_CBC_SHA256') REPLACE
END
EOF

echo "Client channel definition written to: /var/mqm/qmgrs/QM1/@ipcc/AMQCLCHL.TAB"
