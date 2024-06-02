file=${args[file]}

is not existing "$file" && echo "File not found: $file" && return 1

if [[ "$file" == *.zip ]]; then
    unzip "$file"
elif [[ "$file" == *.tar.gz || "$file" == *.tgz ]]; then
    tar -xzf "$file"
elif [[ "$file" == *.tar.bz2 || "$file" == *.tbz2 ]]; then
    tar -xjf "$file"
elif [[ "$file" == *.tar.xz || "$file" == *.txz ]]; then
    tar -xJf "$file"
elif [[ "$file" == *.tar ]]; then
    tar -xf "$file"
else
    echo "Unsupported file format: $file"
    return 1
fi
