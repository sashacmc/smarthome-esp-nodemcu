---------------------------------------------------------
-- Simple config writer (key=value) reader for NODEMCU
-- Alexander Bushnev <sashacmc@gmail.com>
---------------------------------------------------------
return function(fn, r)
    if file.open(fn, "w") then
        for k, v in pairs(r) do
            file.writeline(k.."="..v)
        end
        file.close()
    end

    package.loaded['setconfig'] = nil
end
