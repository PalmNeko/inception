# arguments
ARG BASE_IMAGE

# publish
FROM ${BASE_IMAGE} as prod

ENV DOMAIN=${DOMAIN}

RUN <<EOF
    apt-get -y update
    apt-get -y upgrade
    apt-get install -y nginx openssl
EOF

EXPOSE 443/tcp

COPY /tools/docker-entrypoint.sh /
COPY /conf/ssl.conf /etc/nginx/conf.d/ssl.conf

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
