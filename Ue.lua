-- UE Spell
UI.Separator()
UI.Label("Spells")
UI.TextEdit(storage.UeSpell or "Exevo gran mas Frigo",
            function(widget, newText) storage.UeSpell = newText end)

local distance = 15
macro(50, "UE SAFE",  function() -- editar nome da spell
    local playerInScreen = false
    if not g_game.isAttacking() then
        return
    end
    for i,mob in ipairs(getSpectators()) do
        if (getDistanceBetween(player:getPosition(), mob:getPosition())  <= distance and mob:isPlayer())  and (player:getName() ~= mob:getName()) then
            playerInScreen = true
        end
    end

    if not playerInScreen then 
      say(storage.UeSpell) 
    end
end)