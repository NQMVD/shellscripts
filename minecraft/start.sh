gum log -l info 'Setting up pueue'
pueued -d
pueue parallel -g MINECRAFT 2 > /dev/null

GROUPLIST=$(pueue status -g MINECRAFT status=running)
ISEMPTY=$(echo "$GROUPLIST" | rg -q -i -F 'empty')

if [ $ISEMPTY -eq 0 ]; then
  gum log -l error "another instance is still running:"
  pueue status -g MINECRAFT
  exit 1
fi

gum log -l info 'Starting Minecraft Server...'
pueue clear > /dev/null
pueue add -g MINECRAFT -w "$(pwd)" "./run.sh"
