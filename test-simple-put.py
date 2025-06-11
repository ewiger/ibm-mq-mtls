import os
import traceback
import pymqi
# Install pymqi with: pip install pymqi
# But you also need to run extra/mq-ubuntu-install.sh
# Usage:
# export LD_LIBRARY_PATH=/opt/mqm/lib64:/opt/mqm/lib:$LD_LIBRARY_PATH
# python test-simple-put.py

# Config
QMGR_NAME = "QM1"
CHANNEL_NAME = "CERT.SVRCONN"
QUEUE_NAME = "Q1"
HOST = "localhost"
PORT = "1414"

# Paths to certs and CCDT
CCDT_URL = os.path.abspath("client_ccdt.json")
KEY_REPOSITORY = os.path.abspath("mq-certs/key")  # Path to key.kdb without extension

# Set environment variables for MQ client
os.environ["MQCCDTURL"] = CCDT_URL
os.environ["MQSSLKEYR"] = KEY_REPOSITORY

# Optional: Set trace/debug if needed
os.environ["MQ_TRACE_OPTIONS"] = "-tall"
os.environ["MQTRACEPATH"] = os.getcwd()
os.environ["MQTRACEFILE"] = "mq_trace.log"
os.environ["MQTRACELEVEL"] = "1"
os.environ["MQ_TRACE_OPTIONS"] = "-tall"

try:
    # Connect using channel and connection inf
    conn_info = f"{HOST}({PORT})"
    qmgr = pymqi.QueueManager(None)
    cd = pymqi.CD()
    qmgr.connect_with_options(QMGR_NAME, user=None, password=None, cd=cd, sco=None)

    # Connect using CCDT (channel and connection info from CCDT)
    # qmgr = pymqi.QueueManager(None)
    # queue = pymqi.Queue(qmgr, QUEUE_NAME)
    # queue.put(b"foo")
    # print("✅ Message put successfully.")
    # queue.close()
    # qmgr.disconnect()
except Exception as e:
    print(f"❌ MQ put failed: {e}")
    traceback.print_exc()
