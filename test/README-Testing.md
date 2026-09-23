# Testing

## Continuous Integration

For continuous integration testing we have the following:

`gitactions` script which runs whenever a PR is pushed:

1. Uses `docker compose` to start `pebble` (letsencrypt test server) and `challtestsrv` (minimal dns client for pebble)
2. Then runs the `bats` test scripts (all the files with a ".bats" extension) for each OS (alpine, centos6, debian, ubuntu)
3. Runs the `bats` test script against the staging server (using ubuntu docker image and duckdns.org)

Tests can also be triggered manually from the GitHub website.

## Testing using the Staging server

For dynamic DNS tests, you need accounts on duckdns.org and dynu.com, and need to create 4 domain names in each account.

For duckdns.org:

- Add DUCKDNS_TOKEN to your repository's environment secrets.  The value is your account's token
- Add domains \<reponame>-centos7-getssl.duckdns.org, wild-\<reponame>-centos7.duckdns.org, \<reponame>-ubuntu-getssl.duckdns.org, and wild-\<reponame>-ubuntu-getssl.duckdns.org

For dynu.com:

- Add DYNU_API_KEY to your repository's environment secrets.  The value is your account's API Key.
- Add domains \<reponame>-centos7-getssl.freedns.org, wild-\<reponame>-centos7.freedns.org, \<reponame>-ubuntu-getssl.freedns.org, and wild-\<reponame>-ubuntu-getssl.freedns.org

For ACME DNS (also needs Dynu)

- Register to get a user, key and subdomain from acme-dns.io (see https://github.com/joohoi/acme-dns?tab=readme-ov-file)
- Create a CNAME _acme-challenge.ubuntu-acmedns-getssl.freeddns.org. to ${ACMEDNS_SUBDOMAIN}.auth.acme-dns.io (this is done automatically in run-test.sh)

To run dynamic DNS tests outside the CI environment, you need accounts without \<reponame> in the domain names.  Export the environment variable corresponding to the secrets (with the same values).

For individual accounts, \<reponame> is your github account name.

## Testing locally using pebble

1. Start `pebble` and `challtestsrv` using ```docker compose up -d --build```

### To run all the tests on a single OS

Run the test suite ```test/run-test.sh [<os>]```
eg. `test/run-test.sh ubuntu16`

### To run a single bats test on a single OS

`test/run-test.sh <os> <bats test script>`
e.g. `test/run-test.sh ubuntu test/1-simple-http01.bats`

### To print the output of a test when it succeeds (automatically printed if it fails)

`test/run-test.sh <os> -d <test script>`
e.g. `test/run-test.sh ubuntu -d test/1-simple-http01-dig.bats`

### To debug a test

`run-test.sh <os> /getssl/test/debug-test.sh <getssl config file>`
e.g. `test/run-test.sh ubuntu /getssl/test/debug-test.sh -d /getssl/test/test-config/getssl-http01.cfg`
or `test/run-test.sh ubuntu /getssl/test/debug-test.sh -d getssl-http01.cfg`

### To start a shell and debug a test

```bash
run-test.sh <os> bash
cd /getssl
test/debug-test.sh -d /getssl/test/test-config/getssl-http01.cfg
```

Note: If curl to pebble:14000 fails, change debug-test.sh to use the pebble.minica.pem file
Note: Certificates will be created in /etc/nginx/pki

### To run bats on a file manually

```bash
run-test.sh <os> bash
cd /root
bats /getssl/test/<test-script>.bats
```

Note: This doesn't work if run inside the `getssl` directory
