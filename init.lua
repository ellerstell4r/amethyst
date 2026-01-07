do
    local addr, invoke = computer.getBootAddress(), component.invoke
    local function loadfile(file)
        local handle, reason = invoke(addr, "open", file)
        if not handle then
            error("amethyst: could not open" .. file .. ": " .. tostring(reason))
        end

        local buffer = ""
        repeat
            local data = invoke(addr, "read", handle, 1024*32)
            buffer = buffer .. (data or "")
        until not data
        invoke(addr, "close", handle)
        return load(buffer, "=" .. file, "bt", _G)
    end
    local boot = loadfile("/sys/boot.lua")
    boot(loadfile)
end
