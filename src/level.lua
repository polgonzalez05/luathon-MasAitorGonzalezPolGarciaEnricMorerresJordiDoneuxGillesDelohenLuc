local Object = Object or require "lib/classic"

local Sti = require "lib/sti"
local Character = require "src/character"
local VendingMachine = require "src/vendingMachine"
local Camera = require "src/camera"
local Background = require "src/background"
local Hud = require "src/hud"
local SoundManager = require "src/soundManager"
local Collision = require "src/collision"
local Menu = require "src/menu"
local EndScreen = require "src/endScreen"

local Level = Object:extend()

function Level:new()

  self.screen = "menu"

  self.video = nil
  self.videoTerminado = nil

  self.menu = Menu:new()
  self.endScreen = nil

  self.character = nil
  self.vendingMachine = nil

  self.soundManager = SoundManager()

  self.dificultad = nil

  self.teleportado = false
end

function Level:crearPartida()

  self.video = love.graphics.newVideo("src/video/intro.ogv")
  self.video:play()

  self.tiempoVideo = 0
  self.duracionVideo = 16

  self.videoTerminado = false
  self.screen = "intro"
end
  

function Level:iniciarPartida()
  self.map = Sti("src/mapa.lua")
  self.collision = Collision(self.map, "Capa de patrones 1")
  self.soundManager = SoundManager()
  self.character = Character(self.soundManager)

  self.character.collision = self.collision
  
  self.vendingMachine = VendingMachine(self.character,self.soundManager, self.dificultad)
  self.character.boss = self.vendingMachine
  
  self.teleportado = false

  self.actors = {}
  table.insert(self.actors, self.character)
  table.insert(self.actors, self.vendingMachine)

  self.hud = Hud(self.vendingMachine, self.character)

  self.camera = Camera(self.map, self.character)
  self.background = Background("src/textures/fondo.png")
  

  self.soundManager:stop("boss")
  self.soundManager:playLoop("boss")
  self.soundManager:setVolume("boss", 0.15)

  self.screen = "game"
end

function Level:accion(action)
  if action == "jugar" then
    self.screen = "difficulty"

  elseif action == "facil" or action == "dificil" or action == "imposible" then
    self.dificultad = action
    self:crearPartida()

  elseif action == "volver" then
    self.screen = "menu"

  elseif action == "retry" then
    self:crearPartida()

  elseif action == "menu" then
    self.character = nil
    self.vendingMachine = nil
    self.map = nil
    self.actors = nil
    self.camera = nil
    self.background = nil
    self.hud = nil
    self.endScreen = nil

    self.screen = "menu"

  elseif action == "salir" then
    love.event.quit()
  end
end

  

function Level:update(dt)
  if self.screen == "intro" then

    self.tiempoVideo = self.tiempoVideo + dt

    if self.tiempoVideo >= self.duracionVideo then
      self.video:pause()
      self.video = nil
      self:iniciarPartida()
    end

  elseif self.screen == "game" then
    for _, actor in ipairs(self.actors) do
      if not(actor == self.vendingMachine and self.character.position.y >= 600) then
        actor:update(dt)
      end
    end

    if not self.teleportado and self.character.position.y <= 600 and self.character.position.y >= 500 then
      self.character:teleport(700, 450)
      self.teleportado = true
    end

    self.map:update(dt)
    self.camera:update(dt)

    self.hud:update(dt)

    if not self.character.alive then
      self.soundManager:play("lose")
      self.endScreen = EndScreen:new("muerte")
      self.screen = "end"

    elseif not self.vendingMachine.vivo then
      if (self.vendingMachine.animationFinished) then
        self.soundManager:play("win")
        self.endScreen = EndScreen:new("victoria")
        self.screen = "end"
      end
    end

  elseif self.screen == "end" then
    self.endScreen:update(dt)
  end

end


function Level:resize(w, h)
  if self.map then
    self.map:resize(w, h)
  end
end


function Level:draw(mx, my)
    if self.screen == "menu" then
      self.menu:draw(mx, my, "menu")
    elseif self.screen == "difficulty" then
      self.menu:draw(mx, my, "dificultad")
    elseif self.screen == "game" then
      self:drawGame()
    elseif self.screen == "end" then
      self:drawGame()
      self.endScreen:draw(mx, my)
    elseif self.screen == "intro" then
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(self.video, 0, 0, 0,
          1920 / self.video:getWidth(),
          1080 / self.video:getHeight()
      )
  end
end

function Level:drawGame()
  self.background:draw(self.camera:progress())
  self.map:draw(self.camera.tx, self.camera.ty)

  self.camera:attach()

  for _, actor in ipairs(self.actors) do
    actor:draw()
  end

  self.camera:detach()

  self.hud:draw()
end



function Level:mousepressed(x, y, button)
  if self.screen == "menu" then
    self:accion(self.menu:mousepressed(x, y, button, "menu"))
  elseif self.screen == "difficulty" then
    self:accion(self.menu:mousepressed(x, y, button, "dificultad"))
  elseif self.screen == "end" then
    self:accion(self.endScreen:mousepressed(x, y, button))
  end
end

function Level:keypressed(key)
  if self.screen == "menu" then
    self:accion(self.menu:keypressed(key, "menu"))

  elseif self.screen == "game" then
    if key == "escape" then
      self.soundManager:stopAllSounds()
      self:accion("menu")
    end
  elseif self.screen == "difficulty" then
    self:accion(self.menu:keypressed(key, "dificultad"))
  elseif self.screen == "end" then
    self:accion(self.endScreen:keypressed(key))
  elseif self.screen == "intro" then
    if key == "escape" or key == "return" then
        self.video:pause()
        self.video = nil
        self:iniciarPartida()
    end
  end
end

return Level