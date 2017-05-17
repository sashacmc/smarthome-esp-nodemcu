---------------------------------------------------------
-- Multiply Wi-Fi connector for NODEMCU
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

local cap = nil -- curent access point
local cc = 0 -- connect timeout counter
local crh = nil -- connect result handler
local wl = nil -- wifi list

local checkConnected = nil
local connectWifiByList = nil
local onGetAP = nil
local startScan = nil 

checkConnected = function() 
    tmr.softwd(60)
    local r = false 

    cc = cc - 1
    if cc == 0 then
        print("Timeout exceeded")
    else
        local st = wifi.sta.status()
        if st == 1 then
            print("Connect to: "..cap) 
            return
        end
        
        if st == 2 then
            print("Wrong pwd: "..cap)
        elseif st == 3 then
            print("AP not found: "..cap)
        elseif st == 4 then
            print("Failed connect: "..cap)
        else
            print("Connected: "..cap..", IP: "..wifi.sta.getip())
            r = true
        end
    end
    
    tmr.stop(1)

    if r then
        -- if connected process result handler
        package.loaded['mywifi'] = nil
        crh(cap)
    else
        -- try next
        connectWifiByList()
    end
end

connectWifiByList = function()
    if #wl == 0 then
        -- list empty, then reboot after timeout
        print('Wifi is broken, rescan...')
        tmr.alarm(3, 5000, 0, function() startScan() end)
        return
    end
    -- extract first ap
    local ap = table.remove(wl, 1)

    -- and try connect
    wifi.sta.disconnect()
    wifi.sta.config(ap[1], ap[2], 0)
    wifi.sta.connect()
    cc = 30 -- connect timeout value = 30 min
    cap = ap[1] 

    tmr.alarm(1, 1000, 1, function() checkConnected() end)
end

onGetAP = function(l)
    print("Wifi scan done")
    -- extract RSSI value -53 from "3,-59,bc:ae:c5:c3:c2:5c,11"
    local sl = {}
    for k, v in pairs(l) do
        table.insert(sl, {k, string.gmatch(v, '-%d+')()})
    end
    -- sort by RSSI
    table.sort(sl, function(a, b) return a[2] < b[2] end)
    -- prepare list {ap, pass} sorted by RSSI
    wl = {}
    local cl = require('config')("wifi.cfg")
    for _, v in ipairs(sl) do
        if cl[v[1] ] ~= nil then
            print("Found: ", v[1], v[2])
            table.insert(wl, {v[1], cl[v[1] ]})
        end
    end
    connectWifiByList()
end

startScan = function()
    tmr.softwd(60)
    wifi.sta.disconnect()
    wifi.sta.getap(onGetAP)
end

return function(rh)
    crh = rh
    print('Init wifi...')
    wifi.setmode(wifi.STATION)
    startScan()
end
