return function()
    for f, v in pairs(file.list()) do
        local l = string.len(f)
        if string.sub(f, l - 3, l) == '.lua'
            and f ~= 'init.lua'
            and f ~= 'setup.lua' then
           if file.open(f) then
              file.close()
              print('Compiling:', f)
              node.compile(f)
              file.remove(f)
              collectgarbage()
           end
        end
    end
    package.loaded['setup'] = nil
end

