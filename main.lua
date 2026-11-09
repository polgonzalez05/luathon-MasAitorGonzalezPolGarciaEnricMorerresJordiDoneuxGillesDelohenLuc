local Vector = Vector or require "lib/vector"
local Actor = Actor or require "lib/actor"

actorList = {}

function love.load()
  
end

function love.update(dt)
  if (love.keyboard.isDown("escape")) then
    love.event.quit()
  end
end

function love.draw()
  
end