# arguments
ARG BASE_IMAGE=debian:latest

# prepare
FROM ${BASE_IMAGE} AS prepare
RUN <<EOF
    apt-get update -y && apt-get upgrade -y
    apt-get install -y \
        wget
EOF

RUN <<EOF
    wget https://ja.wordpress.org/wordpress-6.8.1-ja.tar.gz -O /wordpress.tar.gz
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /wp-cli.phar
    chmod +x /wp-cli.phar
EOF

# publish
FROM ${BASE_IMAGE} as publish

RUN <<EOF
    apt-get update -y && apt-get upgrade -y
    apt-get install -y \
        php-fpm \
        php-mysql \
        netcat.openbsd
EOF

COPY --from=prepare --chown=www-data:www-data /wordpress.tar.gz /
COPY --from=prepare --chown=www-data:www-data /wp-cli.phar /usr/local/bin/wp
COPY --chown=root:root --chmod=0770 /tools/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "php-fpm7.4", "-F" ]
