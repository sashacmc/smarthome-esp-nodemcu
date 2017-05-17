---------------------------------------------------------
-- Temperature value sender module
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

require('ds18b20')
require('config')
require('ow_helpers')

ds18b20.setup(6) -- OW IO pin

local key="" -- thingspeak write API key (readed from config)
local sensors = {}
local data = ""
local sto = nil -- deep sleep tiomout (sec)

function initSensors()
    for k, v in pairs(readConfig("sensors.cfg")) do
        if k == "key" then
            key = v
        else
            sensors[k] = owAddrEnc(v)
        end
    end
end

function getData()
    local d = {}
    for k, v in pairs(sensors) do
        local t = readSesnor(v)
        if t then
            table.insert(d, k.."="..t)
        end
    end;
    data = table.concat(d, "&")
    return data
end

function getSysData(ap)
    local r = "";
    r = r.."ap: "..ap..", "
    r = r.."ip: "..wifi.sta.getip()..", "
    r = r.."uptime: "..tmr.time()..", "
    r = r.."heap: "..node.heap()..", "
    r = r.."br: "..node.bootreason()..", "
    
    r = r.."1w:"
    for k, v in pairs(ds18b20.addrs()) do
        r = r.." "..owAddrDec(v)
    end

    return r
end

function sendData(ap, to)
    print("Sending...")
    sto = to
    data = getData().."&status="..getSysData(ap)

    local c = net.createConnection(net.TCP, 0) 

    --c:on("receive", function(c, payload) print("Payload: "..payload) end)
    --c:on("reconnection", function(c) print("Got reconnection...") end)

    c:on("disconnection",
        function(c)
            print("Disconnect")
            c:close()
            
            if sto ~= nil then
                print("Done, sleep...")
                node.dsleep(sto * 1000000, 1)
            end
        end)

    c:on("sent",
        function(c)
            print("Sent")
        end)

    c:on("connection",
        function(c) 
            print(string.len(data).."\n"..data)
            
            c:send("POST /update HTTP/1.1\n")
            c:send("Host: api.thingspeak.com\n")
            c:send("Connection: close\n")
            c:send("X-THINGSPEAKAPIKEY: "..key.."\n");
            c:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\n")
            c:send("Content-Type: application/x-www-form-urlencoded\n")
            c:send("Content-Length: "..string.len(data).."\n")
            c:send("\n")
            c:send(data)
        end)    

    -- api.thingspeak.com 144.212.80.11
    c:connect(80, "api.thingspeak.com") 
end

