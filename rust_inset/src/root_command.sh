#!/bin/bash

while read -r line; do
    if [[ $line =~ ^let\s+([a-zA-Z_][a-zA-Z_0-9]*)\s*=\s* ]]; then
        var_name=${BASH_REMATCH[1]}
    elif [[ $line =~ ^\s*$ ]]; then
        # ignore blank lines
        continue
    fi
done

read -r first_line second_line
if [[ $first_line =~ ^let\s+([a-zA-Z_][a-zA-Z_0-9]*)\s*=\s*(.*)$ ]]; then
    var_name=${BASH_REMATCH[1]}
    expression=${BASH_REMATCH[2]}
fi

while read -r line; do
    if [[ $line == $second_line ]]; then
        echo "Replacing ${var_name} with ${expression}"
        second_line="${second_line//${var_name}/${expression}}"
    else
        echo "$line"
    fi
done
