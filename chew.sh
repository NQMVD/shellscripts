is empty "$1" && echo "Needs a HEADER" && exit 1
HEADER="$1"

TYPE='input'
is not empty "$2" && TYPE='write'

while true; do
  INPUT=$(gum $TYPE --header "${HEADER} (non-empty)")

  if is not empty "$INPUT"; then
    break
  fi

  if is equal $? 130; then
    return 1
  fi
done

echo "$INPUT"