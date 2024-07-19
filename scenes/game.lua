local composer = require("composer")
local scene = composer.newScene()

local Socket = require("classes.socket")
local Rune = require("classes.rune")

local numberOfSockets = 12
local offsetX = 300
local offsetY = 700
local selectedRune
local sockets = {}
local runes = {}

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function addRune(sceneGroup, x, y, boardPosition)
  local rune = Rune:new()

  rune:create(sceneGroup, x, y, boardPosition)
  table.insert(runes, rune)
end

-- local function hasCollided(rune, socket)
--   if (rune == nil) then
--     return false
--   end

--   if (socket == nil) then
--     return false
--   end

--   local dx = rune.x - socket.x
--   local dy = rune.y - socket.y
--   local distance = math.sqrt(dx * dx + dy * dy)
--   local objectSize = (socket.contentWidth / 2 - 48) + (rune.contentWidth / 2)

--   if (distance < objectSize) then
--     return true
--   end

--   return false
-- end

-- local function handleRuneMove(event)
--   for i = 1, #sockets do
--     if (sockets[i] and hasCollided(event.target, sockets[i].image)) then
--       event.target.runeInstance:updateAngle(i)
--     end
--   end

--   return true
-- end

-- local function handleRuneDrop(event, sceneGroup)
--   for i = 1, #sockets do
--     if (sockets[i] and hasCollided(event.target, sockets[i].image) and not sockets[i].hasRune) then
--       sockets[i].hasRune = true

--       if event.target.runeInstance.socketPosition then
--         sockets[event.target.runeInstance.socketPosition].hasRune = false
--       end

--       event.target.runeInstance:updatePosition(sockets[i].image.x, sockets[i].image.y)
--       event.target.runeInstance.socketPosition = i

--       if (event.target.runeInstance.boardPosition ~= nil) then
--         local boardPosition = event.target.runeInstance.boardPosition

--         event.target.runeInstance.boardPosition = nil
--         addRune(sceneGroup, display.contentCenterX - offsetX + (offsetX * (boardPosition - 1)), display.contentCenterY + offsetY, boardPosition)
--       end

--       return true
--     end
--   end

--   if (event.target.runeInstance.boardPosition ~= nil) then
--     event.target.runeInstance:updateAngle(12)
--     event.target.runeInstance:updatePosition(
--       display.contentCenterX - offsetX + (offsetX * (event.target.runeInstance.boardPosition - 1)),
--       display.contentCenterY + offsetY
--     )
--   else
--     local socketPosition = event.target.runeInstance.socketPosition

--     event.target.runeInstance:updatePosition(sockets[socketPosition].image.x, sockets[socketPosition].image.y)
--     event.target.runeInstance:updateAngle(socketPosition)
--   end

--   return true
-- end

local function handleSelectRune(event)
  if selectedRune then
    transition.cancel(selectedRune)
    selectedRune.alpha = 1

    if selectedRune ~= event.target then
      selectedRune.runeInstance.isSelected = false
    end
  end

  if selectedRune ~= event.target then
    selectedRune = event.target
  else
    if selectedRune and selectedRune.runeInstance.isSelected == false then
      selectedRune = nil
    end
  end

  return true
end

local function handleSelectSocket(event, sceneGroup)
  if selectedRune then
    local socketPosition = event.target.socketInstance.boardPosition

    transition.to(selectedRune, { x = sockets[socketPosition].image.x, y = sockets[socketPosition].image.y, time = 150, onComplete = function()
      local boardPosition = selectedRune.runeInstance.boardPosition
      transition.cancel(selectedRune)
      selectedRune.alpha = 1
      selectedRune.runeInstance.boardPosition = nil
      selectedRune.runeInstance.isSelected = false
      selectedRune = nil

      if boardPosition then
        addRune(sceneGroup, display.contentCenterX - offsetX + (offsetX * (boardPosition - 1)), display.contentCenterY + offsetY, boardPosition)
      end
    end
    })

    selectedRune.runeInstance:updateAngle(socketPosition)
  end

  return true
end

-- create()
function scene:create(event)
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

  for i = 1, numberOfSockets, 1 do
    local socket = Socket:new()

    local x = display.contentCenterX + math.sin((i * 30 * math.pi) / 180) * 400
    local y = display.contentCenterY - math.cos((i * 30 * math.pi) / 180) * 400

    socket:create(sceneGroup, x, y, i)
    table.insert(sockets, socket)
  end

  for i = 0, 2, 1 do
    local boardPosition = i + 1

    addRune(sceneGroup, display.contentCenterX - offsetX + (offsetX * i), display.contentCenterY + offsetY, boardPosition)
  end

  Runtime:addEventListener("selectRune", handleSelectRune)
  Runtime:addEventListener("selectSocket", function(event)
      handleSelectSocket(event, sceneGroup)
    end
  )

  -- Runtime:addEventListener("runeMove", handleRuneMove)
  -- Runtime:addEventListener("runeDrop",
  --   function(event)
  --     handleRuneDrop(event, sceneGroup)
  --   end
  -- )
end

-- show()
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will") then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
	elseif (phase == "did") then
		-- Code here runs when the scene is entirely on screen
	end
end

-- hide()
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will") then
		-- Code here runs when the scene is on screen (but is about to go off screen)
	elseif (phase == "did") then
		-- Code here runs immediately after the scene goes entirely off screen
	end
end

-- destroy()
function scene:destroy(event)
	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
