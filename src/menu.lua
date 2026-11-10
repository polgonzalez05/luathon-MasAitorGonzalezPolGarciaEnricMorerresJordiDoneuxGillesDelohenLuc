-- src/menu.lua
local Menu = {}
Menu.__index = Menu

function Menu:new()
    return setmetatable({}, Menu)
end

local function botones()
    local ancho = 220
    local alto = 60
    local x = (love.graphics.getWidth() - ancho) / 2
    local y = love.graphics.getHeight() / 2

    return {
        jugar = { x = x, y = y - 20, w = ancho, h = alto },
        salir = { x = x, y = y + 60, w = ancho, h = alto }
    }
end

local function dibujarBoton(rect, texto, mouseX, mouseY)
    local encima = mouseX >= rect.x and mouseX <= rect.x + rect.w
        and mouseY >= rect.y and mouseY <= rect.y + rect.h

    if encima then
        love.graphics.setColor(0.25, 0.6, 0.95)
    else
        love.graphics.setColor(0.15, 0.4, 0.75)
    end

    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(texto, rect.x, rect.y + 20, rect.w, "center")
end

function Menu:draw()
    love.graphics.clear(0.08, 0.08, 0.12)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        "MI JUEGO",
        0,
        love.graphics.getHeight() / 2 - 120,
        love.graphics.getWidth(),
        "center"
    )

    local b = botones()
    local mouseX, mouseY = love.mouse.getPosition()

    dibujarBoton(b.jugar, "Jugar", mouseX, mouseY)
    dibujarBoton(b.salir, "Salir", mouseX, mouseY)
end

function Menu:mousepressed(x, y, boton)
    if boton ~= 1 then
        return nil
    end

    local b = botones()

    for nombre, rect in pairs(b) do
        if x >= rect.x and x <= rect.x + rect.w
        and y >= rect.y and y <= rect.y + rect.h then
            return nombre
        end
    end

    return nil
end

function Menu:keypressed(key)
    if key == "return" or key == "kpenter" or key == "space" then
        return "jugar"
    elseif key == "escape" then
        return "salir"
    end

    return nil
end

return Menu