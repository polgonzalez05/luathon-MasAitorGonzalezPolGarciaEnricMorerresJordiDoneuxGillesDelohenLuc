
local Object = Object or require "lib/classic"

local Camera = Object:extend()

local virtualWidth = 1920
local virtualHeight = 1080

function Camera:new(map, target)
  self.map = map
  self.target = target
  self.anclaY = 0.65
  self.tx = 0
  self.ty = 0
  self:update(0)
end

function Camera:mapSize()
  return self.map.width * self.map.tilewidth,
         self.map.height * self.map.tileheight
end

function Camera:update(dt)
  local sw = virtualWidth
  local sh = virtualHeight

  local mw, mh = self:mapSize()
  local t = self.target

  self.tx = math.floor((sw - mw) / 2)

  local cy = t.position.y + (t.height * t.scale.y) / 2
  local camY = sh * self.anclaY - cy

  camY = math.max(sh - mh, camY)

  self.ty = math.floor(camY)
end

function Camera:progress()
  local sh = virtualHeight
  local _, mh = self:mapSize()

  if mh <= sh then return 0 end

  return math.max(0, math.min(1, -self.ty / (mh - sh)))
end

function Camera:attach()
  love.graphics.push()
  love.graphics.translate(self.tx, self.ty)
end

function Camera:detach()
  love.graphics.pop()
end

return Camera
