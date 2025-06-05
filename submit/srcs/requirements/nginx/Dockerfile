# arguments
ARG BASE_IMAGE

# publish
FROM ${BASE_IMAGE} AS prod

ENV DOMAIN=${DOMAIN}

RUN <<EOF
    apt-get -y update
    apt-get -y upgrade
    apt-get install -y nginx openssl
EOF

EXPOSE 443/tcp

COPY --chown=root:root --chmod=0770 /tools/docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "nginx", "-g", "daemon off;" ]

FROM prod AS dev

# install development tools
RUN <<EOF
    apt-get install -y \
        net-tools \
        psmisc \
        procps
EOF
