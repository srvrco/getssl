FROM koalaman/shellcheck-alpine:v0.4.7

RUN apk add --no-cache --virtual .circleci-deps \
    ca-certificates \
    git \
    gzip \
    openssh \
    tar
