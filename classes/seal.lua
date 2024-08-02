local runes = require("consts.runes")
local colors = require("consts.colors")

Seal = {
  runeType,
  colorType,
  sealType,
  boardPosition,
  image
}

function Seal:new(o)
  o = o or {}
  self.__index = self

  setmetatable(o, self)

  return o
end

function Seal:create(sceneGroup, x, y, boardPosition, type)
  local angle = boardPosition * 22.5
  self.sealType = type
  self.boardPosition = boardPosition

  if self.sealType == 'rune' then
    self.runeType = runes[math.random(#runes)]
    self.image = display.newImage(sceneGroup, "assets/images/seal_"..self.runeType..".png")
  elseif self.sealType == 'color' then
    self.colorType = colors[math.random(#colors)]
    self.image = display.newImage(sceneGroup, "assets/images/seal_"..self.colorType..".png")
  end

  self.image.x = x
  self.image.y = y
  self.image.rotation = angle
  self.image.sealInstance = self
end

return Seal
