local Menu = require "src/menu"
local Level = require "src/level"
local EndScreen = require "src/endScreen"

local menu
local level
local endScreen
local screen = "menu"

function love.load()
    menu = Menu:new()
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
    if screen == "menu" then
        menu:draw()
    elseif screen == "game" then
        level:draw()
    elseif screen == "end" then
        level:draw()
        endScreen:draw()
    end
end

local function handleMenuAction(action)
    if action == "jugar" then
        level = Level()
        menu = nil
        screen = "game"
    elseif action == "salir" then
        love.event.quit()
    end
end

local function handleEndAction(action)
    if action == "retry" then
      level = Level()
      endScreen = nil
      screen = "game"
    elseif action == "menu" then
        level = nil
        endScreen = nil
        menu = Menu:new()
        screen = "menu"
    elseif action == "salir" then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button)
    if screen == "menu" then
        handleMenuAction(menu:mousepressed(x, y, button))
    elseif screen == "end" then
        handleEndAction(endScreen:mousepressed(x, y, button))
    end
end

function love.keypressed(key)
    if screen == "menu" then
        handleMenuAction(menu:keypressed(key))
    elseif screen == "end" then
        handleEndAction(endScreen:keypressed(key))
    end
end

function love.resize(w, h)
    if level then
        level:resize(w, h)
    end
end