# arguments
ARG BASE_IMAGE

# prepare
FROM ${BASE_IMAGE} as prepare

ENV DOMAIN=${DOMAIN}

COPY tools/prepare.sh /prepare.sh

RUN <<EOF
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install openssl
    bash /prepare.sh
EOF

# publish
FROM ${BASE_IMAGE} as prod

RUN <<EOF
    apt-get -y update
    apt-get -y upgrade
    apt-get install -y nginx
EOF

EXPOSE 443/tcp

COPY /tools/docker-entrypoint.sh /
COPY /conf/ssl.conf /etc/nginx/conf.d/ssl.conf
COPY --from=prepare --chown=nginx:nginx \
    /ssl/nginx.key /ssl/nginx.key
COPY --from=prepare --chown=nginx:nginx \
    /ssl/nginx.crt /ssl/nginx.crt

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "nginx", "-g", "daemon off;" ]

FROM prod as dev

# install development tools
RUN <<EOF
    apt-get install -y \
        net-tools \
        psmisc \
        procps
EOF
