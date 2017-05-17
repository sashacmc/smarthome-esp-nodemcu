-- stop timers, compile and reboot

local compileAndRemoveIfNeeded = function(f)
   if file.open(f) then
      file.close()
      print('Compiling:', f)
      node.compile(f)
      file.remove(f)
      collectgarbage()
   end
end

tmr.stop(0)
tmr.stop(1)
tmr.stop(2)
tmr.stop(3)

local serverFiles = {'config.lua', 'sensors.lua', 'http.lua', 'httpserver.lua', 'httpsender.lua', 'mywifi.lua', 'main.lua'}
for i, f in ipairs(serverFiles) do
    compileAndRemoveIfNeeded(f)
end

node.restart()
