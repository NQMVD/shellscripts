template=${args[--template]}

if is not empty "$template"; then
    echo "Creating a template from $template"
    if is equal "$template" "rust"; then
        echo "./src/main.rs" > 'editfile'
        is dir '.git' && echo "./README.md" >> 'editfile'
    elif is equal "$template" "bashly"; then
        echo "./src/root_command.sh" > 'editfile'
        echo "./src/bashly.yml" >> 'editfile'
    else
        echo "not yet implemented..."
    fi
    return 0
fi

if is existing "editfile"; then
    joinedlines=$(tr '\n' ' '< "editfile")
    $EDITOR $joinedlines
else
    echo "no editfile found..."
    exit 1
fi
