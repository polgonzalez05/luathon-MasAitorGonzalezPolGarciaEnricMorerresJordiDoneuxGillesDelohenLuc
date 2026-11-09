local Vector = Vector or require "lib/vector"
local Actor = Actor or require "lib/actor"
local Character = Character or require "src/character"
local Menu = Menu or require "src/menu"

actorList = {}

function love.load()
  actorList[#actorList + 1] = Character:new()
end

function love.update(dt)
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end
end

function love.draw()
  
end


function love.mousepressed(x, y, button)
    handlePress(x, y, button)
end