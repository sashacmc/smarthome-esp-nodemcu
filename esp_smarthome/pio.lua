---------------------------------------------------------
-- Hight level PIO control 
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

local lpio
local c_led = nil
local c_ledh = nil
local c_in = {}
local c_inv = {}
local c_out = {}
local c_outh = {}
local c_onInChgd = nil

local onInt = function()
    local tm = tmr.time()
    print("onInt")
    for k, v in pairs(c_in) do
        local cv = lpio.get(v)
        if cv ~= c_inv[k] then
            c_inv[k] = cv
            print("changed:", k, cv)
            if c_onInChgd ~= nil then
                c_onInChgd(k, cv)
            end
        end
    end
end

local getIn = function(p)
    return lpio.get(c_in[p])
end

local getOut = function(p)
    return lpio.get(c_out[p], c_outh[p])
end

local setOut = function(p, v)
    return lpio.set(c_out[p], v, c_outh[p])
end

local getAllInOut = function()
    local r = {}
    for k, v in pairs(c_in) do
        r["in"..k] = tonumber(lpio.get(v))
    end
    for k, v in pairs(c_out) do
        r["out"..k] = tonumber(lpio.get(v, c_outh[k]))
    end
    return r
end

local setLed = function(v)
    if c_led ~= nil then
        return lpio.set(c_led, v, c_ledh)
    end
    return false
end

local getLed = function()
    if c_led ~= nil then
        return lpio.get(c_led, c_ledh)
    else
        return 0
    end
end

return function(cfg, onInChgd, lpio_)
    local tm = tmr.time()
    if tm == 0 then
        tm = 1
    end
    c_onInChgd = onInChgd
    lpio = lpio_
    for k, vh in pairs(cfg) do
        local p = string.find(vh, ":")
        local v = 0
        local h = 0
        if p then
            v = tonumber(string.sub(vh, 1, p - 1))
            h = tonumber(string.sub(vh, p + 1, p + 1))
        else
            v = tonumber(vh)
        end
        if k == "led" then
            c_led = v
            c_ledh = h
            lpio.setMode(c_led, gpio.OUTPUT)
        elseif k == "inInt" then
            gpio.mode(v, gpio.INT)
            gpio.trig(v, "low", onInt)
        elseif string.sub(k, 1, 2) == "in" then
            local ik = tonumber(string.sub(k, 3, 3))
            c_in[ik] = v
            lpio.setMode(v, gpio.INPUT)
            c_inv[ik] = lpio.get(v) 
        elseif string.sub(k, 1, 3) == "out" then
            local ik = tonumber(string.sub(k, 4, 4))
            c_out[ik] = v
            c_outh[ik] = h
            lpio.setMode(v, gpio.OUTPUT)
            lpio.set(v, 0, h)
        end
    end
    
    package.loaded['pio'] = nil
    lpio.setMode = nil
    
    return {
        getIn = getIn,
        initIn = initIn,
        getOut = getOut,
        setOut = setOut,
        getAllInOut = getAllInOut,
        setLed = setLed,
        getLed = getLed,
    }
end

