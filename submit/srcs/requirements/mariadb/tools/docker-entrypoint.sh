#!/bin/bash

main () {
	echo '[ start mariadbd container ]'

	if [ "$1" = "mariadbd" ]; then
		setup_mariadbd
		if [ -n "$INIT_DB_FILE" ]; then
			merge_init_file
			exec "$@" --init-file="$INIT_DB_FILE"
		fi
	fi
	echo '[ the setup is now complete ]'
	exec "$@"
}

setup_mariadbd () {
	echo '[ into setup_mariadbd ]'
	setup_directory__socket
	setup_directory__pid_file
	echo '[ out of setup_mariadbd ]'
}

setup_directory__socket() {
	SOCKET_DIRECTORY='/tmp/run/mysqld'
	echo 'setup directory for "socket" mariadb setting'
	mkdir -p "$SOCKET_DIRECTORY"
	chown -R mysql:mysql "$SOCKET_DIRECTORY"
	ls -ld "$SOCKET_DIRECTORY"
}

setup_directory__pid_file() {
	PID_FILE_DIRECTORY='/tmp/run/mysqld'
	echo 'setup directory for "pid-file" mariadb setting'
	mkdir -p "$PID_FILE_DIRECTORY"
	chown -R mysql:mysql "$PID_FILE_DIRECTORY"
	ls -ld "$PID_FILE_DIRECTORY"
}

merge_init_file() {
	INIT_DB_FILE_DIR=/etc/mysql/initdb.d
	INIT_DB_FILE=/etc/mysql/initdb.sql
	local init_db_file_dir="${INIT_DB_FILE_DIR:-/etc/mysql/initdb.d}"
	local init_db_file="${INIT_DB_FILE:-/etc/mysql/initdb.sql}"
	echo 'merge init-files'
	mkdir -p "$init_db_file_dir"
	touch "$init_db_file"
	for file in $(find "$init_db_file_dir" -name "*.sql" | sort); do
		cat "$file" >> "$init_db_file"
		echo -e ';' >> "$init_db_file"
	done
}

main "$@"
