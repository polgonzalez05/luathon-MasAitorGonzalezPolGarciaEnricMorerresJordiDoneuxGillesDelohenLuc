local Vector = Vector or require "lib/vector"
local Object = Object or require "lib/object"
local Actor = Object:extend()

function Actor:new(_image, _x, _y, _speed)
    self.position = Vector.new(_x or 0, _y or 0)
    self.forward = Vector.new(1, 0)
    self.speed = _speed or 150
    self.image = love.graphics.newImage(_image or "src/textures/bear.png")
    self.origin = Vector.new(self.image:getWidth() / 2, self.image:getHeight() / 2)
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.rot = 0
end

function Actor:update(dt)
end

function Actor:draw()
end

function Actor:dist(aa)
    local xx = self.position.x - aa.position.x
    local yy = self.position.y - aa.position.y
    return math.sqrt(xx ^ 2 + yy ^ 2)
end

function Actor:checkCollision(aa)
    local a_left = aa.position.x
    local a_right = aa.position.x + aa.width
    local a_top = aa.position.y
    local a_bottom = aa.position.y + aa.height

    local b_left = self.position.x
    local b_right = self.position.x + self.width
    local b_top = self.position.y
    local b_bottom = self.position.y + self.height

    if
        a_right > b_left and --and Red's left side is further to the left than Blue's right side.
            a_left < b_right and --and Red's bottom side is further to the bottom than Blue's top side.
            a_bottom > b_top and --and Red's top side is further to the top than Blue's bottom side then..
            a_top < b_bottom
     then
        --There is collision!
        return true
    else
        --If one of these statements is false, return false.
        return false
    end
end

function Actor:keyPressed(key)
end

return Actor
