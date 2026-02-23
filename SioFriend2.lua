UI.Separator()

UI.Label("Heal Friend")

if not storage.friendName then
  storage.friendName = ""
end

addLabel("friendLabel", "Friend Name")
addTextEdit("friendNameBox", storage.friendName, function(widget, text)
  storage.friendName = text
end)

local healPercent = 70
local spellCD = 1000

macro(100, "Friend Healer", function()

  local friendName = storage.friendName
  if not friendName or friendName == "" then return end

  for _, creature in ipairs(getSpectators()) do
    if creature:isPlayer()
    and creature:getName():lower() == friendName:lower()
    then
      if creature:getHealthPercent() <= healPercent then
        say('exura sio "' .. friendName .. '"')
        delay(spellCD)
      end
      break
    end
  end

end)
