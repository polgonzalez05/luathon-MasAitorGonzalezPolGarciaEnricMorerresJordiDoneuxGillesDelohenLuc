local Object = Object or require "lib/classic"

local Sti = require "lib/sti"
local Character = require "src/character"
local VendingMachine = require "src/vendingMachine"
local Camera = require "src/camera"
local Background = require "src/background"
local Hud = require "src/hud"
local SoundManager = require "src/soundManager"
local Collision = require "src/collision"

local Level = Object:extend()

function Level:new()

  proyectiles = {}
  self.map = Sti("src/mapa.lua")
  self.collision = Collision(self.map, "Capa de patrones 1")
  self.soundManager = SoundManager()
  self.character = Character(self.soundManager)

  self.character.collision = self.collision
  
  self.vendingMachine = VendingMachine(self.character,self.soundManager)
  self.character.boss = self.vendingMachine
  
  

  self.actors = {}
  table.insert(self.actors, self.character)
  table.insert(self.actors, self.vendingMachine)

  self.hud = Hud(self.vendingMachine, self.character)

  self.camera = Camera(self.map, self.character)
  self.background = Background("src/textures/fondo.png")
  

  self.soundManager:stop("boss")
  self.soundManager:playLoop("boss")
  self.soundManager:setVolume("boss", 0.15)
end

function Level:update(dt)
  for _, actor in ipairs(self.actors) do
    if not(actor == self.vendingMachine and self.character.position.y >= 600) then
      actor:update(dt)
    end
  end
  if self.character.position.y <= 600 and self.character.position.y >= 550 then
    self.character.position.y = 450
  end

  for _, proyectil in ipairs(proyectiles) do
    proyectil:update(dt)
  end
  
  self.map:update(dt)
  self.camera:update(dt)        

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

function Level:mousepressed(x,y,button)
end
function Level:keypressed(x,y,button)
end

return Level