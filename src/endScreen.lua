-- src/endScreen.lua
local EndScreen = {}
EndScreen.__index = EndScreen

local ANCHO = 1920
local ALTO = 1080

function EndScreen:new(result)
    local screen = setmetatable({}, EndScreen)

    screen.result = result
    screen.fade = 0
    screen.fadeDuration = 0.8
    screen.titleFont = love.graphics.newFont("src/fonts/Minecraft.ttf", 64)
    screen.buttonFont = love.graphics.newFont("src/fonts/Minecraft.ttf", 28)

    return screen
end

function EndScreen:update(dt)
    self.fade = math.min(1, self.fade + dt / self.fadeDuration)
end

local function botones()
    local ancho = 320
    local alto = 64
    local x = (ANCHO - ancho) / 2
    local y = ALTO * 0.62

    return {
        retry = { x = x, y = y, w = ancho, h = alto },
        menu = { x = x, y = y + 84, w = ancho, h = alto }
    }
end

function EndScreen:draw(mouseX, mouseY)
    love.graphics.setColor(0, 0, 0, self.fade * 0.92)
    love.graphics.rectangle("fill", 0, 0, ANCHO, ALTO)

    if self.fade < 1 then
        love.graphics.setColor(1, 1, 1, 1)
        return
    end

    local titulo = "GAME OVER"
    if self.result == "victoria" then
        titulo = "VICTORIA"
    end

    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(1, 0.1, 0.1, 1)
    love.graphics.printf(titulo, 0, ALTO * 0.38, ANCHO, "center")

    local b = botones()
    mouseX = mouseX or -1
    mouseY = mouseY or -1

    local function dibujarBoton(rect, texto)
        local encima = mouseX >= rect.x and mouseX <= rect.x + rect.w and mouseY >= rect.y and mouseY <= rect.y + rect.h

        if encima then
            love.graphics.setColor(0.25, 0.45, 0.65, 1)
        else
            love.graphics.setColor(0.1, 0.2, 0.32, 1)
        end

        love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 10, 10)
        love.graphics.setFont(self.buttonFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf( texto, rect.x, rect.y + 18, rect.w, "center")
    end

    dibujarBoton(b.retry, "RETRY")
    dibujarBoton(b.menu, "RETURN TO MENU")

    love.graphics.setColor(1, 1, 1, 1)
end

function EndScreen:mousepressed(x, y, button)
    if button ~= 1 or self.fade < 1 then
        return nil
    end

    for nombre, rect in pairs(botones()) do
        if x >= rect.x and x <= rect.x + rect.w
            and y >= rect.y and y <= rect.y + rect.h then
            return nombre
        end
    end

    return nil
end

function EndScreen:keypressed(key)
    if self.fade < 1 then
        return nil
    end

    if key == "return" or key == "kpenter" or key == "space" then
        return "retry"
    elseif key == "escape" then
        return "menu"
    end

    return nil
end

return EndScreen