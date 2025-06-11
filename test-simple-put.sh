#!/bin/bash
set -e

# Config
CONTAINER_NAME="ibmmq"
CERTS_DIR="/etc/mqm/pki/keys"             # Path inside container
JSON_CCDT_PATH="/etc/mqm/client_ccdt.json"

QMGR_NAME="QM1"
CHANNEL_NAME="CERT.SVRCONN"
IBMMQHOST="localhost"  # Hostname or IP of the MQ server
PORT=1414
CIPHER="TLS_RSA_WITH_AES_256_CBC_SHA256"

# Create JSON CCDT inside the running container
docker exec -i "${CONTAINER_NAME}" bash -c "
  set -e
  cat > ${JSON_CCDT_PATH} <<EOF
{
  \"channel\": [
    {
      \"name\": \"${CHANNEL_NAME}\",
      \"type\": \"clientConnection\",
      \"clientConnection\": {
        \"queueManagerName\": \"${QMGR_NAME}\",
        \"connection\": [
          { \"host\": \"${IBMMQHOST}\", \"port\": ${PORT} }
        ]
      },
      \"transmissionSecurity\": {
        \"cipherSpecification\": \"${CIPHER}\",
        \"certificatePeerName\": \"CN=QM1,OU=MQ,O=IBM,C=US\"
      }
    }
  ]
}
EOF
"

# Run the MQ put command inside the container using the JSON CCDT and MQSERVER
# MQSERVER="${CHANNEL_NAME}/TCP/${IBMMQHOST}(${PORT})"
# -e MQSERVER="$MQSERVER" \
docker exec -e LICENSE=accept \
            -e MQSSLKEYR=${CERTS_DIR}/key \
            -e MQCCDTURL="file://${JSON_CCDT_PATH}" \
            "${CONTAINER_NAME}" bash -c "
  set -e
  export PATH=\$PATH:/opt/mqm/bin:/opt/mqm/samp/bin
  export MQTRACEPATH=/var/mqm/trace
  export MQTRACELEVEL=2
  echo \"foo\" | amqsputc Q1 QM1
"
