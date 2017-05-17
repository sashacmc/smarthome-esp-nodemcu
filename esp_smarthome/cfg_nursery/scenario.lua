function offlineInit()
    pio.setOut(0, pio.getIn(0))
    pio.setOut(3, pio.getIn(1))
    pio.setOut(2, 0)
    pio.setOut(1, 0)
end
-- OUT1 doesn't work!!!
function offlineScenario(id, v)
    if id == 0 then
        led.blink(200)
        pio.setOut(id, v)
    elseif id == 1 then
        led.blink(200)
        pio.setOut(3, v)
    end
end

function onlineInit()
    for i = 0,5 do
        smarthome:setSensor("in"..tostring(i), pio.getIn(i))
    end
end

function onlineScenario(id, v)
    smarthome:setSensor("in"..tostring(id), v)
end
