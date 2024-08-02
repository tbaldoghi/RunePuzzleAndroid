local runes = require("consts.runes")
local colors = require("consts.colors")

Rune = {
  stoneSprite,
  rune,
  runeType,
  colorType,
  group,
  boardPosition,
  socketPosition,
  isSelected = false,
  isDestoryed = false
}

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
  self.runeType = runes[math.random(#runes)]
  self.colorType = colors[math.random(#colors)]

  self.boardPosition = boardPosition
  self.stoneSprite = display.newSprite(self.group, stoneImageSheet, { name="stone", start = 1, count = 12 })
  self.stoneSprite:setFrame(12)
  self.rune = display.newImage(self.group, "assets/images/rune_"..self.runeType.."_"..self.colorType..".png")
  self.group.x = x
  self.group.y = y
  self.group.runeInstance = self

  self.group:addEventListener("touch", touchListener)

  sceneGroup:insert(self.group)
end

function Rune:updateAngle(frame)
  local angle = frame * 22.5

  self.socketPosition = frame
  self.stoneSprite:setFrame(frame)
  self.rune.rotation = angle
end

function Rune:updatePosition(x, y)
  self.group.x = x;
  self.group.y = y;
end

function Rune:disable()
  self.group:removeEventListener("touch", touchListener)
end

function Rune:hide()
  local transitionParams = {
    time = 1500,
    xScale = 0,
    yScale = 0,
    iterations = -1,
    transition = easing.linear
  }

  transition.scaleTo(self.group, transitionParams)
end

return Rune
