#!/bin/bash

#
# If you change this file, you have to rebuild the image.
#

main () {
	echo '[ start mariadbd container ]'

	if [ "$1" = "mariadbd" ]; then
		setup_mariadbd
	fi
	echo '[ the setup is now complete ]'
	exec "$@"
}

##### logics #####

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
}

setup_database() {
	local sql

	sql+=$(flush_privileges)$(echo)
	sql+=$(sql_install_ed25519)$(echo)
	sql+=$(setup_root_password)$(echo)

	execute_sql_at_temporary_server "$sql"
}

##### SQL logics #####

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

##### setup run directory (pid and socket)  #####

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

##### Mariadb Server #####

execute_sql_at_temporary_server() {
	local sql="$1"

	local mariadb_pid;
	start_temporary_server 
	mariadb_pid="$MARIADB_PID"
	wait_temporary_until_initialize "$mariadb_pid"
	
	echo "SQL:"
	echo "$sql"
	
	mariadb -u root -h localhost -e "$sql"
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

##### SQL wrappers #####

setup_password() {
	local user="$1" host="$2" password="$3"
	echo "ALTER USER '$user'@'$host' IDENTIFIED VIA ed25519 USING PASSWORD('$password');"
}

sql_install_ed25519() {
	echo "INSTALL SONAME 'auth_ed25519';"
}

flush_privileges() {
	echo "FLUSH PRIVILEGES;"
}

##### SQL Instruction Buffer #####

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

##### Others (not recommended) #####

cat_password() {
	cat $1 | tr -d '\n'
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

##### MAIN #####

main "$@"
