local raw_loadfile = ...
_G.amethyst = { modules = {}, api = {}, env = { cwd = "/" } }
amethyst.modules.component, amethyst.modules.computer = component, computer

local function sys_load(path)
    local code, err = raw_loadfile(path)
    if not code then error("amethyst: failed to load" .. path .. ": " .. tostring(err)) end
    return code()
end

amethyst.modules.gpu = sys_load("/sys/modules/gpu.lua")
amethyst.modules.gpu.init()
local term = amethyst.api.term

term.clear()
term.setColor(0x00FF00) term.write("task: "); term.setColor(0xFFFFFF); term.write("boot amethyst\n")
amethyst.api.fs = sys_load("/sys/api/fs.lua"); term.setColor(0x00FF00) term.write("task: "); term.setColor(0xFFFFFF); term.write("load filesystem\n")
amethyst.modules.kbd = sys_load("/sys/modules/kbd.lua")
amethyst.modules.kbd.init(); term.setColor(0x00FF00) term.write("task: "); term.setColor(0xFFFFFF); term.write("init keyboard\n")
amethyst.api.component = amethyst.modules.component
amethyst.api.computer = amethyst.modules.computer
local kernel = sys_load("/sys/kernel.lua"); term.setColor(0x00FF00) term.write("task: "); term.setColor(0xFFFFFF); term.write("init kernel\n"); term.setColor(0x00FF00) term.write("task: "); term.setColor(0xFFFFFF); term.write("send raw_loadfile\n")
kernel.run(raw_loadfile, term)
