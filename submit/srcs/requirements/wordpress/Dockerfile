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
    wget https://ja.wordpress.org/wordpress-6.8.1-ja.tar.gz -O wordpress.tar.gz
    mkdir -p /srv
    tar -xf wordpress.tar.gz -C /srv
EOF

# publish
FROM ${BASE_IMAGE} as publish

ENV DOMAIN=${DOMAIN}

RUN <<EOF
    apt-get update -y && apt-get upgrade -y
    apt-get install -y \
        php-fpm \
        mariadb-client
EOF

COPY conf/fpm/php-fpm.conf /etc/php/7.4/fpm
COPY conf/fpm/php.ini /etc/php/7.4/fpm
COPY conf/fpm/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY --from=prepare --chown=www-data:www-data /srv /srv

COPY --chown=root:root --chmod=0770 /tools/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "php-fpm7.4", "-F" ]
