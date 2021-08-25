# Testing

## Continuous Integration

For continuous integration testing we have the following:

`gitactions` script which runs whenever a PR is pushed:

1. Uses `docker-compose` to start `pebble` (letsencrypt test server) and `challtestsrv` (minimal dns client for pebble)
2. Then runs the `bats` test scripts (all the files with a ".bats" extension) for each OS (alpine, centos6, debian, ubuntu)
3. Runs the `bats` test script against the staging server (using ubuntu docker image and duckdns.org)

Tests can also be triggered manually from the GitHub website.

For dynamic DNS tests, you need accounts on duckdns.org and dynu.com, and need to create 4 domain names in each account.

For duckdns.org:
- Add DUCKDNS_TOKEN to your repository's environment secrets.  The value is your account's token
- Add domains <reponame>-centos7-getssl.duckdns.org, wild-<reponame>-centos7.duckdns.org, <reponame>-ubuntu-getssl.duckdns.org, and wild-<reponame>-ubuntu-getssl.duckdns.org

For dynu.com:
 - Add DYNU_API_KEY to your repository's environment secrets.  The value is your account's API Key.
 - Add domains <reponame>-centos7-getssl.freedns.org, wild-<reponame>-centos7.freedns.org, <reponame>-ubuntu-getssl.freedns.org, and wild-<reponame>-ubuntu-getssl.freedns.org

To run dynamic DNS tests outside the CI environment, you need accounts without <reponame> in the domain names.  Export the environment variable corresponding to the secrets (with the same values).

For individual accounts, <reponame> is your github account name.


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
