---------------------------------------------------------
-- Http sender module
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

require('config')

local key="KEY" -- thingspeak write API key (readed from config)
local data = ""

function getSysData(ap)
    local r = "";
    r = r.."ap: "..ap..", "
    r = r.."ip: "..wifi.sta.getip()..", "
    r = r.."uptime: "..tmr.time()..", "
    r = r.."heap: "..node.heap()..", "
    r = r.."br: "..node.bootreason()..", "

    return r
end

function sendData(ap, to)
    --print("Sending...")
    data = "field1="..co2..
           "&field2="..pres..
           "&field3="..hum..
           "&field4="..temp..
           "&status="..getSysData(ap)

    local c = net.createConnection(net.TCP, 0) 

    --c:on("receive", function(c, payload) print("Payload: "..payload) end)
    --c:on("reconnection", function(c) print("Got reconnection...") end)
    --c:on("sent", function(c) print("Sent") end)

    c:on("disconnection",
        function(c)
            --print("Disconnect")
            c:close()
        end)

    c:on("connection",
        function(c) 
            --print(string.len(data).."\n"..data)
            req = 
                "POST /update HTTP/1.1\r\n"..
                "Host: api.thingspeak.com\r\n"..
                "Connection: close\r\n"..
                "X-THINGSPEAKAPIKEY: "..key.."\r\n"..
                "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"..
                "Content-Type: application/x-www-form-urlencoded\r\n"..
                "Content-Length: "..string.len(data).."\r\n"..
                "\r\n"..
                data
            c:send(req)
        end)    

    -- api.thingspeak.com 144.212.80.11
    c:connect(80, "api.thingspeak.com") 
end
