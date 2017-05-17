---------------------------------------------------------
-- Hight level PIO control 
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

local lpio
local c_led = nil
local c_in = {}
local c_inv = {}
local c_out = {}
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
    return lpio.get(c_out[p])
end

local setOut = function(p, v)
    return lpio.set(c_out[p], v)
end

local getAllInOut = function()
    local r = {}
    for k, v in pairs(c_in) do
        r["in"..k] = tonumber(lpio.get(v))
    end
    for k, v in pairs(c_out) do
        r["out"..k] = tonumber(lpio.get(v))
    end
    return r
end

local setLed = function(v)
    if c_led ~= nil then
        return lpio.set(c_led, v)
    end
    return false
end

local getLed = function()
    if c_led ~= nil then
        return lpio.get(c_led)
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
    for k, v in pairs(cfg) do
        if k == "led" then
            c_led = tonumber(v)
            lpio.setMode(c_led, gpio.OUTPUT)
        elseif k == "inInt" then
            local n = tonumber(v)
            gpio.mode(n, gpio.INT)
            gpio.trig(n, "low", onInt)
        elseif string.sub(k, 1, 2) == "in" then
            local ik = tonumber(string.sub(k, 3, 3))
            local iv = tonumber(v)
            c_in[ik] = iv
            lpio.setMode(iv, gpio.INPUT)
            c_inv[ik] = lpio.get(iv) 
        elseif string.sub(k, 1, 3) == "out" then
            local ik = tonumber(string.sub(k, 4, 4))
            local iv = tonumber(v)
            c_out[ik] = iv
            lpio.setMode(iv, gpio.OUTPUT)
            lpio.set(iv, 0)
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

