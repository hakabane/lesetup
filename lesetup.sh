#!/bin/sh

if [ "$#" -ne 1 ]; then
	echo "Usage : lesetup.sh example.com"
	exit 1
fi

DOMAIN=${1}
LEDIR="/var/lib/letsencrypt"
ACMEDIR="/var/www/localhost/acme-challenge"
DOMAINSFILE=${LEDIR}/domains.txt

mkdir -p ${LEDIR} && \
mkdir -p ${ACMEDIR} && \
cd ${LEDIR} && \
openssl genrsa 4096 > ${DOMAIN}.key && \
openssl req -new -sha256 -key ${DOMAIN}.key -subj "/CN=${DOMAIN}" > ${DOMAIN}.csr && \
acme-tiny --account-key account.key --csr ${DOMAIN}.csr --acme-dir ${ACMEDIR} > ${DOMAIN}.crt && \
wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem && \
cat ${DOMAIN}.crt intermediate.pem > ${DOMAIN}.pem && \
echo && \
echo "--- apache configuraton ---" && \
echo "SSLCertificateFile ${LEDIR}/${DOMAIN}.pem" && \
echo "SSLCertificateKeyFile ${LEDIR}/${DOMAIN}.key" && \
echo && \
echo "vhost file : /etc/apache2/vhosts.d/${DOMAIN}_443.conf" && \
echo ${DOMAIN} >> ${DOMAINSFILE}
