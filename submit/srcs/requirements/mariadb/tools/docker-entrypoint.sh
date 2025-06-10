#!/bin/bash

#
# If you change this file, you have to rebuild the image.
#

main () {
	echo '[ start mariadbd container ]'

	if [ "$1" = "mariadbd" ]; then
		set_exit_trap
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

	tmpfile="$(mktemp)"
	add_exit_rm_file "$tmpfile"
	
	# SQLs
	flush_privileges >> "$tmpfile"
	
	change_plugin "root" "localhost" "mysql_native_password" >> "$tmpfile"
	setup_root_password >> "$tmpfile"

	create_user "wordpress" "%" >> "$tmpfile"
	change_plugin "wordpress" "%" "mysql_native_password" >> "$tmpfile"
	set_wordpress_password >> "$tmpfile"
	
	create_wordpress_database >> "$tmpfile"
	grant_wordpress_database >> "$tmpfile"
	
	# execute SQLs
	execute_sql_at_temporary_server "$(cat "$tmpfile")"

	rm -f "$tmpfile"
	remove_exit_rm_file "$tmpfile"
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

set_wordpress_password() {
	if [ -z "$WP_DB_PASS_FILE" ]; then
		echo 'Error: You must set environment: WP_DB_PASS_FILE' > /dev/stderr
		exit 1
	elif ! [ -f "$WP_DB_PASS_FILE" ]; then
		echo "Error: $WP_DB_PASS_FILE: No such file or directory" > /dev/stderr
		exit 1
	fi

	local password="$(cat "$WP_DB_PASS_FILE")"
	setup_password "wordpress" "%" "$password"
}

create_wordpress_database() {
	create_database wordpress
}

grant_wordpress_database() {
	local priv_types="SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER"
	local priv_level="wordpress.*"
	local user_specification="'wordpress'@'%'"

	grant_table "$priv_types" "$priv_level" "$user_specification"
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
	echo 'Start temporary server'
	mariadbd --skip-grant-tables --skip-networking &
	echo "$!"
	declare -g MARIADB_PID
	MARIADB_PID=$!
}

stop_temporary_server() {
	echo 'Stop temporary server'
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
	echo "ALTER USER '$user'@'$host' IDENTIFIED VIA mysql_native_password;"
	echo "SET PASSWORD FOR '$user'@'$host' = PASSWORD('$password');"
}

flush_privileges() {
	echo "FLUSH PRIVILEGES;"
}

create_user() {
	local user="$1" host="${2:-"%"}"
	echo "CREATE USER IF NOT EXISTS '$user'@'$host';"
}

change_plugin() {
	local user="$1" host="$2" plugin="$3"
	echo "ALTER USER '$user'@'$host' IDENTIFIED VIA $plugin;"
}

create_database() {
	local dbname="$1"
	echo "CREATE DATABASE IF NOT EXISTS $dbname;"
}

grant_table() {
	local priv_types="$1" priv_level="$2" user_specification="$3" password="$4"
	echo "GRANT $priv_types"
	echo "  ON $priv_level"
	echo "  TO $user_specification;"
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

##### Exit Trap #####

set_exit_trap() {
	trap exit_handler EXIT
}

exit_handler() {
	for file in "${g_delete_files[@]}"; do
		rm -f "$file"
	done
}

add_exit_rm_file() {
	declare -a g_delete_files;

	local file="$1"

	g_delete_files+=("$file")
}

remove_exit_rm_file() {
	for key in "${!g_delete_files[@]}"; do
		if [ "${g_delete_files["$key"]}" = "$file" ]; then
			unset g_delete_files["$key"]
		fi
	done
}

##### MAIN #####

main "$@"
