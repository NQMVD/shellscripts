readonly package_name="${args[pkg]}"

# if is empty $package_name; then
#     echo "Usage: $0 <package_name>"
#     exit 1
# fi

managers=("apt" "yay" "go" "cargo")
installed_managers=()
FAILED="✗"
SUCCESS="✓"

for manager in "${managers[@]}"; do
    if command -v "$manager" >/dev/null 2>&1; then
        installed_managers+=("$manager")
    fi
done

echo "Installed package managers: ${installed_managers[*]}"

results=()
for manager in "${installed_managers[@]}"; do
    case "$manager" in
        "apt")
            ;;
        "yay")
            output=$(yay -Ss "$package_name")
            if [ -n "$output" ]; then
                lines=()

                while IFS= read -r line; do
                    # gum log -l debug "line: $line"
                    if [[ "$line" != " "* ]] && [ -n "$line" ] && ; then
                        lines+=("$line")
                    fi
                done <<< "$output"

                count=${#lines[@]}
                gum log -l debug "count: $count"
                line="${lines[$((count - 1))]}"
                gum log -l debug "line: $line"
                chunks=($line)
                fullname="${chunks[0]}"
                gum log -l debug "fullname: $fullname"
                IFS='/' read -ra fullnamesplit <<< "$fullname"
                repo="${fullnamesplit[0]}"
                name="${fullnamesplit[1]}"
                version="${chunks[1]}"
                gum log -l debug "repo, name, version: $repo, $name, $version"

                if [ "$package_name" == "$name" ]; then
                    if [[ "$line" == *"Installed"* ]]; then
                        results+=("I -   yay: $fullname $version [installed]")
                    else
                        results+=("A -   yay: $fullname $version")
                    fi
                else
                    results+=("X -   yay: $package_name != $fullname")
                fi
            fi
            ;;
        "go")
            output=$(go version -m /home/noah/go/bin 2>/dev/null)
            if [ -n "$output" ]; then
                while IFS= read -r line; do
                    if [[ "$line" == *"path"* ]] && [ -n "$line" ]; then
                        chunks=($line)
                        fullname="${chunks[1]}"
                        IFS='/' read -ra fullnamesplit <<< "$fullname"
                        name="${fullnamesplit[-1]}"
                        repo=$(IFS='/'; echo "${fullnamesplit[*]}")

                        if [ "$package_name" == "$name" ]; then
                            results+=("I -    go: $name ($repo) [installed]")
                        fi
                    fi
                done <<< "$output"
            else
                echo "stdout is empty!"
                echo "$output"
            fi
            ;;
        "cargo")
            installed=false
            output=$(cargo install --list 2>/dev/null)
            if [ -n "$output" ]; then
                while IFS= read -r line; do
                    if [[ "$line" != " "* ]] && [ -n "$line" ]; then
                        chunks=($line)
                        name="${chunks[0]}"
                        version="${chunks[1]}"

                        if [ "$package_name" == "$name" ]; then
                            results+=("I - cargo: $name $version [installed]")
                            installed=true
                        fi
                    fi
                done <<< "$output"
            fi

            if [ "$installed" = false ]; then
                output=$(cargo search "$package_name" 2>/dev/null)
                if [ -n "$output" ]; then
                    line=$(echo "$output" | head -n 1)
                    chunks=($line)
                    name="${chunks[0]}"
                    version="${chunks[2]}"
                    description=$(echo "${chunks[@]:3}" | tr ' ' ' ')

                    if [ "$package_name" == "$name" ]; then
                        results+=("A - cargo: $name $version $description")
                    else
                        results+=("X - cargo: $package_name != $name $description")
                    fi
                fi
            fi
            ;;
        *)
            echo "Unsupported package manager: $manager"
            ;;
    esac
done

echo -e "\nResults:"
for result in "${results[@]}"; do
    echo "$result"
done
