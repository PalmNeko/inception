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

main "$@"
