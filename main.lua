local Menu = require "src/menu"
local Level = require "src/level"
local EndScreen = require "src/endScreen"

local W, H = 1920, 1080
local canvas, menu, level, endScreen
local screen = "menu"
local scale, offsetX, offsetY

function love.load()
    canvas = love.graphics.newCanvas(W, H)
    menu = Menu:new()

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

local function accion(action)
    if action == "jugar" or action == "retry" then
        level = Level()
        menu, endScreen = nil, nil
        screen = "game"
    elseif action == "menu" then
        level, endScreen = nil, nil
        menu = Menu:new()
        screen = "menu"
    elseif action == "salir" then
        love.event.quit()
    end
end

function love.update(dt)
    if screen == "game" then
        level:update(dt)

        if not level.character.alive then
            endScreen = EndScreen:new("muerte")
            screen = "end"
        elseif not level.vendingMachine.vivo then
            endScreen = EndScreen:new("victoria")
            screen = "end"
        end
    elseif screen == "end" then
        endScreen:update(dt)
    end
end

function love.draw()
    local mx, my = love.mouse.getPosition()
    mx, my = (mx - offsetX) / scale, (my - offsetY) / scale

    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 1)

    if screen == "menu" then
        menu:draw(mx, my)
    elseif screen == "game" then
        level:draw()
    else
        level:draw()
        endScreen:draw(mx, my)
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas, offsetX, offsetY, 0, scale, scale)
end

function love.mousepressed(x, y, button)
    x, y = (x - offsetX) / scale, (y - offsetY) / scale

    if screen == "menu" then
        accion(menu:mousepressed(x, y, button))
    elseif screen == "end" then
        accion(endScreen:mousepressed(x, y, button))
    end
end

function love.keypressed(key)
    if screen == "menu" then
        accion(menu:keypressed(key))
    elseif screen == "end" then
        accion(endScreen:keypressed(key))
    end
end