local AnimatedActor = AnimatedActor or require "lib/animatedActor"
local Vector = Vector or require "lib/vector"
local StateMachine = StateMachine or require "lib/FSM/StateMachine"

local VendingMachine = AnimatedActor:extend()

function VendingMachine:new()
  VendingMachine.super.new(self, "src/textures/vendingMachineSpritesheet.png", 20, 20, 8, 0, 0, 24, 12)


  self.espera = math.random(30, 200) / 100

  self.maxT = 2
  self.minT = 0.3

  self.ataqueTerminado = false

  self.probabilidadIdle = 30
  self.probabilidadWalk = 30
  self.probabilidadAttack = 40

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
            self.espera = math.random(self.minT * 100, self.maxT * 100) / 100
    end,

    exit = function()

    end,

    from = {"moving", "atacking", "aereal", "throw", "barrido"}

  })

  bossState:addState("moving", 
  {
    enter = function()
            print("Boss moviendose")
            self.espera = math.random(self.minT * 100, self.maxT * 100) / 100
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
          self:terminarAtaque()
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
  VendingMachine.super.update(self, dt)

  local estado = bossState.state 

  if (estado == "idle" or estado == "moving") then
    self.espera = self.espera - dt

    if (self.espera <= 0) then
      self:elegirAtaque()
    end

  elseif (estado == "aereal" or estado == "throw" or estado == "barrido") then
    if (self.ataqueTerminado) then
      self.ataqueTerminado = false
      self:siguienteEstado()
    end
  end

  bossState:tick(dt)

end

function VendingMachine:draw()
    VendingMachine.super.draw(self)
end

function VendingMachine:elegirAtaque()
  local n = math.random(1, #self.ataques)

  bossState:changeStateToAtNextTick(self.ataques[n])
end

function VendingMachine:siguienteEstado()
  local prob = math.random(1, 100)

  if (prob <= self.probabilidadIdle) then
    bossState:changeState("idle")
  elseif (prob <= self.probabilidadIdle + self.probabilidadWalk) then
    bossState:changeState("moving")
  else
    self:elegirAtaque()
  end

end

function VendingMachine:terminarAtaque()
  self.ataqueTerminado = true
  self:siguienteEstado()
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
self:terminarAtaque()
end

return VendingMachine



