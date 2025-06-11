import os
import pymqi
# Install pymqi with: pip install pymqi
# But you also need to run extra/mq-ubuntu-install.sh
# Usage:
# export LD_LIBRARY_PATH=/opt/mqm/lib64:/opt/mqm/lib:$LD_LIBRARY_PATH
# python test-simple-put.py

# Connection parameters
QMGR_NAME = "QM1"
CHANNEL_NAME = "CERT.SVRCONN"
QUEUE_NAME = "Q1"
HOST = "localhost"
PORT = "1414"
CONN_INFO = f"{HOST}({PORT})"

# Optional: paths to SSL certs
KEY_REPOSITORY = os.path.abspath("mq-certs/key")  # No file extension

# Set MQSSLKEYR environment if using mutual TLS
os.environ["MQSSLKEYR"] = KEY_REPOSITORY

# Set up connection descriptor (CD)
cd = pymqi.CD()
cd.ChannelName = CHANNEL_NAME.encode()
cd.ConnectionName = CONN_INFO.encode()
cd.TransportType = pymqi.CMQC.MQXPT_TCP
cd.SSLCipherSpec = b'TLS_RSA_WITH_AES_256_CBC_SHA256'  # Match your MQ server config
cd.CertificateLabel = b'ibmwebspheremqqm1'  # Optional, if using a specific cert label

# Set up SSL configuration object (SCO)
sco = pymqi.SCO()
sco.KeyRepository = KEY_REPOSITORY.encode()

# Connect to queue manager
qmgr = pymqi.QueueManager(None)
qmgr.connect_with_options(QMGR_NAME, cd=cd, sco=sco)

# Put a message
queue = pymqi.Queue(qmgr, QUEUE_NAME)
queue.put(b"foo")
print("✅ Message put successfully.")
queue.close()
qmgr.disconnect()
