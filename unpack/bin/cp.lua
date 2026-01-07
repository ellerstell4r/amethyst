local args = {...}
local fs, term = amethyst.api.fs, amethyst.api.term
local recursive, verbose = false, false
local paths = {}

for _, a in ipairs(args) do
    if a == "-rv" or a == "-vr" then recursive, verbose = true, true
    elseif a == "-r" then recursive = true
    elseif a == "-v" then verbose = true
    else table.insert(paths, a) end
end

if #paths < 2 then term.write("Usage: cp [-rv] <src> <dest>\n") return end

local function copy_task(src, dest)
    src = fs.resolve(src)
    dest = fs.resolve(dest)

    if fs.isDirectory(src) then
        if not recursive then return end
        fs.makeDirectory(dest)
        for _, item in ipairs(fs.list(src)) do
            copy_task(fs.concat(src, item), fs.concat(dest, item))
        end
    else
        if verbose then term.write(src .. " -> " .. dest .. "\n") end
        local content = fs.readAll(src)
        local ok, err = fs.writeAll(dest, content)
        if not ok and verbose then term.write("err: " .. tostring(err) .. "\n") end
    end
end

local s_raw = paths[1]
if s_raw:sub(-1) == "*" then
    local dir = fs.resolve(s_raw:sub(1, -2))
    for _, item in ipairs(fs.list(dir)) do
        copy_task(fs.concat(dir, item), fs.concat(paths[2], item))
    end
else
    copy_task(paths[1], paths[2])
end
