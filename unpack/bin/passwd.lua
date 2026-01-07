local args = {...}
local fs, term, kbd = amethyst.api.fs, amethyst.api.term, amethyst.api.kbd
local user = args[1] or amethyst.env.user

if not user then term.write("Usage: passwd <user>\n") return end

term.write("Changing password for " .. user .. "\n")
term.write("New password: ")
local pass1 = kbd.readLine()
term.write("Retype password: ")
local pass2 = kbd.readLine()

if pass1 ~= pass2 then
    term.write("Passwords do not match!\n")
    return
end

local content = fs.readAll("/etc/shadow") or ""
local lines = {}
local found = false

for line in content:gmatch("[^\n]+") do
    local u, p = line:match("([^:]+):(.*)")
    if u == user then
        table.insert(lines, u .. ":" .. pass1)
        found = true
    else
        table.insert(lines, line)
    end
end

if not found then table.insert(lines, user .. ":" .. pass1) end

fs.writeAll("/etc/shadow", table.concat(lines, "\n") .. "\n")
term.write("Password updated successfully.\n")
