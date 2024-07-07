Socket = {
  image
}

function Socket:new(o)
  o = o or {}
  self.__index = self

  setmetatable(o, self)

  return o
end

function Socket:create(sceneGroup, x, y)
  self.image = display.newImage(sceneGroup, "assets/images/socket.png")
  self.image.x = x
  self.image.y = y
end

return Socket
