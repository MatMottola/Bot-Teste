-- -- script
local walkDir
 onKeyDown(function(keys)
   if modules.game_walking.wsadWalking then
     if keys == "D" or keys == "A" or keys == "S" or keys == "W" then
       walkDir = keys
     end
   end
   if keys == "Up" or keys == "Right" or keys == "Down" or keys == "Left" then
     walkDir = keys
   end
 end)

 macro(100, "Auto Levitate", function()
   local playerPos = pos()
   local levitateTile
   if walkDir == "W" or walkDir == "Up" then -- north
     playerPos.y = playerPos.y - 1
     turn(0)
     levitateTile = g_map.getTile(playerPos)
   elseif walkDir == "D" or walkDir == "Right" then -- east
     playerPos.x = playerPos.x + 1
     turn(1)
     levitateTile = g_map.getTile(playerPos)
   elseif walkDir == "S" or walkDir == "Down" then -- south
     playerPos.y = playerPos.y + 1
     turn(2)
     levitateTile = g_map.getTile(playerPos)
   elseif walkDir == "A" or walkDir == "Left" then -- west
     playerPos.x = playerPos.x - 1
     turn(3)
     levitateTile = g_map.getTile(playerPos)
   end

   if levitateTile and not levitateTile:isWalkable() then
     if levitateTile:getGround() then
       say('exani hur "up')
       walkDir = nil
     else
       say('exani hur "down')
       walkDir = nil
     end
   end
   walkDir = nil
 end)