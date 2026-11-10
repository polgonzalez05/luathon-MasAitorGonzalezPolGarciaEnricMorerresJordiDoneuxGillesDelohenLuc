local Object = Object or require "lib/classic"
local Vector = Vector or require "lib/vector"

local Proyectil = Object:extend()

function Proyectil:new(x, y, targetX, targetY)
    self.position = Vector(x,y)

    local dir = Vector(targetX-x, targetY-y)
    self.forward = dir:normalized()
    self.speed = 400
    self.radius = 15

end

function Proyetil:draw()
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius)
end

return Proyectil