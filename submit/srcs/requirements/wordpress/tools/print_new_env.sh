#!/bin/bash

main() {
	declare -A configs;
	set_environment
	print_environment | sort
}

set_environment() {
	configs["WORDPRESS_LISTEN"]="$(prompt_for_environment "wordpress listen configuration: ( WORDPRESS_LISTEN )" "$WORDPRESS_LISTEN" "9000")" ; validate_required "WORDPRESS_LISTEN"
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
