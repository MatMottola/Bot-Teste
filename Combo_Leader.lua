setDefaultTab("War")


local leaderOutfit = {
    head = 0,
    body = 94,
    legs = 79,
    feet = 79,
    type = 12, -- outfit id
    auxType = 0,
    addons = 3, -- 1, 2, or 3 for all
    mount = 0, -- mount id
}

local targetOutfit = {
    head = 0,
    body = 0,
    legs = 0,
    feet = 0,
    type = 280, -- outfit id
    auxType = 0,
    addons = 0, -- 1, 2, or 3 for all
    mount = 0, -- mount id
}

local allyOutfit = {
    head = 79,
    body = 114,
    legs = 114,
    feet = 79,
    type = 128, -- outfit id
    auxType = 0,
    addons = 3, -- 1, 2, or 3 for all
    mount = 0, -- mount id
}

local enemyOutfit = {
    head = 94,
    body = 38,
    legs = 38,
    feet = 94,
    type = 128, -- outfit id
    auxType = 0,
    addons = 0, -- 1, 2, or 3 for all
    mount = 0, -- mount id
}

local comboTargetName

function outfitEquals(o1, o2)
    if o1.type ~= o2.type then return false end
    if o1.head ~= o2.head then return false end
    if o1.body ~= o2.body then return false end
    if o1.legs ~= o2.legs then return false end
    if o1.feet ~= o2.feet then return false end
    if o1.addons ~= o2.addons then return false end
    return true
end


UI.Separator()
UI.Label("Leader target:")
UI.TextEdit(storage.comboLeaderName or "Palpa", function(widget, newText)
  storage.comboLeaderName = newText
end)

local comboLeader = macro(100, "Leader/Target Outfit", function()

    local leaderName = storage.comboLeaderName
    local dimension = modules.game_interface.getMapPanel():getVisibleDimension()
    local spectators = g_map.getSpectatorsInRangeEx(player:getPosition(), false, math.floor(dimension.width / 2), math.floor(dimension.width / 2), math.floor(dimension.height / 2), math.floor(dimension.height / 2))

    for _, creature in ipairs(spectators) do
        if creature:getId() == player:getId() then
        elseif leaderName and getRealName(creature):lower() == leaderName:lower() then
            if not outfitEquals(creature:getOutfit(), leaderOutfit) then
                creature:setOutfit(leaderOutfit)
            end
        elseif comboTargetName and getRealName(creature):lower() == comboTargetName:lower() then
            if not outfitEquals(creature:getOutfit(), targetOutfit) then
                creature:setOutfit(targetOutfit)
            end
        elseif creature:getEmblem() == 1 then
            if not outfitEquals(creature:getOutfit(), allyOutfit) then
                creature:setOutfit(allyOutfit)
            end
        elseif creature:getEmblem() == 2 then
            if not outfitEquals(creature:getOutfit(), enemyOutfit) then
                creature:setOutfit(enemyOutfit)
            end
        end
    end
end)

local attackLeaderTarget = macro(500, "Attack Leader Target", function()
    if g_game.getFollowingCreature() then
        return
    end
    local target = getCreatureByName(comboTargetName)
    local attacking = g_game.getAttackingCreature()
    local attackingId
    if attacking then
        attackingId = attacking:getId()
    end
    if target and attackingId ~= target:getId() then
        attack(target)
        delay(500)
    end
end)

local sdTargetCmd = macro(1000, "SdTarget Command  ", function()
end)

UI.Separator()

onTalk(function(name, level, mode, text, channelId, pos)
    if (comboLeader.isOn() or attackLeaderTarget.isOn()) and name == storage.comboLeaderName and string.sub(text, 1, 1) == "." then
      comboTargetName = string.sub(text, 2)
    end
    if sdTargetCmd.isOn() and name == storage.comboLeaderName and text == "!sd" then
        local target = getCreatureByName(comboTargetName)
        if target then
            g_game.useInventoryItemWith(3155, target, subType)
        end
    end
end)

onMissle(function(missle)
    if (comboLeader.isOn() or attackLeaderTarget.isOn()) then
      local src = missle:getSource()
      if src.z ~= posz() then
        return
      end
      local from = g_map.getTile(src)
      local to = g_map.getTile(missle:getDestination())
      if not from or not to then
        return
      end
      local fromCreatures = from:getCreatures()
      local toCreatures = to:getCreatures()
      if #fromCreatures ~= 1 or #toCreatures ~= 1 then
        return
      end
      local c1 = fromCreatures[1]
      local c2 = toCreatures[1]
      if getRealName(c1):lower() == storage.comboLeaderName:lower() then
        comboTargetName = getRealName(c2)
      end
    end
end)

onKeyPress(function(keys)
    if keys == "Escape" then
        comboTargetName = ''
    end
end)