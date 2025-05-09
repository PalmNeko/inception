#!/bin/bash

# docker-entrypoint.sh

main() {
    echo "[ into docker-entry.sh $@ ]"

    if [ "$1" = "nginx" ]; then
        service --status-all 2> /dev/stdout | grep nginx | grep '+' \
            && nginx -s stop && echo "stop nginx!!" \
                # if nginx is beginning, stop nginx
        chk_nginx
    fi

    echo "[ out of docker-entry.sh ]"

    echo "run nginx!!!"
    exec "$@"
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
