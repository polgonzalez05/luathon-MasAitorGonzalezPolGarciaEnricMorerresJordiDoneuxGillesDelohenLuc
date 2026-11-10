local AnimatedActor = AnimatedActor or require "lib/animatedActor"
local Vector = Vector or require "lib/vector"

local Character = AnimatedActor:extend()

function Character:new()
    Character.super.new(self, "src/textures/idle/char-idle-0.png", 300, 200, 1, 0, 0, 1, 1)
    self.scale = Vector(1.5, 1.5)

    self.speed = 200
    self.gravity = 2000
    self.jumpSpeed = -850
    self.velocityY = 0
    self.groundY = 320
    
end


function Character:update(dt)
    if love.keyboard.isDown("a") then
        self.position.x = self.position.x - self.speed * dt
    end

    if love.keyboard.isDown("d") then
        self.position.x = self.position.x + self.speed * dt
    end

    if love.keyboard.isDown("space") then
        if (self.position.y >= self.groundY) then
            self.velocityY = self.jumpSpeed
        end
    end


    self.velocityY = self.velocityY + self.gravity * dt
    self.position.y = self.position.y + self.velocityY * dt

    if self.position.y >= self.groundY then
        self.position.y = self.groundY
        self.velocityY = 0
    end
end

function Character:draw()
    Character.super.draw(self)
end

function Character:jump()
    if self.position.y >= self.groundY then
        self.velocityY = self.jumpSpeed
    end
end

return Character