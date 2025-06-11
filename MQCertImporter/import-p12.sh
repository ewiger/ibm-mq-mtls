#!/bin/zsh
# Export certificate from KDB to PKCS#12 (.p12) file
# Update the following variables as needed
KDB_PATH="../mq-certs/clientkey.kdb"
P12_PATH="../mq-certs/clientkey.p12"
KDB_PASSWORD="password"      # TODO: set your KDB password
P12_PASSWORD="password"      # TODO: set your desired PKCS#12 password
CERT_LABEL="ibmwebspheremqqm1_client"          # TODO: set the certificate label to export

# Export the certificate and private key to PKCS#12
runmqckm -cert -export \
  -db "$KDB_PATH" \
  -stashed \
  -label "$CERT_LABEL" \
  -target "$P12_PATH" \
  -target_type pkcs12 \
  -target_pw "$P12_PASSWORD"

echo "Export complete: $P12_PATH"


# Verify the PKCS#12 file
# openssl pkcs12 -info -in ../mq-certs/clientkey.p12 -nodes
