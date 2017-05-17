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

local serverFiles = {'ds18b20.lua', 'config.lua', 'http.lua', 'httpsender.lua', 'ow_helpers.lua', 'mywifi.lua', 'httpserver.lua', 'main.lua'}
for i, f in ipairs(serverFiles) do
    compileAndRemoveIfNeeded(f)
end

node.restart()
