# arguments
ARG BASE_IMAGE=debian:latest

# publish
FROM ${BASE_IMAGE}

ENV DOMAIN=${DOMAIN}

RUN <<EOF
    apt-get update -y && apt-get upgrade -y
    apt-get install -y \
        php-fpm
EOF

COPY conf/fpm/php-fpm.conf /etc/php/7.4/fpm
COPY conf/fpm/php.ini /etc/php/7.4/fpm
COPY conf/fpm/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY --chown=root:root --chmod=0770 /tools/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "php-fpm7.4", "-F" ]
