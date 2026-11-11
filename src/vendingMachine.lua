local AnimatedActor = AnimatedActor or require "lib/animatedActor"
local Vector = Vector or require "lib/vector"
local StateMachine = StateMachine or require "lib/FSM/StateMachine"
local Proyectil = Proyectil or require "src/proyectil"

local VendingMachine = AnimatedActor:extend()

function VendingMachine:new(character, soundManager)
  VendingMachine.super.new(self, "src/textures/boss/vendingMachineSpritesheet.png", 480, 458, 8, 0, 0, 24, 12)

  self.proyectiles = {}

  self.character = character
  self.soundManager = soundManager

  self.espera = love.math.random(30, 200) / 100

  self.maxT = 2
  self.minT = 0.3
  self.ataqueTerminado = false

  self.probabilidadIdle = 30
  self.probabilidadWalk = 30
  self.probabilidadAttack = 40 

  self.velocidadBarrido = 500
  self.faseBarrido = ""
  self.direccionBarrido = 1
  self.esperaP = 0.6
  self.tiempoP = 0

  self.sueloY = self.position.y
  self.faseAereo = ""

  self.alturaAerea = 250
  self.velocidadVuelo = 700
  self.velocidadCaida = 1400
  self.esperaAereo = 0.5
  self.tiempoAereo = 0
  self.rangoAereo = 80
  self.objetivoX = 0
  self.objetivoY = 0

  self.ataques = {
    "aereal",
    "throw",
    "barrido"
  }

  self.animations = {
        idle = {"src/textures/boss/idle.png", 4, 10, true},
        idleBroken = {"src/textures/boss/idleBroken.png", 4, 6, true},
        transformation = {"src/textures/boss/Transformation.png", 24, 12, false},
        turn = {"src/textures/boss/Turn.png", 5, 10, false}
  }

  self.currentAnimation = ""
  self:setCharacterAnimation("transformation")

  self.scale = Vector(-1,1)

  self.vidaMax = 1000
  self.vida = self.vidaMax
  self.vivo = true

  self.hitboxOffsetX = 35
  self.hitboxOffsetY = 10

  self.repeticionesAereo = 0

  self.firstTime = true

  self.bossState = StateMachine()

  self.bossState:addState("idle", 
  {
    enter = function()
            print("Boss en idle")
            if(self.firstTime) then
              self:setCharacterAnimation("transformation")
            else
              self:setCharacterAnimation("idleBroken")
            end

            self.espera = love.math.random(self.minT * 100, self.maxT * 100) / 100
    end,

    exit = function()
      
    end,

    from = {"moving", "atacking", "aereal", "throw", "barrido"}

  })

  self.bossState:addState("moving", 
  {
    enter = function()
            print("Boss moviendose")
            self:setCharacterAnimation("idleBroken")
            self.espera = love.math.random(self.minT * 100, self.maxT * 100) / 100
    end,

    exit = function()

    end,

    from = {"idle", "atacking", "aereal", "throw", "barrido"}

  })

  self.bossState:addState("atacking", 
  {
    enter = function()
            print("Boss atacando")
    end,

    exit = function()
            print("Boss termina de atacar")
    end,

    from = {"moving", "idle", "aereal", "throw", "barrido"}

  })



  self.bossState:addState("aereal", 
  {
    enter = function()
      self.repeticionesAereo = love.math.random(1, 5)
        self:aerealAttack()
    end,

    exit = function()
    end,

    from = {"moving", "idle", "aereal", "throw", "barrido"},

    parent = "atacking"

  })

  self.bossState:addState("throw", 
  {
    enter = function()
        self:throwAttack()
    end,

    exit = function()
    end,

    from = {"moving", "idle", "aereal", "throw", "barrido"},

    parent = "atacking"

  })

  self.bossState:addState("barrido", 
  {
    enter = function()
          self:barridoAttack()
    end,

    exit = function()
    end,

    from = {"moving", "idle", "aereal", "throw", "barrido"},

    parent = "atacking"

  })

  self.bossState:addState("death", 
  {
    enter = function()
            print("Boss muerto")
    end,

    exit = function()

    end,

    from = {"*"}

  })

  self.bossState:setInitialState("idle")


end

function VendingMachine:update(dt)

  local estado = self.bossState.state 

  if(self.firstTime) then 
    self.speed = 0
    VendingMachine.super.update(self, dt)

    if(self.animationFinished) then
      self.firstTime = false
      self.espera = love.math.random(self.minT * 100, self.maxT * 100) / 100
    end

    self.bossState:tick(dt)
    return
  end

  -- Si el ataque ha terminado, preparamos el siguiente estado
  if (self.ataqueTerminado) then
    self.ataqueTerminado = false
    self:siguienteEstado()

  else

    -- Primero movemos al boss
    VendingMachine.super.update(self, dt)

    if (estado == "idle" or estado == "moving") then
      self.espera = self.espera - dt

      if (self.espera <= 0) then
        self:elegirAtaque()
      end

    elseif (estado == "barrido") then

      local ancho = 1088

      if (self.faseBarrido == "buscarBorde") then

        if (self.forward.x < 0 and self.position.x <= 0) then
          self.position.x = 0
          self.speed = 0

          self.direccionBarrido = 1

          self.faseBarrido = "preparar"
          self:setCharacterAnimation("turn")

        elseif (self.forward.x > 0 and self.position.x + self.width >= ancho) then
          self.position.x = ancho - self.width
          self.speed = 0

          self.direccionBarrido = -1

          self.faseBarrido = "preparar"
          self:setCharacterAnimation("turn")
        end

      elseif (self.faseBarrido == "preparar") then
        
        self.speed = 0
        self.rot = 0

        if(self.animationFinished) then

          self:setDirection(self.direccionBarrido)

          self.speed = self.velocidadBarrido
          self.rot = 0.12 * self.direccionBarrido

          self.faseBarrido = "barrer"
        end

      elseif (self.faseBarrido == "barrer") then
        self.soundManager:setVolume("arrastre", 0.3)
        self.soundManager:playLoop("arrastre")
        if (self.forward.x > 0 and self.position.x + self.width >= ancho) then
          self.position.x = ancho - self.width
          self:terminarAtaque()
          self.soundManager:setVolume("arrastre", 0)
        elseif (self.forward.x < 0 and self.position.x <= 0) then
          self.position.x = 0
          self.soundManager:stop("arrastre", 0)
          self:terminarAtaque()
        end

      end
    elseif (estado == "aereal") then
      
      self:setCharacterAnimation("idleBroken")

      if (self.faseAereo == "volar") then
        local dx = self.objetivoX - self.position.x
        local dy = self.objetivoY - self.position.y
        local dist = math.sqrt(dx * dx + dy * dy)
        local paso = self.velocidadVuelo * dt

        if (dist <= paso) then
          self.position.x = self.objetivoX
          self.position.y = self.objetivoY
          self.tiempoAereo = self.esperaAereo
          self.faseAereo = "esperar"
        else
          self.position.x = self.position.x + dx / dist * paso
          self.position.y = self.position.y + dy / dist * paso
        end

      elseif (self.faseAereo == "esperar") then
        self.tiempoAereo = self.tiempoAereo - dt
        
        if (self.tiempoAereo <= 0) then
          self.faseAereo = "caer"
        end
      elseif (self.faseAereo == "caer") then
        self.position.y = self.position.y + self.velocidadCaida * dt
        if (self.position.y >= self.sueloY) then
          self.position.y = self.sueloY
          
          self.soundManager:play("stomp")
          self.soundManager:setVolume("stomp", 0.2)

          self.repeticionesAereo = self.repeticionesAereo - 1

          if (self.repeticionesAereo > 0) then
            self:aerealAttack()
          else
            self:terminarAtaque()
          end
        end
      end
    end
  end
  
  for i = #self.proyectiles, 1, -1 do
    self.proyectiles [i]:update(dt)
    if (self.proyectiles[i]:checkCollision(self.character)) then
      self.character:recibirDaño(1)
      table.remove(self.proyectiles, i)

    elseif (self.proyectiles[i].position.y > love.graphics.getHeight() + 100) then
      table.remove(self.proyectiles, i)
    end
  end

  self.bossState:tick(dt)

end

function VendingMachine:draw()
    VendingMachine.super.draw(self)

    for _, proyectil in ipairs(self.proyectiles) do
      proyectil:draw()
    end
end

function VendingMachine:elegirAtaque()
  local n = love.math.random(1, #self.ataques)

  self.bossState:changeStateToAtNextTick(self.ataques[n])
end

function VendingMachine:siguienteEstado()
  local prob = love.math.random(1, 100)

  if (prob <= self.probabilidadIdle) then
    self.bossState:changeStateToAtNextTick("idle")
  elseif (prob <= self.probabilidadIdle + self.probabilidadWalk) then
    self.bossState:changeStateToAtNextTick("moving")
  else
    self:elegirAtaque()
  end

end

function VendingMachine:terminarAtaque()
  self.speed = 0
  self.rot = 0
  self.faseBarrido = ""
  self.faseAereo = ""
  self:setCharacterAnimation("idleBroken")
  self.ataqueTerminado = true
end

function VendingMachine:aerealAttack()
    print("esta haciendo un ataque aereo")

    self:setCharacterAnimation("idleBroken")

    self.speed = 0
    self.rot = 0
    self.objetivoY = math.max(0, self.sueloY - self.alturaAerea)
    self:elegirObjetivoAereo()
    self.faseAereo = "volar"
end

function VendingMachine:elegirObjetivoAereo()
  local ancho = love.graphics.getWidth()
  local c = self.character

  local centroJugador = c.position.x + c.width * c.scale.x / 2
  local offset = love.math.random(-self.rangoAereo, self.rangoAereo)

  local x = centroJugador + offset - self.width / 2
  self.objetivoX = math.max(0, math.min(ancho - self.width, x))

end


function VendingMachine:throwAttack()

  self:setCharacterAnimation("idleBroken")

  local x = self.position.x + self.width / 2
  local y = self.position.y + self.height / 2

  local targetX = self.character.position.x + self.character.width * self.character.scale.x / 2
  local targetY = self.character.position.y + self.character.height * self.character.scale.y / 2

  self.soundManager:play("chips")
  local proyectil = Proyectil(x, y, targetX, targetY)

  table.insert(self.proyectiles, proyectil)
  self:terminarAtaque()
end


function VendingMachine:barridoAttack()
  print("Esta haciendo el ataque de barrido")

  local ancho = 1088

  if (self.position.x < 0) then
    self.position.x = 0
  elseif (self.position.x + self.width > ancho) then
    self.position.x = ancho - self.width
  end

  local dI = self.position.x
  local dD = ancho - (self.position.x + self.width)

  self.speed = self.velocidadBarrido

  if (dI <= 5) then
    self:setDirection(1)
    self.rot = 0.12
    self.direccionBarrido = 1
    self.faseBarrido = "barrer"
    
  elseif (dD <= 5) then
    self:setDirection(-1)
    self.direccionBarrido = -1
    self.faseBarrido = "buscarBorde"

  else

    if(dI < dD) then
      self:setDirection(-1)
    else
      self:setDirection(1)
    end

    self.faseBarrido = "buscarBorde"
  end

  self.scale = self.scale * Vector(self.forward.x, 1)

end

function VendingMachine:restarVida(value)
  self.vida = math.max(0, self.vida - value)

  if (self.vida <= 0) then
    self.vivo = false
  end
end

function VendingMachine:setCharacterAnimation(name)
    if self.currentAnimation == name then
        return
    end

    local anim = self.animations[name]

    self:setAnimation(anim[1], anim[2], anim[3], anim[4])
    self.currentAnimation = name
end

function VendingMachine:setDirection(direction)
  self.forward = Vector(direction, 0)

    self.scale.x = direction
  end

return VendingMachine