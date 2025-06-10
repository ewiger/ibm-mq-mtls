# ibm-mq-mtls
IBM MQ test setup with mTLS auth 


## Generate MQ Certificates
This repository provides scripts to generate the necessary certificates for setting up IBM MQ with mutual TLS (mTLS) authentication. The process involves creating a keystore for the MQ server and a client, and exchanging public certificates between them.

## Prerequisites
- Docker and Docker Compose installed
- OpenSSL installed (for certificate generation)
- Basic knowledge of IBM MQ and mTLS concepts

## Steps to Generate Certificates
1. **Generate and cross-import all certificates**: This step will generate the server and client keystores, cross-import the public certificates, and merge all public certs into `mq-certs/merged_certs.arm` for server consumption.

```bash
./gen-keys.sh
```

2. **Start MQ**: After the certificates are set up, you can start the MQ server using Docker Compose.

```bash
docker compose up -d
```
