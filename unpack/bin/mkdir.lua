local args = {...}
if not args[1] then amethyst.api.term.write("Usage: mkdir <path>\n") return end
local ok, err = amethyst.api.fs.makeDirectory(args[1])
if not ok then amethyst.api.term.write("mkdir: " .. tostring(err) .. "\n") end
