print("3 sec...")
-- reset debug pin
gpio.write(3, 0)
-- wait, may be main.lc broken
tmr.alarm(0, 3000, 0, function() dofile("main.lc") end)
