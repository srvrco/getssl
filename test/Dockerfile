FROM ubuntu:bionic
# bionic = latest 18 version

# Update and install required software
RUN apt-get update
# TODO work out why default version of awk fails
RUN apt-get install -y git curl dnsutils wget linux-libc-dev make gcc binutils nginx-light gawk
RUN apt-get install -y vim dos2unix # for debugging
# TODO test with drill, dig, host

WORKDIR /root
RUN mkdir /etc/nginx/pki
RUN mkdir /etc/nginx/pki/private
COPY ./test/test-config/nginx-ubuntu-sites-enabled-default /etc/nginx/sites-enabled/default

# BATS (Bash Automated Testings)
# RUN git clone https://github.com/bats-core/bats-core.git
# RUN bats-core/install.sh /usr/local

COPY test/test-config/getssl-ubuntu.cfg getssl.cfg

EXPOSE 80 443

# Run eternal loop - for testing
CMD ["/bin/bash", "-c", "while :; do sleep 10; done"]

# with Pebble
# docker-compose -f "test\docker-compose.yml" up -d --build
# docker exec -it test_getssl /bin/bash
# /getssl/test/run-test.sh
