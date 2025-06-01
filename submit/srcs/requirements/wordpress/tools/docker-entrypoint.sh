#!/bin/bash

main () {

	if [ "$1" = "wordpress" ]; then
		setup_wordpress
	fi

	exec "$@"
}

setup_wordpress () {
	echo '[ into setup_wordpress ]'
	service mariadb start
	echo '[ out of setup_wordpress ]'
}

main "$@"
