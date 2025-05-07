ARG DEBIAN_VERSION=11.11-slim
FROM debian:${DEBIAN_VERSION}

RUN <<EOF
apt-get -y update
apt-get -y upgrade
apt-get install -y mariadb-server
EOF

EXPOSE 3306/tcp

# COPY  entrypoint.sh TODO:
# ENTRYPOINT [""] TODO:
# CMD ["mariadbd"]
