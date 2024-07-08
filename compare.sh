BRIEF=$1
find . -maxdepth 1 -type d | while read -r dir; do
    base=$(basename "$dir")
    if [[ -f "$dir/$base" && -f "/usr/local/bin/$base" ]]; then
        echo '----------------------------------------------'
        echo "Comparing $dir/$base with /usr/local/bin/$base"
        diff --color=always -a $BRIEF "$dir/$base" "/usr/local/bin/$base"
    fi
done

for file in *; do
    if [[ -f "$file" ]]; then
        base="${file%.*}"
        if [[ -f "/usr/local/bin/$base" ]]; then
        echo '----------------------------------------------'
            echo "Comparing $file with /usr/local/bin/$base"
            diff --color=always -a $BRIEF "$file" "/usr/local/bin/$base"
        fi
    fi
done
