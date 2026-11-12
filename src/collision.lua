local Object = Object or require "lib/classic"

local Collision = Object:extend()

local SOLID = { [5] = true, [14] = true, [16] = true } -- ledge, left wall, right wall

function Collision:new(map, layerName)
  self.layer = map.layers[layerName]
  self.size = map.tilewidth -- 32
end

-- 0-based tile coords
function Collision:solidAt(tx, ty)
  local row = self.layer.data[ty + 1]
  local tile = row and row[tx + 1]
  return tile ~= nil and SOLID[tile.gid] == true
end

function Collision:solidAtPixel(px, py)
  return self:solidAt(math.floor(px / self.size), math.floor(py / self.size))
end

-- does the box overlap any solid tile?
function Collision:hits(x, y, w, h)
  local s = self.size
  for ty = math.floor(y / s), math.floor((y + h - 0.01) / s) do
    for tx = math.floor(x / s), math.floor((x + w - 0.01) / s) do
      if self:solidAt(tx, ty) then return true end
    end
  end
  return false
end

-- moves the box 1px at a time, X first then Y, stopping when blocked
-- returns newX, newY, hitX, hitY
function Collision:move(x, y, w, h, dx, dy)
  local hitX, hitY = false, false

  while dx ~= 0 do
    local step = math.abs(dx) < 1 and dx or (dx > 0 and 1 or -1)
    if self:hits(x + step, y, w, h) then hitX = true break end
    x, dx = x + step, dx - step
  end

  while dy ~= 0 do
    local step = math.abs(dy) < 1 and dy or (dy > 0 and 1 or -1)
    if self:hits(x, y + step, w, h) then hitY = true break end
    y, dy = y + step, dy - step
  end

  return x, y, hitX, hitY
end

return Collision