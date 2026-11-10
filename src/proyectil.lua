local AnimatedActor = AnimatedActor or require "lib/actor"
local Vector = Vector or require "lib/vector"

local Proyectil = AnimatedActor:extend()

function Proyectil:new(x, y, targetX, targetY)
    self.position = Vector(x,y)

    local n = love.math.random(1, 3)

    Proyectil.super.new(self, "src/textures/bolsa/bolsa" .. n .. ".png", x, y, 1, 0, 0, 1, 1)
    
    self.scale = Vector(0.07, 0.07)
    local dx = targetX - x
    
    self.speedX = dx * 0.8
    self.speedY = -500
    self.gravity = 900
    self.radius = 15

end

function Proyectil:update(dt)
    self.speedY = self.speedY + self.gravity * dt

    self.position.x = self.position.x + self.speedX * dt
    self.position.y = self.position.y + self.speedY * dt
end

function Proyectil:draw()
    love.graphics.draw(self.image, self.position.x, self.position.y, self.rot,self.scale.x, self.scale.y, self.origin.x, self.origin.y)
end

return Proyectil