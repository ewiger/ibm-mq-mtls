#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Generate and cross-import all MQ server and client certificates, merging
# all outputs into mq-certs for server consumption.
# ---------------------------------------------------------------------------
set -euo pipefail

# Clean and recreate mq-certs
rm -rf mq-certs
mkdir -p mq-certs

# Step 1: Generate server keystore and public cert in server-certs
./bootstrap-server-certs.sh
sudo chown $(id -u):$(id -g) server-certs/*
chmod 644 server-certs/*

# Step 2: Generate client keystore and public cert in client-certs
./bootstrap-client-certs.sh
sudo chown $(id -u):$(id -g) client-certs/*
chmod 644 client-certs/*

# Step 3: Cross-import public certs
cp server-certs/qm1_cert.arm client-certs/
cp client-certs/client_cert.arm server-certs/

# Step 4: Merge all outputs into mq-certs
cp server-certs/* mq-certs/
cp client-certs/* mq-certs/

# Step 5: Merge all public certs into mq-certs/merged_certs.arm
cat mq-certs/*.arm > mq-certs/merged_certs.arm

# Step 6: (Optional) List contents for verification
ls -l mq-certs/
echo "✅  All keys generated, cross-imported, and merged in mq-certs/merged_certs.arm"
