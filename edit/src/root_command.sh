template=${args[--template]}

function create_template() {
    echo "Creating a template from $template"
    if is equal "$template" "rust"; then
        echo "./src/main.rs" > 'editfile'
        is dir '.git' && echo "./README.md" >> 'editfile'
    elif is equal "$template" "bashly"; then
        echo "./src/root_command.sh" > 'editfile'
        echo "./src/bashly.yml" >> 'editfile'
    else
        echo "not yet implemented..."
        return 1
    fi
}

if is not empty "$template"; then
    exit 0
fi

if is existing "editfile"; then
    joinedlines=$(tr '\n' ' ' < "editfile")
    $EDITOR $joinedlines
else
    echo "no editfile found..."
    gum confirm 'create one from a template?' && \
        template=$(gum choose 'rust' 'bashly') create_template && exit 0
    exit 1
fi
