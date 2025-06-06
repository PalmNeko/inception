#!/bin/bash

#
# replace placeholder with environment value
# example
# echo "{{NAME}}" | NAME="Jhon" $0 "NAME"
# cat file | $0 "NAME"
#
main() {
	replace "$@"
}

replace() {
	local content="$(cat)"

	for param in "$@"; do
		local value="${!param}"
		content="${content//\{\{$param\}\}/$value}"
	done
	echo "$content"
}

main "$@"
