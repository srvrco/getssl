#!/usr/bin/env bash

docker exec getssl-alpine bats /getssl/test
docker exec getssl-centos6 bats /getssl/test
docker exec getssl-debian bats /getssl/test
docker exec getssl-ubuntu bats /getssl/test
docker exec getssl-ubuntu18 bats /getssl/test
docker exec getssl-duckdns bats /getssl/test
