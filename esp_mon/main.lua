---------------------------------------------------------
-- Temperature monitoring main module
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

require("mywifi")
require("httpsender")

print("Setting up Wifi...")

wifi.sta.disconnect()
wifi.setmode(wifi.STATION)

-- if something will be wrong and sleep doesn't happen, reboot in 5 min
tmr.alarm(0, 5 * 60 * 1000, 0, function() node.restart() end)

initWifi(
    function(ap)
        initSensors()
        sendData(ap, 60)
    end
)