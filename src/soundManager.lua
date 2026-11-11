Vector = Vector or require "lib/vector"
Object = Object or require "lib/classic"

local SoundManager = Object:extend()

function SoundManager:new()
    self.sounds = {
        ["hurt"] = love.audio.newSource("src/sounds/hurt.wav", "static"),
        ["boss"] = love.audio.newSource("src/sounds/bosstheme.wav", "stream"),
        ["jump"] = love.audio.newSource("src/sounds/jump.wav", "static"),
        ["shoot"] = love.audio.newSource("src/sounds/shoot.wav", "static"),
        ["stomp"] = love.audio.newSource("src/sounds/stomp.wav", "static"),
        ["arrastre"] = love.audio.newSource("src/sounds/arrastre.wav", "static"),
        ["chips"] = love.audio.newSource("src/sounds/chips.wav", "static")
    }
end

function SoundManager:play(soundName)
    local sound = self.sounds[soundName]
    sound:stop()
    sound:play()
end

function SoundManager:playLoop(soundName)
    local sound = self.sounds[soundName]

    sound:setLooping(true)
    sound:play()
end

function SoundManager:stop(soundName)
    local sound = self.sounds[soundName]

    if sound then
        sound:stop()
    end
end

function SoundManager:setVolume(soundName, volume)
    local sound = self.sounds[soundName]
    sound:setVolume(volume)
end

return SoundManager