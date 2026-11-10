local AnimatedActor = require "lib/animatedActor"
local Vector = require "lib/vector"
local Bullet = require "src/bullet"

local Character = AnimatedActor:extend()

-- Carga los PNG de una carpeta en orden alfabético.
local function loadFrames(folder)
    local info = love.filesystem.getInfo(folder)

    if not info or info.type ~= "directory" then
        return {}
    end

    local files = love.filesystem.getDirectoryItems(folder)
    table.sort(files)

    local frames = {}

    for _, file in ipairs(files) do
        if file:lower():match("%.png$") then
            table.insert(frames, love.graphics.newImage(folder .. "/" .. file))
        end
    end

    return frames
end

function Character:new()
    -- Inicializa position y scale de AnimatedActor.
    Character.super.new(
        self,
        "src/textures/idle/char-idle-0.png",
        300, 200, 1, 0, 0, 1, 1
    )

    self.scale = Vector(1.5, 1.5)

    self.speed = 200
    self.gravity = 2500
    self.jumpSpeed = -850
    self.velocityY = 0
    self.groundY = 320
    self.jumpWasDown = false
    self.jumpHoldTime = 0
    self.maxJumpHold = 0.25

    self.animations = {
        Idle = { frames = loadFrames("src/textures/idle"), speed = 0.12 },
        Pistol = { frames = loadFrames("src/textures/pistol"), speed = 0.12 },
        Run = { frames = loadFrames("src/textures/run"), speed = 0.08 },
        Jump = { frames = loadFrames("src/textures/jump"), speed = 0.10 },
        Shoot = { frames = loadFrames("src/textures/shoot"), speed = 0.08 },
        ["Run-pistol"] = {
            frames = loadFrames("src/textures/run-pistol"),
            speed = 0.08
        }
    }

    self.effectFrames = loadFrames("src/textures/effect")
    self.effectTime = nil
    self.effectSpeed = 0.05

    self.bullets = {}
    self.facing = 1
    self.hasPistol = true

    self.fireCooldown = 0
    self.fireRate = 0.5
    self.shootTime = 0

    self.currentAnimation = nil
    self.currentFrame = 1
    self.frameTimer = 0
    self.animationLoops = true

    self:setAnimation("Idle", true)
end

function Character:setAnimation(name, loops)
    local animation = self.animations[name]

    if not animation or #animation.frames == 0 then
        return false
    end

    if self.currentAnimation ~= name then
        self.currentAnimation = name
        self.currentFrame = 1
        self.frameTimer = 0
    end

    self.animationLoops = loops
    return true
end

function Character:setAvailableAnimation(names, loops)
    for _, name in ipairs(names) do
        if self:setAnimation(name, loops) then
            return
        end
    end
end

function Character:updateFrames(dt)
    local animation = self.animations[self.currentAnimation]

    if not animation or #animation.frames == 0 then
        return
    end

    self.frameTimer = self.frameTimer + dt

    if self.frameTimer < animation.speed then
        return
    end

    self.frameTimer = 0

    if self.currentFrame < #animation.frames then
        self.currentFrame = self.currentFrame + 1
    elseif self.animationLoops then
        self.currentFrame = 1
    end
end

function Character:update(dt)
    -- Moverse con A y D.
    local moving = false

    if love.keyboard.isDown("a") then
        self.position.x = self.position.x - self.speed * dt
        self.facing = -1
        moving = true
    end

    if love.keyboard.isDown("d") then
        self.position.x = self.position.x + self.speed * dt
        self.facing = 1
        moving = true
    end

    -- Saltar con espacio.
    local spaceDown = love.keyboard.isDown("space")
    local onGround = self.position.y >= self.groundY

    if spaceDown and not self.jumpWasDown and onGround then
        self:jump()
    end

    self.jumpWasDown = spaceDown

    local gravity = self.gravity

    if spaceDown and self.velocityY < 0
        and self.jumpHoldTime < self.maxJumpHold then
        gravity = self.gravity * 0.35
        self.jumpHoldTime = self.jumpHoldTime + dt
    end

    self.velocityY = self.velocityY + gravity * dt
    self.position.y = self.position.y + self.velocityY * dt

    if self.position.y >= self.groundY then
        self.position.y = self.groundY
        self.velocityY = 0
    end

    -- Disparar con F o el botón izquierdo del ratón.
    self.fireCooldown = math.max(0, self.fireCooldown - dt)
    self.shootTime = math.max(0, self.shootTime - dt)

    if self.effectTime then
        self.effectTime = self.effectTime + dt

        if self.effectTime >= #self.effectFrames * self.effectSpeed then
            self.effectTime = nil
        end
    end

    if (love.keyboard.isDown("f") or love.mouse.isDown(1))
        and self.fireCooldown == 0 then
        self:shoot()
        self.fireCooldown = self.fireRate
    end

    -- Actualizar y borrar balas que salen de la pantalla.
    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        bullet:update(dt)

        if bullet:isOffScreen() then
            table.remove(self.bullets, i)
        end
    end

    -- Elegir la animación apropiada.
    if self.shootTime > 0 then
        self:setAvailableAnimation({ "Shoot", "Pistol", "Idle" }, false)
    elseif self.position.y < self.groundY then
        self:setAvailableAnimation({ "Jump", "Pistol", "Idle" }, false)
    elseif moving and self.hasPistol then
        self:setAvailableAnimation(
            { "Run-pistol", "Run", "Pistol", "Idle" },
            true
        )
    elseif moving then
        self:setAvailableAnimation({ "Run", "Idle" }, true)
    else
        self:setAvailableAnimation({ "Pistol", "Idle" }, true)
    end

    self:updateFrames(dt)
end

function Character:shoot()
    local muzzleX = 46.5

    if self.facing == -1 then
        muzzleX = 17.5
    end

    local bulletX = self.position.x + muzzleX * self.scale.x
    local bulletY = self.position.y + 35.5 * self.scale.y

    table.insert(self.bullets, Bullet:new(bulletX, bulletY, self.facing))

    self.shootTime = 6 * 0.08
    self.currentAnimation = nil
    self:setAnimation("Shoot", false)

    if #self.effectFrames > 0 then
        self.effectTime = 0
    end
end

function Character:jump()
    self.velocityY = self.jumpSpeed
    self.jumpHoldTime = 0
end

function Character:draw()
    for _, bullet in ipairs(self.bullets) do
        bullet:draw()
    end

    local animation = self.animations[self.currentAnimation]

    if animation and #animation.frames > 0 then
        local image = animation.frames[self.currentFrame]
        local x = self.position.x
        local scaleX = self.scale.x * self.facing

        if self.facing == -1 then
            x = x + image:getWidth() * self.scale.x
        end

        love.graphics.draw(
            image,
            x,
            self.position.y,
            0,
            scaleX,
            self.scale.y
        )
    end

    if self.effectTime and #self.effectFrames > 0 then
        local frame = math.floor(self.effectTime / self.effectSpeed) + 1
        frame = math.min(frame, #self.effectFrames)

        local image = self.effectFrames[frame]
        local x = self.position.x
        local scaleX = self.scale.x * self.facing

        if self.facing == -1 then
            x = x + image:getWidth() * self.scale.x
        end

        love.graphics.draw(
            image,
            x,
            self.position.y,
            0,
            scaleX,
            self.scale.y
        )
    end
end

return Character