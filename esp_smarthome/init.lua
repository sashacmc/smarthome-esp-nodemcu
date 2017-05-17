print("3 sec...")
-- wait, may be main.lc broken
tmr.alarm(0, 3000, 0,
function()
    require('setup')()
    dofile("main.lc")
end)
