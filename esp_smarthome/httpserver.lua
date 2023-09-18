---------------------------------------------------------
-- HTTP server request processor
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

local srv

local sendStatus = function(res)
    local r = '{'
    for k, v in pairs(sensors.readData()) do
        r = r..'"'..k..'":'..v..','
    end
    for k, v in pairs(pio.getAllInOut()) do
        r = r..'"'..k..'":'..v..','
    end
    r = r..'"uptime":'..tmr.time()..'}'
    res:send(r)
end

local split = function(s, c)
    local p = string.find(s, c)
    if p then
        local k = string.sub(s, 1, p - 1)
        local v = string.sub(s, p + 1, string.len(s))
        return k, v
    end
    return s, ""
end

local splitOpts = function(opt)
    local r = {}
    local f, l = split(opt, '&')
    if f ~= "" then
        local k, v = split(f, '=')
        if k ~= "" then
            r[k] = v
        end
    end
    if l ~= "" then
        for k, v in pairs(splitOpts(l)) do
            r[k] = v
        end
    end
    return r
end

local setRegReq = function(res, opts)
    for k, v in pairs(opts) do
        registry.set(k, v)
    end
    res:send('OK')
end

local getRegReq = function(res)
    local r = ''
    for k, v in pairs(registry.getAll()) do
        if r ~= '' then
            r = ','..r
        end
        r = '"'..k..'":'..v..r
    end
    r = '{'..r..'}'
    res:send(r)
end

local setValueReq = function(res, opts)
    for k, v in pairs(opts) do
        if string.sub(k, 1, 3) == "out" then
            local ik = tonumber(string.sub(k, 4, 4))
            led.blink(200)
            pio.setOut(ik, tonumber(v))
            res:send('OK')
            return
        end
    end
    res:send('NONE')
end

local onRequest = function(req, res)
    print("+R", req.method, req.url, node.heap())

    res:init(200)
    res:send_header("Connection", "close")
    if req.method == "GET" then
        local uri, opt = split(req.url, '?')
        if uri == "/" then
            sendStatus(res)
        elseif uri == "/set" then
            setValueReq(res, splitOpts(opt))
        elseif uri == "/getreg" then
            getRegReq(res)
        elseif uri == "/setreg" then
            setRegReq(res, splitOpts(opt))
        elseif uri == "/telnet" then
            tmr.alarm(3, 2 * 1000, 0,
                function()
                    srv:close()
                    dofile("telnet_srv.lc")
                end
            )
            res:send('OK')
        end        
    end                
    res:finish()
end

return function()
    srv = require("http").createServer(80, onRequest)
    package.loaded['httpserver'] = nil
    package.loaded['http'] = nil
end
