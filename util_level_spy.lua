-- config

local keyUp = "="
local keyDown = "-"


-- script

local lockedLevel = pos().z
local m = macro(1000, "Spy Level", function() end)

onPlayerPositionChange(function(newPos, oldPos)
    if oldPos.z ~= newPos.z then
        lockedLevel = pos().z
        modules.game_interface.getMapPanel():unlockVisibleFloor()
    end
end)

onKeyPress(function(keys)
    if m.isOn() and modules.game_walking.wsadWalking then
        if keys == keyDown then
            lockedLevel = lockedLevel + 1
            modules.game_interface.getMapPanel():lockVisibleFloor(lockedLevel)
        elseif keys == keyUp then
            lockedLevel = lockedLevel - 1
            modules.game_interface.getMapPanel():lockVisibleFloor(lockedLevel)
        end
    end
end)