---------------------------------------------------------
-- Low level PIO control 
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

local myi2c
local pcfa          -- pcf i2c address
local pcfwm         -- pcf write mask (sensed pis must be writed by 1)
local pcfmid = 100  -- pcf minimal ID

local setMode = function(id, mode)
    if id < pcfmid then
        gpio.mode(id, mode)
    else 
        if mode == gpio.OUTPUT then
            id = id - pcfmid
            pcfwm = bit.clear(pcfwm, id)
        end
    end
end

local set = function(id, st)
    if id == nil then
        return false
    end
    if id < pcfmid then
        local bt
        if st == 0 then
            bt = gpio.HIGH
        else 
            bt = gpio.LOW
        end
        gpio.write(id, bt)
        return true
    else 
        id = id - pcfmid
        local curr = bit.bor(pcfwm, myi2c.readPCF(pcfa))
        local bt
        if st == 0 then
            bt = bit.set(curr, id)
        else 
            bt = bit.clear(curr, id)
        end
        return myi2c.writePCF(pcfa, bt)
    end
end

local get = function(id)
    if id == nil then
        return 0 
    end
    if id < pcfmid then
        local bt = gpio.read(id)
        if bt == gpio.HIGH then
            return 0
        else 
            return 1
        end
    else 
        id = id - pcfmid
        local curr = myi2c.readPCF(pcfa)
        if bit.isclear(curr, id) then
            return 1
        else 
            return 0
        end
    end
end

return function(pcf, myi2c_)
    myi2c = myi2c_
    pcfa = pcf
    pcfwm = 0xFF
    package.loaded['lowpio'] = nil
    return {
        setMode = setMode,
        set = set,
        get = get,
    }
end
