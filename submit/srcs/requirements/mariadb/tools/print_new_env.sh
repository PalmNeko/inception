#!/bin/bash

main() {
	declare -A configs;
	set_environment
	print_environment | sort
}

set_environment() {
	configs["WORDPRESS_USERNAME"]="$(prompt_for_environment "database username for wordpress: ( WORDPRESS_USERNAME )" "$WORDPRESS_USERNAME" "wordpress")" ; validate_required "WORDPRESS_USERNAME"
	configs["WORDPRESS_DBNAME"]="$(prompt_for_environment "database name for wordpress: ( WORDPRESS_DBNAME )" "$WORDPRESS_DBNAME" "wordpress")" ; validate_required "WORDPRESS_DBNAME"
	configs["WORDPRESS_PASSWORD"]="$(prompt_for_secret_environment "password for wordpress database: ( WORDPRESS_PASSWORD )" "$WORDPRESS_PASSWORD" "" "")" ; validate_required "WORDPRESS_PASSWORD"
	configs["MARIADB_SOCKET"]="$(prompt_for_environment "mariadbd socket: ( MARIADB_SOCKET )" "$MARIADB_SOCKET" "/run/mysqld/mysqld.sock")"
	configs["MARIADB_PID_FILE"]="$(prompt_for_environment "mariadbd pid-file: ( MARIADB_PID_FILE )" "$MARIADB_PID_FILE" "/run/mysqld/mysqld.pid")"
	configs["INIT_DB_FILE_PATH"]="$(prompt_for_environment "mariadbd init-file path: ( INIT_DB_FILE_PATH )" "$INIT_DB_FILE_PATH" "/etc/mysql/init-file.sql")"
	configs["INIT_DB_FILE_DIR"]="$(prompt_for_environment "mariadbd .sql files for init path: ( INIT_DB_FILE_DIR )" "$INIT_DB_FILE_DIR" "/etc/mysql/initdb.d")"
}

# Usage: $0
print_environment() {
	for key in ${!configs[@]}; do
		echo "$key=${configs[$key]}";
	done
}

# Usage: $0 prompt [old_env_value] [default_value]
prompt_for_environment() {
	local prompt="$1" old_env_value="$2" default_env_value="$3"
		echo_prompt "$prompt" "$old_env_value" "$default_env_value" > /dev/stderr

	local value
	read value
	if [ -n "$value" ]; then
		echo "$value"
	elif [ -n "$old_env_value" ]; then
		echo "$old_env_value"
	else
		echo "$default_env_value"
	fi
	return 0
}

# Usage: $0 prompt [old_env_value] [default_value default_explain]
prompt_for_secret_environment() {
	local prompt="$1" old_env_value="$2" default_env_value="$3" default_explain="$4"
	echo_prompt "$prompt" "$old_env_value" "$default_explain" > /dev/stderr
	local value
	read -s value
	if [ -n "$value" ]; then
		echo "$value"
	elif [ -n "$old_env_value" ]; then
		echo "$old_env_value"
	else
		echo "$default_env_value"
	fi
	echo > /dev/stderr
	return 0
}

echo_prompt() {
	local prompt="$1" old_env_value="$2" default_env_value="$3" 
	local msg="$prompt"
	if [ -n "$old_env_value" ]; then
		msg+="$(printf " (old: \e[32m%s\e[m)" "$old_env_value")"
	fi
	if [ -n "$default_env_value" ]; then
		msg+="$(printf " (default: \e[34m%s\e[m)" "$default_env_value")"
	fi
	printf "%s > " "$msg"
}

# Usage: $0 configs_key
validate_required() {
	local key="$1"
	if [ -z "${configs["$key"]}" ]; then
		echo -e "\e[31mError:\e[m $key environment value is required" > /dev/stderr;
		exit 1
	fi
}

main "$@"
