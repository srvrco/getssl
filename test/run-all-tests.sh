#!/usr/bin/env bash

docker exec -it getssl-alpine bats /getssl/test
docker exec -it getssl-centos6 bats /getssl/test
docker exec -it getssl-debian bats /getssl/test
docker exec -it getssl-ubuntu bats /getssl/test
docker exec -it getssl-ubuntu18 bats /getssl/test
