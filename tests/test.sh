#!/bin/bash

TEST_URL=127.0.0.1
NGINX_PORT=443

main() {
    if [ "$1" = "--help" ]; then
        help
        exit 0
    fi
    parse_option "$@"
    test_nginx
    if [ -n "$FAILURE" ]; then
        return 1
    fi
}

help() {
    echo "Usage: $0 [options]"
    echo "  -r     Toggle print test result. default on."
    echo "  -g     Toggle print test genre. default off."
    echo "  -c     Toggle print test command. default off."
    echo "  -s     Toggle print test case. default on."
    echo "  -e     Toggle print test error message. default off."
    echo "  --help Print help."
}

parse_option() {
    ARGS=$(getopt srgce "$@")
    eval set -- "$ARGS"

    OPT_RESULT="on"
    OPT_GENRE=""
    OPT_CMD=""
    OPT_CASE="on"
    OPT_EMSG="on"
    while true; do
        case "$1" in
            -r) OPT_RESULT="" ; shift ;;
            -g) OPT_GENRE="on" ; shift ;;
            -c) OPT_CMD="on" ; shift ;;
            -s) OPT_CASE="" ; shift ;;
            -e) OPT_EMSG="" ; shift ;;
            *) break; ;;
        esac
    done
    OPT_ANY="${OPT_CASE}${OPT_RESULT}${OPT_GENRE}${OPT_CMD}${OPT_EMSG}"
    [ -n "$OPT_ANY" ] && OPT_ANY="on"
}

test_nginx() {
    [[ -n $OPT_ANY ]] && echo "[ test nginx ]"
    test -x /usr/bin/which || prepare_fail "you need which command"
    which openssl > /dev/null || prepare_fail "you need openssl command"


    TLS_TEST_TEMPLATE="openssl s_client -connect $TEST_URL:$NGINX_PORT -quiet -no_ign_eof"
    test_false "$TLS_TEST_TEMPLATE -tls1_1  < /dev/null" "don't use the TLSv1.1" "$(mkerr "enable TLSv1.1")"
    test_true "$TLS_TEST_TEMPLATE -tls1_2  < /dev/null" "can use the TLSv1.2" "$(mkwarn "disable the TLSv1.2")"
    test_true "$TLS_TEST_TEMPLATE -tls1_3  < /dev/null" "can use the TLSv1.3" "$(mkwarn "disable the TLSv1.3")"

}

mkerr() {
    echo "Error: $1"
}

mkwarn() {
    echo "Warn: $1"
}

# Usage: $0 command label err_msg
test_true() {
    local command="$1" label="$2" err_msg="$3"
    local success_text="\033[32m  [OK]\033[m"
    local failure_text="\033[31m  [NG]\033[m"
    local genre="false"
    test_base "$command" "$label" "$err_msg" "$success_text" "$failure_text" "$genre"
}

# Usage: $0 command label err_msg
test_false() {
    local command="$1" label="$2" err_msg="$3"
    local success_text="\033[31m  [NG]\033[m"
    local failure_text="\033[32m  [OK]\033[m"
    local genre="false"
    test_base "$command" "$label" "$err_msg" "$success_text" "$failure_text" "$genre"
}

# Usage: $0 command label err_msg success_text failure_text test_genre
# description: test_true test_false base
test_base() {
    local command="$1" label="$2" err_msg="$3" success_text="$4" failure_text="$5" test_genre="$6"
    local result_text
    if bash -c "$command" > /dev/null 2> /dev/null; then
        result_text="$success_text"
    else
        result_text="$failure_text"
    fi
    local failure=""
    if echo "$result_text" | grep NG > /dev/null; then
        FAILURE="true"
        failure="true"
    fi

    local spacer="" colon=""
    [[ -n "$OPT_RESULT" ]] && printf "%b" "$result_text" && spacer=" " colon=":"
    [[ -n "$OPT_GENRE" ]] && printf "${colon}${spacer}${test_genre}" && spacer=" " colon=":"
    [[ -n "$OPT_CMD" ]] && printf "${spacer}( %s )" "$command" && spacer=" " colon=":"
    [[ -n "$OPT_CASE" ]] && printf "${colon}${spacer}${label}"  && spacer=" " colon=":"
    [[ -n "$OPT_EMSG" && -n "$failure" ]] && printf "${colon}${spacer}${err_msg}" && spacer=" " colon=":"
    [[ -n "$OPT_ANY" ]] && printf "\n"
    [[ -n "$failure" ]] && return 1
    return 0
}

prepare_fail() {
    echo "$@"
    exit 1
}

main "$@"
