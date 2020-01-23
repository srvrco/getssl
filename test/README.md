# Testing

This directory contains a simple test script which tests creating certificates with Pebble (testing version of the LetsEncrypt server)

Start up pebble, the challdnstest server for DNS challenges
`docker-compose -f "docker-compose.yml" up -d --build`

Run the tests
`docker exec -it getssl bats /getssl/test`

Run individual test
`docker exec -it getssl bats /getssl/test/<filename.bats>`

Debug (need to set CURL_CA_BUNDLE as pebble uses a local certificate, otherwise you get a "unknown API version" error)
`docker exec -it getssl /bin/bash`
`export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt`
`/getssl/getssl -d getssl`

# TODO
1. Test RHEL6, Debian as well
2. Test SSH, SFTP
3. Test wildcards
