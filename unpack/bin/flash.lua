local args = {...}
local fs, term = amethyst.api.fs, amethyst.api.term
local component = amethyst.modules.component

if not args[1] then
    term.write("Usage: flash <file.lua> [label]\n")
    return
end

local eeprom = component.getPrimary("eeprom")
if not eeprom then
    term.write("flash: EEPROM component not found!\n")
    return
end

local path = fs.resolve(args[1])
local code = fs.readAll(path)

if code then
    term.write("Flashing " .. args[1] .. " to EEPROM... ")
    eeprom.set(code)
    if args[2] then eeprom.setLabel(args[2]) end
    term.setColor(0x00FF00)
    term.write("DONE\n")
    term.setColor(0xFFFFFF)
else
    term.write("flash: could not read file\n")
end
