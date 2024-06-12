delimiter=${args[delimiter]}
input=$(cat)

# Split the input string and store chunks in an array
IFS="$delimiter" read -ra chunks <<< "$input"

# Print the chunks in a format suitable for storing in an array
for chunk in "${chunks[@]}"; do
    echo -n "$chunk "
done
echo
