#! /bin/sh

wget --no-clobber https://raw.githubusercontent.com/letsencrypt/pebble/master/test/certs/pebble.minica.pem
export CURL_CA_BUNDLE=/root/pebble.minica.pem

service nginx start
/getssl/getssl -c getssl
cp getssl.cfg /root/.getssl/getssl
/getssl/getssl getssl
