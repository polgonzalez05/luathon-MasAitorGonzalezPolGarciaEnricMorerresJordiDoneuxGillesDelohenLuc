local AnimatedActor = AnimatedActor or require "lib/animatedActor"
local Vector = Vector or require "lib/vector"
local StateMachine = StateMachine or require "lib/FSM/StateMachine"

local VendingMachine = AnimatedActor:extend()

function VendingMachine:new()
  VendingMachine.super.new(self, "src/textures/vendingMachineSpritesheet.png", 200, 250, 8, 0, 0, 24, 12)


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

  self.ataques = {
    "aereal",
    "throw",
    "barrido"
  }

  bossState = StateMachine()

  bossState:addState("idle", 
  {
    enter = function()
            print("Boss en idle")
            self.espera = love.math.random(self.minT * 100, self.maxT * 100) / 100
    end,

    exit = function()

    end,

    from = {"moving", "atacking", "aereal", "throw", "barrido"}

  })

  bossState:addState("moving", 
  {
    enter = function()
            print("Boss moviendose")
            self.espera = love.math.random(self.minT * 100, self.maxT * 100) / 100
    end,

    exit = function()

    end,

    from = {"idle", "atacking", "aereal", "throw", "barrido"}

  })

  bossState:addState("atacking", 
  {
    enter = function()
            print("Boss atacando")
    end,

    exit = function()
            print("Boss termina de atacar")
    end,

    from = {"moving", "idle", "aereal", "throw", "barrido"}

  })



  bossState:addState("aereal", 
  {
    enter = function()
        self:aerealAttack()
    end,

    exit = function()
        self:terminarAtaque()
    end,

    from = {"moving", "idle", "aereal", "throw", "barrido"},

    parent = "atacking"

  })

  bossState:addState("throw", 
  {
    enter = function()
        self:throwAttack()
    end,

    exit = function()
        self:terminarAtaque()
    end,

    from = {"moving", "idle", "aereal", "throw", "barrido"},

    parent = "atacking"

  })

  bossState:addState("barrido", 
  {
    enter = function()
          self:barridoAttack()
    end,

    exit = function()
    end,

    from = {"moving", "idle", "aereal", "throw", "barrido"},

    parent = "atacking"

  })

  bossState:addState("death", 
  {
    enter = function()
            print("Boss muerto")
    end,

    exit = function()

    end,

    from = {"*"}

  })

  bossState:setInitialState("idle")


end

function VendingMachine:update(dt)

  local estado = bossState.state 

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

      local ancho = love.graphics.getWidth()

      if (self.faseBarrido == "buscarBorde") then

        if (self.forward.x < 0 and self.position.x <= 0) then
          self.position.x = 0
          self.speed = 0
          self.tiempoP = self.esperaP
          self.faseBarrido = "preparar"

        elseif (self.forward.x > 0 and self.position.x + self.width >= ancho) then
          self.position.x = ancho - self.width
          self.speed = 0
          self.tiempoP = self.esperaP
          self.faseBarrido = "preparar"
        end

      elseif (self.faseBarrido == "preparar") then
        self.tiempoP = self.tiempoP - dt
        
        if (self.tiempoP <= 0) then
          self.forward = Vector(-self.forward.x, 0)
          self.speed = self.velocidadBarrido
          self.rot = 0.12 * self.forward.x
          self.faseBarrido = "barrer"
        end

      elseif (self.faseBarrido == "barrer") then

        if (self.forward.x > 0 and self.position.x + self.width >= ancho) then
          self.position.x = ancho - self.width
          self:terminarAtaque()

        elseif (self.forward.x < 0 and self.position.x <= 0) then
          self.position.x = 0
          self:terminarAtaque()
        end

      end
    end
  end

  bossState:tick(dt)

end

function VendingMachine:draw()
    VendingMachine.super.draw(self)
end

function VendingMachine:elegirAtaque()
  local n = love.math.random(1, #self.ataques)

  bossState:changeStateToAtNextTick(self.ataques[n])
end

function VendingMachine:siguienteEstado()
  local prob = love.math.random(1, 100)

  if (prob <= self.probabilidadIdle) then
    bossState:changeStateToAtNextTick("idle")
  elseif (prob <= self.probabilidadIdle + self.probabilidadWalk) then
    bossState:changeStateToAtNextTick("moving")
  else
    self:elegirAtaque()
  end

end

function VendingMachine:terminarAtaque()
  self.speed = 0
  self.rot = 0
  self.faseBarrido = ""
  self.ataqueTerminado = true
end

function VendingMachine:aerealAttack()
    print("esta haciendo un ataque aereo")
    self:terminarAtaque()
end

function VendingMachine:throwAttack()

    print("Esta haciendo el ataque de lanzamiento")
self:terminarAtaque()
end


function VendingMachine:barridoAttack()
  print("Esta haciendo el ataque de barrido")

  local ancho = love.graphics.getWidth()

  if (self.position.x < 0) then
    self.position.x = 0
  elseif (self.position.x + self.width > ancho) then
    self.position.x = ancho -self.width
  end

  local dI = self.position.x
  local dD = ancho - (self.position.x + self.width)

  self.speed = self.velocidadBarrido
  self.rot = 0

  if (dI < dD) then
    self.forward = Vector(-1, 0)
  else
    self.forward = Vector(1, 0)
  end

  self.faseBarrido = "buscarBorde"

end

return VendingMachine



