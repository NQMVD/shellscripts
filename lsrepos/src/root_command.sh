# description: prints the starship promt for all git repos in the cwd

is not available starship && ( gum log -l error '*starship* not available...'; return 1 )

for dir in */; do
  # if [ -d "$dir/.git" ]; then
  if is a dir "$dir/.git"; then

    (cd "$dir" || exit
    content=$(starship explain)
    cwd=$(echo "$content" | rg 'working dir' | sed 's/.*"\(.*\)".*/\1/')
    branch=$(echo "$content" | rg 'branch' | sed 's/.*"\(.*\)".*/\1/')
    state=$(echo "$content" | rg 'state' | sed 's/.*"\(.*\)".*/\1/')
    versions=$(echo "$content" | rg 'via' | \
      while read -r line; do echo "$line" | sed 's/.*"\(.*\)".*/\1/'; done | \
      tr '\n' ' ')

    echo "- ${cwd}${branch}${state}${versions}")
  fi
done
