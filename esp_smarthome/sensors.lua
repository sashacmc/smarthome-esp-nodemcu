---------------------------------------------------------
-- Temperature/Pressure/Humidity sensors module
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

-- global sensors values
local dhtPin
local myi2c

local readHumidityAndTemp = function()
    local s, t, h, t_, h_ = dht.read(dhtPin)
    if s == dht.OK then
        return h, t
    else
        return -1, -1
    end
end
    
local readData = function()
    local sns = {}
    local lux = myi2c.readTSL()
    if lux ~= -1 then
        sns["lux"] = lux
    end
    if dhtPin ~= nil then
        h, t = readHumidityAndTemp()
        if h ~= -1 then
            sns["hum"] = h
            sns["temp"] = t
        end
    end
    return sns
end

return function(cfg, myi2c_)
    dhtPin = tonumber(cfg["dht"])
    myi2c = myi2c_
    
    package.loaded['sensors'] = nil
    return {
        readData = readData,
    }
end
