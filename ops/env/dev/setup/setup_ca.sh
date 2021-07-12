#!/bin/bash

echo "Creating self-signed CA certificates for local TLS testing and installing them in local trust stores"

CA_CERTS_FOLDER="$(pwd)/.certs"

# This requires mkcert to be installed/available
echo "${CA_CERTS_FOLDER}"
rm -rf ${CA_CERTS_FOLDER}
mkdir -p ${CA_CERTS_FOLDER}
mkdir -p ${CA_CERTS_FOLDER}/dev

# The CAROOT env variable is used by mkcert to determine where to read/write files - Reference: https://github.com/FiloSottile/mkcert
CAROOT=${CA_CERTS_FOLDER}/dev mkcert -install
