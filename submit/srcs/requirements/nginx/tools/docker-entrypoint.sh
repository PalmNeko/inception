#!/bin/bash

# docker-entrypoint.sh

main() {
    echo "[ into docker-entry.sh $@ ]"

    if [ "$1" = "nginx" ]; then
        service --status-all 2> /dev/stdout | grep nginx | grep '+' \
            && nginx -s stop && echo "stop nginx!!" \
                # if nginx is beginning, stop nginx
        chk_nginx
    fi

    echo "[ out of docker-entry.sh ]"

    echo "run nginx!!!"
    exec "$@"
}

chk_nginx() {
    check_env \
		"SSL_CRT_MOUNT_PATH" \
		"SSL_KEY_MOUNT_PATH"

    local ssl_keyfile="$SSL_CRT_MOUNT_PATH"
    local ssl_crtfile="$SSL_KEY_MOUNT_PATH"

    test -f "$ssl_keyfile" || errexit "$ssl_keyfile: No such file or directory - check Dockerfile in prepare stage"
    echo "$ssl_keyfile: exists"
    test -f "$ssl_crtfile" || errexit "$ssl_keyfile: No such file or directory - check Dockerfile in prepare stage"
    echo "$ssl_crtfile: exists"
}

errexit() {
    echo "$@" > /dev/stderr
    exit 1
}

check_env() {
	echo 'check use environment'
	echo '✅ is having. ❌ is not having'
	local environment="$(env)"
	for env_name in "$@"; do
		if echo "$environment" | grep -e "^$env_name=" > /dev/null; then
			echo "✅ $env_name"
		else
			echo "❌ $env_name"
		fi
	done
}

main "$@"
