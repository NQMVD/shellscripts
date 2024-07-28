#!/usr/bin/env bash
COLS="$(tput cols)"
if (( COLS <= 0 )) ; then
    COLS="${COLUMNS:-80}"
fi

hr() {
    local WORD="$1"
    local LINE=''

    if [[ -z "$WORD" ]] ; then
        return;
    fi

    printf -v LINE '%*s' "$COLS"
    LINE="${LINE// /${WORD}}"
    echo "${LINE:0:${COLS}}"
}

hrs() {
    local WORD

    for WORD in "${@:--}"
    do
        hr "$WORD"
    done
}

hrs "$@"
