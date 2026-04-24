setDefaultTab("Tools")

UI.Label("Anti Red-Skull")


local m = macro(1000, "Anti Red", function() end)
local frags = 0
onTextMessage(function(mode, text)
    if not m.isOn() then return end
    if not text:lower():find("warning! the murder of") then return end
    info(text)
    frags = frags + 1
    if frags > 10 then
        modules.game_interface.forceExit()
    end
end)

UI.Separator()