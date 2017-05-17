---------------------------------------------------------
-- Smarthome server interaction 
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

local host
local port
local id 
local pool = {}
local size = 0
local busy = false

local setOnlineMode = function(self, m)
    if m ~= self.onlineMode then
        self.onRegisterOk(m)
        self.onlineMode = m
        print('Online mode:'..tostring(m))
    end
end

local onSensor = function(self, c, d)
    print("onSensor:"..tostring(c)..":"..d)

    if c ~= 200 then
        self:setOnlineMode(false)
    end

    if not self.onlineMode then
        self:register(id, wifi.sta.getip()) 
    end
end

local setSensor = function(self, n, v)
    self:send("[SERVER_NOTIFY_COMMAND]&m="..id.."&n="..n.."&v="..v, self.onSensor)
end

local onRegister = function(self, c, d)
    self:setOnlineMode(c == 200 and d == "true")
end

local register = function(self, n, ip)
    print("Try register")
    self:send("[SERVER_REGISTER_COMMAND]&n="..n.."&v="..ip, self.onRegister)
end

local send = function(self, data, callback)
    if size > 10 then
        print("Send overload")
        return 
    end
    if busy then
        print("Send busy")
        return
    end
    busy = true 

    size = size + 1
    local onCon = function(c) 
        local req =
            "GET "..pool[c].." HTTP/1.1\r\n"..
            "Host: smarthome\r\n"..
            "Connection: close\r\n\r\n"
        c:send(req)
    end

    local onDiscon = function(c)
        c:close()
        pool[c] = nil
        size = size - 1
        if callback ~= nil then
            callback(self, 0, "")
        end
    end

    local onRec = function(c, d)
        local code = 0
        local data = ""
        local p1 = string.find(d, " ")
        local p2 = string.find(d, " ", p1 + 1)
        if p1 ~= nil and p2 ~= nil then
            code = tonumber(string.sub(d, p1 + 1, p2))
            p1 = string.find(d, "\r\n\r\n", p2)
            if p1 ~= nil then
                data = string.sub(d, p1 + 4, string.len(d))
            end
        end    
        callback(self, code, data)
        callback = nil
    end

    local c = net.createConnection(net.TCP, 0) 
    pool[c] = data
    c:on("connection", onCon)
    c:on("disconnection", onDiscon)
    c:on("receive", onRec)

    c:connect(port, host) 
    busy = false
end

return function(onRegisterOk)
    local cfg = require('config')("smarthome.cfg")
    id = cfg["id"]
    host = cfg["host"]
    port = cfg["port"]

    res = {
        onSensor = onSensor,
        setSensor = setSensor,
        onRegister = onRegister,
        register = register,
        send = send,
        
        onRegisterOk = onRegisterOk,
        setOnlineMode = setOnlineMode,
        onlineMode = false,
    }
    res:register(id, wifi.sta.getip()) 

    package.loaded['smarthome'] = nil
    return res
end
