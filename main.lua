local Character = require "src/character"
local Menu = require "src/menu"

local menu = Menu:new()
local estado = "menu"
local player

local function elegir(accion)
    if accion == "jugar" then
        player = Character()
        estado = "juego"
    elseif accion == "salir" then
        love.event.quit()
    end
end

function love.update(dt)
    if estado == "juego" then
        player:update(dt)
    end
end

function love.draw()
    if estado == "menu" then
        menu:draw()
    else
        player:draw()
    end
end

function love.mousepressed(x, y, boton)
    if estado == "menu" then
        elegir(menu:mousepressed(x, y, boton))
    end
end

function love.keypressed(key)
    if estado == "menu" then
        elegir(menu:keypressed(key))
    elseif key == "space" then
        player:jump()
    elseif key == "escape" then
        estado = "menu"
    end
end