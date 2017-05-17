---------------------------------------------------------
-- LED control 
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

local ltmr = 6
local pio

local blink = function(tm)
    pio.setLed(1)
    tmr.stop(ltmr)
    tmr.alarm(ltmr, tm, 0, function() pio.setLed(0) end)
end

local slow = function()
    tmr.stop(ltmr)
    tmr.alarm(ltmr, 500, 1, function() pio.setLed((pio.getLed() + 1) % 2) end)
end

local fast = function()
    tmr.stop(ltmr)
    tmr.alarm(ltmr, 100, 1, function() pio.setLed((pio.getLed() + 1) % 2) end)
end

local stop = function()
    tmr.stop(ltmr)
    pio.setLed(0)
end

return function(pio_)
    pio = pio_
    
    package.loaded['led'] = nil
    return {
        blink = blink,
        slow = slow,
        fast = fast,
        stop = stop,
    }
end
