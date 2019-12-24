FROM ubuntu:bionic
# bionic = latest 18 version

# Update and install required software
# https://packages.ubuntu.com/cosmic-updates/
RUN apt-get update
RUN apt-get install -y git curl dnsutils wget linux-libc-dev make gcc binutils nginx-light
RUN apt-get install -y vim  # for debugging
# TODO test with drill, dig, host

WORKDIR /root
RUN mkdir /etc/nginx/pki
RUN mkdir /etc/nginx/pki/private
COPY test/test-config/nginx-ubuntu-sites-enabled-default /etc/nginx/sites-enabled/default

ARG noip_version=noip-2.1.9-1
RUN wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz \
 && tar -zvxf noip-duc-linux.tar.gz \
 && cd ${noip_version} \
 && make
#COPY no-ip2.conf /root/${noip_version}/no-ip2.conf
#RUN /root/${noip_version}/noip2 -c /root/${noip_version}/no-ip2.conf

RUN git clone https://github.com/bats-core/bats-core.git
RUN bats-core/install.sh /usr/local
RUN git clone https://github.com/capitalone/bash_shell_mock.git
# RUN bash_shell_mock/install.sh /usr/local
# RUN git clone https://github.com/srvrco/getssl.git

COPY ./getssl getssl
COPY test/test-config/getssl-ubuntu.cfg getssl.cfg

EXPOSE 80 443
ENTRYPOINT /bin/bash

# Testing
# =======
# docker build --rm -f "test/Dockerfile" -t 294541140870.dkr.ecr.eu-west-1.amazonaws.com/getssl:latest .
# docker run --rm -it 294541140870.dkr.ecr.eu-west-1.amazonaws.com/getssl:latest
