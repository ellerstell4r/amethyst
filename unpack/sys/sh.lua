local term, fs = amethyst.api.term, amethyst.api.fs
local kbd, sys = amethyst.api.kbd, amethyst.api.sys
local function login()
    while true do
        term.write("\nLogin: ")
        local user = kbd.readLine()
        term.write("Password: ")
        local pass = kbd.readLine()

        local shadow = fs.readAll("/etc/shadow") or "root:"
        for line in shadow:gmatch("[^\n]+") do
            local u, p = line:match("([^:]+):(.*)")
            if u == user and p == pass then
                amethyst.env.user = u
                amethyst.env.cwd = "/home/" .. u
                if not fs.exists(amethyst.env.cwd) then fs.makeDirectory(amethyst.env.cwd) end
                return u, (p == "" or p == nil)
            end
        end
        term.write("Login incorrect\n")
    end
end

local currentUser, noPass = login()
local hostname = "amethyst"
if fs.exists("/etc/hostname") then hostname = fs.readAll("/etc/hostname"):gsub("%s+", "") end
if fs.exists("/etc/motd") then term.write("\n" .. fs.readAll("/etc/motd")) end
local forcePasswd = (currentUser == "root" and noPass)

local history = {}
local history_path = "/home/" .. currentUser .. "/.history"
if fs.exists(history_path) then
    for line in fs.readAll(history_path):gmatch("[^\n]+") do table.insert(history, line) end
end

while true do
    if forcePasswd then
        term.write("\n*** WARNING: root has no password! ***\n")
        term.write("Run 'passwd' immediately to secure the system.\n")
        forcePasswd = false
    end
    term.setColor(0x00FF00); term.write(currentUser .. "@" .. hostname)
    term.setColor(0xFFFFFF); term.write(":"); term.setColor(0x55FFFF)
    term.write(amethyst.env.cwd); term.setColor(0xFFFFFF); term.write("# ")

    local input = kbd.readLine(history)
    if input and input ~= "" then
        table.insert(history, input)
        fs.writeAll(history_path, table.concat(history, "\n") .. "\n")

        local tokens = {}
        for w in input:gmatch("%S+") do table.insert(tokens, w) end
        local cmd = table.remove(tokens, 1)

        if cmd == "cd" then
            local target = fs.resolve(tokens[1] or "/")
            if fs.isDirectory(target) then amethyst.env.cwd = target
            else term.write("cd: no such directory\n") end
        elseif cmd == "exit" then
            currentUser, noPass = login()
            history = {}
        elseif cmd == "clear" then
            term.clear()
        else
            local path = "/bin/" .. cmd .. ".lua"
            if fs.exists(path) then
                local ok, err = sys.execute(path, table.unpack(tokens))
                if not ok then term.write("err: " .. tostring(err) .. "\n") end
            else
                term.write("sh: " .. cmd .. " not found\n")
            end
        end
    end
end
