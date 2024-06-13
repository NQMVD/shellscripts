new name:
    @gum log -sl info "Creating" "project" {{ name }}
    mkdir {{ name }} && cd {{ name }} && bashly init --minimal

cec file:
    chmod +x {{file}}
    sudo cp "{{file}}" "/usr/local/bin/`basename {{file}} .sh`"
    @eza /usr/local/bin -1
