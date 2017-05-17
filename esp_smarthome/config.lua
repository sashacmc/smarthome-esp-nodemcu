---------------------------------------------------------
-- Simple config (key=value) reader for NODEMCU
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------
return function(fn)
    local r = {}
    file.open(fn, "r")
    local l = file.readline()
    while l do
        local p = string.find(l, "=")
        if p then
            local k = string.sub(l, 1, p - 1)
            local v = string.sub(l, p + 1, string.len(l) - 1)
            r[k] = v 
            --print("readConfig:"..k.."|"..v)
        end
        l = file.readline()
    end
    file.close()

    package.loaded['config'] = nil
    return r
end
