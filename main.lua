
local Vector = Vector or require "lib/vector"
local Actor = Actor or require "lib/actor"

local VendingMachine = VendingMachine or require "src/vendingMachine"
local Character = Character or require "src/character"
local Hud = Hud or require "src/hud"

actorList = {}

function love.load()

  proyectiles = {}

  local character = Character()
  local vendingMachine = VendingMachine(character)

  table.insert(actorList, character)
  table.insert(actorList, vendingMachine)
  
  hud = Hud(vendingMachine)

  table.insert(actorList, hud)

end

function love.update(dt)
  for _, actor in ipairs(actorList) do
    actor:update(dt)
  end

  for _, proyectil in ipairs(proyectiles) do
    proyectil:update(dt)
  end
  
  if (love.keyboard.isDown("escape")) then
    love.event.quit()
  end
end

function love.draw()
  for _, actor in ipairs(actorList) do
    actor:draw()
  end

  for _, proyectil in ipairs(proyectiles) do
    proyectil:draw()
  end
end