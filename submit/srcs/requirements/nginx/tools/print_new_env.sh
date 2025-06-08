#!/bin/bash

main() {
	declare -A configs;
	set_environment
	print_environment | sort
}

set_environment() {
	configs["CGI_HOSTNAME"]="$(prompt_for_environment "cgi hostname: ( CGI_HOSTNAME )" "$CGI_HOSTNAME" "wordpress")" ; validate_required "CGI_HOSTNAME"
	configs["CGI_PORT"]="$(prompt_for_environment "cgi port number: ( CGI_PORT )" "$CGI_PORT" "9000")" ; validate_required "CGI_PORT"
	configs["CGI_ROOT"]="$(prompt_for_environment "cgi root directory: ( CGI_ROOT )" "$CGI_ROOT" "/srv/wordpress")" ; validate_required "CGI_ROOT"
	configs["NGINX_SERVER_NAME"]="$(prompt_for_environment "nginx server_name: ( NGINX_SERVER_NAME )" "$NGINX_SERVER_NAME" "tookuyam.42.fr")" ; validate_required "NGINX_SERVER_NAME"
	configs["SSL_KEY_PATH"]="$(prompt_for_environment "ssl key mount path: ( SSL_KEY_PATH )" "$SSL_KEY_PATH" "/ssl.key")" ; validate_required "SSL_KEY_PATH"
	configs["SSL_CRT_PATH"]="$(prompt_for_environment "ssl crt mount path: ( SSL_CRT_PATH )" "$SSL_CRT_PATH" "/ssl.crt")" ; validate_required "SSL_CRT_PATH"
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
