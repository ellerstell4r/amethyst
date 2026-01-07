local fs_api = {}
local comp = amethyst.modules.component
local bootAddr = amethyst.modules.computer.getBootAddress()
local mounts = { ["/"] = comp.proxy(bootAddr) }

local function findFullAddr(short)
    if #short >= 36 then return short end
    for addr in comp.list("filesystem") do
        if addr:sub(1, #short) == short then
            return addr
        end
    end
    return nil
end

local function getProxy(path)
    local full = fs_api.resolve(path)
    if full == "/tmp" or full:sub(1, 5) == "/tmp/" then
        if not mounts["tmp"] then
            for addr in comp.list("filesystem") do
                local p = comp.proxy(addr)
                if p.getLabel() == "tmpfs" then mounts["tmp"] = p break end
            end
        end
        if mounts["tmp"] then
            local sub = full:sub(5)
            return mounts["tmp"], (sub == "" and "/" or sub)
        end
    end

    if full:sub(1, 5) == "/mnt/" then
        local part = full:match("/mnt/([^/]+)")
        if part then
            local addr = findFullAddr(part)
            if addr then
                if not mounts[addr] then
                    local s, p = pcall(comp.proxy, addr)
                    if s and p then mounts[addr] = p else return nil, "no dev" end
                end
                local sub = full:sub(6 + #part)
                return mounts[addr], (sub == "" and "/" or sub)
            end
        end
    end
    return mounts["/"], full
end

fs_api.resolve = function(path)
    if not path or path == "" or path == "." then return amethyst.env.cwd end

    local absolute = ""
    if path:sub(1,1) == "/" then
        absolute = path
    else
        local cwd = amethyst.env.cwd
        if cwd:sub(-1) ~= "/" then cwd = cwd .. "/" end
        absolute = cwd .. path
    end

    local parts = {}
    for part in absolute:gmatch("[^/]+") do
        if part == ".." then
            table.remove(parts)
        elseif part ~= "." then
            table.insert(parts, part)
        end
    end

    local res = "/" .. table.concat(parts, "/")
    return res:gsub("//+", "/")
end

fs_api.list = function(p)
    local full = fs_api.resolve(p)
    local list = {}
    if full == "/" then
        table.insert(list, "mnt/")
        table.insert(list, "tmp/")
    end

    if full == "/mnt" or full == "/mnt/" then
        for addr in comp.list("filesystem") do
            table.insert(list, addr:sub(1, 4) .. "/")
        end
    end

    local pr, c = getProxy(p)
    if pr then
        local disk_list = pr.list(c)
        if disk_list then
            for _, v in ipairs(disk_list) do table.insert(list, v) end
        end
    end

    local hash = {}
    local res = {}
    for _, v in ipairs(list) do
        if not hash[v] then
            res[#res+1] = v
            hash[v] = true
        end
    end

    return res
end

fs_api.isDirectory = function(p)
    local pr, c = getProxy(p)
    return pr and pr.isDirectory(c)
end

fs_api.exists = function(p)
    local pr, c = getProxy(p)
    return pr and pr.exists(c)
end

fs_api.writeAll = function(p, d)
    local pr, c = getProxy(p)
    local h = pr.open(c, "w")
    if h then pr.write(h, d or ""); pr.close(h); return true end
end

fs_api.readAll = function(p)
    local pr, c = getProxy(p)
    local h = pr.open(c, "r")
    if not h then return nil end
    local buf = ""
    repeat local chunk = pr.read(h, 8192); buf = buf .. (chunk or "") until not chunk
    pr.close(h)
    return buf
end

fs_api.getDevices = function()
    local devices = {}
    for addr in comp.list("filesystem") do
        local proxy = comp.proxy(addr)
        table.insert(devices, {
            address = addr,
            label = proxy.getLabel() or "no label",
            isReadOnly = proxy.isReadOnly(),
            totalSpace = proxy.spaceTotal()
        })
    end
    return devices
end

fs_api.concat = function(path, name)
    if path:sub(-1) ~= "/" then path = path .. "/" end
    return (path .. name):gsub("//+", "/")
end

fs_api.makeDirectory = function(p)
    local pr, c = getProxy(p)
    return pr.makeDirectory(c)
end

fs_api.remove = function(p)
    local pr, c = getProxy(p)
    if pr then return pr.remove(c) end
end

return fs_api
