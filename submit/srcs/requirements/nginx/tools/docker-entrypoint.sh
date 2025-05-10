#!/bin/bash

# docker-entrypoint.sh

main() {
    echo "[ into docker-entry.sh $@ ]"

    if [ "$1" = "nginx" ]; then
        service --status-all 2> /dev/stdout | grep nginx | grep '+' \
            && nginx -s stop && echo "stop nginx!!" \
                # if nginx is beginning, stop nginx
        make_cert
        chk_nginx
    fi

    echo "[ out of docker-entry.sh ]"

    echo "run nginx!!!"
    exec "$@"
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

chk_nginx() {
    # import environment from .env
    # - DOMAIN
    DOMAIN=$DOMAIN
    SSL_KEYFILE="/ssl/nginx.key"
    SSL_CRTFILE="/ssl/nginx.crt"

    test -f "$SSL_KEYFILE" || errexit "$SSL_KEYFILE: No such file or directory - check Dockerfile in prepare stage"
    echo "$SSL_KEYFILE: exists"
    test -f "$SSL_CRTFILE" || errexit "$SSL_KEYFILE: No such file or directory - check Dockerfile in prepare stage"
    echo "$SSL_CRTFILE: exists"
}

errexit() {
    echo "$@" > /dev/stderr
    exit 1
}

main "$@"
