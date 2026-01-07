local kbd = {}

function kbd.init()
    amethyst.api.kbd = {
        readLine = function(history)
            history = history or {}
            local input = ""
            local term = amethyst.api.term
            local h_idx = #history + 1
            local temp_input = ""

            while true do
                local sig, _, char, code = computer.pullSignal()
                if sig == "key_down" then
                    if code == 28 then
                        term.write("\n")
                        return input

                    elseif code == 14 then
                        if #input > 0 then
                            input = input:sub(1, -2)
                            term.write("\b \b")
                        end

                    elseif code == 200 then
                        if h_idx > 1 then
                            if h_idx == #history + 1 then temp_input = input end
                            for i = 1, #input do term.write("\b \b") end
                            h_idx = h_idx - 1
                            input = history[h_idx]
                            term.write(input)
                        end

                    elseif code == 208 then
                        if h_idx < #history + 1 then
                            for i = 1, #input do term.write("\b \b") end
                            h_idx = h_idx + 1
                            if h_idx == #history + 1 then
                                input = temp_input
                            else
                                input = history[h_idx]
                            end
                            term.write(input)
                        end

                    elseif char >= 32 and char <= 126 then
                        local s = string.char(char)
                        input = input .. s
                        term.write(s)
                    end
                end
            end
        end
    }
end

return kbd
