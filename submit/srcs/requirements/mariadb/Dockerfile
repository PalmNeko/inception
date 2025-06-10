# arguments
ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN <<EOF
apt-get -y update
apt-get -y upgrade
apt-get install -y mariadb-server
EOF

COPY --chown=mysql:mysql --chmod=0770 tools/docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "mariadbd" ]
