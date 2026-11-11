local Menu = {}
Menu.__index = Menu

function Menu:new()
    local menu = setmetatable({}, Menu)

    menu.fondo =
    love.graphics.newImage("src/textures/ui/menu-background.png")
    menu.logo = love.graphics.newImage("src/textures/ui/jump-snack-logo.png")
    menu.fuente = love.graphics.newFont("src/fonts/Minecraft.ttf", 30)

    return menu
end


local function botones()
    local ancho = 300
    local alto = 60
    local x = (love.graphics.getWidth() - ancho) / 2
    local y = love.graphics.getHeight() *   0.64

    return {
        jugar = { x = x, y = y, w = ancho, h = alto },
        salir = { x = x, y = y + 86, w = ancho, h = alto }
    }
end

local function dibujarBoton(rect, texto, fuente, mouseX, mouseY)
    local encima = mouseX >= rect.x and mouseX <= rect.x + rect.w and mouseY >= rect.y and mouseY <= rect.y + rect.h

    if encima then
        love.graphics.setColor(0.08, 0.30, 0.45, 0.95)
    else
        love.graphics.setColor(0.02, 0.08, 0.16, 0.85)
    end

    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 10, 10)
    love.graphics.setColor(0.25, 0.75, 1, 1)
    love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 10, 10)
    love.graphics.setFont(fuente)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(texto, rect.x, rect.y + (rect.h - fuente:getHeight()) / 2, rect.w, "center")

end

function Menu:draw()
    local ancho = love.graphics.getWidth()
    local alto = love.graphics.getHeight()
    local anchoFondo, altoFondo = self.fondo:getDimensions()

    local escala = math.max(ancho / anchoFondo, alto / altoFondo)
    local x = (ancho - anchoFondo * escala) / 2
    local y = (alto - altoFondo * escala) / 2

    local anchoLogo = 650
    local escalaLogo = anchoLogo / self.logo:getWidth()
    local xLogo = (love.graphics.getWidth() - anchoLogo) / 2
    local yLogo = love.graphics.getHeight() * 0.20


    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.fondo, x, y, 0, escala, escala)
    love.graphics.draw(self.logo, xLogo, yLogo, 0, escalaLogo, escalaLogo)
    
    local b = botones()
    local mouseX, mouseY = love.mouse.getPosition()

    dibujarBoton(b.jugar, "PLAY", self.fuente, mouseX, mouseY)
    dibujarBoton(b.salir, "EXIT", self.fuente, mouseX, mouseY)
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