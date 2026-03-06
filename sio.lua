addSeparator()
addLabel("", "Green Emblem Sio"):setColor("green")

local spell = "exura sio"
local hpPercent = 80
local minMana = 100
local delay = 200

macro(delay, "Guild SIO 80%", function()

    if mana() < minMana then return end

    local lowestTarget = nil
    local lowestHp = 101

    for _, creature in ipairs(getSpectators()) do
        if creature:isPlayer()
        and not creature:isLocalPlayer()
        and creature:getEmblem() == 1
        and creature:getHealthPercent() > 0
        and creature:getHealthPercent() < hpPercent then

            if creature:getHealthPercent() <= lowestHp then
                lowestHp = creature:getHealthPercent()
                lowestTarget = creature
            end
        end
    end

    if lowestTarget then
        say(spell .. ' "' .. lowestTarget:getName())
    end

end)

UI.Label("Verifique o numero do emblema do servidor")
addSeparator()