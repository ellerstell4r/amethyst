local gpu = {}

function gpu.init()
    local gp = component.proxy(component.list("gpu")() or "")
    local screen = component.list("screen")()

    if gp and screen then
        gp.bind(screen)
        gp.setResolution(gp.maxResolution())
        gp.setBackground(0x000000)
        gp.setForeground(0xFFFFFF)
        local w, h = gp.getResolution()
        gp.fill(1, 1, w, h, " ")
    end

    local cursor_x, cursor_y = 1, 1
    local w, h = gp.getResolution()

    amethyst.api.term = {
        clear = function()
            gp.fill(1, 1, w, h, " ")
            cursor_x, cursor_y = 1, 1
        end,
        setColor = function(color) gp.setForeground(color or 0xFFFFFF) end,
        write = function(text)
            text = tostring(text)
            for char in text:gmatch(".") do
                if char == "\n" then
                    cursor_x = 1
                    cursor_y = cursor_y + 1
                elseif char == "\b" then
                    cursor_x = math.max(1, cursor_x - 1)
                    gp.set(cursor_x, cursor_y, " ")
                else
                    gp.set(cursor_x, cursor_y, char)
                    cursor_x = cursor_x + 1
                end
                if cursor_x > w then cursor_x = 1; cursor_y = cursor_y + 1 end
                if cursor_y > h then
                    gp.copy(1, 2, w, h - 1, 0, -1)
                    gp.fill(1, h, w, 1, " ")
                    cursor_y = h
                end
            end
        end
    }
end
return gpu
