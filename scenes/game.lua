local composer = require("composer")
local scene = composer.newScene()

local Socket = require("classes.socket")
local Rune = require("classes.rune")

local numberOfSockets = 12
local sockets = {}
local runes = {}

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function hasCollided(rune, socket)
  if (rune == nil) then
    return false
  end

  if (socket == nil) then
    return false
  end


  local dx = rune.x - socket.x
  local dy = rune.y - socket.y
  local distance = math.sqrt(dx * dx + dy * dy)
  local objectSize = (socket.contentWidth / 2 - 48) + (rune.contentWidth / 2)

  if (distance < objectSize) then
    return true
  end

  return false
end

local function gameLoop(event)
  for i = 1, #sockets do
    if (sockets[i] and hasCollided(event.target, sockets[i].image)) then
      event.target.runeInstance:updateAngle(i)
    end
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

    socket:create(sceneGroup, x, y)
    table.insert(sockets, socket)
  end

  local rune = Rune:new()
  rune:create(sceneGroup, display.contentCenterX, display.contentCenterY)
  table.insert(runes, rune)

  Runtime:addEventListener("dropRune", gameLoop)
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
