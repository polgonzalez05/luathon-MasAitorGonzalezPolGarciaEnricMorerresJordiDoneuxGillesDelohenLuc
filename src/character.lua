local AnimatedActor = require "lib/animatedActor"
local Vector = require "lib/vector"
local Bala = require "src/bala"

local Character = AnimatedActor:extend()

function Character:new(boss)
    Character.super.new(self, "src/textures/player/idle/idle.png", 700, 500, 8, 0, 0, 4, 1)

    self.animations = {
        idle = {"src/textures/player/idle/idle.png", 4, 8, true},
        run = {"src/textures/player/run/run.png", 4, 10, true},
        jump = {"src/textures/player/jump/char-jump-0.png", 1, 1, false},
        landing = {"src/textures/player/jump/char-fall-0.png", 1, 1, false},
        runGun = {"src/textures/player/run-pistol/run-pistol.png", 4, 10, true},
        shoot = {"src/textures/player/shoot/shoot.png", 6, 12, false}
    }

    self.currentAnimation = ""

    self:setCharacterAnimation("idle")

    self.boss = boss
    self.daño = 1511 -- Daño BALAS
    self.scale = Vector(1.5, 1.5)

    -- Spawn Incio
    -- local sueloY = 99 * 32
    -- self.position.x = (34 * 32 - self.width * self.scale.x) / 2
    -- self.position.y = sueloY - self.height * self.scale.y
    -- self.groundY = self.position.y
    --
    
    -- Spawn del boss
    self.position.x, self.position.y, self.groundY = 700, 500, 500
    --
    self.speed = 200
    self.gravity = 2500
    self.jumpSpeed = -750
    self.velocityY = 0

    self.maxJumpHold = 0.25
    self.jumpHoldTime = 0
    self.jumpWasDown = false

    self.facing = 1

    self.hasPistol = true
    
    self.fireRate = 0.5
    self.fireCooldown = 0

    self.projectiles = {}

    self.vida = 1
    self.dañoCooldown = 2
    self.tCooldown = 0
    self.alive = true

    self.parpadeo = 0

    self.wasInAir = false
    self.shootTimer = 0

    self.hitboxOffsetX = 30
    self.hitboxOffsetY = 20
end


function Character:update(dt)

    if not self.alive then
        return
    end

    local spaceDown = love.keyboard.isDown("space")
    local moving = false

    if (love.keyboard.isDown("a") and self.position.x>= 0) then
        self.position.x = self.position.x - self.speed * dt
        self.facing = -1
        moving = true
    end

    if (love.keyboard.isDown("d") and self.position.x<= 992) then
        self.position.x = self.position.x + self.speed * dt
        self.facing = 1
        moving = true
    end

    if (spaceDown and not self.jumpWasDown and self.position.y >= self.groundY) then
        self:jump()
    end

    self.jumpWasDown = spaceDown

    local gravity = self.gravity

    if (spaceDown and self.velocityY < 0 and self.jumpHoldTime < self.maxJumpHold) then
        gravity = self.gravity * 0.35
        self.jumpHoldTime = self.jumpHoldTime + dt
    end

    self.velocityY = self.velocityY + gravity * dt
    self.position.y = self.position.y + self.velocityY * dt

    if (self.position.y >= self.groundY) then
        self.position.y = self.groundY
        self.velocityY = 0
    end

    local inAir = self.position.y < self.groundY

    if (self.wasInAir and not inAir) then
        self:setCharacterAnimation("landing")
    end

    self.wasInAir = inAir

    if (self.shootTimer > 0) then
        self:setCharacterAnimation("shoot")
    elseif (inAir) then
        self:setCharacterAnimation("jump")
    elseif (self.currentAnimation == "landing" and not self.animationFinished) then

    elseif (moving) then
        self:setCharacterAnimation("run")
    else
        self:setCharacterAnimation("idle")
    end

    self.fireCooldown = math.max(0, self.fireCooldown - dt)
    self.shootTimer = math.max(0, self.shootTimer - dt)

    if ((love.keyboard.isDown("f") or love.mouse.isDown(1)) and self.fireCooldown <= 0) then
        self:shoot()
        self.fireCooldown = self.fireRate
        self.shootTimer = 0.25
    end

    for i = #self.projectiles, 1, -1 do
        self.projectiles[i]:update(dt)

        if (self.projectiles[i]:checkCollision(self.boss)) then
            print("BALA HA IMPACTADO")
            self.boss:restarVida(self.daño)
            print("VIDA DEL BOSS: " .. self.boss.vida)
            table.remove(self.projectiles, i)

        elseif (self.projectiles[i].position.x <= 30 or self.projectiles[i].position.x > 1050) then
            table.remove(self.projectiles, i)
        end
    end

    self.tCooldown = math.max(0, self.tCooldown - dt)

    if (self:checkCollision(self.boss)) then
        self:recibirDaño(1)
    end

    self.parpadeo = math.max(0, self.parpadeo - dt)

    Character.super.update(self, dt)
end

function Character:shoot()
    soundManager:play("shoot")
    local offsetX = 30

    local x = self.position.x + offsetX * self.scale.x
    local y = self.position.y + 36 * self.scale.y

    local targetX = x + self.facing * 1000
    local targetY = y

    table.insert(self.projectiles, Bala(x, y, targetX, targetY))
        
end

function Character:setCharacterAnimation(name)
    if self.currentAnimation == name then
        return
    end

    local anim = self.animations[name]

    self:setAnimation(anim[1], anim[2], anim[3], anim[4])
    self.currentAnimation = name
end

function Character:jump()
    soundManager:play("jump")
    if self.position.y >= self.groundY then
        self.velocityY = self.jumpSpeed
        self.jumpHoldTime = 0
    end
end

function Character:recibirDaño(n)
    if(self.tCooldown > 0 or not self.alive) then
        return
    end
    soundManager:play("hurt")
    self.vida = self.vida - n
    self.parpadeo = self.dañoCooldown
    self.tCooldown = self.dañoCooldown

    if (self.vida <= 0) then
        self.vida = 0
        self.alive = false
        print("MUERTO")
    end
end


function Character:draw()
    local drawX = self.position.x + self.origin.x * self.scale.x
    local drawY = self.position.y + self.origin.y * self.scale.y

    if (self.parpadeo > 0 and math.floor(self.parpadeo * 8) % 2 == 0) then
        love.graphics.setColor(1,1,1,0)
    else
        love.graphics.setColor(1,1,1,1)
    end


    love.graphics.draw(self.image, self.frames[math.floor(self.actFrame)],
        drawX, drawY, 0,
        self.scale.x * self.facing, self.scale.y,
        self.facing == -1 and self.width - self.origin.x or self.origin.x,
        self.origin.y)

    love.graphics.setColor(1,1,1,1)

    for _, projectile in ipairs(self.projectiles) do 
        projectile:draw()
    end
end

return Character