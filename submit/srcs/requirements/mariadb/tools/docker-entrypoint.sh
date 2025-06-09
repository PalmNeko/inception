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

sql_install_ed25519() {
	append_instruction "INSTALL SONAME 'auth_ed25519';"
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
	sql_install_ed25519
	setup_root_password
}

setup_root_password() {
	if [ -z "$ROOT_PASS_FILE" ]; then
		echo 'Error: You must set environment: ROOT_PASS_FILE' > /dev/stderr
		exit 1
	elif ! [ -f "$ROOT_PASS_FILE" ]; then
		echo "Error: $ROOT_PASS_FILE: No such file or directory" > /dev/stderr
		exit 1
	fi
	setup_password "root" "localhost" "$(cat_password $ROOT_PASS_FILE)"
}

setup_password() {
	local user="$1" host="$2" password="$3"
	append_instruction "ALTER USER '$user'@'$host' IDENTIFIED VIA ed25519 USING PASSWORD('$password');"
}

append_instruction() {
	local sql="$1"
	INSTRUCTION="$INSTRUCTION
${sql}"
}

push_instruction() {
	local sql="$1"
	INSTRUCTION="${sql}
$INSTRUCTION"
}

get_instructions() {
	echo "$INSTRUCTION"
}

execute_sql_instructions() {
	local mariadb_pid;
	push_instruction "FLUSH PRIVILEGES;"
	start_temporary_server
	mariadb_pid="$MARIADB_PID"
	wait_temporary_until_initialize "$mariadb_pid"
	
	echo "SQL:"
	echo "$(get_instructions)"
	echo ""
	
	mariadb -u root -h localhost -e "$(get_instructions)"
	stop_temporary_server "$mariadb_pid"
}

start_temporary_server() {
	mariadbd --skip-grant-tables &
	echo "$!"
	declare -g MARIADB_PID
	MARIADB_PID=$!
}

stop_temporary_server() {
	local mariadb_pid="$1";
	kill "$mariadb_pid"
	wait "$mariadb_pid"
}

cat_password() {
	cat $1 | tr -d '\n'
}

wait_temporary_until_initialize() {
	echo 'Waiting...'
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
	echo 'Temporary server is begun'
}

check_temporary_server_initialized() {
	mariadb -e 'SELECT 1;' &> /dev/null;
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
