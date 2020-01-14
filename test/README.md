# Testing

This directory contains a simple test script which tests creating certificates with Pebble (testing version of the LetsEncrypt server)

Start up pebble, the challdnstest server for DNS challenges
`docker-compose -f "docker-compose.yml" up -d --build`

Run the tests
`docker exec -it getssl /getssl/test/run-test.sh`

Debug (need to set CURL_CA_BUNDLE as pebble uses a local certificate, otherwise you get a "unknown API version" error)
`docker exec -it getssl /bin/bash`
`export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt`
`/getssl/getssl -d getssl`

# TODO
1. Move to BATS (bash automated testing) instead of run-test.sh
2. Test RHEL6, Debian as well
3. Test SSH, SFTP
4. Test wildcards
