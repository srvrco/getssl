echo %time%
docker exec -it getssl-alpine bats /getssl/test
echo %time%
docker exec -it getssl-centos6 bats /getssl/test
echo %time%
docker exec -it getssl-debian bats /getssl/test
echo %time%
docker exec -it getssl-ubuntu bats /getssl/test
echo %time%
docker exec -it getssl-ubuntu18 bats /getssl/test
echo %time%
docker exec -it getssl-ubuntu16 bats /getssl/test
echo %time%
docker exec -it getssl-duckdns bats /getssl/test
echo %time%
