local args = {...}
local fs, term = amethyst.api.fs, amethyst.api.term
local name = args[1]

if not name or name == "root" then
    term.write("Usage: userdel <user> (cannot delete root)\n")
    return
end

local shadow = fs.readAll("/etc/shadow") or ""
local new_shadow = ""
local found = false

for line in shadow:gmatch("[^\n]+") do
    if not line:find("^" .. name .. ":") then
        new_shadow = new_shadow .. line .. "\n"
    else
        found = true
    end
end

if found then
    fs.writeAll("/etc/shadow", new_shadow)
    term.write("User " .. name .. " deleted.\n")
else
    term.write("User not found.\n")
end
