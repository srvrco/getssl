# Testing

## Continuous Integration

For continuous integration testing we have the following:

`gitactions` script which runs whenever a PR is pushed:

1. Uses `docker-compose` to start `pebble` (letsencrypt test server) and `challtestsrv` (minimal dns client for pebble)
2. Then runs the `bats` test scripts (all the files with a ".bats" extension) for each OS (alpine, centos6, debian, ubuntu)
3. Runs the `bats` test script against the staging server (using nn ubuntu docker image and duckdns.org)

## To run all the tests on a single OS

1. Start `pebble` and `challtestsrv` using ```docker-compose up -d --build```
2. Run the test suite ```run-test.sh [<os>]```
3. eg. `run-test.sh ubuntu16`

## To run a single bats test on a single OS

1. Start `pebble` and `challtestsrv` using ```docker-compose up -d --build```
2. ```run-test.sh <os> bats <bats test script>```
3. e.g. `run-test.sh ubuntu bats /getssl/test/1-simple-http01.bats`

## To debug a test

1. Start `pebble` and `challtestsrv` using ```docker-compose up -d --build```
2. ```run-test.sh <os> /getssl/test/debug-test.sh <getssl config file>```
3. e.g. `run-test.sh ubuntu /getssl/test/debug-test.sh -d /getssl/test/test-config/getssl-http01-cfg`

## TODO

1. Test wildcards
2. Test SSH, SFTP, SCP
3. Test change of key algorithm (should automatically delete and re-create account.key)
