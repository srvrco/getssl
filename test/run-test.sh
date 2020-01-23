#! /bin/bash

set -e

# Test setup
if [[ -d /root/.getssl ]]; then
    rm -r /root/.getssl
fi

HOST=getssl.test

wget --no-clobber https://raw.githubusercontent.com/letsencrypt/pebble/master/test/certs/pebble.minica.pem
# cat /etc/pki/tls/certs/ca-bundle.crt /root/pebble.minica.pem > /root/pebble-ca-bundle.crt
cat /etc/ssl/certs/ca-certificates.crt /root/pebble.minica.pem > /root/pebble-ca-bundle.crt
export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt

curl -X POST -d '{"host":"'$HOST'", "addresses":["10.30.50.4"]}' http://10.30.50.3:8055/add-a

# Test #1 - http-01 verification
echo Test \#1 - http-01 verification

cp /getssl/test/test-config/nginx-ubuntu-no-ssl /etc/nginx/sites-enabled/default
service nginx restart
/getssl/getssl -c $HOST
cp /getssl/test/test-config/getssl-http01.cfg /root/.getssl/${HOST}/getssl.cfg
/getssl/getssl -f $HOST

# Test #2 - http-01 forced renewal
echo Test \#2 - http-01 forced renewal
/getssl/getssl $HOST -f

# Test cleanup
rm -r /root/.getssl

# Test #3 - dns-01 verification
echo Test \#3 - dns-01 verification
cp /getssl/test/test-config/nginx-ubuntu-no-ssl /etc/nginx/sites-enabled/default
service nginx restart
/getssl/getssl -c $HOST
cp /getssl/test/test-config/getssl-dns01.cfg /root/.getssl/${HOST}/getssl.cfg
/getssl/getssl $HOST

# Test #4 - dns-01 forced renewal
echo Test \#4 - dns-01 forced renewal
/getssl/getssl $HOST -f
