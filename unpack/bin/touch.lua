local args = {...}
local fs, term = amethyst.api.fs, amethyst.api.term

if not args[1] then
    term.write("Usage: touch <file>\n")
    return
end

local path = fs.resolve(args[1])
local ok, err = fs.writeAll(path, "")
if not ok then term.write("touch: " .. tostring(err) .. "\n") end
