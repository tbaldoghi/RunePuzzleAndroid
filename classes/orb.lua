Orb = {
  value = 1,
  images = {}
}

function Orb:new(o)
  o = o or {}
  self.__index = self

  setmetatable(o, self)

  return o
end

function Orb:create(sceneGroup)
  self:renderOrb(sceneGroup, self.value)

  -- self.image.orbInstance = self
end

function Orb:renderOrb(sceneGroup, fill)
  self.value = fill

  for i = 1, #self.images, 1 do
    display.remove(self.images[i])
  end

  self.images = {}

  if self.value < 5 then
    for i = self.value, 4, 1 do
      local sheetOptions = {
        width = 256,
        height = 64,
        numFrames = 4
      }
      local imageSheet = graphics.newImageSheet("assets/images/orb.png", sheetOptions)
      local options = {
        name = "orb"..i,
        start = i,
        count = 1,
        time = 0,
        loopCount = 0
      }
      local sprite = display.newSprite(sceneGroup, imageSheet, options)

      sprite.x = 200
      sprite.y = 32 + i * 64

      table.insert(self.images, sprite)
    end
  end

end

return Orb
