local Level = require "src/level"

local level

function love.load()
  level = Level("src/mapa.lua")
end

function love.update(dt)
  level:update(dt)
end

function love.draw()
  level:draw()
end

function love.resize(w, h)
  level:resize(w, h)
end