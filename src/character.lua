local Actor = Actor or require "lib/actor"

local Character = Actor:extend()

function Character:new()
    self.image = love.graphics.newImage("src/textures/idle/char-idle-0.png")
    self.pos = { x = 180, y = 540 }

    self.speed = 200
    self.gravity = 900
    self.jumpSpeed = -450
    self.velocityY = 0
    self.groundY = 540
    
end


function Character:update(dt)
    if love.keyboard.isDown("a") then
        self.pos.x = self.pos.x - self.speed * dt
    end

    if love.keyboard.isDown("d") then
        self.pos.x = self.pos.x + self.speed * dt
    end

    self.velocityY = self.velocityY + self.gravity * dt
    self.pos.y = self.pos.y + self.velocityY * dt

    if self.pos.y >= self.groundY then
        self.pos.y = self.groundY
        self.velocityY = 0
    end
end

function Character:draw()
    love.graphics.draw(self.image, self.pos.x, self.pos.y)
end

function Character:jump()
    if self.pos.y >= self.groundY then
        self.velocityY = self.jumpSpeed
    end
end

return Character