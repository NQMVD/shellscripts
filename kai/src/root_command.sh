
# header with info
gum style \
  --border normal --margin "1" --padding "1 2" --border-foreground 4 \
  "bash script AI prompt generator $(gum style --foreground 99 'KAI')."

# script description (write)
DESC=$(gum write --header "Description:")
is empty "$DESC" && gum log -l error "Description cannot be empty!" && exit 1

# read stdin? single multi
READSTDIN=$(gum choose --header "Read from $(gum style --foreground 99 'stdin')" "no" "single-line" "multi-line")
is empty "$READSTDIN" && gum log -l error "Need to know..." && exit 1

# take args? list them with write
TAKEARGS=$(gum confirm "Take args?" && echo "Yes" || echo "No")
if [[ "$TAKEARGS" == "Yes" ]]; then
  ARGSLIST=$(gum write --header "List of args (Ctrl+d to send)")
  is empty "$ARGSLIST" && gum log -l error "Args list cannot be empty!" && exit 1
fi

# generate
PROMPT="You will be writing a Linux bash script based on a description provided by the user. 
Here is the description of what the script should do:

<script_description>
${DESC}
</script_description>

"

case "$READSTDIN" in
  "no")
    PROMPT="${PROMPT}The script will ignore the stdin."
    ;;
  "single-line")
    PROMPT="${PROMPT}The script will read a single line string from stdin."
    ;;
  "multi-line")
    PROMPT="${PROMPT}The script will read a multi line string from stdin."
    ;;
esac

PROMPT="${PROMPT}

"

if [[ "$TAKEARGS" == "No" ]]; then
  PROMPT="${PROMPT}The script will ingore any command line arguments."
else 
    PROMPT="${PROMPT}The script will take these command line arguments:
    ${ARGSLIST}"
fi

PROMPT="${PROMPT}

First, write out a high-level plan for how you will implement this bash script in a <scratchpad>. Break down the key steps and logic needed.

Then, write out the actual bash script inside <bash_script> tags.
Wrap the code in three backticks markdown style.
When generating the code make sure to:
- Take command line arguments as described
- Read from stdin as described
- Handle errors and edge cases
- Provide useful output

Aim to write a correct, robust and clear bash script that fully implements the functionality described by the user.

After you write the script, show an example of how it would be executed."


# copy or run with ollama?
if gum confirm --affirmative "Copy" --negative "Run (ollama)" "$(gum style --foreground 99 'Done!') Next?"; then
  echo "$PROMPT" | wl-copy
else
  MODEL='codellama'
  RESPONSE=$(gum spin --title="Generating..." -- ollama run "$MODEL" "$PROMPT")
  echo "# DATE: $(date)
---
# MODEL: ${MODEL}
---
# PROMPT::
${PROMPT}
---
# RESPONSE::
${RESPONSE}
" > "${HOME}/ai/${MODEL}/question_$(date +%c | tr ' ' '_').md"

  # show with glow
  echo "$RESPONSE" | glow
  # ask if okay or regen
  if gum confirm 'Accept Response?'; then
    FILENAME=$(gum input --header "filename to save to (in $(pwd))")
    if is not empty "${FILENAME}"; then
      echo "$RESPONSE" > "$FILENAME"
      echo "Saved!"
    else 
    fi
  else
    echo 'WIP!'
  fi
  # if okay ask for file name to dump to
fi
