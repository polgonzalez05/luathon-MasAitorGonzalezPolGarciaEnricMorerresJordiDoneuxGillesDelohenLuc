local Actor = Actor or require "lib/actor"
local Vector = Vector or require "lib/vector"

local Character = Actor:extend()

function Character:new()
  Character.super.new(self, "src/textures/Character.png", 180, 540, 0)
  self.rot = math.pi
  self.actualTime = 0
  self.cooldown = 0.3
end

function Character:update(dt)
    if (love.keyboard.IsDown("a")) then
        self.pos.x = self.pos.x - 200 * dt
    end
    if (love.keyboard.IsDown("d")) then
        self.pos.x = self.pos.x + 200 * dt
    end
    if (love.keyboard.isDown(keyboard.keys["space"])) then
        self.actualTime = self.actualTime + dt
        if (self.actualTime >= self.cooldown) then
            self.actualTime = 0
            self:shoot()
        end
    end

end

function Character:draw()
end

return Character



