#!/bin/bash

#
# If you change this file, you have to rebuild the image.
#

main () {
	echo '[ start mariadbd container ]'

	if [ "$1" = "mariadbd" ]; then
		setup_mariadbd
		if [ -n "$INIT_DB_FILE_PATH" ]; then
			merge_init_files
			exec "$@" --init-file="$INIT_DB_FILE_PATH"
		fi
	fi
	echo '[ the setup is now complete ]'
	exec "$@"
}

setup_mariadbd () {
	check_env \
		"INIT_DB_FILE_PATH" \
		"MARIADB_SOCKET" \
		"MARIADB_PID_FILE" \
		"INIT_DB_FILE_DIR" \
		"INIT_DB_FILE_PATH" \
		"ROOT_PASS_FILE"
	echo '[ into setup_mariadbd ]'
	setup_directory__socket
	setup_directory__pid_file
	setup_database
	echo '[ out of setup_mariadbd ]'
	echo '[ execute sql ]'
	execute_sql_instructions
	echo '[ executed sql ]'
}

setup_directory__socket() {
	local socket_directory="$(dirname ${MARIADB_SOCKET:-"/run/mysqld/mysqld.sock"})"
	echo 'setup directory for "socket" mariadb setting'
	mkdir -p "$socket_directory"
	chown -R mysql:mysql "$socket_directory"
	ls -ld "$socket_directory"
}

setup_directory__pid_file() {
	local pid_file_directory="$(dirname ${MARIADB_PID_FILE:-"/run/mysqld/mysqld.pid"})"
	echo 'setup directory for "pid-file" mariadb setting'
	mkdir -p "$pid_file_directory"
	chown -R mysql:mysql "$pid_file_directory"
	ls -ld "$pid_file_directory"
}

merge_init_files() {
	local init_db_file_dir="${INIT_DB_FILE_DIR:-/etc/mysql/initdb.d}"
	local init_db_file="${INIT_DB_FILE_PATH:-/etc/mysql/initdb.sql}"
	echo 'merge init-files'
	mkdir -p "$init_db_file_dir"
	touch "$init_db_file"
	for file in $(find "$init_db_file_dir" -name "*.sql" | sort); do
		cat "$file" >> "$init_db_file"
		echo -e ';' >> "$init_db_file"
	done
}

setup_database() {
	setup_root_password
}

setup_root_password() {
	if [ -z "$ROOT_PASS_FILE" ]; then
		echo 'Error: You must set environment: ROOT_PASS_FILE' > /dev/stderr
	fi
	append_instruction "ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('$(cat $ROOT_PASS_FILE | tr -d '\n')');"
}

append_instruction() {
	INSTRUCTION="$INSTRUCTION$(echo "$1")"
}

get_instructions() {
	echo "$INSTRUCTION"
}

execute_sql_instructions() {
	start_temporary_server
	wait_temporary_until_initialize
	mariadb -u root -h localhost -e "$(get_instructions)"
	echo ""
	echo "$get_instructions"
	echo ""
	stop_temporary_server
}

start_temporary_server() {
	mariadbd &
	declare -g MARIADB_PID
	MARIADB_PID=$!
}

stop_temporary_server() {
	kill "$MARIADB_PID"
	wait "$MARIADB_PID"
}

wait_temporary_until_initialize() {
	for i in {30..0}; do
		if check_temporary_server_initialized; then
			break
		fi
		sleep 1
	done
	if [ "$i" -eq 0 ]; then
		echo "Don't start temporary server"
		exit 1
	fi
}

check_temporary_server_initialized() {
	if ! mariadb --database=mysql -e 'SELECT 1;' &> /dev/null; then
		cat $ROOT_PASS_FILE | tr -d '\n' | mariadb --database=mysql -p -e 'SELECT 1;' &> /dev/null
	fi
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
