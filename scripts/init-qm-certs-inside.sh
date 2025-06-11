#!/bin/bash
# /etc/mqm/bootstrap-certs.sh

cp /etc/mqm/pki/keys/key.kdb /var/mqm/qmgrs/QM1/ssl/
cp /etc/mqm/pki/keys/key.sth /var/mqm/qmgrs/QM1/ssl/
chmod 640 /var/mqm/qmgrs/QM1/ssl/key.*
# chown mqm:mqm /var/mqm/qmgrs/QM1/ssl/key.*
# chown 1001:1001 /var/mqm/qmgrs/QM1/ssl/key.*