local args = {...}
local fs, term = amethyst.api.fs, amethyst.api.term
local recursive, force = false, false
local target = nil

for _, a in ipairs(args) do
    if a == "-rf" or a == "-fr" then recursive, force = true, true
    elseif a == "-r" then recursive = true
    elseif a == "-f" then force = true
    else target = a end
end

if not target then term.write("Usage: rm [-rf] <path>\n") return end

local function remove(p)
    p = fs.resolve(p)
    if p == "/" then term.write("what the fucking shit are u tryna to do.") end
    if fs.isDirectory(p) and recursive then
        for _, i in ipairs(fs.list(p)) do
            remove(fs.concat(p, i))
        end
    end
    fs.remove(p)
end

remove(target)
