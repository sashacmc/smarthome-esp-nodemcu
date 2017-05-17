---------------------------------------------------------
-- HTTP server
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

function sendStatus(res)
    res:send('{'..
        '"co2":'..co2..','..
        '"humidity":'..hum..','..
        '"pressure":'..pres..','..
        '"temperature":'..temp..'}'
    )
end

function onRequest(req, res)
    --print("+R", req.method, req.url, node.heap())

    res:init(200)
    res:send_header("Connection", "close")
    if req.method == "GET" then
        if req.url == "/" then
            sendStatus(res)
        end        
    end                
    res:finish()
end

function startServer()
    require("http").createServer(80, onRequest)
end
