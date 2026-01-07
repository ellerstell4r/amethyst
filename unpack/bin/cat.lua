local fs = amethyst.api.fs
local term = amethyst.api.term
local args = {...}

if not args[1] then
    term.write("Usage: cat <file>\n")
    return
end

local content, err = fs.readAll(args[1])
if not content then
    term.write("cat: " .. tostring(err) .. "\n")
else
    term.write(content .. "\n")
end
