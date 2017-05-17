---------------------------------------------------------
-- I2C helpers 
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

local busy = false
local tslReady = false
    
local readPCF = function(da)
    if busy then
        return 0
    end
    busy = true
    i2c.start(0)
    i2c.address(0, da, i2c.RECEIVER)
    local bdata = i2c.read(0, 1)
    i2c.stop(0)
    busy = false
    return string.byte(bdata, 1)
end

local writePCF = function(da, value)
    if busy then
        return
    end
    busy = true
    i2c.start(0)
    i2c.address(0, da, i2c.TRANSMITTER)
    i2c.write(0, value)
    i2c.stop(0)
    busy = false
end

local readTSL = function()
    if busy or not tslReady then
        return -1
    end
    res = tsl2561.getlux()
    if res == 384 then -- workaround: returns when tsl2561 not connected
        return -1
    end
    return res
end

return function(sda, scl)
    i2c.setup(0, sda, scl, i2c.SLOW)
    tslReady = tsl2561.TSL2561_OK == tsl2561.init(sda, scl)
    package.loaded['myi2c'] = nil
    return {
        readPCF = readPCF,
        writePCF = writePCF,
        readTSL = readTSL,
    }
end
