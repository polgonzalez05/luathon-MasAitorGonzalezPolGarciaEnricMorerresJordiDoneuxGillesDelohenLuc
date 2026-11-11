local Object = Object or require "lib/classic"

local Background = Object:extend()

function Background:new(path)
  self.image = love.graphics.newImage(path)
end

function Background:draw(progreso)
  local sw, sh = love.graphics.getDimensions()
  local iw, ih = self.image:getDimensions()
  local escala = math.max(sw / iw, sh / ih)
  local y = -(ih * escala - sh) * (progreso or 0)

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.image, (sw - iw * escala) / 2, y, 0, escala, escala)
end

return Background