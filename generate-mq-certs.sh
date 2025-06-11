#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# IBM MQ Mutual TLS Certificate Generator
# - Generates client and server keystores
# - Extracts certs as .arm files
# - Cross-imports trust anchors for mTLS
# - Uses distinct labels for clarity
# -----------------------------------------------------------------------------

set -euo pipefail

# === CONFIGURATION ===
CERT_PWD="${CERT_PWD:-password}"

DN_SERVER="${DN_SERVER:-CN=QM1,OU=MQ,O=IBM,C=US}"
DN_CLIENT="${DN_CLIENT:-CN=Client,OU=MQ,O=IBM,C=US}"

CERT_LABEL_SERVER="ibmwebspheremqqm1_server"
CERT_LABEL_CLIENT="ibmwebspheremqqm1_client"

WORK_DIR="$(pwd)/mq-certs"
mkdir -p "$WORK_DIR"
chmod 0777 "$WORK_DIR"

# === Ensure MQ tools are in PATH ===
MQ_PATHS="/opt/mqm/bin:/opt/mqm/samp/bin"
if [[ ":$PATH:" != *":/opt/mqm/bin:"* ]] || [[ ":$PATH:" != *":/opt/mqm/samp/bin:"* ]]; then
  export PATH="$MQ_PATHS:$PATH"
fi

# === Function: Generate KDB, self-signed cert, and ARM ===
generate_initial_keystore() {
  local role=$1
  local kdb_file=$2
  local dn=$3
  local arm_file=$4
  local label=$5

  if [ ! -f "$WORK_DIR/$kdb_file" ]; then
    echo "🔧 Creating $role keystore: $kdb_file..."
    runmqakm -keydb -create -db "$WORK_DIR/$kdb_file" -pw "$CERT_PWD" -type cms -stash
    runmqakm -cert  -create -db "$WORK_DIR/$kdb_file" -pw "$CERT_PWD" -label "$label" -dn "$dn"
    runmqakm -cert  -extract -db "$WORK_DIR/$kdb_file" -pw "$CERT_PWD" -label "$label" -target "$WORK_DIR/$arm_file" -format ascii
  else
    echo "🔁 $kdb_file already exists – skipping."
  fi

  ls -l "$WORK_DIR"
}

# === Function: Import peer cert for mTLS trust ===
import_peer_cert() {
  local kdb_file=$1
  local peer_arm=$2
  local peer_label=$3

  if [ -f "$WORK_DIR/$peer_arm" ]; then
    echo "🔗 Importing $peer_label into $kdb_file..."
    runmqakm -cert -add -db "$WORK_DIR/$kdb_file" -pw "$CERT_PWD" -label "$peer_label" -file "$WORK_DIR/$peer_arm" -format ascii || true
  else
    echo "⚠️ WARNING: $peer_arm not found for import into $kdb_file"
  fi

  echo "🔍 Certificates in $kdb_file:"
  runmqakm -cert -list -db "$WORK_DIR/$kdb_file" -pw "$CERT_PWD"
}

# === EXECUTION ===

# Step 1: Server keystore
generate_initial_keystore "server" "serverkey.kdb" "$DN_SERVER" "qm1_cert.arm" "$CERT_LABEL_SERVER"

# Step 2: Client keystore
generate_initial_keystore "client" "clientkey.kdb" "$DN_CLIENT" "client_cert.arm" "$CERT_LABEL_CLIENT"

# Step 3: Cross-import trust anchors
import_peer_cert "clientkey.kdb" "qm1_cert.arm" "qm1_signer"
import_peer_cert "serverkey.kdb" "client_cert.arm" "client_signer"

# Step 4: stash passwords
cd "$WORK_DIR"
runmqakm -keydb -stashpw -db clientkey.kdb -pw "$CERT_PWD"
runmqakm -keydb -stashpw -db serverkey.kdb -pw "$CERT_PWD"
cd ..

# Done
echo -e "\n✅ All certificates and keystores created in $WORK_DIR"
ls -l "$WORK_DIR"

# Set permissions for generated files
chmod 0664 "$WORK_DIR"/*