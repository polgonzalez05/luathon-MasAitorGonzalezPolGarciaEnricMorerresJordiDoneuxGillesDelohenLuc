local Bullet = {}
Bullet.__index = Bullet

local images = nil

local function loadImages()
    if images == nil then
        images = {
            love.graphics.newImage("src/textures/projectile/projectile1.png"),
            love.graphics.newImage("src/textures/projectile/projectile2.png")
        }
    end

    return images
end

function Bullet:new(x, y, direction)
    local bullet = setmetatable({}, Bullet)

    bullet.x = x
    bullet.y = y
    bullet.direction = direction
    bullet.speed = 650
    bullet.scale = 1.5

    bullet.images = loadImages()
    bullet.currentFrame = 1
    bullet.frameTimer = 0
    bullet.frameSpeed = 0.08

    return bullet
end

function Bullet:update(dt)
    self.x = self.x + self.direction * self.speed * dt

    self.frameTimer = self.frameTimer + dt

    if self.frameTimer >= self.frameSpeed then
        self.frameTimer = self.frameTimer - self.frameSpeed
        self.currentFrame = self.currentFrame % #self.images + 1
    end
end

function Bullet:draw()
    local image = self.images[self.currentFrame]

    love.graphics.draw(
        image,
        self.x,
        self.y,
        0,
        self.scale * self.direction,
        self.scale,
        image:getWidth() / 2,
        image:getHeight() / 2
    )
end

function Bullet:isOffScreen()
    return self.x < -50 or self.x > love.graphics.getWidth() + 50
end

function Bullet:getBounds()
    local image = self.images[self.currentFrame]
    local width = image:getWidth() * self.scale
    local height = image:getHeight() * self.scale

    return {
        x = self.x - width / 2,
        y = self.y - height / 2,
        width = width,
        height = height
    }
end

return Bullet