local AnimatedActor = require "lib/animatedActor"
local Vector = require "lib/vector"

local Character = AnimatedActor:extend()

local function loadFrames(folder)
    local info = love.filesystem.getInfo(folder)

    if not info or info.type ~= "directory" then
        return {}
    end

    local files = love.filesystem.getDirectoryItems(folder)

    table.sort(files, function(a, b)
        local numberA = tonumber(a:match("(%d+)%.[Pp][Nn][Gg]$")) or 0
        local numberB = tonumber(b:match("(%d+)%.[Pp][Nn][Gg]$")) or 0

        if numberA == numberB then
            return a < b
        end

        return numberA < numberB
    end)

    local frames = {}

    for _, file in ipairs(files) do
        if file:lower():match("%.png$") then
            frames[#frames + 1] =
                love.graphics.newImage(folder .. "/" .. file)
        end
    end

    return frames
end

local function makeAnimation(folder, frameTime)
    return {
        frames = loadFrames(folder),
        speed = frameTime
    }
end

function Character:new()
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

    self.maxJumpHold = 0.25
    self.jumpHoldTime = 0
    self.jumpWasDown = false

    self.animations = {
        Idle = makeAnimation("src/textures/idle", 0.12),
        Pistol = makeAnimation("src/textures/pistol", 0.12),
        Run = makeAnimation("src/textures/run", 0.08),
        Jump = makeAnimation("src/textures/jump", 0.10),
        Shoot = makeAnimation("src/textures/shoot", 0.08),
        ["Run-pistol"] = makeAnimation("src/textures/run-pistol", 0.08)
    }

    self.effectFrames = loadFrames("src/textures/effect")
    self.projectileFrames = loadFrames("src/textures/projectile")

    self.projectiles = {}
    self.effects = {}

    self.hasPistol = true
    self.facing = 1

    self.fireRate = 0.5
    self.fireCooldown = 0
    self.shootTimer = 0
    self.effectFrameTime = 0.05

    self.currentAnimation = nil
    self.currentFrame = 1
    self.frameTimer = 0
    self.animationLoop = true

    self:playAnimation("Idle", true)
end

function Character:playAnimation(name, loop)
    local animation = self.animations[name]

    if not animation or #animation.frames == 0 then
        return false
    end

    if self.currentAnimation ~= name then
        self.currentAnimation = name
        self.currentFrame = 1
        self.frameTimer = 0
    end

    self.animationLoop = loop
    return true
end

function Character:playFirstAvailable(names, loop)
    for _, name in ipairs(names) do
        if self:playAnimation(name, loop) then
            return
        end
    end
end

function Character:updateAnimation(dt)
    local animation = self.animations[self.currentAnimation]

    if not animation or #animation.frames == 0 then
        return
    end

    self.frameTimer = self.frameTimer + dt

    while self.frameTimer >= animation.speed do
        self.frameTimer = self.frameTimer - animation.speed

        if self.currentFrame < #animation.frames then
            self.currentFrame = self.currentFrame + 1
        elseif self.animationLoop then
            self.currentFrame = 1
        else
            self.currentFrame = #animation.frames
            self.frameTimer = 0
            break
        end
    end
end

function Character:updateProjectiles(dt)
    local screenWidth = love.graphics.getWidth()

    for i = #self.projectiles, 1, -1 do
        local projectile = self.projectiles[i]

        projectile.x = projectile.x
            + projectile.direction * projectile.speed * dt
        projectile.time = projectile.time + dt

        if projectile.x < -100 or projectile.x > screenWidth + 100 then
            table.remove(self.projectiles, i)
        end
    end

    for i = #self.effects, 1, -1 do
        local effect = self.effects[i]
        effect.time = effect.time + dt

        if effect.time >= #self.effectFrames * self.effectFrameTime then
            table.remove(self.effects, i)
        end
    end
end

function Character:update(dt)
    local spaceDown = love.keyboard.isDown("space")
    local onGround = self.position.y >= self.groundY

    if spaceDown and not self.jumpWasDown and onGround then
        self:jump()
    end

    self.jumpWasDown = spaceDown

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

    self.fireCooldown = math.max(0, self.fireCooldown - dt)

    local fireDown =
        love.keyboard.isDown("f") or love.mouse.isDown(1)

    if fireDown and self.fireCooldown <= 0 then
        self:shoot()
        self.fireCooldown = self.fireRate
    end

    self.shootTimer = math.max(0, self.shootTimer - dt)
    self:updateProjectiles(dt)

    if self.shootTimer > 0 then
        self:playFirstAvailable({ "Shoot", "Pistol", "Idle" }, false)
    elseif self.position.y < self.groundY then
        self:playFirstAvailable({ "Jump", "Pistol", "Idle" }, false)
    elseif moving and self.hasPistol then
        self:playFirstAvailable(
            { "Run-pistol", "Run", "Pistol", "Idle" },
            true
        )
    elseif moving then
        self:playFirstAvailable({ "Run", "Idle" }, true)
    elseif self.hasPistol then
        self:playFirstAvailable({ "Pistol", "Idle" }, true)
    else
        self:playAnimation("Idle", true)
    end

    self:updateAnimation(dt)
end

function Character:shoot()
    local shootAnimation = self.animations["Shoot"]

    if shootAnimation and #shootAnimation.frames > 0 then
        self.shootTimer = #shootAnimation.frames * shootAnimation.speed

        self.currentAnimation = nil
        self:playAnimation("Shoot", false)
    end

    local offsetX

    if self.facing == 1 then
        offsetX = 46.5
    else
        offsetX = 17.5
    end

    local muzzleX = self.position.x + offsetX * self.scale.x
    local muzzleY = self.position.y + 35.5 * self.scale.y

    if #self.effectFrames > 0 then
        table.insert(self.effects, {
            x = self.position.x,
            y = self.position.y,
            direction = self.facing,
            time = 0
        })
    end

    if #self.projectileFrames > 0 then
        table.insert(self.projectiles, {
            x = muzzleX,
            y = muzzleY,
            direction = self.facing,
            speed = 650,
            time = 0
        })
    end
end

function Character:jump()
    if self.position.y >= self.groundY then
        self.velocityY = self.jumpSpeed
        self.jumpHoldTime = 0
    end
end

function Character:draw()
    for _, projectile in ipairs(self.projectiles) do
        local frameNumber =
            math.floor(projectile.time / 0.08) % #self.projectileFrames + 1
        local image = self.projectileFrames[frameNumber]

        love.graphics.draw(
            image,
            projectile.x,
            projectile.y,
            0,
            1.5 * projectile.direction,
            1.5,
            image:getWidth() / 2,
            image:getHeight() / 2
        )
    end

    -- Dibuja el personaje.
    local animation = self.animations[self.currentAnimation]

    if animation and #animation.frames > 0 then
        local image = animation.frames[self.currentFrame]
        local drawX = self.position.x
        local scaleX = self.scale.x * self.facing

        if self.facing < 0 then
            drawX = drawX + image:getWidth() * self.scale.x
        end

        love.graphics.draw(
            image,
            drawX,
            self.position.y,
            0,
            scaleX,
            self.scale.y
        )
    end

    for _, effect in ipairs(self.effects) do
        if #self.effectFrames > 0 then
            local frameNumber =
                math.floor(effect.time / self.effectFrameTime) + 1

            frameNumber = math.min(frameNumber, #self.effectFrames)

            local image = self.effectFrames[frameNumber]
            local drawX = effect.x
            local scaleX = self.scale.x * effect.direction

            if effect.direction < 0 then
                drawX = drawX + image:getWidth() * self.scale.x
            end

            love.graphics.draw(
                image,
                drawX,
                effect.y,
                0,
                scaleX,
                self.scale.y
            )
        end
    end
end

return Character