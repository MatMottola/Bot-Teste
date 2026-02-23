BotServer.url = "ws://127.0.0.1:5000/send"

BotPanelName = "BOTserver"
local ui = setupUI([[
Panel
  height: 18

  Button
    id: botServer
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    height: 18
    !text: tr('BotServer')
]])
ui:setId(BotPanelName)

if not storage[BotPanelName] then
storage[BotPanelName] = {
  manaInfo = false,
  mwallInfo = false,
  runeCombo = false,
  paramax = false,
  playerPos = false,
  comboSDHotkey = "F12",
  paramaxHotkey = "F11",
}
end

if not storage.BotServerChannel then
  storage.BotServerChannel = tostring(math.random(1000000000000,9999999999999))
end

local channel = tostring(storage.BotServerChannel)
BotServer.init(name(), channel)

rootWidget = g_ui.getRootWidget()
if rootWidget then
  botServerWindow = g_ui.createWidget('BotServerWindow', rootWidget)
  botServerWindow:hide()


  botServerWindow.Data.Channel:setText(storage.BotServerChannel)
  botServerWindow.Data.Channel.onTextChange = function(widget, text)
    storage.BotServerChannel = text
  end

  botServerWindow.Data.Random.onClick = function(widget)
    storage.BotServerChannel = tostring(math.random(1000000000000,9999999999999))
    botServerWindow.Data.Channel:setText(storage.BotServerChannel)
  end

  botServerWindow.Features.Feature1:setOn(storage[BotPanelName].manaInfo)
  botServerWindow.Features.Feature1.onClick = function(widget)
    storage[BotPanelName].manaInfo = not storage[BotPanelName].manaInfo
    widget:setOn(storage[BotPanelName].manaInfo)
  end

  -- botServerWindow.Features.Feature2:setOn(storage[BotPanelName].mwallInfo)
  -- botServerWindow.Features.Feature2.onClick = function(widget)
  --   storage[BotPanelName].mwallInfo = not storage[BotPanelName].mwallInfo
  --   widget:setOn(storage[BotPanelName].mwallInfo)
  -- end

  botServerWindow.Features.Feature3:setOn(storage[BotPanelName].runeCombo)
  botServerWindow.Features.Feature3.onClick = function(widget)
    storage[BotPanelName].runeCombo = not storage[BotPanelName].runeCombo
    widget:setOn(storage[BotPanelName].runeCombo)
  end

  botServerWindow.Features.Feature4:setOn(storage[BotPanelName].paramax)
  botServerWindow.Features.Feature4.onClick = function(widget)
    storage[BotPanelName].paramax = not storage[BotPanelName].paramax
    widget:setOn(storage[BotPanelName].paramax)
  end

  botServerWindow.Features.Feature5:setOn(storage[BotPanelName].playerPos)
  botServerWindow.Features.Feature5.onClick = function(widget)
    storage[BotPanelName].playerPos = not storage[BotPanelName].playerPos
    widget:setOn(storage[BotPanelName].playerPos)
  end

  botServerWindow.Features.comboSDHotkey:setText(storage[BotPanelName].comboSDHotkey)
  botServerWindow.Features.comboSDHotkey.onTextChange = function(widget, text)
    storage[BotPanelName].comboSDHotkey = text
  end

  botServerWindow.Features.paramaxHotkey:setText(storage[BotPanelName].paramaxHotkey)
  botServerWindow.Features.paramaxHotkey.onTextChange = function(widget, text)
    storage[BotPanelName].paramaxHotkey = text
  end
  
end

function updateStatusText()
  if BotServer._websocket then 
    botServerWindow.Data.ServerStatus:setText("CONNECTED")
    if serverCount then
      botServerWindow.Data.Participants:setText(#serverCount)
    end
  else
    botServerWindow.Data.ServerStatus:setText("DISCONNECTED")
    botServerWindow.Data.Participants:setText("-")
  end
end

macro(2000, function()
  if BotServer._websocket then
    BotServer.send("list")
  end
  updateStatusText()
end)

local regex = [["(.*?)"]]
BotServer.listen("list", function(name, data)
  serverCount = regexMatch(json.encode(data), regex)  
  storage.serverMembers = json.encode(data) 
end)

ui.botServer.onClick = function(widget)
    botServerWindow:show()
    botServerWindow:raise()
    botServerWindow:focus()
end

botServerWindow.closeButton.onClick = function(widget)
    botServerWindow:hide()
end

--Mwalls

-- storage[BotPanelName].mwalls = {}
-- BotServer.listen("mwall", function(name, message)
--   if storage[BotPanelName].mwallInfo then
--     if not storage[BotPanelName].mwalls[message["pos"]] or storage[BotPanelName].mwalls[message["pos"]] < now then
--       storage[BotPanelName].mwalls[message["pos"]] = now + message["duration"] - 150 -- 150 is latency correction
--     end
--   end
-- end)

-- onAddThing(function(tile, thing)
--   if storage[BotPanelName].mwallInfo then
--     if thing:isItem() and (thing:getId() == 2129 or thing:getId() == 2128) then
--       local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
--       if not storage[BotPanelName].mwalls[pos] or storage[BotPanelName].mwalls[pos] < now then
--         storage[BotPanelName].mwalls[pos] = now + 20000
--         BotServer.send("mwall", {pos=pos, duration=20000})
--       end
--       tile:setTimer(storage[BotPanelName].mwalls[pos] - now)
--     end
--   end
-- end)

--Mana

BotServer.listen("mana", function(name, message)
  if storage[BotPanelName].manaInfo then
    if message["mana"] and message["id"] then
      local creature = getCreatureById(message["id"])
      if creature then
        creature:setManaPercent(message["mana"])
      end
    end
  end
end)

local lastMana = 0
macro(100, function()
  if storage[BotPanelName].manaInfo then
    if manapercent() ~= lastMana then
      lastMana = manapercent()
      BotServer.send("mana", {mana=lastMana, id=player:getId()})
    end
  end
end)

--Combo

BotServer.listen("useItemWith", function(senderName, message)
  if storage[BotPanelName].runeCombo then
    if message["pos"] then
      local tile = g_map.getTile(message["pos"])
      if tile then
        local topThing = tile:getTopUseThing()
        if topThing then
          useWith(message["itemId"], topThing)
        end
      end
    elseif message["targetId"] then
      local target = getCreatureById(message["targetId"])
      if target then
        usewith(message["itemId"], target)
      end
    end
  end
end)

onKeyDown(function(keys)
  if keys == storage[BotPanelName].comboSDHotkey then
    local creature = g_game.getAttackingCreature()
    if creature then
      BotServer.send("useItemWith", {itemId=3155, targetId=creature:getId()})
    end
  end
end)

--Set Target?

BotServer.listen("attack", function(senderName, message)
  if storage[panelName].enabled and name() ~= senderName and senderName == storage[panelName].bombLeaderName then
    local targetId = message["targetId"]
    if targetId == 0 then
      g_game.cancelAttackAndFollow()
    else
      local leaderTarget = getCreatureById(targetId)
      local target = g_game.getAttackingCreature()
      if target == nil then
        if leaderTarget then
          g_game.attack(leaderTarget)
        end
      else
        if leaderTarget and target:getId() ~= leaderTarget:getId() then
          g_game.attack(leaderTarget)
        end
      end
    end
  end
end)

--Paramax

local paramaxTargetId = nil
local paramaxTargetSpeed = 0
local paramaxScore = {}
local amIDruid = false
local vocCheck = false

local isParalyzed = function(target)
  if paramaxTargetSpeed * 0.5 >= target:getSpeed() then
    return true
  end
  return false
end

local calcScore = function(target)
  if not target:canShoot() then
    return 0
  end
  local multiplier = 1
  local mana = player:getMana()
  if mana < 1600 then return 0 end
  if getDistanceBetween(pos(), target:getPosition()) > 5 then
    local multiplier = multiplier * 0.5
  end
  return mana * multiplier
end

BotServer.listen("paramax", function(name, message)
  if not storage[BotPanelName].paramax then return end
  if not amIDruid then return end
  if message["targetId"] and message["setStatus"] and message["setStatus"] == "on" then
    paramaxTargetId = message["targetId"]
  elseif message["setStatus"] and message["setStatus"] == "off" then
    local target = getCreatureById(paramaxTargetId)
    if target and target:getText() == "PARAMAX" then
      target:setText("")
    end
    paramaxTargetId = nil
    paramaxTargetSpeed = 0
    paramaxScore = {}
  end
  if paramaxTargetId and message["targetSpeed"] and message["targetSpeed"] > paramaxTargetSpeed then
    paramaxTargetSpeed = message["targetSpeed"]
  end
  if paramaxTargetId and message["score"] and message["score"] ~= nil then
    paramaxScore[realNameFromStr(name)] = message["score"]
  end
end)

macro(50, function()
  if not storage[BotPanelName].paramax then return end
  if not vocCheck then g_game.look(player) end
  if not amIDruid then return end
  if paramaxTargetId then
    local payload = {score=0}
    local target = getCreatureById(paramaxTargetId)
    if target and not isParalyzed(target) then
      local myScore = calcScore(target)
      local myTurn = false
      payload.score = myScore
      local highest_score = 0
      for name, score in pairs(paramaxScore) do
        if score > highest_score then
          highest_score = score
        end
      end
      if myScore > 0 and myScore >= highest_score then
        myTurn = true
      end
      if target:getSpeed() > paramaxTargetSpeed then
        payload.targetSpeed = target:getSpeed()
      end
      if myTurn then
        g_game.useInventoryItemWith(3165, target, subType)
      end
      if target:getText() == "" then
        target:setText("PARAMAX")
      end
    end
    BotServer.send("paramax", payload)
  end
end)

onTextMessage(function(mode, text)
  if vocCheck or not mode == 20 then return end
  local voc = string.match(text:lower(), "you are an? [a-z]* ?([a-z]+)%.")
  if voc then
    if voc == "druid" then
      amIDruid = true
    end
    vocCheck = true
  end
end)

onKeyDown(function(keys)
  if not storage[BotPanelName].paramax then return end
  if keys == storage[BotPanelName].paramaxHotkey then
    local creature = g_game.getAttackingCreature()
    if creature and creature ~= paraMaxTarget then
      paraMaxTarget = creature
      BotServer.send("paramax", {setStatus="on", targetId=creature:getId()})
    else
      paraMaxTarget = nil
      BotServer.send("paramax", {setStatus="off"})
    end
  end
end)

onCreatureAppear(function(creature)
  if creature:getText() == "PARAMAX" and creature:getId() ~= paramaxTargetId then
    creature:setText("")
  end
end)

--PlayerPos

BotServer.listen("playerPos", function(name, message)
  if storage[BotPanelName].playerPos then
    if message["x"] and message["y"] and message["z"] then
      local pos = {x=message["x"], y=message["y"], z=message["z"]}
      if not EXIVA_PANELS[name] then
        EXIVA_PANELS[name] = {}
      end
      EXIVA_PANELS[name].pos = pos
      EXIVA_PANELS[name].lastUpdate = os.time()
    end
  end
end)

macro(500, function()
  if storage[BotPanelName].playerPos then
    BotServer.send("playerPos", pos())
  end
end)

addSeparator()