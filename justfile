new name:
    gum log -sl info "Creating" "project" {{ name }}
    mkdir {{ name }} && cd {{ name }} && bashly init --minimal
