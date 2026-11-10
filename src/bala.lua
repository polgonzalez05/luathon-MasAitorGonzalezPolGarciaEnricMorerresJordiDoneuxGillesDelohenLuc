local AnimatedActor = require "lib/animatedActor"
local Vector = require "lib/vector"

local Bala = AnimatedActor:extend()

function Bala:new(x, y, targetX, targetY)
    Bala.super.new(self, "src/textures/projectile/projectile1.png", x, y, 1, 0, 0, 1, 1)

    self.scale = Vector(1, 1)
    
    local dx = targetX - x 
    self.speedX = dx * 0.8
    self.speedY = 0

end

function Bala:update(dt)
    self.position.x = self.position.x + self.speedX * dt
end

return Bala