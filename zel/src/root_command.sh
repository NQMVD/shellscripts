gum style --foreground="#7359f8" 'Zellij Sessions:'
zellij list-sessions
echo ''

SESSIONS=$(zellij list-sessions --no-formatting)

if echo "$SESSIONS" | rg -q -F -- 'current'; then
    gum style --foreground="#7359f8" 'Already in a Session...'
    exit 1
fi

if echo "$SESSIONS" | rg -q -F -- 'No active zellij sessions found.'; then
    case $(gum choose --header='Action:' "new" "new (layout)") in
        new)
            NAME=$(gum input --header="New Session" --placeholder="..." --prompt="Name: ")
            [[ $? -eq 130 ]] && echo "Cancelled" && exit 130
            zellij --session "$NAME"
            ;;

        "new (layout)")
            NAME=$(gum input --header="New Session" --placeholder="..." --prompt="Name: ")
            [[ $? -eq 130 ]] && echo "Cancelled" && exit 130
            LAYOUT=$(eza ~/.config/zellij/layouts | xargs basename -s '.kdl' | gum choose --header='Layouts:')
            [[ $? -eq 130 ]] && echo "Cancelled" && exit 130
            zellij --layout "$LAYOUT" --session "$NAME"
            ;;

        *)
            echo "Cancelled!"
            ;;
    esac
else
    case $(gum choose --header='Action:' "attach" "new" "new (layout)" "kill" "delete") in
        attach)
            NAME=$(zellij list-sessions | gum filter | awk '{print $1}')
            [[ $? -eq 130 ]] && echo "Cancelled" && exit 130
            zellij attach "$NAME"
            ;;

        new)
            NAME=$(gum input --header="New Session" --placeholder="..." --prompt="Name: ")
            [[ $? -eq 130 ]] && echo "Cancelled" && exit 130
            zellij --session "$NAME"
            ;;

        "new (layout)")
            NAME=$(gum input --header="New Session" --placeholder="..." --prompt="Name: ")
            [[ $? -eq 130 ]] && echo "Cancelled" && exit 130
            LAYOUT=$(eza ~/.config/zellij/layouts | xargs basename -s '.kdl' | gum choose --header='Layouts:')
            [[ $? -eq 130 ]] && echo "Cancelled" && exit 130
            zellij --layout "$LAYOUT" --session "$NAME"
            ;;

        kill)
            NAME=$(zellij list-sessions | gum filter | awk '{print $1}')
            [[ $? -eq 130 ]] && echo "Cancelled" && exit 130
            zellij kill-session "$NAME"
            ;;

        delete)
            SELECTED=()
            zellij ls | gum choose --no-limit | awk '{print $1}' | while IFS="" read -r line; do array+=("$line"); done
            gum confirm "Delete ${#SELECTED[@]}?" || exit 1
            for name in "${SELECTED[@]}"
            do
                zellij delete-session "$name"
            done
            ;;

        *)
            echo "Cancelled"
            ;;
    esac
fi
