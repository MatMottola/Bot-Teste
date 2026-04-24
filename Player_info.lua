local regex_voc = "s?he is an? ([a-z A-Z]*)%."
local regex_level = "%(level (%d+)%)"
local regex_name = "You see ([a-z A-Z']*) %("

player_info = macro(1000, "Player Info", function()
    local found = false
    local dimension = modules.game_interface.getMapPanel():getVisibleDimension()
    local spectators = g_map.getSpectatorsInRangeEx(player:getPosition(), false, math.floor(dimension.width / 2), math.floor(dimension.width / 2), math.floor(dimension.height / 2), math.floor(dimension.height / 2))
    for _, creature in ipairs(spectators) do
        if creature and creature:isPlayer() and #g_map.getTile(creature:getPosition()):getCreatures() == 1 then
            local creatureName = getRealName(creature)
            local isMarked = creatureName:find(" | ")
            if not isMarked and creature:getId() ~= player:getId() then
                found = false
                for name, info in pairs(PLAYERS_INFO) do
                    if creatureName == name then
                        creature:setName(creatureName.." | "..info.voc.." "..info.level) 
                        found = true
                    end
                end
                if not found then
                    g_game.look(creature)
                end
            end
        end
    end
end)

onTextMessage(function(mode, text)
    if player_info.isOn() and mode == 20 then
        local t = text:lower()
        if not t:find("%(level ") then return end
        local name = string.match(text, regex_name)
        local level = string.match(t, regex_level)
        local vocation = string.match(t, regex_voc)
        if name and level and vocation then
            if vocation:find("knight") then voc = "EK"
            elseif vocation:find("paladin") then voc = "RP"
            elseif vocation:find("druid") then voc = "ED"
            elseif vocation:find("sorcerer") then voc = "MS" end
            PLAYERS_INFO[name] = {level=tonumber(level), voc=voc}
        end
    end
end)

-- onCreatureAppear(function(creature)
--     if not player_info.isOn() then return end
--     if not creature:isPlayer() or creature == player then return end
--     g_game.look(creature)
-- end)