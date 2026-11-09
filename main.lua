local Vector = Vector or require "lib/vector"
local Actor = Actor or require "src/actor"
local Character = Character or require "src/character"

actorList = {}

function love.load()

    c = Character()
    table.insert(actorList, c)

  
end

function love.update(dt)
  
end

function love.draw()
  
end