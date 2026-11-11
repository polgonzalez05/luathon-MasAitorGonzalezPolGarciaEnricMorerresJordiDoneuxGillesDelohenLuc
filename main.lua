local Level = require "src/level"

local level

local virtualWidth = 1920
local virtualHeight = 1080

local canvas

function love.load()
  canvas = love.graphics.newCanvas(virtualWidth, virtualHeight)
  level = Level()
end

function love.update(dt)
  level:update(dt)
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  level:draw()

  love.graphics.setCanvas()

  local sw, sh = love.graphics.getDimensions()

  local scale = math.min(sw / virtualWidth, sh / virtualHeight)

  local x = (sw - virtualWidth * scale) / 2
  local y = (sh - virtualHeight * scale) / 2

  love.graphics.draw(canvas, x, y, 0, scale, scale)
end

function love.resize(w, h)
  level:resize(w, h)
end