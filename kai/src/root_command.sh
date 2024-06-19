
# header with info
gum style \
  --border normal --margin "1" --padding "1 2" --border-foreground 4 \
  "bash script AI prompt generator $(gum style --foreground 99 'KAI')."

# script description (write)
DESC=$(gum write --header "Description:")
is empty "$DESC" && gum log -l error "Description cannot be empty!" && exit 1

# read stdin? single multi
READSTDIN=$(gum confirm "Read from $(gum style --foreground 99 'stdin')?" && echo "Yes" || echo "No")
is empty "$READSTDIN" && gum log -l error "Need to know..." && exit 1

# take args? list them with write
TAKEARGS=$(gum confirm "Take $(gum style --foreground 99 'args')?" && echo "Yes" || echo "No")
is empty "$TAKEARGS" && gum log -l error "Need to know..." && exit 1
if [[ "$TAKEARGS" == "Yes" ]]; then
  ARGSLIST=$(chewwrite "List of args (Ctrl+d to send)")
  is empty "$ARGSLIST" && gum log -l error "Args list cannot be empty!" && exit 1
fi

# use gum?
USEGUM=$(gum confirm "Use $(gum style --foreground 99 'Gum') for prompts?" && echo "Yes" || echo "No")
is empty "$USEGUM" && gum log -l error "Need to know..." && exit 1

# generate
PROMPT="You will be writing a Linux bash script based on a description provided by the user. 
Here is the description of what the script should do:

<script_description>
${DESC}
</script_description>

"

if [[ "$READSTDIN" == "Yes" ]]; then
  PROMPT="${PROMPT}The script will recieve piped input via the stdin.
  "
fi

if [[ "$TAKEARGS" == "Yes" ]]; then
  PROMPT="${PROMPT}The script will take these command line arguments:
  ${ARGSLIST}
  "
fi

if [[ "$USEGUM" == "Yes" ]]; then
  GUMINFO='
  When prompting the user for any input, use this "chewinput" command instead of the read command, DO NOT USE THE DEFAULT READ COMMAND:
  INPUT=$(chewinput "MESSAGE")

  When asking the user to choose an option from a list, use this "gum choose" command and provide it with all the options as arguments like so
  CHOICE=$(gum choose "option1" "option2" "option3")

  When asking for multiple choice, append the --no-limit flag like so:
  MULTICHOICE=$(gum choose --no-limit "option1" "option2" "option3")

  When asking for a confirmation, use the "gum confirm" command and also provide it with a header like so:
  IMPORTANT! the gum confirm command returns 0 if the user chose YES and 1 if the user chose NO!
  if gum confirm "HEADER"; then
    # user chose YES
  else
    # user chose NO
  fi

  IMPORTANT! if theres no need for a prompt, a choice or a confirm, DO NOT USE ANY! DO NOT BOTHER THE USER!
  '

  PROMPT="${PROMPT}
  ${GUMINFO}
  "
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

CHOICE='none'
while true; do
  CHOICE=$(gum choose --header "$(gum style --foreground 99 'Done!') Next?" "View" "Copy" "Run" "Quit")

  if [[ "$CHOICE" == "View" ]]; then
    echo "$PROMPT" | gum pager --show-line-numbers='no'
  else
    break
  fi
done

if [[ "$CHOICE" == "Copy" ]]; then
  echo "$PROMPT" | wl-copy
  echo 'Copied!'
elif [[ "$CHOICE" == "Run" ]]; then
  MODEL='codellama'

  while true; do
    # RESPONSE=$(gum spin --title="Generating..." -- ollama run "$MODEL" "$PROMPT")

    MODELS=$(aichat --list-models)
    SHORTMODEL=$(gum choose 'codellama' 'llama3' 'opus')
    FULLMODEL=$(echo "$MODELS" | rg "$SHORTMODEL")
    # echo "Fullmodel: ${FULLMODEL}" >> fullmodel.log
    RESPONSE=$(gum spin --title="Generating..." -- aichat --model "$FULLMODEL" "$PROMPT")
    # RESPONSE=$(aichat --model "$FULLMODEL" "$PROMPT")

    echo "# DATE: $(date)
  ---
  # MODEL: ${MODEL}
  ---
  # PROMPT::
  ${PROMPT}
  ---
  # RESPONSE::
  ${RESPONSE}
  " > "${HOME}/ai/${SHORTMODEL}/question_$(date +%c | tr ' ' '_').md"

    echo "$RESPONSE" | glow

    if gum confirm 'Accept Response?'; then
      break
    else
      clear
    fi

  done

  CODEBLOCKNUM=$(echo "$RESPONSE" | getcodeblocks | gum choose --header='Choose a Codeblock:'| awk -F: '{print $1}') # | cut out the first number
  CODEBLOCK=$(echo "$RESPONSE" | getcodeblocks -n "$CODEBLOCKNUM")

  FILENAME=$(gum input --header "filename to save to (in $(pwd))")
  is empty "$FILENAME" && echo 'Aborted...' && exit 1
  
  echo "$CODEBLOCK" > "$FILENAME"
  echo "Saved!"
fi
