-- src/endScreen.lua
local EndScreen = {}
EndScreen.__index = EndScreen

function EndScreen:new(result)
    local screen = setmetatable({}, EndScreen)

    screen.result = result
    screen.fade = 0
    screen.fadeDuration = 0.8 -- Duracion Fundido
    screen.titleFont = love.graphics.newFont("src/fonts/Minecraft.ttf", 64)
    screen.buttonFont = love.graphics.newFont("src/fonts/Minecraft.ttf", 28)

    return screen
end

function EndScreen:update(dt)
    self.fade = math.min(1, self.fade + dt / self.fadeDuration)
end

local function getButtons(width, height)
    local buttonWidth = 320
    local buttonHeight = 64
    local x = (width - buttonWidth) / 2
    local y = height * 0.62

    return {
        retry = { x = x, y = y, w = buttonWidth, h = buttonHeight },
        menu = { x = x, y = y + 84, w = buttonWidth, h = buttonHeight }
    }
end

function EndScreen:draw()
    local width, height = love.graphics.getDimensions()

    -- Dibuja un rectángulo negro transparente sobre el nivel.
    love.graphics.setColor(0, 0, 0, self.fade * 0.92)
    love.graphics.rectangle("fill", 0, 0, width, height)

    if self.fade < 1 then
        love.graphics.setColor(1, 1, 1)
        return
    end

    local title = "GAME OVER"
    if self.result == "victoria" then
        title = "VICTORIA"
    end

    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(1, 0.1, 0.1)
    love.graphics.printf(title, 0, height * 0.38, width, "center")

    local buttons = getButtons(width, height)
    local mouseX, mouseY = love.mouse.getPosition()

    local function drawButton(rect, text)
        local hovered = mouseX >= rect.x and mouseX <= rect.x + rect.w and mouseY >= rect.y and mouseY <= rect.y + rect.h

        if hovered then
            love.graphics.setColor(0.25, 0.45, 0.65)
        else
            love.graphics.setColor(0.1, 0.2, 0.32)
        end

        love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 10, 10)

        love.graphics.setFont(self.buttonFont)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(text, rect.x, rect.y + 18, rect.w, "center")
    end

    drawButton(buttons.retry, "RETRY")
    drawButton(buttons.menu, "RETURN TO MENU")

    love.graphics.setColor(1, 1, 1)
end

function EndScreen:mousepressed(x, y, button)
    if button ~= 1 or self.fade < 1 then
        return nil
    end

    local buttons = getButtons(love.graphics.getWidth(),love.graphics.getHeight())

    for name, rect in pairs(buttons) do
        if x >= rect.x and x <= rect.x + rect.w
            and y >= rect.y and y <= rect.y + rect.h then
            return name
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