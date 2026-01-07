local args = {...}
local fs, term = amethyst.api.fs, amethyst.api.term

if not args[1] then term.write("Usage: run <file>\n") return end

local name = args[1]
local path = name:match("%.lua$") and name or name .. ".lua"
path = fs.resolve(path)

if fs.exists(path) then
    term.setColor(0x00FF00)
    term.write("task: "); term.setColor(0xFFFFFF); term.write("executing " .. name .. "\n")

    local ok, err = amethyst.api.sys.execute(path, table.unpack(args, 2))
    if not ok then term.write("runtime err: " .. tostring(err) .. "\n") end
else
    term.write("run: " .. name .. " not found\n")
end
