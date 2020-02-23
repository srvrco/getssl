# Testing

This directory contains a simple test script which tests creating
certificates with Pebble (testing version of the LetsEncrypt server)

Start up pebble, the challdnstest server for DNS challenges

```sh
docker-compose -f "docker-compose.yml" up -d --build
```

Run the tests

```sh
test/run-all-tests.sh
```

Run individual test

```sh
docker exec -it getssl bats /getssl/test/<filename.bats>
```

Debug (uses helper script to set `CURL_CA_BUNDLE` as pebble uses a local certificate,
otherwise you get a "unknown API version" error)

```sh
docker exec -it getssl-<os> /getssl/test/debug-test.sh <config-file>`

eg.

```sh
docker exec -it getssl-ubuntu18 /getssl/test/debug-test.sh getssl-http01.cfg
```

## TODO

1. Test wildcards
2. Test SSH, SFTP, SCP
3. Test change of key algorithm
