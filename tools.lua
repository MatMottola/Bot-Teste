-- tools tab
setDefaultTab("Tools")

local size = 350
CaveBot.actionList:getParent():setHeight(size)



-- allows to test/edit bot lua scripts ingame, you can have multiple scripts like this, just change storage.ingame_lua
UI.Button("Ingame macro editor", function(newText)
  UI.MultilineEditorWindow(storage.ingame_macros or "", {title="Macro editor", description="You can add your custom macros (or any other lua code) here"}, function(text)
    storage.ingame_macros = text
    reload()
  end)
end)
UI.Button("Ingame hotkey editor", function(newText)
  UI.MultilineEditorWindow(storage.ingame_hotkeys or "", {title="Hotkeys editor", description="You can add your custom hotkeys/singlehotkeys here"}, function(text)
    storage.ingame_hotkeys = text
    reload()
  end)
end)

UI.Separator()

for _, scripts in ipairs({storage.ingame_macros, storage.ingame_hotkeys}) do
  if type(scripts) == "string" and scripts:len() > 3 then
    local status, result = pcall(function()
      assert(load(scripts, "ingame_editor"))()
    end)
    if not status then 
      error("Ingame edior error:\n" .. result)
    end
  end
end



UI.Separator()

local moneyIds = {3031, 3035,3043} -- gold coin, platinium coin
macro(500, "Exchange money", function()
  local containers = g_game.getContainers()
  for index, container in pairs(containers) do
    if not container.lootContainer then -- ignore monster containers
      for i, item in ipairs(container:getItems()) do
        if item:getCount() == 100 then
          for m, moneyId in ipairs(moneyIds) do
            if item:getId() == moneyId then
              return g_game.use(item)            
            end
          end
        end
      end
    end
  end
end)

macro(500, "Stack items", function()
  local containers = g_game.getContainers()
  local toStack = {}
  for index, container in pairs(containers) do
    if not container.lootContainer then -- ignore monster containers
      for i, item in ipairs(container:getItems()) do
        if item:isStackable() and item:getCount() < 100 then
          local stackWith = toStack[item:getId()]
          if stackWith then
            g_game.move(item, stackWith[1], math.min(stackWith[2], item:getCount()))
            return
          end
          toStack[item:getId()] = {container:getSlotPosition(i - 1), 100 - item:getCount()}
        end
      end
    end
  end
end)

macro(10000, "Anti Kick",  function()
  local dir = player:getDirection()
  turn((dir + 1) % 4)
  turn(dir)
end)


UI.Separator()

UI.Label("Mana training")
if type(storage.manaTrain) ~= "table" then
  storage.manaTrain = {on=false, title="MP%", text="utevo lux", min=80, max=100}
end

local manatrainmacro = macro(1000, function()
  if TargetBot and TargetBot.isActive() then return end -- pause when attacking
  local mana = math.min(100, math.floor(100 * (player:getMana() / player:getMaxMana())))
  if storage.manaTrain.max >= mana and mana >= storage.manaTrain.min then
    say(storage.manaTrain.text)
  end
end)
manatrainmacro.setOn(storage.manaTrain.on)

UI.DualScrollPanel(storage.manaTrain, function(widget, newParams) 
  storage.manaTrain = newParams
  manatrainmacro.setOn(storage.manaTrain.on)
end)

UI.Separator()

macro(60000, "Send message on trade", function()
  local trade = getChannelId("advertising")
  if not trade then
    trade = getChannelId("trade")
  end
  if trade and storage.autoTradeMessage:len() > 0 then    
    sayChannel(trade, storage.autoTradeMessage)
  end
end)
UI.TextEdit(storage.autoTradeMessage or "O Dg é muito gostoso", function(widget, text)    
  storage.autoTradeMessage = text
end)

UI.Separator()
 -- ANTI PUSH
  setDefaultTab("war")
  

  local function botPrintMessage(message)
    modules.game_textmessage.displayGameMessage(message)
  end
  
  

  if not storage.AntiPushItems then
    storage.AntiPushItems = "3031,3035"
  end

  
  addLabel("antiPushItemsLabel", "Anti Push Items:")
  addTextEdit("antiPushItemsTxtEdit", storage.AntiPushItems, function(widget, text)
    storage.AntiPushItems = text
  end)
  

  local function stringToTable(inputstr, sep)
    if sep == nil then
      sep = ","
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          table.insert(t, tonumber(str))
    end
    return t
  end

  local goldIds = 
  {
    [3031] = 3035,
    [3035] = 3043
  }

  local function AntiPush()
    local dropItems = stringToTable(storage.AntiPushItems)
    local tile = g_map.getTile(pos())
    if not tile  then return end
    local thing = tile:getTopThing()
    if not thing then return end
    for i, item in pairs(dropItems) do
      if item ~= thing:getId() then
        local dropItem = findItem(item)
        if dropItem then
          if dropItem:getCount() == 1 then
            g_game.move(dropItem, pos(), 1)
          else
            g_game.move(dropItem, pos(), 2)
          end
        elseif goldIds[item] ~= nil then
          --change gold
          local nextCurrency = findItem(goldIds[item])
          if not nextCurrency then return end
          g_game.use(nextCurrency)
        end
      end
    end
  end
  local isOn = false
  local antiPushIcon = addIcon("antipushIcon", {item={id=3734, count=1}, text="AntPush"},           
  macro(600,"Anti-Push", function(m)
    AntiPush()
    isOn = true
    schedule(600, function() 
      if m.isOff() then
       isOn=false 
      end
    end)
  end))

  onPlayerPositionChange(function() 
    if not isOn then return end
      AntiPush()
  end)

  
  Push_max = addIcon("Push Max", {item = 3035, text = "Push Max"},
  macro(175, "PushMax", function()
    local trashitem = nil
    for _, tile in pairs(g_map.getTiles(posz())) do
        if distanceFromPlayer(tile:getPosition()) == 1 and #tile:getItems() ~= 0 and not tile:getTopUseThing():isNotMoveable() then
            trashitem = tile:getTopUseThing()
            g_game.move(trashitem, pos(), trashitem:getCount())
            return
        end
    end
  end))
  addSeparator()


  -- antiPushIcon:breakAnchors()
  -- antipushIcon:move(80,80)
lblInfo= UI.Label("Auto Follow")

addLabel("Label", "Follow Name")
addTextEdit("TxtEdit", storage.fName or "name", function(widget, text)
  storage.fName = text
end)
--------------------------
local lastPos = nil
follow = macro(200, "Follow", function()
  
  local leader = getCreatureByName(storage.fName)
  local target = g_game.getAttackingCreature()
  if leader then
    if target and lastPos then
      return player:autoWalk(lastPos)
    end
    if not g_game.getFollowingCreature() then
      return g_game.follow(leader)
    end
  elseif lastPos then
    player:autoWalk(lastPos)
  end
end)

onCreaturePositionChange(function(creature, newPos, oldPos)
  local leader = getCreatureByName(storage.fName)
  if leader ~= creature or not newPos then return end
  lastPos = newPos
end)
follow = addIcon("follow", {item =30367, text = "FOLLOW",  }, follow )



addSeparator()
lblInfo= UI.Label("-- COMBO --")

lblInfo:setColor("green")

if not storage.ComboUni then
    storage.ComboUni = {}
end

local settings = storage.ComboUni

--[Config]
--[ID SD]-----------------------------------------
settings.SDId = 3155
--[ID Missle (sd)]--------------------------------
settings.SDEffectID = 32
--------------------------------------------------
--Atacar Alvo
local attackTarget = true
--------------------------------------------------


local comboSD = macro(200, function() end)
local comboSpell = macro(200, function() end)
local comboSpellL = macro(200, function() end)





onMissle(function(missle)
    local src = missle:getSource()
    if src.z ~= posz() then return end

    local from = g_map.getTile(src)
    local to = g_map.getTile(missle:getDestination())
    if not from or not to then return end

    local fromCreatures = from:getCreatures()
    local toCreatures = to:getCreatures()
    if #fromCreatures ~= 1 or #toCreatures ~= 1 then return end

    local c1 = fromCreatures[1]
    local t1 = toCreatures[1]

    --Remova os "--" da linha abaixo para ver o ID dos missle (caso não esteja combando com a SD do lider), e mude o id em settings.SDEffectID no código acima.
    -- modules.game_textmessage.displayGameMessage("Quem Jogou: "..c1:getName()..", ID Missle: "..missle:getId())

    if c1:getName():lower() == settings.LeaderName:lower() and  missle:getId() == settings.SDEffectID then
        if attackTarget then
            local target = g_game.getAttackingCreature()
            if not target or target ~= t1 then
                g_game.attack(t1)
            end
        end
        if comboSD.isOn() then
            local SDRune = findItem(settings.SDId)
            if SDRune then 
                
                return g_game.useWith(SDRune, t1)
            end
        end
        if comboSpell.isOn() then
            say(settings.spell)
        end
    end
end)

onTalk(function(name, level, mode, text, channelId, pos) 
    if comboSpellL.isOn() and name:lower() == settings.LeaderName:lower() and text:lower() == settings.LeaderSpell:lower() then
        say(settings.UE)
    end
end)

posSD = addIcon("sd1", {item =12905, text = "COMBO SD ", }, comboSD )

posSpell = addIcon("sd2", {item =12905, text = "SPELL COMBO", }, comboSpell )


poscomboSpellL = addIcon("sd3", {item =12905, text = "UE COMBO", }, comboSpellL )



Sd_Pvp= macro(200, "SD", function()
    local creature = g_game.getAttackingCreature()
if creature then
    creatureId = creature:getId()
	if creatureId > 0 then
		local target = getCreatureById(creatureId)
		if target and target:canShoot() then
			pausar_potions = os.clock()*2000
			usewith(3155, g_game.getAttackingCreature())
			delay(300)
		end
	end
end
end)

marrom = addIcon("(Sd) Pvp", {item=3155, text="(SD)"},
function(icon, isOn)
Sd_Pvp.setOn(isOn)
end)



Lyse_Pvp= macro(200, "Paralyse", function()
    local creature = g_game.getAttackingCreature()
if creature then
    creatureId = creature:getId()
	if creatureId > 0 then
		local target = getCreatureById(creatureId)
		if target and target:canShoot() then
			pausar_potions = os.clock()*2000
			usewith(3165, g_game.getAttackingCreature())
			delay(300)
		end
	end
end
end)

marrom = addIcon("(Paralyse) Pvp", {item=3165, text="(Lyse)"},
function(icon, isOn)
Lyse_Pvp.setOn(isOn)
end)


Ssd_Pvp= macro(200, "SuperSD", function()
    if g_game.isAttacking() then
        usewith(3150, g_game.getAttackingCreature())
        delay(400)
    end
end)

marrom = addIcon("(Super SD) Pvp", {item=3150, text="(Super)"},
function(icon, isOn)
Ssd_Pvp.setOn(isOn)
end)



-- equip ssa. NÃO PRECISA DA BP ABERTA PRA PUXAR!

-- equip might ring. NÃO PRECISA DA BP ABERTA PRA PUXAR!



if not storage.ComboAttack then
    storage.ComboAttack = {}
end

local settings = storage.ComboAttack

addSeparator()
addLabel("", "Combo Attack"):setColor("green")
addSeparator()

addLabel()
addLabel("", "Leader Name")
addTextEdit("TxtEditLeader1", settings.LeaderName or "name", function(widget, text)
    settings.LeaderName = text
end)

addLabel()
addLabel("", "Leader Name 2")
addTextEdit("TxtEditLeader2", settings.LeaderName2 or "name", function(widget, text)
    settings.LeaderName2 = text
end)

addLabel()
addLabel("", "Leader Name 3")
addTextEdit("TxtEditLeader3", settings.LeaderName3 or "name", function(widget, text)
    settings.LeaderName3 = text
end)

-- Macro principal
local m_main = macro(10000, "Combo Attack", function() end)

-- Ícone para ativar/desativar
addIcon("Combo Leader", {item = 3547, text = "Combo Leader"}, function(icon, isOn)
    if isOn then
        m_main.setOn()
    else
        m_main.setOff()
    end
end)

onMissle(function(missle)
    if m_main.isOff() then return end
    local src = missle:getSource()
    if src.z ~= posz() then return end
    
    local from = g_map.getTile(src)
    local to = g_map.getTile(missle:getDestination())
    if not from or not to then return end
    
    local fromCreatures = from:getCreatures()
    local toCreatures = to:getCreatures()
    if #fromCreatures ~= 1 or #toCreatures ~= 1 then return end
    
    local c1 = fromCreatures[1]
    local t1 = toCreatures[1]
    local leaders = {settings.LeaderName, settings.LeaderName2, settings.LeaderName3}

    if table.find(leaders, c1:getName(), true) then
        local target = g_game.getAttackingCreature()
        if (not target or target ~= t1) 
        and not table.find(storage.playerList.friendList, t1:getName(), true) then
            g_game.attack(t1)
        end
    end
end)

addSeparator()


