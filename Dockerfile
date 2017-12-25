FROM alpine:3.6

RUN apk --no-cache --virtual .run-depends add \
    bash \
    bind-tools \
    curl \
    openssl

COPY getsslD /
WORKDIR /

COPY ./docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
