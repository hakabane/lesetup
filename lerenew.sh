#!/bin/bash

LEDIR="/var/lib/letsencrypt"
DOMAINSFILE=${LEDIR}/domains.txt
ACMEDIR="/var/www/localhost/acme-challenge"

cd ${LEDIR} && \
wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem && \
while IFS='' read -r line || [[ -n "$line" ]]; do
	acme-tiny --account-key account.key --csr ${line}.csr --acme-dir ${ACMEDIR} > ${line}.crt && \
	cat ${line}.crt intermediate.pem > ${line}.pem
done < "${DOMAINSFILE}"
/etc/init.d/apache2 restart
