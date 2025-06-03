#!/bin/bash

main () {
	echo '[ start mariadbd container ]'

	if [ "$1" = "mariadbd" ]; then
		setup_mariadbd
	fi
	echo '[ the setup is now complete ]'
	exec "$@"
}

setup_mariadbd () {
	echo '[ into setup_mariadbd ]'
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
	ls -ld /run/mysqld
	echo '[ out of setup_mariadbd ]'
}

main "$@"
