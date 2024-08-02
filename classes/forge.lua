Forge = {
  image
}

local function touchListener(event)
  if event.phase == "ended" then
    local event = { name = "selectForge", target = event.target }

    Runtime:dispatchEvent(event)
  end

  return true
end

function Forge:new(o)
  o = o or {}
  self.__index = self

  setmetatable(o, self)

  return o
end

function Forge:create(sceneGroup)
  self.image = display.newImage(sceneGroup, "assets/images/forge.png")
  self.image.x = display.contentCenterX
  self.image.y = display.contentCenterY
  self.image.forgeInstance = self

  self.image:addEventListener("touch", touchListener)
end

function Forge:disable()
  self.image:removeEventListener("touch", touchListener)
end

return Forge
