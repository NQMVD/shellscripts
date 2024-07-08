
gum style --foreground="#7359f8" 'Zellij Sessions:'
zellij list-sessions
echo ''

if [[ -n "$ZELLIJ_SESSION_NAME" ]]; then
    # zellij attach $(zellij list-sessions | gum filter | awk '{print $1}')
    gum style --foreground="#7359f8" 'Already in a Session...'
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
            SELECTED=($(zellij ls | gum choose --no-limit | awk '{print $1}'))
            gum confirm "Delete ${#SELECTED[@]}?" || exit 1
            for name in "${SELECTED[@]}"
            do
                # gum log -sl info 'deleting' 'session' "$name"
                zellij delete-session "$name"
            done
            ;;

        *)
            echo "Cancelled!"
            ;;
    esac
fi
