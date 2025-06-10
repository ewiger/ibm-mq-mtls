# once, create a throw-away container that shares the keystore mount
HOSTNAME="imbmq"
docker run --rm -it \
  --env LICENSE=accept \
  --env MQSSLCIPH=TLS_RSA_WITH_AES_256_CBC_SHA256 \
  --env MQSERVER="CERT.SVRCONN/TCP:${HOSTNAME}(1414)" \
  --env MQSSLKEYR=/etc/mqm/pki/keys/key \
  --mount type=bind,source=$PWD/mq-certs,target=/etc/mqm/pki/keys \
  --entrypoint bash \
  ibmcom/mq:latest \
  -c "
    export PATH=\$PATH:/opt/mqm/bin:/opt/mqm/samp/bin
    amqsputc Q1 QM1
  "
