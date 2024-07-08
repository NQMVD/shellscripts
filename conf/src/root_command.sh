echo "# this file is located in 'src/root_command.sh'"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args


### STUPID VERSION

LIST=$(eza '~/dotfiles')

CHOICE=$(echo $LIST | gum filter --header 'Config to open:')

if is file "~/dotfiles/$CHOICE"; then
  hx "$HOME/dotfiles/$CHOICE"
elif is dir "~/dotfiles/$CHOICE"; then
  yazi "$HOME/dotfiles/$CHOICE"
fi


### SMART VERSION
# TODO: sub categories? with choose

# LIST=('zsh' 'zellij' 'wezterm')

# CHOICE=$(echo $LIST | gum filter --header 'Config to open:')

# case $CHOICE in
#   'zsh')
#     hx '~/dotfiles/zsh/'
#     ;;
# esac
