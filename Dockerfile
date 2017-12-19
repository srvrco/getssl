FROM alpine:3.6

WORKDIR /etc/getssl
COPY getssl .

RUN apk --no-cache --virtual .run-depends add \
    bash \
    curl \
    openssl
