local Object = Object or require "lib/classic"

local Sti = require "lib/sti"
local Character = require "src/character"
local VendingMachine = require "src/vendingMachine"
local Camera = require "src/camera"
local Background = require "src/background"
local Hud = require "src/hud"
local SoundManager = require "src/soundManager"

local Menu = require "src/menu"
local EndScreen = require "src/endScreen"

local Level = Object:extend()

function Level:new()

  self.screen = "menu"

  self.menu = Menu:new()
  self.endScreen = nil

  self.character = nil
  self.vendingMachine = nil

  self.soundManager = SoundManager()

  self.dificultad = nil
end

function Level:crearPartida()
  
  self.map = Sti("src/mapa.lua")

  self.character = Character(self.soundManager)
  self.vendingMachine = VendingMachine(self.character, self.soundManager)

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

  self.menu = nil
  self.endScreen = nil

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
    self.menu = Menu:new()

    self.screen = "menu"

  elseif action == "salir" then
    love.event.quit()
  end
end

function Level:update(dt)
  if self.screen == "game" then
    for _, actor in ipairs(self.actors) do
      actor:update(dt)
    end

    self.map:update(dt)
    self.camera:update(dt)

    self.hud:update(dt)

    if not self.character.alive then
      self.endScreen = EndScreen:new("muerte")
      self.screen = "end"

    elseif not self.vendingMachine.vivo then
      if (self.vendingMachine.animationFinished) then
        self.endScreen = EndScreen:new("victoria")
        self.screen = "end"
      end
    end
    
    if love.keyboard.isDown("escape") then
      love.event.quit()
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
  elseif self.screen == "difficulty" then
    self:accion(self.menu:keypressed(key, "dificultad"))
  elseif self.screen == "end" then
    self:accion(self.endScreen:keypressed(key))
  end
end

return Level