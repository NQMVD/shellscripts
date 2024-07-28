# new bashly project
new name:
    @gum log -sl info "Creating" "project" {{ name }}
    mkdir {{ name }} && cd {{ name }} && bashly init --minimal

# create executable copy in local bin
cec file:
    chmod +x {{file}}
    sudo cp "{{file}}" "/usr/local/bin/`basename {{file}} .sh`"
    @eza /usr/local/bin -lah

# show diff to last git update
diff:
    @git diff --name-only HEAD~1 HEAD
