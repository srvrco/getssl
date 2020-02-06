#!/usr/bin/env bash

docker exec -it getssl-alpine bats /getssl/test
docker exec -it getssl-centos6 bats /getssl/test
docker exec -it getssl-debian bats /getssl/test
docker exec -it getssl-ubuntu18 bats /getssl/test
docker exec -it getssl-ubuntu18-no-gawk bats /getssl/test/5-old-awk-error.bats
