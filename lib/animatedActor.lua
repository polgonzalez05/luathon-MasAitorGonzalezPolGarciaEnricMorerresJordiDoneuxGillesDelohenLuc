Object = Object or require "lib/classic"
Vector = Vector or require "lib/vector"
Actor = Actor or require "lib/actor"

local AnimatedActor = Actor:extend()

function AnimatedActor:new(_image, _x, _y, _speed,_fx,_fy,_nFrames,_fr)
  self.position = Vector(_x or 0, _y or 0)
  self.scale = Vector(1, 1)
  self.forward = Vector(_fx or 1, _fy or 0)
  self.nFrames = _nFrames or 6
  self.speed = _speed or 30
  self.image = love.graphics.newImage(_image or "src/textures/background.jpg")
  self.width = self.image:getWidth() / self.nFrames
  self.height = self.image:getHeight()
  self.origin = Vector(self.width / 2, self.height /2 )
  self.rot = 0
  self.frames ={}
  self.frameRate = _fr or 12
  self.actFrame = 1
  for i=1,self.nFrames do
    self.frames[i] =love.graphics.newQuad(self.width*(i-1), 0, self.width, self.height, self.image:getWidth(), self.image:getHeight())
  end
end
function AnimatedActor:update(dt)
  self.actFrame = self.actFrame + self.frameRate * dt

  if self.actFrame > self.nFrames then
    if self.loop then
        self.actFrame = 1
    else
      self.actFrame = self.nFrames
      self.animationFinished = true
    end
  end

  self.position = self.position + self.forward * self.speed * dt
end

function AnimatedActor:draw()
  local i = math.floor(self.actFrame)
  love.graphics.draw(self.image,self.frames[i],self.position.x + self.origin.x,self.position.y + self.origin.y,self.rot, self.scale.x, self.scale.y, self.origin.x, self.origin.y)
end

function AnimatedActor:setAnimation(_image, _nFrames, _frameRate, _loop)
  self.image = love.graphics.newImage(_image)
  self.nFrames = _nFrames
  self.frameRate = _frameRate or 12
  self.loop = _loop
  self.actFrame = 1
  self.animationFinished = false

  self.width = self.image:getWidth() / self.nFrames
  self.height = self.image:getHeight()
  self.origin = Vector(self.width / 2, self.height / 2)

  self.frames =  {}

  for i = 1, self.nFrames do
    self.frames[i] = love.graphics.newQuad(self.width * (i - 1), 0, self.width, self.height, self.image:getWidth(), self.image:getHeight())
  end
end


return AnimatedActor
