local term = amethyst.api.term
local fs = amethyst.api.fs
local kbd = amethyst.api.kbd

term.write(" --- Amethyst OS Installer ---\n\n")
local devices = fs.getDevices()
for _, dev in ipairs(devices) do
    term.write(string.format("[%s] %s (%d KB)\n",
        dev.address:sub(1,4), dev.label, dev.totalSpace / 1024))
end

term.write("\nInstall to (short addr): ")
local addr_short = kbd.readLine()
local dest = "/mnt/" .. addr_short .. "/"
term.write("Username: ")
local user = kbd.readLine()
term.write("Password: ")
local pass = kbd.readLine()

term.write("\nPreparing directories...\n")
local dirs = {
    dest .. "mnt",
    dest .. "tmp",
    dest .. "bin",
    dest .. "etc",
    dest .. "home",
    dest .. "home/" .. user,
    dest .. "sys",
    dest .. "sys/api",
    dest .. "sys/modules"
}

for _, d in ipairs(dirs) do
    fs.makeDirectory(d)
end

local function install_recursive(path)
    local items = fs.list("/unpack" .. path) or {}
    for _, item in ipairs(items) do
        local is_dir = item:sub(-1) == "/"
        local name = is_dir and item:sub(1, -2) or item

        local src_path = "/unpack" .. path .. item
        local dst_path = dest .. path .. item

        if is_dir then
            fs.makeDirectory(dst_path)
            install_recursive(path .. item)
        else
            term.write(" Copying: " .. path .. item .. "\n")
            local data = fs.readAll(src_path)
            if data then
                local ok, err = fs.writeAll(dst_path, data)
                if not ok then term.write(" ! Error: " .. tostring(err) .. "\n") end
            else
                term.write(" ! Could not read source\n")
            end
        end
    end
end

install_recursive("/")
term.write("Configuring...")
fs.writeAll(dest .. "etc/shadow", "root:\n" .. user .. ":" .. pass)
fs.writeAll(dest .. "etc/hostname", "amethyst-" .. addr_short)
fs.writeAll(dest .. "init.lua", fs.readAll("/init.lua"))
