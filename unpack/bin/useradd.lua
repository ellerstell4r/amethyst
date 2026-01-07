local args = {...}
local fs, term = amethyst.api.fs, amethyst.api.term
local name, makeHome = nil, false

for _, a in ipairs(args) do
    if a == "-m" then makeHome = true else name = a end
end

if not name then term.write("Usage: useradd [-m] <user>\n") return end

local shadow = fs.readAll("/etc/shadow") or "root:\n"
if shadow:find(name .. ":") then
    term.write("User " .. name .. " already exists\n")
    return
end

fs.writeAll("/etc/shadow", shadow .. name .. ":\n")
if makeHome then
    fs.makeDirectory("/home/" .. name)
    term.write("Created home directory: /home/" .. name .. "\n")
end
term.write("User " .. name .. " added.\n")
