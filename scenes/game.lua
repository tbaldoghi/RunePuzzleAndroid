local composer = require("composer")
local scene = composer.newScene()

local Orb = require("classes.orb")
local Socket = require("classes.socket")
local Rune = require("classes.rune")
local Forge = require("classes.forge")
local Seal = require("classes.seal")

local levels = require("consts.levels")

local level = composer.getVariable("level")
local numberOfSockets = 16
local offsetX = 300
local offsetY = 700
local selectedRune
local orb
local forge
local sockets = {}
local runes = {}
local seals = {}

local handleSelectSocketReference
local handleSelectForgeReference

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

local function disableDisplayObjects()
  for i = 1, #runes, 1 do

    if not runes[i].isDestoryed then
      runes[i]:disable()
    end
  end

  for i = 1, #sockets, 1 do
    sockets[i]:disable()
  end

  forge:disable()
end

local function isGameEnded()
  for i = 1, numberOfSockets, 1 do
    if sockets[i].hasRune == false then
      return false
    end
  end

  return true
end

local function findRune(socketPosition)
  for i = 1, #runes, 1 do
    if runes[i].socketPosition == socketPosition and not runes[i].isDestoryed then
      return runes[i]
    end
  end
end

local function findSocket(socketPosition)
  for i = 1, #sockets, 1 do
    if sockets[i].boardPosition == socketPosition then
      return sockets[i]
    end
  end
end

local function findSeal(socketPosition)
  print(socketPosition)
  for i = 1, #seals, 1 do
    if seals[i].boardPosition == socketPosition then
      return seals[i]
    end
  end

  return nil
end

local function isGameSolved()
  for i = 1, numberOfSockets, 1 do
    local leftIndex
    local rightIndex

    if i - 1 > 1 then
      leftIndex = i - 1
    else
      leftIndex = 1
    end

    if i + 1 < numberOfSockets then
      rightIndex = i + 1
    else
      rightIndex = numberOfSockets
    end

    local socketPosition = sockets[i].boardPosition
    local currentRune = findRune(socketPosition)
    local leftRune = findRune(leftIndex)
    local rightRune = findRune(rightIndex)
    local currentSeal = findSeal(socketPosition)
    local isLeftSideSolved = currentRune.runeType == leftRune.runeType or currentRune.colorType == leftRune.colorType
    local isRightSideSolved = currentRune.runeType == rightRune.runeType or currentRune.colorType == rightRune.colorType

    if not (isLeftSideSolved and isRightSideSolved) then
      return false
    end

    if currentSeal then
      if currentSeal.sealType == "rune" then
        if currentSeal.runeType ~= currentRune.runeType then
          return false
        end
      elseif currentSeal.sealType == "color" then
        if currentSeal.colorType ~= currentRune.colorType then
          return false
        end
      end
    end
  end

  return true
end

local function addSockets(sceneGroup)
  for i = 1, numberOfSockets, 1 do
    local socket = Socket:new()

    local x = display.contentCenterX + math.sin((i * 22.5 * math.pi) / 180) * 425
    local y = display.contentCenterY - math.cos((i * 22.5 * math.pi) / 180) * 425

    socket:create(sceneGroup, x, y, i)
    table.insert(sockets, socket)
  end
end

local function addSeals(sceneGroup)
  local currentLevel = levels[level]
  local socketPositions = {}

  for i = 1, numberOfSockets, 1 do
    table.insert(socketPositions, i)
  end

  for i = 1, currentLevel.runeSeals, 1 do
    local position = table.remove(socketPositions, math.random(#socketPositions))

    local seal = Seal:new()

    local x = display.contentCenterX + math.sin((position * 22.5 * math.pi) / 180) * 290
    local y = display.contentCenterY - math.cos((position * 22.5 * math.pi) / 180) * 290

    seal:create(sceneGroup, x, y, position, 'rune')
    table.insert(seals, seal)
  end

  for i = 1, currentLevel.colorSeals, 1 do
    local position = table.remove(socketPositions, math.random(#socketPositions))

    local seal = Seal:new()

    local x = display.contentCenterX + math.sin((position * 22.5 * math.pi) / 180) * 290
    local y = display.contentCenterY - math.cos((position * 22.5 * math.pi) / 180) * 290

    seal:create(sceneGroup, x, y, position, 'color')
    table.insert(seals, seal)
  end
end

local function handleContinueButtonTouch(event)
  if event.phase == "ended" then
    composer.gotoScene("scenes.statistics")
  end

  return true
end

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
    local previousSocketPosition = selectedRune.runeInstance.socketPosition
    local socketPosition = event.target.socketInstance.boardPosition

    transition.to(selectedRune, { x = sockets[socketPosition].image.x, y = sockets[socketPosition].image.y, time = 150, onComplete = function()
        local boardPosition = selectedRune.runeInstance.boardPosition

        transition.cancel(selectedRune)
        event.target.socketInstance.hasRune = true
        selectedRune.alpha = 1
        selectedRune.runeInstance.boardPosition = nil
        selectedRune.runeInstance.isSelected = false
        selectedRune = nil

        if boardPosition then
          addRune(sceneGroup, display.contentCenterX - offsetX + (offsetX * (boardPosition - 1)), display.contentCenterY + offsetY, boardPosition)
        else
          if previousSocketPosition then
            local socket = findSocket(previousSocketPosition)

            socket.hasRune = false
          end
        end

        if isGameEnded() then
          disableDisplayObjects()

          local message = ""

          if (isGameSolved()) then
            message = "Level Completed"

            local continueButton = display.newText(sceneGroup, "Continue", 800, 300)

            continueButton:addEventListener("touch", handleContinueButtonTouch)
          else
            message = "Game Over"
          end

          display.newText(sceneGroup, message, 800, 200)
        end
      end
    })

    selectedRune.runeInstance:updateAngle(socketPosition)
  end

  return true
end

local function handleSelectForge(event, sceneGroup)
  if selectedRune then
    local previousSocketPosition = selectedRune.runeInstance.socketPosition
    local x = event.target.x
    local y = event.target.y

    transition.to(selectedRune, { x = x, y = y, time = 150, onComplete = function()
      local boardPosition = selectedRune.runeInstance.boardPosition
      local orbBar = composer.getVariable("orbBar") + 1

      composer.setVariable("orbBar", orbBar)
      orb:renderOrb(sceneGroup, orbBar)
      transition.cancel(selectedRune)

      selectedRune.alpha = 1

      transition.to(selectedRune, { alpha = 0, time = 300 , onComplete = function()
          selectedRune.runeInstance.isDestoryed = true
          selectedRune:removeSelf()
          selectedRune = nil

          if boardPosition then
            addRune(sceneGroup, display.contentCenterX - offsetX + (offsetX * (boardPosition - 1)), display.contentCenterY + offsetY, boardPosition)
          else
            if previousSocketPosition then
              local socket = findSocket(previousSocketPosition)

              socket.hasRune = false
            end
          end
        end
      })
    end
    })
  end

  return true
end

-- create()
function scene:create(event)
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

  if level == 1 then
    composer.setVariable("orbBar", 1)
  end

  orb = Orb:new()

  orb:create(sceneGroup)
  orb:renderOrb(sceneGroup, composer.getVariable("orbBar"))

  addSockets(sceneGroup)
  addSeals(sceneGroup)

  forge = Forge:new()

  forge:create(sceneGroup)

  for i = 1, 3, 1 do
    local boardPosition = i

    addRune(sceneGroup, display.contentCenterX - offsetX + (offsetX * (i - 1)), display.contentCenterY + offsetY, boardPosition)
  end

  -- FOR TESTING
  local continueButton = display.newText(sceneGroup, "Continue", 800, 300)

  continueButton:addEventListener("touch", handleContinueButtonTouch)
  --

  handleSelectSocketReference = function(event)
    handleSelectSocket(event, sceneGroup)
  end

  handleSelectForgeReference = function(event)
    handleSelectForge(event, sceneGroup)
  end

  Runtime:addEventListener("selectRune", handleSelectRune)
  Runtime:addEventListener("selectSocket", handleSelectSocketReference)
  Runtime:addEventListener("selectForge", handleSelectForgeReference)
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
  for i = 1, #sockets, 1 do
    sockets[i]:disable()
    sockets[i].image:removeSelf()
    sockets[i].image = nil
    sockets[i] = nil
  end

  for i = 1, #runes, 1 do
    if not runes[i].isDestoryed then
      runes[i].group:removeSelf()
      runes[i].group = nil
    end

    runes[i] = nil
  end

  sockets = nil
  runes = nil
  seals = nil

  Runtime:removeEventListener("selectRune", handleSelectRune)
  Runtime:removeEventListener("selectSocket", handleSelectSocketReference)
  Runtime:removeEventListener("selectForge", handleSelectForgeReference)
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
