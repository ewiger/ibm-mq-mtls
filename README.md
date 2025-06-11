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

## Running dotnet apps

import certs into *USER keystore* (not MQ keystore) and run the .NET apps:

```bash
cd MQCertImporter
dotnet run ../mq-certs/clientkey.p12 password
```

then run the client app:

```bash
cd MqPutClient
dotnet run
```

## FAQ: MQSC Configuration Script (`scripts/20-config.mqsc`)

**Q: How do I troubleshoot connection issues with SSL**

Test with a simple tool (like openssl s_client) to verify SSL handshake:

```bash
openssl s_client -connect localhost:1414
```

If this fails, the problem is at the SSL/TLS layer, not the MQ client.


**Q: When and how is `scripts/20-config.mqsc` executed?**

- The `scripts/20-config.mqsc` file contains MQSC commands to configure the queue manager (create queue, channel, security, etc.).
- This file is mounted into the container at `/etc/mqm/20-config.mqsc` via Docker Compose.
- IBM MQ containers automatically execute any `.mqsc` files found in `/etc/mqm` during the initial creation of the queue manager (when the data directory is empty).
- The script is only run the first time the queue manager is created (i.e., when the `qm1data` volume is empty). If the volume already exists, the script will not be re-run unless you delete the volume or reset the queue manager data.

**To re-run the script:**
1. Stop and remove the running container:

```bash
docker compose down
```
2. Remove the persistent data volume:

```bash
docker volume rm ibm-mq-mtls_qm1data
```
3. Start the container again:

```bash
docker compose up -d
```
This will re-initialize the queue manager and re-apply the configuration in `scripts/20-config.mqsc`.

## Running MQSC Scripts on a Running Container

If you need to apply configuration changes to a running IBM MQ container, you can use the provided `run-mqsc.sh` script. This script allows you to run any MQSC file against the active queue manager without restarting the container.

**Usage:**

```zsh
chmod +x ./run-mqsc.sh
./run-mqsc.sh [container_name] [mqsc_file]
```
- `container_name` (optional): Name of the running MQ container (default: `ibmmq`)
- `mqsc_file` (optional): Path to the MQSC file to apply (default: `scripts/20-config.mqsc`)

**Example:**

```zsh
./run-mqsc.sh
```

This will apply `scripts/20-config.mqsc` to the running `ibmmq` container.

## How do I check the status of the queue manager and resources inside the container?

1. Open a shell in the running MQ container:

```zsh
./run-mq-shell.sh
```
2. Start the MQSC command interface for your queue manager:

```zsh
runmqsc QM1
```

3. At the MQSC prompt, you can run commands such as:

   - Show queue manager status:
     ```
     DISPLAY QMGR
     ```
   - Show all queues:
     ```
     DISPLAY QUEUE(*)
     ```
   - Show all channel statuses:
     ```
     DISPLAY CHSTATUS(*)
     ```
   - To exit MQSC:
     ```
     END
     ```

This allows you to inspect the state of your queue manager and resources interactively.

## How to fix cipher on the client side?

```
DEFINE CHANNEL(CERT.SVRCONN_CLNT) CHLTYPE(CLNTCONN) +
  QMNAME(QM1) +
  CONNAME('ibmmq(1414)') +
  SSLCIPH('TLS_RSA_WITH_AES_256_CBC_SHA256')
```

```
export MQCHLLIB=/var/mqm/qmgrs/QM1/@ipcc/AMQCLCHL.TAB
export MQCHLTAB=AMQCLCHL.TAB
```

## What is the specs for JSON CCDT?

[Complete list of CCDT channel attribute definitions for a client connection channel](https://www.ibm.com/docs/en/ibm-mq/9.2.x?topic=ccdt-json-examples)