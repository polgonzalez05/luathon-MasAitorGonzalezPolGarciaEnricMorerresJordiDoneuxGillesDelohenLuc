local AnimatedActor = AnimatedActor or require "lib/animatedActor"
local Vector = Vector or require "lib/vector"

local Character = AnimatedActor:extend()

function Character:new()
    Character.super.new(self, "src/textures/idle/char-idle-0.png", 300, 200, 1, 0, 0, 1, 1)
    self.scale = Vector(1.5, 1.5)

    self.speed = 200
    self.gravity = 2500
    self.jumpSpeed = -850
    self.velocityY = 0
    self.groundY = 320
    self.maxJumpHold = 0.25 
    self.jumpHoldTime = 0
    self.jumpWasDown = false
end


function Character:update(dt)
    local spaceDown = love.keyboard.isDown("space")
    local onGround = self.position.y >= self.groundY

    if spaceDown and not self.jumpWasDown and onGround then
        self:jump()
    end

    self.jumpWasDown = spaceDown

    if love.keyboard.isDown("a") then
        self.position.x = self.position.x - self.speed * dt
    end

    if love.keyboard.isDown("d") then
        self.position.x = self.position.x + self.speed * dt
    end

    local gravity = self.gravity

    if spaceDown
        and self.velocityY < 0
        and self.jumpHoldTime < self.maxJumpHold then
        gravity = self.gravity * 0.35
        self.jumpHoldTime = math.min(
            self.jumpHoldTime + dt,
            self.maxJumpHold
        )
    end

    self.velocityY = self.velocityY + gravity * dt
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
        self.jumpHoldTime = 0
    end
end

return Character