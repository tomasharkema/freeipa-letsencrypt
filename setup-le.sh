#!/usr/bin/bash
set -o nounset -o errexit

FQDN=$(hostname -f)
WORKDIR=$(dirname "$(realpath $0)")
CERTS=("isrgrootx1.pem" "isrg-root-x2.pem")
CERTS2=("e7.pem" "e8.pem" "r12.pem" "r13.pem")

sed -i "s/server.example.test/$FQDN/g" $WORKDIR/ipa-httpd.cnf

dnf install letsencrypt -y

if [ ! -d "/etc/ssl/$FQDN" ]
then
  mkdir -p "/etc/ssl/$FQDN"
fi

for CERT in "${CERTS[@]}"
do
  if command -v wget &> /dev/null
  then
    wget -O "/etc/ssl/$FQDN/$CERT" "https://letsencrypt.org/certs/$CERT"
  elif command -v curl &> /dev/null
  then
    curl -o "/etc/ssl/$FQDN/$CERT" "https://letsencrypt.org/certs/$CERT"
  fi
  ipa-cacert-manage install "/etc/ssl/$FQDN/$CERT"
done


for CERT2 in "${CERTS2[@]}"
do
  if command -v wget &> /dev/null
  then
    wget -O "/etc/ssl/$FQDN/$CERT2" "https://letsencrypt.org/certs/2024/$CERT2"
  elif command -v curl &> /dev/null
  then
    curl -o "/etc/ssl/$FQDN/$CERT2" "https://letsencrypt.org/certs/2024/$CERT2"
  fi
  ipa-cacert-manage install "/etc/ssl/$FQDN/$CERT2"
done


ipa-certupdate

"$WORKDIR/renew-le.sh" --first-time
