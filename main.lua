local Level = require "src/level"

local W, H = 1920, 1080
local canvas, level
local scale, offsetX, offsetY

function love.load()
    canvas = love.graphics.newCanvas(W, H)
    level = Level()

    local w, h = love.graphics.getDimensions()
    love.resize(w, h)
end

function love.resize(w, h)
    scale = math.min(w / W, h / H)
    offsetX = (w - W * scale) / 2
    offsetY = (h - H * scale) / 2

    if level then
        level:resize(W, H)
    end
end

function love.update(dt)
    level:update(dt)
end

function love.draw()
    local mx, my = love.mouse.getPosition()
    mx, my = (mx - offsetX) / scale, (my - offsetY) / scale

    love.graphics.setCanvas(canvas)
    love.graphics.clear(0,0,0,1)

    level:draw(mx, my)

    love.graphics.setCanvas()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(canvas, offsetX, offsetY, 0, scale, scale)
end

function love.mousepressed(x, y, button)
    x, y = (x - offsetX) / scale, (y - offsetY) / scale
    level:mousepressed(x, y, button)
end

function love.keypressed(key)
    level:keypressed(key)
end