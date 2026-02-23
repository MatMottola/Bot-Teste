setDefaultTab("HP")
addLabel("title", "Energy Ring")

local panelName = "energyRing"

local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Auto E-ring')

  Button
    id: setup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

]])

if not storage[panelName] then
    storage[panelName] = {
        enabled = false,
        itemId = 3051,
        itemIdEquipped = 3088,
        hpPercent = 50,
        hpPercentRemove = 90,
        manaPercentRemove = 10,
        screenMonsters = 0,
        screenPlayers = 0
    }
end

ui.title:setOn(storage[panelName].enabled)
ui.title.onClick = function(widget)
    storage[panelName].enabled = not storage[panelName].enabled
    widget:setOn(storage[panelName].enabled)
end

ui.setup.onClick = function(widget)
  eRingWindow:show()
  eRingWindow:raise()
  eRingWindow:focus()
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  eRingWindow = g_ui.createWidget('EnergyRingWindow', rootWidget)
  eRingWindow:hide()

  eRingWindow.closeButton.onClick = function(widget)
    eRingWindow:hide()
  end

  local updateHpPercentText = function()
    eRingWindow.hpPercentText:setText("Use Ring HP% < ".. storage[panelName].hpPercent.."%")
  end
  updateHpPercentText()
  eRingWindow.hpPercent.onValueChange = function(scroll, value)
    storage[panelName].hpPercent = value
    updateHpPercentText()
  end
  eRingWindow.hpPercent:setValue(storage[panelName].hpPercent)

  local updatehpPercentRemoveText = function()
    eRingWindow.hpPercentRemoveText:setText("Remove Ring HP% > ".. storage[panelName].hpPercentRemove.."%")
  end
  updatehpPercentRemoveText()
  eRingWindow.hpPercentRemove.onValueChange = function(scroll, value)
    storage[panelName].hpPercentRemove = value
    updatehpPercentRemoveText()
  end
  eRingWindow.hpPercentRemove:setValue(storage[panelName].hpPercentRemove)

  local updatemanaPercentRemoveText = function()
    eRingWindow.manaPercentRemoveText:setText("Remove Ring MP% < ".. storage[panelName].manaPercentRemove.."%")
  end
  updatemanaPercentRemoveText()
  eRingWindow.manaPercentRemove.onValueChange = function(scroll, value)
    storage[panelName].manaPercentRemove = value
    updatemanaPercentRemoveText()
  end
  eRingWindow.manaPercentRemove:setValue(storage[panelName].manaPercentRemove)

  local updateScreenMonstersText = function()
    eRingWindow.screenMonstersText:setText("Monsters for Ring: ".. storage[panelName].screenMonsters)
  end
  updateScreenMonstersText()
  eRingWindow.screenMonsters.onValueChange = function(scroll, value)
    storage[panelName].screenMonsters = value
    updateScreenMonstersText()
  end
  eRingWindow.screenMonsters:setValue(storage[panelName].screenMonsters)

  local updateScreenPlayersText = function()
    eRingWindow.screenPlayersText:setText("Players for Ring: ".. storage[panelName].screenPlayers)
  end
  updateScreenPlayersText()
  eRingWindow.screenPlayers.onValueChange = function(scroll, value)
    storage[panelName].screenPlayers = value
    updateScreenPlayersText()
  end
  eRingWindow.screenPlayers:setValue(storage[panelName].screenPlayers)

  eRingWindow.itemId.onItemChange = function(widget)
    storage[panelName].itemId = widget:getItemId()
  end
  eRingWindow.itemId:setItemId(storage[panelName].itemId)

  eRingWindow.itemIdEquipped.onItemChange = function(widget)
    storage[panelName].itemIdEquipped = widget:getItemId()
  end
  eRingWindow.itemIdEquipped:setItemId(storage[panelName].itemIdEquipped)
end

local original_ring = getFinger(); -- Your original ring

macro(50, function()
    if not storage[panelName].enabled then return end
    local flagCreatureDanger = false
    if storage[panelName].screenMonsters > 0 or storage[panelName].screenPlayers > 0 then
      local players = 0
      local monsters = 0
      local dimension = modules.game_interface.getMapPanel():getVisibleDimension()
      local spectators = g_map.getSpectatorsInRangeEx(player:getPosition(), false, math.floor(dimension.width / 2), math.floor(dimension.width / 2), math.floor(dimension.height / 2), math.floor(dimension.height / 2))
      for _, creature in ipairs(spectators) do
        if creature:isPlayer() and creature:getId() ~= player:getId() then
          players = players + 1
        end
        if creature:isMonster() then
          monsters = monsters + 1
        end
      end
      if (storage[panelName].screenMonsters > 0 and monsters >= storage[panelName].screenMonsters) or (storage[panelName].screenPlayers > 0 and players >= storage[panelName].screenPlayers) then
        flagCreatureDanger = true
      end
    end
    if ((manapercent() <= storage[panelName].manaPercentRemove or player:getHealthPercent() >= storage[panelName].hpPercentRemove) and not flagCreatureDanger) and getFinger() and getFinger():getId() == storage[panelName].itemIdEquipped then
        if original_ring then
            local ring = findItem(getInactiveItemId(original_ring:getId()))
            g_game.move(ring, {x=65535, y=9, z=0}, 1)
            if not ring then
              g_game.move(getFinger(), {x=65535, y=3, z=0}, 1)
            end
        else
            g_game.move(getFinger(), {x=65535, y=3, z=0}, 1)
        end
        delay(200)
    elseif ((player:getHealthPercent() <= storage[panelName].hpPercent or flagCreatureDanger) and manapercent() >= storage[panelName].manaPercentRemove and (not getFinger() or getFinger():getId() ~= storage[panelName].itemIdEquipped)) then
        local ring = findItem(storage[panelName].itemId);
        if ring then
            original_ring = getFinger()
            g_game.move(ring, {x=65535, y=9, z=0}, 1)
            delay(200)
        end
    end
end)
