---------------------------------------------------------
-- Thingspeak module
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

local data = nil
local key = nil -- thingspeak write API key

local getSysData = function(ap)
    local r = "";
    r = r.."ap: "..ap..", "
    r = r.."ip: "..wifi.sta.getip()..", "
    r = r.."uptime: "..tmr.time()..", "
    r = r.."heap: "..node.heap()..", "
    r = r.."br: "..node.bootreason()..", "

    return r
end

local onDiscon = function(c)
    --print("Thingspeak done")
    c:close()
    package.loaded['thingspeak'] = nil
end

local onCon = function(c) 
    --print(string.len(data).."\n"..data)
    local req = 
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
    --print(req)
end

local pioToData = function(pio)
    local r = ''
    for k, v in pairs(pio.getAllInOut()) do
        r = r..k..': '..v..', '
    end
    return r
end

return function(sensors, pio, ap)
    --print("Thingspeak start")
    local cfg = require('config')("thingspeak.cfg")
    local sns = sensors.readData()
    local status = getSysData(ap)
    data = ""
    for k, v in pairs(cfg) do
        if k == "key" then
            key = v
        elseif k == "sendPio" and v == "1" then
            status = status..pioToData(pio)
        elseif string.sub(k, 1, 5) == "field" then
            if sns[v] ~= nil then
                data = data..'&'..k..'='..tostring(sns[v])
            end
        end
    end
    data = data.."&status="..status

    local c = net.createConnection(net.TCP, 0) 

    --c:on("receive", function(c, payload) print("Payload: "..payload) end)
    --c:on("reconnection", function(c) print("Got reconnection...") end)
    --c:on("sent", function(c) print("Sent") end)

    c:on("connection", onCon)
    c:on("disconnection", onDiscon)

    -- api.thingspeak.com 144.212.80.11
    c:connect(80, "api.thingspeak.com") 
end
