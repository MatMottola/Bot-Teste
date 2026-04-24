openBackpacks = function()
   for _, container in pairs(g_game.getContainers()) do
        g_game.close(container)
   end
    schedule(1000, function()
        bpItem = getBack()
        if bpItem ~= nil then g_game.open(bpItem) end
    end)

    schedule(2000, function()
        local nextContainers = {}
        containers = getContainers()
        for i, container in pairs(g_game.getContainers()) do
            for i, item in ipairs(container:getItems()) do
                if item:isContainer() then
                    table.insert(nextContainers, item)
                end
            end
            if #nextContainers == 0 then return end
            local delay = 1
            for i = 1, #nextContainers do
                schedule(delay, function()
                    g_game.open(nextContainers[i], nil)
                end)
                delay = delay + 250
            end
        end
    end)
end

-- this loads the function straighta way when reloading config
openBackpacks()
-- this adds a button to your bot, so you can press it
UI.Button("Backpack Open", function()
    openBackpacks()
end)


