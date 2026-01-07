local term = amethyst.api.term
local fs = amethyst.api.fs

local devices = fs.getDevices()

term.write("Disks:\n")

for _, dev in ipairs(devices) do
    local short = dev.address:sub(1, 4)
    term.setColor(0x55FFFF)
    term.write("[" .. short .. "] ")

    term.setColor(0xFFFFFF)
    term.write(dev.label)

    local kb = math.floor(dev.totalSpace / 1024)
    term.setColor(0xAAAAAA)
    term.write(" - " .. kb .. " KB")

    if dev.isReadOnly then
        term.setColor(0xFF5555)
        term.write(" [RO]")
    end

    term.write("\n")
end

term.setColor(0xFFFFFF)
term.write("Use cd /mnt/<addr> to mount any one\n")
