local AnimatedActor = AnimatedActor or require "lib/animatedActor"
local Vector = Vector or require "lib/vector"
local StateMachine = StateMachine or require "lib/FSM/StateMachine"

local VendingMachine = AnimatedActor:extend()

function VendingMachine:new()
  VendingMachine.super.new(self, "src/textures/vendingMachineSpritesheet.png", 20, 20, 8, 0, 0, 24, 12)

  bossState = StateMachine()

  bossState:addState("idle", 
  {
    enter = function()
    
    end,

    exit = function()

    end,

    from = {"moving", "atacking"}

  })

  bossState:addState("moving", 
  {
    enter = function()
    
    end,

    exit = function()

    end,

    from = {"idle", "atacking"}

  })

  bossState:addState("atacking", 
  {
    enter = function()
    end,

    exit = function()
    end,

    from = {"moving", "idle"}

  })



  bossState:addState("aereal", 
  {
    enter = function()
      
    end,

    exit = function()

    end,

    from = {"moving", "idle"},

    parent = "atacking"

  })

  bossState:addState("throw", 
  {
    enter = function()
    
    end,

    exit = function()

    end,

    from = {"moving", "idle"},

    parent = "atacking"

  })

  bossState:addState("barrido", 
  {
    enter = function()
    
    end,

    exit = function()

    end,

    from = {"moving", "idle"},

    parent = "atacking"

  })

  bossState:addState("death", 
  {
    enter = function()
    
    end,

    exit = function()

    end,

    from = {"*"}

  })

  bossState:setInitialState("aereal")

end

function VendingMachine:update(dt)
  VendingMachine.super.update(self, dt)

end

function VendingMachine:draw()
    VendingMachine.super.draw(self)
end

return VendingMachine



