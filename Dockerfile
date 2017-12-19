FROM alpine:3.6

ENV WORKING_DIR="/root/getssl"
RUN apk --no-cache --virtual .run-depends add \
    bash \
    curl \
    openssl

COPY getssl /usr/local/bin/getssl

WORKDIR /

COPY ./docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
