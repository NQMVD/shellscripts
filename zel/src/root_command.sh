# list sessions
# choose: new -> input name; attach, kill, delete (fzf choose)

gum style --foreground="#7359f8" 'Zellij Sessions:'
zellij list-sessions
echo ''

if [[ -n "$ZELLIJ_SESSION_NAME" ]]; then
    zellij attach $(zellij list-sessions | gum filter | awk '{print $1}')
else
    case $(gum choose --header='Action:' "new" "new layout" "attach" "kill" "delete") in
        new)
            zellij --session $(gum input --header="New Session" --placeholder="..." --prompt="Name: ")
            ;;

        "new layout")
            zellij --layout $(eza ~/.config/zellij/layouts | xargs basename -s '.kdl' | gum choose --header='Layouts:') --session $(gum input --header="New Session" --placeholder="..." --prompt="Name: ")
            ;;

        attach)
            zellij attach $(zellij list-sessions | gum filter | awk '{print $1}')
            ;;

        kill)
            zellij kill-session $(zellij list-sessions | gum filter | awk '{print $1}')
            ;;

        delete)
            zellij delete-session $(zellij list-sessions | gum filter | awk '{print $1}')
            ;;

        *)
            echo "Cancelled!"
            ;;
    esac
fi
