# once, create a throw-away container that shares the keystore mount
docker run --rm -it \
  --env LICENSE=accept \
  --mount type=bind,source=$PWD/mq-certs,target=/etc/mqm/pki/keys \
  ibmcom/mqcommunity \
  bash -c '
    export MQSERVER="CERT.SVRCONN/TCP/mq(1414)"
    export MQSSLKEYR=/etc/mqm/pki/keys/key
    amqsputc Q1 QM1
  '
