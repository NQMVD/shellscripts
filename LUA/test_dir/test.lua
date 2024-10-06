local bash = require("bash")

-- Color a string in red
local error_message = bash.color_text("This is an error message.", "red")
bash.write_stderr(error_message .. "\n")

-- Color a string in bright green
local success_message = bash.color_text("Operation successful!", "bright_green")
bash.write_stdout(success_message .. "\n")

-- Color a string with cyan foreground and bright yellow background
local highlighted_text = bash.color_text_bg("Important Note", "cyan", "bright_yellow")
print(highlighted_text)

-- Example 1: Execute a simple command
local exit_code = bash.execute("mkdir test_dir")
print("Exit Code:", exit_code)

-- Example 2: Capture output and exit code
local output, exit_code = bash.capture_output("ls -l")
print("Output:\n" .. output)
print("Exit Code:", exit_code)

-- Example 3: Pipe commands
local commands = {
    "echo 'hello world, i am a test string and i hate errors'",
    "grep error",
    "sort",
    "uniq -c"
}
local output, exit_code = bash.pipe(commands)
print("Piped Output:\n" .. output)
print("Exit Code:", exit_code)

-- Example 4: Read from stdin and write to stdout
local input_data = bash.read_stdin()
bash.write_stdout("Received input:\n" .. input_data)

-- Example 5: Write to stderr
bash.write_stderr("This is an error message.\n")

-- Example 6: if chain
bash.when('test -d ./.git')
    :success('git fetch --quiet')
    :fail('echo "No git repository found."')
