local Character = require "src/character"
local player

function love.load()
    player = Character()
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    player:update(dt)
end

function love.draw()
    player:draw()
end

function love.keypressed(key)
    if key == "space" then
        player:jump()
    end
end