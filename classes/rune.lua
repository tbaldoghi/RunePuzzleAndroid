Rune = {
  stoneSprite,
  group
}

local function tapListener(event)
  if ( event.phase == "moved" ) then
    event.target.x = event.x
    event.target.y = event.y
    display.getCurrentStage():setFocus(event.target, event.id)

    local event = { name = "dropRune", target = event.target }

    Runtime:dispatchEvent(event)
  elseif ( event.phase == "ended" ) then
    display.getCurrentStage():setFocus(event.target, nil)
  end

  return true  -- Prevents tap/touch propagation to underlying objects
end

function Rune:new(o)
  o = o or {}
  self.__index = self

  setmetatable(o, self)

  return o
end

function Rune:create(sceneGroup, x, y)
  self.group = display.newGroup()

  local options = {
    width = 128,
    height = 128,
    numFrames = 12,
    sheetContentWidth = 1536,
    sheetContentHeight = 128,
  }
  local imageSheet = graphics.newImageSheet("assets/images/stone.png", options)

  self.stoneSprite = display.newSprite(self.group, imageSheet, { name="stone", start = 1, count = 12 })
  self.stoneSprite:setFrame(12)
  self.group.x = x
  self.group.y = y
  self.group.runeInstance = self

  self.group:addEventListener("touch", tapListener)

  sceneGroup:insert(self.group)
end

function Rune:updateAngle(frame)
  print(frame)
  self.stoneSprite:setFrame(frame)
end

return Rune
