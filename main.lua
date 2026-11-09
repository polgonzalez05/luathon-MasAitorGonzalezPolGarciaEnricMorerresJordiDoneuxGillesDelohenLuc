local Vector = Vector or require "lib/vector"
local Actor = Actor or require "lib/actor"

local VendingMachine = VendingMachine or require "src/vendingMachine"

actorList = {}

function love.load()
  local vendingMachine = VendingMachine()
  table.insert(actorList, vendingMachine)
end

function love.update(dt)
  for _, actor in ipairs(actorList) do
    actor:update(dt)
  end
  
  if (love.keyboard.isDown("escape")) then
    love.event.quit()
  end
end

function love.draw()
  for _, actor in ipairs(actorList) do
    actor:draw()
  end
end