function offlineInit()
    pio.setOut(0, pio.getIn(0))
    pio.setOut(1, pio.getIn(1))
    pio.setOut(2, 0)
    pio.setOut(3, 0)
end

function offlineScenario(id, v)
    if v == 0 then
        return
    end

    if id == 0 then
        led.blink(200)
        pio.setOut(0, (pio.getOut(0) + 1) % 2)
    elseif id == 1 then
        led.blink(200)
        local o1 = pio.getOut(1) == 1
        local o2 = pio.getOut(2) == 1
        local o3 = pio.getOut(3) == 1
        
        if o1 and o2 and o3 then
            pio.setOut(1, 0)
            pio.setOut(2, 0)
            pio.setOut(3, 0)
        elseif not o1 and not o2 and not o3 then
            pio.setOut(3, 1)
        elseif not o1 and not o2 and o3 then 
            pio.setOut(1, 1)
        elseif o1 and not o2 and o3 then
            pio.setOut(1, 0)
            pio.setOut(2, 1)
            pio.setOut(3, 0)
        else
            pio.setOut(1, 1)
            pio.setOut(2, 1)
            pio.setOut(3, 1)
        end
    end
end

function onlineInit()
    for i = 0,1 do
        smarthome:setSensor("in"..tostring(i), pio.getIn(i))
    end
end

function onlineScenario(id, v)
    smarthome:setSensor("in"..tostring(id), v)
end
