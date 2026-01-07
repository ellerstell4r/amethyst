local kernel = {}

function kernel.run(raw_loadfile, term)
    amethyst.api.sys = {
        execute = function(path, ...)
            local code, err = raw_loadfile(path)
            if not code then return false, err end
            local result = { pcall(code, ...) }
            if not result[1] then
                return false, result[2]
            end
            return true
        end
    }

    term.setColor(0x00FF00) term.write("task: "); term.setColor(0xFFFFFF); term.write("init shell\n")
    amethyst.api.sys.execute("/sys/sh.lua")
end

return kernel
