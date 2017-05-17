---------------------------------------------------------
-- Main module
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

require("mywifi")
require("httpsender")
require("httpserver")
require("sensors")

print("Setting up Wifi...")

wifi.sta.disconnect()
wifi.setmode(wifi.STATION)

local sap

initWifi(
    function(ap)
        sap = ap
        
        initSensors()
        readData()
        startServer()

        tmr.alarm(0, 10 * 1000, 1,
            function()
                readData()
            end
        )

        tmr.alarm(1, 60 * 1000, 1,
            function()
                if wifi.sta.status() ~= 5 then
                    --print('Lost wifi. Restart...')
                    node.restart()
                end

                sendData(sap)
            end
        )
    end
)
