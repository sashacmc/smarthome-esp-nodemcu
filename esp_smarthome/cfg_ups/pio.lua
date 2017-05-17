local lpio
local c_led = nil
local c_in = {}
local c_inv = {}
local c_out = {}
local c_onInChgd = nil

local conv = function(v)
    if v == 1 then
        return 0
    else
        return 1
    end
end

local getIn = function(p)
    return conv(lpio.get(c_in[p]))
end

local getOut = function(p)
    return conv(lpio.get(c_out[p]))
end

local setOut_ = function(p, v)
    lpio.set(c_out[p], conv(v))
end

local turnOnUPS = function()
    if getIn(1) == 0 then
        setOut_(0, 1)
        tmr.alarm(5, 2000, 0, function() setOut_(0, 0) end)
    end
end

local turnOffUPS = function(df)
    if getIn(1) == 1 then
        setOut_(0, 1)
        tmr.alarm(5, 2000, 0, function() setOut_(0, 0); df() end)
    end
end

-- out values:
-- v > 0 - turn on in v sec
-- v = 0 - turn off
-- v < 0 - turn off in v sec and restart

local setOut = function(p, v)
    if v > 0 then
        tmr.alarm(5, v * 1000, 0, turnOnUPS)
    elseif v == 0 then
        turnOffUPS(function() end)
    else
        tmr.alarm(5, -v * 1000, 0, function() turnOffUPS(function() node.restart() end) end)
    end
    return true
end

local getAllInOut = function()
    local r = {}
    for k, v in pairs(c_in) do
        r["in"..k] = conv(lpio.get(v))
    end
    for k, v in pairs(c_out) do
        r["out"..k] = conv(lpio.get(v))
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
        if string.sub(k, 1, 2) == "in" then
            local ik = tonumber(string.sub(k, 3, 3))
            local iv = tonumber(v)
            c_in[ik] = iv
            gpio.mode(iv, gpio.INPUT)
            c_inv[ik] = conv(lpio.get(iv))
        elseif string.sub(k, 1, 3) == "out" then
            local ik = tonumber(string.sub(k, 4, 4))
            local iv = tonumber(v)
            c_out[ik] = iv
            lpio.setMode(iv, gpio.OUTPUT)
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

