ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN <<EOF
apt-get -y update
apt-get -y upgrade
apt-get install -y nginx
EOF

EXPOSE 80/tcp
COPY /tools/docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "nginx", "-g", "daemon off;" ]
