#! /bin/sh

wget --no-clobber https://raw.githubusercontent.com/letsencrypt/pebble/master/test/certs/pebble.minica.pem
cat /etc/pki/tls/certs/ca-bundle.crt /root/pebble.minica.pem > /root/pebble-ca-bundle.crt
export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt

curl -X POST -d '{"host":"getssl", "addresses":["10.30.50.4"]}' http://10.30.50.3:8055/add-a

# Test certificate creation
cp /getssl/test/test-config/nginx-ubuntu-no-ssl /etc/nginx/sites-enabled/default
service nginx start
/getssl/getssl -c getssl
cp /getssl/test/test-config/getssl-ubuntu.cfg /root/.getssl/getssl/getssl.cfg
/getssl/getssl getssl

# Test forced renewal
/getssl/getssl getssl -f
