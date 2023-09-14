---------------------------------------------------------
-- Simple registry storage (key=value) reader for NODEMCU
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------
local registry
do
    local fn = "registry.cfg"
    local reg = require("config")(fn)
    if reg == nil then
        reg = {}
    end

    local set = function(k, v)
        reg[k] = v
        require("setconfig")(fn, reg)
    end
    
    local get = function(k, def)
        if reg[k] == nil then
            return def
        end
        return reg[k] 
    end
    
    local getAll = function()
        return reg 
    end
        
    registry = {
        set = set,
        get = get,
        getAll = getAll,
    }
end

return registry 