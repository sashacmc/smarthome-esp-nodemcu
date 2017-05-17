---------------------------------------------------------
-- Main module
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------
require('scenario')

sensors = nil
smarthome = nil
pio = nil
led = nil

function onInChanged(id, v)
    if smarthome ~= nil and smarthome.onlineMode then
        onlineScenario(id, v)
    else 
        offlineScenario(id, v)
    end
end

function onRegister(ok)
    if ok then
        led.blink(60 * 1000)
        onlineInit()
    else
        led.slow()
        offlineInit()
    end
end

function onWifiConnected(ap)
    led.slow()
    smarthome = require('smarthome')(onRegister)
    
    tmr.alarm(0, 60 * 1000, 1,
        function()
            print("uptime: "..tmr.time())
            smarthome:setSensor("-", "-") -- ping

            --if not pcall(function () require("thingspeak")(sensors, pio, ap) end) then
            --    print("thingspeak module failed")
            --end
        end
    )

    tmr.alarm(1, 30 * 1000, 1, -- the same tmr num using in wifi scan
        function()
            tmr.softwd(60)
            if wifi.sta.status() ~= 5 then
                print('Lost wifi. Reconnect...')
                tmr.stop(0)
                tmr.stop(1)
                smarthome = nil
                
                led.fast()
                offlineInit()
                
                require('mywifi')(onWifiConnected)
            end
        end
    )
end

function init()
    tmr.softwd(60) 
    local cfg = require('config')("pio.cfg")
    
    local myi2c = require("myi2c")(tonumber(cfg["sda"]), tonumber(cfg["scl"]))
    local lpio = require("lowpio")(tonumber(cfg["pcf"]), myi2c)
    sensors = require("sensors")(cfg, myi2c)
    pio = require("pio")(cfg, onInChanged, lpio)
    led = require('led')(pio)

    led.fast()
    offlineInit()

    print("Boot reason:") 
    print(node.bootreason()) 
    
    print("Setting up Wifi...")
    require('mywifi')(onWifiConnected)

    require("httpserver")()
end

init()
init = nil
