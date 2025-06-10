#!/bin/bash

main () {
	echo '[ start wordpress container ]'
	env
	if [ "$1" = "php-fpm7.4" ]; then
		setup_wordpress
	fi
	echo '[ the setup is now complete ]'
	exec "$@"
}

setup_wordpress () {
	echo '[ into setup_wordpress ]'
	mkdir -p /run/php
	extract_wordpress
	check_require_files
	initialize_wordpress
	echo '[ out of setup_wordpress ]'
}

##### extract wordpress #####
extract_wordpress() {
    mkdir -p /srv/wordpress
	if find /srv/wordpress -type f,d | grep "" > /dev/null; then
		echo 'extract wordpress'
    	tar -xf /wordpress.tar.gz -C /srv
		chown -R www-data:root /srv
		echo 'extracted'
	fi
	chmod 0775 /srv/wordpress
	chown www-data:root /srv/wordpress
}

##### initialize wordpress #####
initialize_wordpress() {
	setup_wordpress_database
}


##### check require files #####
check_require_files() {
	check_db_password_file
}

check_db_password_file() {
	if [ -z "$WP_DB_PASS_FILE" ]; then
		echo 'Error: You must set environment: WP_DB_PASS_FILE' > /dev/stderr
		exit 1
	elif ! [ -f "$WP_DB_PASS_FILE" ]; then
		echo "Error: $WP_DB_PASS_FILE: No such file or directory" > /dev/stderr
		exit 1
	fi
}

##### setup wordpress database #####
setup_wordpress_database() {
	if ! has_wordpress_config; then
		get_wordpress_db_password
		create_wordpress_config
	fi
	set_wordpress_config_pass
}

create_wordpress_config() {
	wpcli config create \
		--dbname=wordpress \
		--dbuser=wordpress \
		--dbhost=mariadb \
		--dbpass="$(get_wordpress_db_password)"
}

set_wordpress_config_pass() {
	wpcli config set DB_PASSWORD "$(get_wordpress_db_password)"
}

get_wordpress_db_password() {
	cat_password "$WP_DB_PASS_FILE"
}

##### wp-cli wrapper #####
wpcli() {
	su -s /bin/bash www-data -c "wp --path=/srv/wordpress $(printf '%q ' "$@")"
}

has_wordpress_config() {
	wpcli config path > /dev/null 2>/dev/null
	A=$?
	return "$A"
}

##### utils #####
cat_password() {
	cat $1 | tr -d '\n'
}

##### MAIN #####

main "$@"
