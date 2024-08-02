Socket = {
  hasRune = false,
  boardPosition,
  image
}

local function touchListener(event)
  if event.phase == "ended" then
    local event = { name = "selectSocket", target = event.target }

    Runtime:dispatchEvent(event)
  end

  return true
end

function Socket:new(o)
  o = o or {}
  self.__index = self

  setmetatable(o, self)

  return o
end

function Socket:create(sceneGroup, x, y, boardPosition)
  self.image = display.newImage(sceneGroup, "assets/images/socket.png")
  self.image.x = x
  self.image.y = y
  self.boardPosition = boardPosition
  self.image.socketInstance = self

  self.image:addEventListener("touch", touchListener)
end

function Socket:disable()
  self.image:removeEventListener("touch", touchListener)
end

return Socket
