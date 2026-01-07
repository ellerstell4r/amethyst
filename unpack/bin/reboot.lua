local term = amethyst.api.term
local machine = amethyst.modules.computer

term.write("Rebooting...\n")

if machine and machine.shutdown then
    local d = computer.uptime() + 1
    repeat until computer.uptime() >= d
    machine.shutdown(true)
else
    term.write("err: computer.shutdown not found\n")
end
