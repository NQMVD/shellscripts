local bash = require("bash")

local answer, exit_code, aborded = bash.gum_confirm("Do you want to proceed?", "Yeah", "Nah")
print("Answer:", answer)
print("Exit Code:", exit_code)
print("Aborded:", aborded)

local output, exit_code, aborded = bash.gum_input("Enter your name", "Max Mustermann")
print("Output:", output)
print("Exit Code:", exit_code)
print("Aborded:", aborded)

local output, exit_code, aborded = bash.gum_write("Write a short note", "Dear Diary, ...")
print("Output:", output)
print("Exit Code:", exit_code)
print("Aborded:", aborded)

local items = { "Apple", "Banana", "Cherry", "Date", "Elderberry" }
local choice, exit_code, aborded = bash.gum_choose(items, "Select a fruit:")
print("Choice:", choice)
print("Exit Code:", exit_code)
print("Aborded:", aborded)

local choices, exit_code, aborded = bash.gum_multichoose(items, "Select fruits:")
print("Choices:")
for _, choice in ipairs(choices) do
    print(choice)
end
print("Exit Code:", exit_code)
print("Aborded:", aborded)


local answer, exit_code, aborded = bash.gum_confirm()
print("Answer:", answer)
print("Exit Code:", exit_code)
print("Aborded:", aborded)

local output, exit_code, aborded = bash.gum_input()
print("Output:", output)
print("Exit Code:", exit_code)
print("Aborded:", aborded)

local output, exit_code, aborded = bash.gum_write()
print("Output:", output)
print("Exit Code:", exit_code)
print("Aborded:", aborded)

local items = { "Apple", "Banana", "Cherry", "Date", "Elderberry" }
local choice, exit_code, aborded = bash.gum_choose(items)
print("Choice:", choice)
print("Exit Code:", exit_code)
print("Aborded:", aborded)

local choices, exit_code, aborded = bash.gum_multichoose(items)
print("Choices:")
for _, choice in ipairs(choices) do
    print(choice)
end
print("Exit Code:", exit_code)
print("Aborded:", aborded)
