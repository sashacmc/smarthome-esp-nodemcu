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
    print("Temp: "..d["temp"])
    print("Hum: "..d["hum"])
    if d["temp"] < 37.5 then
        heatOn()
    else
        heatOff()
    end
end

function heatOn()
    pio.setLed(1)
    pio.setOut(0, 1)
    print("Heater on")
end

function heatOff()
    pio.setLed(0)
    pio.setOut(0, 0)
    print("Heater off")
end
