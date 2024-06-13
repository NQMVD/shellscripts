is empty "$1" && echo "Needs a HEADER" && exit 1
HEADER="$1"
  
while true; do
  INPUT=$(gum input --header "${HEADER} (non-empty)")

  if is not empty "$INPUT"; then
    break
  fi
done

echo "$INPUT"
