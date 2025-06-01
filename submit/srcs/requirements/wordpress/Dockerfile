# arguments
ARG BASE_IMAGE

# publish
FROM ${BASE_IMAGE} as prepare

ENV DOMAIN=${DOMAIN}

RUN <<EOF
    apt-get update -y && apt-get upgrade -y
    apt-get install -y \
        php-fpm \
        wget
EOF

FROM prepare as prod

EXPOSE 80

COPY --chown=root:root --chmod=0770 /tools/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
