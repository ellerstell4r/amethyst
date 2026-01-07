local internet = require("internet")
local component = require("component")
local fs = require("filesystem")
local shell = require("shell")
local term = require("term")
local args = shell.parse(...)
local target = args[1]

if not target then
    print("Usage: makeinstall <floppy_address>")
    print("Example: makeinstall 01a")
    return
end

local function resolveAddr(short)
    if #short >= 36 then return short end
    for addr in component.list("filesystem") do
        if addr:sub(1, #short) == short then
            return addr
        end
    end
end

local addr = resolveAddr(target)
if not addr then print("Disk not found!") return end
local proxy = component.proxy(addr)
if not proxy then print("Disk not found!") return end
local repo = "https://raw.githubusercontent.com/ellerstell4r/amethyst/refs/heads/main/"
local files = {
    "init.lua",
    "sys/boot.lua",
    "sys/kernel.lua",
    "sys/install.lua",
    "sys/api/fs.lua",
    "sys/modules/gpu.lua",
    "sys/modules/kbd.lua",
    "unpack/init.lua",
    "unpack/sys/sh.lua",
    "unpack/sys/boot.lua",
    "unpack/sys/kernel.lua",
    "unpack/sys/api/fs.lua",
    "unpack/sys/modules/gpu.lua",
    "unpack/sys/modules/kbd.lua",
    "unpack/etc/motd",
    "unpack/bin/cat.lua",
    "unpack/bin/cp.lua",
    "unpack/bin/df.lua",
    "unpack/bin/flash.lua",
    "unpack/bin/ls.lua",
    "unpack/bin/mkdir.lua",
    "unpack/bin/passwd.lua",
    "unpack/bin/poweroff.lua",
    "unpack/bin/reboot.lua",
    "unpack/bin/rm.lua",
    "unpack/bin/run.lua",
    "unpack/bin/touch.lua",
    "unpack/bin/useradd.lua",
    "unpack/bin/userdel.lua",
}

print("--- Amethyst OS Floppy Creator ---")
print("Target: " .. target)

for _, path in ipairs(files) do
    term.write("Fetching: " .. path .. "... ")
    local url = repo .. path

    local success, res = pcall(internet.request, url)
    if success and res then
        local content = ""
        for chunk in res do content = content .. chunk end

        if content:sub(1,3) == "404" then
            print("FAILED (404)")
        else
            local dir = path:match("(.+)/[^/]+$")
            if dir then proxy.makeDirectory(dir) end
            local h = proxy.open(path, "w")
            proxy.write(h, content)
            proxy.close(h)
            print("OK")
        end
    else
        print("NET ERROR")
    end
end

print("Floppy is ready! Reboot and set this disk as primary.")
