-- bash.lua

local bash = {}

-- bash.needs = has
-- bash.hr = hr (in gray color tho)
-- bash.file
-- bash.exists
-- bash.is_file
-- bash.is_dir
-- bash.is_dir_empty
-- bash.fork
-- bash.edit
-- bash.kill_process
-- bash.basename
-- bash.dirname
-- bash.pwd
-- bash.zoxide
-- bash.cd
-- bash.mkdir
-- bash.rm
-- bash.touch
-- bash.cp
-- bash.mv
-- bash.ln
-- bash.ls

-- Executes a command and returns its exit code.
function bash.execute(command)
    local ok, exit_type, exit_code = os.execute(command)
    if type(ok) == "number" then
        -- Lua 5.1: os.execute returns the exit code directly
        return ok
    elseif type(ok) == "boolean" then
        -- Lua 5.2 and above: os.execute returns a boolean, exit_type, and exit_code
        if ok then
            return 0
        else
            return exit_code or 1
        end
    else
        error("Unknown os.execute return type")
    end
end

bash.run = bash.execute

-- Executes a command, captures its output (stdout and stderr), and returns the output and exit code.
function bash.capture_output(command)
    local handle = io.popen(command .. "; echo ExitCode: $?")
    -- need check nil
    if handle == nil then
        return "", 1
    end
    local output = handle:read("*a")
    handle:close()

    local exit_code = output:match("ExitCode: (%d+)%s*$")
    if exit_code then
        exit_code = tonumber(exit_code)
        output = output:gsub("ExitCode: %d+%s*$", "")
    else
        exit_code = nil
    end

    return output, exit_code
end

-- Add the conditional chaining feature with success, fail, and aborted
function bash.when(command)
    local exit_code = bash.execute(command)
    local chain = {
        exit_code = exit_code,
        condition_met = (exit_code == 0),
        executed = false
    }

    function chain:success(success_command)
        if self.condition_met and not self.executed then
            bash.execute(success_command)
            self.executed = true
        end
        return self
    end

    function chain:fail(fail_command)
        if not self.condition_met and not self.executed then
            bash.execute(fail_command)
            self.executed = true
        end
        return self
    end

    function chain:aborted(abort_command, abort_exit_code)
        abort_exit_code = abort_exit_code or 130
        if self.exit_code == abort_exit_code and not self.executed then
            bash.execute(abort_command)
            self.executed = true
        end
        return self
    end

    return chain
end

-- Executes a series of commands piped together and returns the output and exit code.
function bash.pipe(commands)
    -- 'commands' is a table of command strings
    local pipeline = table.concat(commands, " | ")
    return bash.capture_output(pipeline)
end

-- Reads all input from stdin.
function bash.read_stdin()
    return io.stdin:read("*a")
end

-- Writes a string to stdout.
function bash.write_stdout(text)
    io.stdout:write(text)
end

-- Writes a string to stderr.
function bash.write_stderr(text)
    io.stderr:write(text)
end

-- Writes a string to a file.
-- If the file does not exist, it will be created.
function bash.write_file(file_path, text)
    local file = io.open(file_path, "w")
    if file then
        file:write(text)
        file:close()
        return true
    else
        return false
    end
end

-- Reads the contents of a file.
-- Returns the file contents as a string, or nil if the file does not exist.
-- Returns an optional second value indicating success (true) or failure (false).
function bash.read_file(file_path)
    local file = io.open(file_path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return content, true
    else
        return nil, false
    end
end

-- Appends a string to a file.
-- If the file does not exist, it will be created.
function bash.append_file(file_path, text)
    local file = io.open(file_path, "a")
    if file then
        file:write(text)
        file:close()
        return true
    else
        return false
    end
end

-- gum wrapper functions
-- always check the exit code if its 130, it means the user cancelled the operation
-- gum confirm, optional prompt, optional titles for yes and no
-- returns true or false, exit code, aborted
function bash.gum_confirm(prompt, yes_title, no_title)
    if prompt == nil then
        prompt = "Confirm?"
    end
    if yes_title == nil then
        yes_title = "Yes"
    end
    if no_title == nil then
        no_title = "No"
    end
    local exit_code = bash.execute("gum confirm '" .. prompt ..
        "' --affirmative='" .. yes_title .. "' --negative='" .. no_title .. "'")
    if exit_code == 130 then
        return false, exit_code, true
    else
        return exit_code == 0, exit_code, false
    end
end

-- gum input, header, optional placeholder
-- returns the output, exit code, aborted
function bash.gum_input(header, placeholder)
    if header == nil then
        header = "Enter:"
    end
    if placeholder == nil then
        placeholder = "..."
    end
    local output, exit_code =
        bash.capture_output("gum input --header='" .. header .. "' --placeholder='" .. placeholder .. "'")
    if exit_code == 130 then
        return "", exit_code, true
    else
        return output:sub(1, -2), exit_code, false
    end
end

-- gum write, header, optional placeholder
-- returns the output, exit code, aborted
function bash.gum_write(header, placeholder)
    if header == nil then
        header = "Write:"
    end
    if placeholder == nil then
        placeholder = "..."
    end
    local output, exit_code = bash.capture_output("gum write --char-limit=500 --header='" ..
        header .. "' --placeholder='" .. placeholder .. "'")
    if exit_code == 130 then
        return "", exit_code, true
    else
        return output:sub(1, -2), exit_code, false
    end
end

-- gum choose, list of items, optional header
-- returns the choice, exit code, aborted
function bash.gum_choose(items, header)
    if items == nil then
        error("No items provided!")
    end
    if header == nil then
        header = "Choose:"
    end
    local items_str = table.concat(items, "\n")
    local output, exit_code = bash.capture_output("echo '" .. items_str .. "' | gum choose --header='" .. header .. "'")
    if exit_code == 130 then
        return "", exit_code, true
    else
        return output, exit_code, false
    end
end

-- gum multichoose, list of items, optional header
-- returns a table of choices, exit code, aborted
function bash.gum_multichoose(items, header)
    if items == nil then
        error("No items provided!")
    end
    if header == nil then
        header = "Choose:"
    end
    local items_str = table.concat(items, "\n")
    local output, exit_code = bash.capture_output("echo '" ..
        items_str .. "' | gum choose --no-limit --header='" .. header .. "'")
    if exit_code == 130 then
        return {}, exit_code, true
    end
    local choices = {}
    for choice in output:gmatch("[^\n]+") do
        table.insert(choices, choice)
    end
    return choices, exit_code, false
end

-- ANSI color codes
bash.colors = {
    reset = '\27[0m',
    black = '\27[0;30m',
    red = '\27[0;31m',
    green = '\27[0;32m',
    yellow = '\27[0;33m',
    blue = '\27[0;34m',
    purple = '\27[0;35m',
    cyan = '\27[0;36m',
    white = '\27[0;37m',
    -- Bright colors
    bright_black = '\27[1;30m',
    bright_red = '\27[1;31m',
    bright_green = '\27[1;32m',
    bright_yellow = '\27[1;33m',
    bright_blue = '\27[1;34m',
    bright_purple = '\27[1;35m',
    bright_cyan = '\27[1;36m',
    bright_white = '\27[1;37m',
}

-- Function to colorize a string
function bash.color_text(text, color_code)
    local color = bash.colors[color_code] or bash.colors.reset
    return color .. text .. bash.colors.reset
end

-- Function to colorize a string with background color
function bash.color_text_bg(text, color_code, bg_color_code)
    local color = bash.colors[color_code] or bash.colors.reset
    local bg_color = bash.colors[bg_color_code] or ''
    return color .. bg_color .. text .. bash.colors.reset
end

return bash
