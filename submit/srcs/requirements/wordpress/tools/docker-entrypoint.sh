#!/bin/bash

main () {
	echo '[ start wordpress container ]'
	env
	if [ "$1" = "php-fpm7.4" ]; then
		setup_wordpress
		for_debug_php_info
	fi
	echo '[ the setup is now complete ]'
	exec "$@"
}

setup_wordpress () {
	echo '[ into setup_wordpress ]'
	mkdir -p /run/php
	extract_wordpress
	echo '[ out of setup_wordpress ]'
}

extract_wordpress() {
    mkdir -p /srv/wordpress
	if find /srv/wordpress -type f,d | grep "" > /dev/null; then
		echo 'extract wordpress'
    	tar -xf /wordpress.tar.gz -C /srv
		chown -R root:www-data /srv
		echo 'extracted'
	fi
	chmod 0775 /srv/wordpress
	chown root:www-data /srv/wordpress
}

main "$@"
