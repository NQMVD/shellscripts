#!/usr/bin/env bash

# Initialize variables
in_code_block=false
first_line=""
line_number=0
code_block_start_line=0
results=()
counter=0
target_block=""
target_line_number=0
mode='results'

# Parse command line arguments
while getopts "n:" opt; do
  case $opt in
    n)
      target_line_number=$OPTARG
      mode='target'
      ;;
    c)
      mode='count'
      ;;
    *)
      echo "Usage: $0 -n NUMBER" >&2
      exit 1
      ;;
  esac
done

# check if run with a target line number
if [[ $mode == 'target' ]]; then
  # Read from stdin line by line
  while IFS= read -r line || [ -n "$line" ]; do
    ((line_number++))
    # Detect the start or end of a code block
    if [[ $line == \`\`\`* ]]; then
      if $in_code_block; then
        # End of code block
        in_code_block=false
        if [[ -n $target_block ]]; then
          # Print the target block and exit
          echo "$target_block"
          exit 0
        fi
      else
        # Start of code block
        in_code_block=true
        code_block_start_line=$line_number
        if [[ $code_block_start_line -eq $target_line_number ]]; then
          target_block=""
        fi
      fi
    elif $in_code_block; then
      # Inside a code block
      if [[ $code_block_start_line -eq $target_line_number ]]; then
        target_block+="$line"$'\n'
      fi
    fi
  done

  # Handle case where the code block might not be properly terminated
  if [[ -n $target_block ]]; then
    echo "$target_block"
  fi
  
elif [[ $mode == 'count' ]]; then
    while IFS= read -r line || [ -n "$line" ]; do
    ((line_number++))
    # Detect the start or end of a code block
    if [[ $line == \`\`\`* ]]; then
      if $in_code_block; then
        # End of code block
        ((counter++))
        in_code_block=false
      else
        # Start of code block
        in_code_block=true
      fi
    fi
  done

else
  # Read from stdin line by line
  while IFS= read -r line || [ -n "$line" ]; do
    ((line_number++))
  
    # Detect the start or end of a code block
    if [[ $line == \`\`\`* ]]; then
      if $in_code_block; then
        # End of code block
        in_code_block=false
      else
        # Start of code block
        in_code_block=true
        code_block_start_line=$line_number
        # Read the next line to get the first line of the code block
        read -r first_line
        ((line_number++))
        results+=("$code_block_start_line: $first_line")
      fi
    fi
  done

  # Print the results
  for result in "${results[@]}"; do
    echo "$result"
  done
fi
