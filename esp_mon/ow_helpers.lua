---------------------------------------------------------
-- OW helpers functions
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------

require('ds18b20')

-- convert OW address to module format
function owAddrEnc(a)
    local s = ""
    for i = 1, string.len(a) / 2 do
        local hs = string.sub(a, i * 2 - 1, i * 2)
        s = s..string.char(tonumber(hs, 16))
    end
    return s
end        

-- convert OW address to readble format
function owAddrDec(a)
    local s = ""
    for i = 1, string.len(a) do
        s = s..string.format("%02X", string.byte(a, i))
    end
    return s
end        

function readSesnor(addr)
    local t = ds18b20.read(addr)
    if t == 85 then
        t = ds18b20.read(addr)
        if t == 85 then
            print("Bad value: "..owAddrDec(addr))
            return nil
        end
    end    
    return t
end    
