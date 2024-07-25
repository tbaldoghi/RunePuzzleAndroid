Rune = {
  stoneSprite,
  runeLeft,
  rune,
  group,
  boardPosition,
  socketPosition,
  isSelected = false,
  isDestoryed = false,
  runes = {
    'fire',
    'earth',
    'water',
    'air',
  },
  colors = {
    'blue',
    'green',
    'red',
    'yellow'
  }
}

-- local function touchListener(event)
--   if ( event.phase == "moved" ) then
--     event.target.x = event.x
--     event.target.y = event.y
--     display.getCurrentStage():setFocus(event.target, event.id)

--     local event = { name = "runeMove", target = event.target }

--     Runtime:dispatchEvent(event)
--   elseif ( event.phase == "ended" ) then
--     display.getCurrentStage():setFocus(event.target, nil)

--     local event = { name = "runeDrop", target = event.target }

--     Runtime:dispatchEvent(event)
--   end

--   return true  -- Prevents tap/touch propagation to underlying objects
-- end

local function touchListener(event)
  if event.phase == "ended" then
    event.target.runeInstance.isSelected = not event.target.runeInstance.isSelected

    local event = { name = "selectRune", target = event.target }

    Runtime:dispatchEvent(event)

    if event.target.runeInstance.isSelected then
      local transitionParams = {
        time = 1500,
        alpha = 0.5,
        iterations = -1,
        transition = easing.continuousLoop
      }

      transition.to(event.target, transitionParams)
    end
  end

  return true
end

function Rune:new(o)
  o = o or {}
  self.__index = self

  setmetatable(o, self)

  return o
end

function Rune:create(sceneGroup, x, y, boardPosition)
  self.group = display.newGroup()

  local options = {
    width = 128,
    height = 128,
    numFrames = 12,
    sheetContentWidth = 1536,
    sheetContentHeight = 128,
  }
  local stoneImageSheet = graphics.newImageSheet("assets/images/stone.png", options)
  local runeLeft = self.runes[math.random(#self.runes)]
  local colorLeft = self.colors[math.random(#self.colors)]

  self.boardPosition = boardPosition
  self.stoneSprite = display.newSprite(self.group, stoneImageSheet, { name="stone", start = 1, count = 12 })
  self.stoneSprite:setFrame(12)
  self.runeLeft = display.newImage(self.group, "assets/images/rune_"..runeLeft.."_"..colorLeft.."_left.png")
  self.group.x = x
  self.group.y = y
  self.group.runeInstance = self

  -- self.group:addEventListener("touch", touchListener)
  self.group:addEventListener("touch", touchListener)

  sceneGroup:insert(self.group)
end

function Rune:updateAngle(frame)
  local angle = frame * 22.5

  self.stoneSprite:setFrame(frame)
  self.runeLeft.rotation = angle
end

function Rune:updatePosition(x, y)
  self.group.x = x;
  self.group.y = y;
end

return Rune
