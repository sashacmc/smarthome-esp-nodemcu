function offlineInit()
    tmr.alarm(4, 1000, 1, tempCheck)
end

function offlineScenario(id, v)
end

function onlineInit()
end

function onlineScenario(id, v)
end

function tempCheck()
    local d = sensors.readData()
    local ct = tonumber(d["temp"])
    if ct ~= nil then
        local rt = tonumber(registry.get("temp", "37"))
        local dt = tonumber(registry.get("dt", "0.1"))
        if ct <= rt - dt then
            heatOn()
        elseif ct >= rt + dt then
            heatOff()
        end
    end
end

function heatOn()
    pio.setLed(1)
    pio.setOut(0, 1)
end

function heatOff()
    pio.setLed(0)
    pio.setOut(0, 0)
end
