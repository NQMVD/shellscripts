header=${args[header]}
content=${other_args[*]}

# Generate the boxed content
boxed_content=$(echo "[-$header-]" "$content" | xargs gum style --padding="0 1" --border=rounded) #$(echo "$content" | box)

# Extract the first line (the top border) from the boxed content
top_border=$(echo "$boxed_content" | head -n 1)

# Calculate the necessary padding
border_length=${#top_border}
header_length=${#header}
padding_length=$(( (border_length - header_length) / 2 ))

# Construct the new top border with the header
new_top_border=""
new_top_border+="${top_border:0:$((padding_length - 2))}"
new_top_border+="[ $(gum style --foreground 6 $header) ]"
new_top_border+="${top_border:$((2 + padding_length + header_length))}"

# Replace the original top border with the new one
result=$(echo "$boxed_content" | sed "2s/.*/$new_top_border/" | sed '1d')

# Print the result
echo "$result"
