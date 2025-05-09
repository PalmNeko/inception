#!/bin/bash

# docker-entrypoint.sh
echo "nginx preparing files..."

main() {
    echo "[ into docker-entrypoint.sh ]"
    make_cert
    echo "[ out of docker-entrypoint.sh ]"

    return 0
}

make_cert() {
    # import environment from .env
    # - DOMAIN
    DOMAIN=$DOMAIN
    SSL_KEYFILE="/ssl/nginx.key"
    SSL_CRTFILE="/ssl/nginx.crt"

    mkdir -p $(dirname "$SSL_KEYFILE")
    mkdir -p $(dirname "$SSL_CRTFILE")

    openssl req -x509 -nodes -days 15 -newkey rsa:2048 \
    -keyout "$SSL_KEYFILE" -out "$SSL_CRTFILE" \
    -subj "/CN=${DOMAIN}"

    test -f "$SSL_KEYFILE" || errexit "$SSL_KEYFILE: Creation failure."
    test -f "$SSL_CRTFILE" || errexit "$SSL_KEYFILE: Creation failure."
}

errexit() {
    echo "$@" > /dev/stderr
    exit 1
}

main "$@"
