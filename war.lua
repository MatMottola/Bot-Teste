local warTab = "War"


setDefaultTab(warTab)
War = {} --global namespace
--importStyle("/war/botserver.otui")
--dofile("/war/botserver.lua")
--dofile("/war/push_anti.lua")
--importStyle("/war/push_close.otui")
--dofile("/war/push_close.lua")
--importStyle("/war/push_distance.otui")
--dofile("/war/push_distance.lua")
--dofile("/war/push_drag.lua")
--dofile("/war/comboLeader.lua")
--dofile("/war/combo_sd.lua")
--dofile("/war/combo_ue.lua")
--dofile("/war/ComboRP.lua")

local mwHotkey = "f7"
local wgHotkey = "f8"


storage.mwPoses = storage.mwPoses or {}
storage.wgPoses = storage.wgPoses or {}

local mwId = 3180
local wgId = 3156
local wallIds = {2128, 2129, 2130}

macro(50, "Force Hold Wg", function()
  for _, pos in ipairs(storage.wgPoses) do
    local tile = g_map.getTile(pos)
    if tile and tile:canShoot() then
      local top = tile:getTopUseThing()
      if not top or not table.find(wallIds, top:getId()) then
        tile:setText("WG")
        useWith(wgId, tile:getGround())
        delay(1000)
        break
      end
    end
  end
end)

macro(50, "Force Hold Mw", function()
  for _, pos in ipairs(storage.mwPoses) do
    local tile = g_map.getTile(pos)
    if tile and tile:canShoot() then
      local top = tile:getTopUseThing()
      if not top or not table.find(wallIds, top:getId()) then
        tile:setText("MW")
        useWith(mwId, tile:getGround())
        delay(1000)
        break
      end
    end
  end
end)

function table.findTable(tbl, value)
  for i, v in ipairs(tbl) do
    if table.equal(v, value) then
      return i
    end
  end
  return nil
end


local function togglePos(tbl, label)
  local tile = getTileUnderCursor()
  if not tile then return end
  
  local pos = tile:getPosition()
  local index = table.findTable(tbl, pos)
  
  if index then
    tile:setText("")
    table.remove(tbl, index)
  else
    tile:setText(label)
    table.insert(tbl, pos)
  end
end

onKeyDown(function(keys)
  keys = keys:lower()
  
  if keys == mwHotkey then
    togglePos(storage.mwPoses, "MW")
  elseif keys == wgHotkey then
    togglePos(storage.wgPoses, "WG")
  end
end)

addButton("", "Clean All Positions", function()
  for _, pos in ipairs(storage.mwPoses) do
    local tile = g_map.getTile(pos)
    if tile then tile:setText("") end
  end
  
  for _, pos in ipairs(storage.wgPoses) do
    local tile = g_map.getTile(pos)
    if tile then tile:setText("") end
  end
  
  storage.mwPoses = {}
  storage.wgPoses = {}
end)

addSeparator()

--MW

local toggle = macro(10, "mwall step","f2",function() end)

onPlayerPositionChange(function(newPos, oldPos)
    if oldPos.z ~= posz() then return end
    if oldPos then
        local tile = g_map.getTile(oldPos)
        if toggle.isOn() and tile:isWalkable() then
            useWith(3180, tile:getTopUseThing())
        end
    end
end)
addIcon("toggle", {item={id = 3180, count = 1}, text="MW step"}, function(icon, isOn)
  toggle.setOn(isOn)
end)


local toggle2 = macro(500, "mwall on target","f1",function() end)

onCreaturePositionChange(function(creature, newPos, oldPos)
    if creature == target() or creature == g_game.getFollowingCreature() then
        if oldPos and oldPos.z == posz() then
            local tile2 = g_map.getTile(oldPos)
            if toggle2.isOn() and tile2:isWalkable() then
                useWith(3180, tile2:getTopUseThing())
            end 
        end
    end
end)

addIcon("toggle2", {item={id = 3180, count = 1}, text=" MW on Target"}, function(icon, isOn)
  toggle2.setOn(isOn)
end)


