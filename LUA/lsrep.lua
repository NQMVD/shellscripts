#!/usr/bin/env luajit

-- Include the bash.lua library
local bash = require("bash")

-- ANSI color codes
local RED = '\27[0;31m'
local GREEN = '\27[0;32m'
local YELLOW = '\27[0;33m'
local BLUE = '\27[0;34m'
local PURPLE = '\27[0;35m'
local CYAN = '\27[0;36m'
local NC = '\27[0m' -- No Color

-- Initialize counters
local total_repos = 0
local owned_repos = 0

-- Get your GitHub username using gh CLI
local output, exit_code = bash.capture_output("gh api user --jq '.login'")
local github_username = output:match("^%s*(.-)%s*$") -- Trim whitespace

-- Function to get remote platform
local function get_remote_platform(dir)
    local cmd = "cd '" .. dir .. "' && git config --get remote.origin.url"
    local remote_url, _ = bash.capture_output(cmd)
    remote_url = remote_url:match("^%s*(.-)%s*$") -- Trim whitespace

    if remote_url:find("github.com") then
        return ""
    elseif remote_url:find("gitlab.com") then
        return ""
    elseif remote_url:find("bitbucket.org") then
        return ""
    else
        return " ?"
    end
end

-- Function to get git status
local function get_git_status(dir)
    -- Fetch updates
    bash.execute("cd '" .. dir .. "' && git fetch --quiet")
    -- Get status
    local status_output, _ = bash.capture_output("cd '" .. dir .. "' && git status --porcelain")
    if status_output == "" then
        return "Clean"
    else
        return "Dirty"
    end
end

-- Function to check if repo is owned by user
local function is_owned_by_me(dir, github_username)
    local cmd = "cd '" .. dir .. "' && git config --get remote.origin.url"
    local remote_url, _ = bash.capture_output(cmd)
    remote_url = remote_url:match("^%s*(.-)%s*$") -- Trim whitespace

    if remote_url:find("github.com[/:]" .. github_username .. "[/:]") then
        return true  -- Yes, owned by me
    else
        return false  -- Not owned by me
    end
end

print(BLUE .. "──────────────────────" .. NC)

-- Get list of directories
local dirs_output, _ = bash.capture_output("ls -d */ 2>/dev/null")
local dirs = {}
for dir in dirs_output:gmatch("[^\n]+") do
    table.insert(dirs, dir)
end

-- Iterate through directories
for _, dir in ipairs(dirs) do
    dir = dir:gsub("/$", "") -- Remove trailing slash

    -- Check if directory is accessible
    local output, exit_code = bash.capture_output("cd '" .. dir .. "' && echo OK")
    if exit_code == 0 then
        -- Check if it's a git repository
        local git_dir_exists = bash.execute("test -d '" .. dir .. "/.git'")
        if git_dir_exists == 0 then
            total_repos = total_repos + 1

            -- Get repository information
            local repo_name = dir
            local branch_output, _ = bash.capture_output("cd '" .. dir .. "' && git rev-parse --abbrev-ref HEAD")
            local branch = branch_output:match("^%s*(.-)%s*$") -- Trim whitespace

            local remote_platform = get_remote_platform(dir)
            local status = get_git_status(dir)

            -- Check ownership
            local ownership_symbol = ""
            if is_owned_by_me(dir, github_username) then
                owned_repos = owned_repos + 1
                ownership_symbol = YELLOW .. "★" .. NC .. " "
            else
                ownership_symbol = "  "
            end

            -- Construct colored output
            local output_line = string.format(
                "%s%s%s %s%s %s[%s] ",
                ownership_symbol,
                CYAN, repo_name,
                PURPLE, remote_platform,
                BLUE, branch
            )

            if status == "Clean" then
                output_line = output_line .. GREEN .. "✓" .. NC
            else
                output_line = output_line .. RED .. "✗" .. NC
            end

            print(output_line)
        end
    end
end

-- Print repository counts or "No repos found" message
if total_repos == 0 then
    print(RED .. "No repositories found" .. NC)
else
    print(BLUE .. "──────────────────────" .. NC)
    print(CYAN .. "Total Repositories: " .. total_repos .. NC)
    print(BLUE .. "Owned by me: " .. owned_repos .. NC)
end
