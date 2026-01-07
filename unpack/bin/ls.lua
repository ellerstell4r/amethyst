local args = {...}
local fs = amethyst.api.fs
local term = amethyst.api.term

local target = args[1] or "."
local list, err = fs.list(target)

if not list then
    term.write("ls: " .. target .. ": " .. tostring(err) .. "\n")
else
    table.sort(list)
    for i = 1, #list do
        local item = list[i]
        if item:sub(-1) == "/" then
            term.setColor(0x55FFFF)
        else
            term.setColor(0xFFFFFF)
        end
        term.write(item .. "  ")
    end
    term.setColor(0xFFFFFF)
    term.write("\n")
end
