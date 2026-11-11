local Object = Object or require "lib/classic"

local Sti = require "lib/sti"
local Character = require "src/character"
local VendingMachine = require "src/vendingMachine"
local Camera = require "src/camera"
local Background = require "src/background"
local Hud = require "src/hud"
local SoundManager = require "src/soundManager"

local Level = Object:extend()

function Level:new()

  proyectiles = {}
  self.map = Sti("src/mapa.lua")

  self.character = Character()
  self.vendingMachine = VendingMachine(self.character)

  self.character.boss = self.vendingMachine

  self.actors = {}
  table.insert(self.actors, self.character)
  table.insert(self.actors, self.vendingMachine)

  self.hud = Hud(self.vendingMachine, self.character)

  self.camera = Camera(self.map, self.character)
  self.background = Background("src/textures/fondo.png")
  
  soundManager = SoundManager()
  soundManager:playLoop("boss")
  soundManager:setVolume("boss", 0.15)
end

function Level:update(dt)
  for _, actor in ipairs(self.actors) do
    actor:update(dt)
  end

  for _, proyectil in ipairs(proyectiles) do
    proyectil:update(dt)
  end

  self.map:update(dt)
  self.camera:update(dt)        -- despues de mover a los actores

  self.hud:update(dt)
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end
end

function Level:resize(w, h)
  self.map:resize(w, h)
end

function Level:draw()
  -- 1) fondo  2) mapa  3) actores  (el orden importa)
  self.background:draw(self.camera:progress())
  self.map:draw(self.camera.tx, self.camera.ty)

  self.camera:attach()

  for _, actor in ipairs(self.actors) do
    actor:draw()
  end

  for _, proyectil in ipairs(proyectiles) do
    proyectil:draw()
  end
  
  self.camera:detach()

  self.hud:draw()
end

return Level