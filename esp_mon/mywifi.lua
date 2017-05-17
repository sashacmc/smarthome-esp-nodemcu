---------------------------------------------------------
-- Multiply Wi-Fi connector for NODEMCU
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

require('config')

local dpin = 3 -- debug pin
local cc = 0 -- connect timeout counter
local crh = nil -- connect result handler
local fs = true -- first scan

function connectWifi(ap, p, rh)
    wifi.sta.disconnect()
    wifi.sta.config(ap, p)
    wifi.sta.connect()
    cc = 60 -- connect timeout value = 1 min

    tmr.alarm(1, 1000, 1,
        function() 
            local r = nil
    
            cc = cc - 1
            if cc == 0 then
                print("Timeout exceeded")
                r = false
            else
                local st = wifi.sta.status()
                if st == 1 then
                    print("Connect to: "..ap) 
                    return
                end
                
                if st == 2 then
                    print("Wrong pwd: "..ap)
                    r = false
                elseif st == 3 then
                    print("AP not found: "..ap)
                    r = false
                elseif st == 4 then
                    print("Failed connect: "..ap)
                    r = false
                else
                    print("Connected: "..ap..", IP: "..wifi.sta.getip())
                    r = true
                    -- set debug pin
                    gpio.write(dpin, 1)
                end
            end
            
            tmr.stop(1)
            rh(r)
        end)
end

function connectWifiByList(wl)
    if #wl == 0 then
        -- list empty, then reboot after timeout
        print('Wifi is broken')
        tmr.alarm(2, 5000, 0, function() node.restart() end)
        return
    end
    -- extract first ap
    local ap = table.remove(wl, 1)
    -- and try connect
    connectWifi(ap[1], ap[2],
        function(r)
            if r then
                -- if connected process result handler
                crh(ap[1])
            else
                -- try next
                connectWifiByList(wl)
            end
        end)
end

function onGetAP(l)
    print("Wifi scan done")
    -- extract RSSI value -53 from "3,-59,bc:ae:c5:c3:c2:5c,11"
    local sl = {}
    for k, v in pairs(l) do
        table.insert(sl, {k, string.gmatch(v, '-%d+')()})
    end
    -- sort by RSSI
    table.sort(sl, function(a, b) return a[2] < b[2] end)
    -- prepare list {ap, pass} sorted by RSSI
    rl = {}
    local cl = readConfig("wifi.cfg")
    for _, v in ipairs(sl) do
        if cl[v[1] ] ~= nil then
            print("Found: ", v[1], v[2])
            table.insert(rl, {v[1], cl[v[1] ]})
        end
    end
    -- restart scan more once if failed
    if fs and #rl == 0 then
        fs = false
        tmr.alarm(3, 1000, 0, function() wifi.sta.getap(onGetAP) end)
        return
    end
    connectWifiByList(rl)
end

function initWifi(rh)
    crh = rh
    fs = true
    print('Init wifi...')
    -- set debug pin
    gpio.write(dpin, 0)
    -- search wifi
    wifi.sta.getap(onGetAP)
end
