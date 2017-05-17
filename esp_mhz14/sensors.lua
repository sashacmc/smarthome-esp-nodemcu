---------------------------------------------------------
-- Temperature/Pressure/Humidity sensors module
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

-- global sensors values
pres = -1
hum = -1
temp = -1
co2 = -1

-- sensors pins setup
local dhtPin = 5
local bmeSdaPin = 2 
local bmeSclPin = 1

function initSensors()
    bme280.init(bmeSdaPin, bmeSclPin)
    uart.setup(0, 9600, 8, 0, 1, 0)
    uart.on("data", 9, onRead, 0)
end


function readHumidityAndTemp()
    s, t, h, t_, h_ = dht.read(dhtPin)
    if s == dht.OK then
        return h, t
    else
        return -1, -1
    end
end

    
function readPressureAndTemp()
    p, t = bme280.baro()
    if p ~= nil and t ~=nil then
        return p/1000., t/100.
    else
        return -1, -1
    end
end

function decodeCO2(rd)
    if string.byte(rd, 1) == 0xFF and string.byte(rd, 2) == 0x86 then
        hl = string.byte(rd, 3)
        ll = string.byte(rd, 4)
        return hl * 256 + ll
    else
        return -1 
    end
end

function onRead(rawdata)
    co2 = decodeCO2(rawdata)
end

function readData()
    pres, temp = readPressureAndTemp()
    hum, t_ = readHumidityAndTemp()

    --onRead("")
    uart.write(0, 0xFF, 0x01, 0x86, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79)
end
