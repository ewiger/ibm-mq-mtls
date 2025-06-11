#!/usr/bin/env bash
# generate-mq-certs.sh
# -----------------------------------------------------------------------------
# All-in-one script to generate IBM MQ server and client TLS certs in one folder
# - Uses Dockerized MQ tooling
# - Server: serverkey.kdb/sth
# - Client: clientkey.kdb/sth
# - Proper mutual TLS via final cross-import (no arm merge)
# -----------------------------------------------------------------------------

set -euo pipefail

# Config
CERT_PWD="${CERT_PWD:-password}"
DN_SERVER="${DN_SERVER:-CN=QM1,OU=MQ,O=IBM,C=US}"
DN_CLIENT="${DN_CLIENT:-CN=Client,OU=MQ,O=IBM,C=US}"
CERT_LABEL="ibmwebspheremqqm1"

WORK_DIR="$(pwd)/mq-certs"
mkdir -p "$WORK_DIR"
chmod 0777 "$WORK_DIR"

# --- Function: Generate KDB and cert (no imports yet) ---
generate_initial_keystore() {
  local role=$1
  local kdb_file=$2
  local dn=$3
  local arm_file=$4

  docker run --rm -e LICENSE=accept --entrypoint bash \
    -v "$WORK_DIR:/keys" "$IMAGE" -c "
      set -e
      cd /keys

      if [ ! -f $kdb_file ]; then
        echo 'Creating $role keystore $kdb_file...'
        runmqakm -keydb -create -db $kdb_file -pw $CERT_PWD -type cms -stash
        runmqakm -cert  -create -db $kdb_file -pw $CERT_PWD -label $CERT_LABEL -dn \"$dn\"
        runmqakm -cert  -extract -db $kdb_file -pw $CERT_PWD -label $CERT_LABEL -target $arm_file -format ascii
      else
        echo '$kdb_file already exists – skipping.'
      fi

      ls -l /keys
    "
}

# --- Function: Import peer cert for mTLS ---
import_peer_cert() {
  local kdb_file=$1
  local peer_arm=$2
  local peer_label=$3

  # Make docker run command optional
  docker run --rm -e LICENSE=accept --entrypoint bash \
    -v "$WORK_DIR:/keys" "$IMAGE" -c "
    set -e
    cd /keys

    if [ -f $peer_arm ]; then
        echo 'Importing $peer_label into $kdb_file...'
        runmqakm -cert -add -db $kdb_file -pw $CERT_PWD -label $peer_label -file $peer_arm -format ascii || true
    else
        echo 'WARNING: $peer_arm not found for import into $kdb_file'
    fi

    runmqakm -cert -list -db $kdb_file -pw $CERT_PWD
    "
}

# Step 1: Generate server cert and export
generate_initial_keystore "server" "serverkey.kdb" "$DN_SERVER" "qm1_cert.arm"

# Step 2: Generate client cert and export
generate_initial_keystore "client" "clientkey.kdb" "$DN_CLIENT" "client_cert.arm"

# Step 3: Cross-import (final mTLS trust setup)
import_peer_cert "clientkey.kdb" "qm1_cert.arm" "qm1_signer"
import_peer_cert "serverkey.kdb" "client_cert.arm" "client_signer"

# Done
echo "✅ All certificates and keystores created in $WORK_DIR"
ls -l "$WORK_DIR"
