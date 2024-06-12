You will be writing a Linux bash script based on a description provided by the user. Here is the description of what the script should do:

<script_description>
{{SCRIPT_DESCRIPTION}}
</script_description>

The script will read a {{single/multi}}-line string from stdin.

The script will take {{AMOUNT}} command line arguments.
Any variables named in the script description with an to you unknown origin will probably be passed in as command line arguments.

First, write out a high-level plan for how you will implement this bash script in a <scratchpad>. Break down the key steps and logic needed.

Then, write out the actual bash script inside <bash_script> tags.
Wrap the code in three backticks markdown style.
When generating the code make sure to:
- Take command line arguments as described
- Read from stdin as described
- Handle errors and edge cases
- Provide useful output

Aim to write a correct, robust and clear bash script that fully implements the functionality described by the user.

After you write the script, show an example of how it would be executed.
