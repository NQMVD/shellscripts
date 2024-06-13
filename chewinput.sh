[[ "$#" -lt 1 ]] && echo "Needs a HEADER" && exit 1
HEADER="$1"
  
while true; do
  INPUT=$(gum input --header "${HEADER} (non-empty)")

  if [ -z "$INPUT" ]; then
    echo "Input cannot be empty. Try again!"
  else
    break
  fi
done

echo "$INPUT"
