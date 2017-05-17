for p = 5,8 do
    print("setmode:", p)
    gpio.mode(p, gpio.OUTPUT)
end

tmr.alarm(1, 500, 1, function()
    local p = math.random(5, 8) 
    local v = (gpio.read(p) + 1) % 2
    print("Set:", p, v)
    gpio.write(p, v)
end)

