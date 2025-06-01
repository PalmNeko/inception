#!/bin/bash

main () {
	echo '[ start wordpress container ]'

	if [ "$1" = "php-fpm7.4" ]; then
		setup_wordpress
	fi
	echo '[ the setup is now complete ]'
	exec "$@"
}

setup_wordpress () {
	echo '[ into setup_wordpress ]'
	mkdir -p /run/php
	echo '[ out of setup_wordpress ]'
}

main "$@"
