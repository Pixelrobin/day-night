local Graphics <const> = playdate.graphics
local Sprite <const> = playdate.graphics.sprite
local Vector2D <const> = playdate.geometry.vector2D

class("Entity").extends(Sprite)

local function createImage(width, height)
  local image = Graphics.image.new(width, height)

  Graphics.lockFocus(image)
  Graphics.setColor(Graphics.kColorWhite)
  Graphics.fillCircleInRect(0, 0, width, height)
  Graphics.unlockFocus()

  return image
end

function Entity:init(x, y, width, height, collisionIndex, map)
  Entity.super.init(self)

  self.width = width
  self.height = height
  self.map = map

  -- local angle = math.random() * 260

  local angle = math.floor(math.random() * 4) * 90 + 45
  angle = angle + math.random() * 10 - 5
  angle %= 260

  self.direction = Vector2D.newPolar(1, angle);

  self:setImage(createImage(width, height))
  self:setImageDrawMode(Graphics.kDrawModeXOR)
  self:moveTo(x, y)
  self:setCollideRect(0, 0, width, height)
  self:setCollidesWithGroups({ collisionIndex, 3 })

  self.collisionResponse = Sprite.kCollisionTypeBounce
end

function Entity:update()
  local actualX, actualY, collisions, collisionCount = self:moveWithCollisions(
    self.x + self.direction.dx * 10,
    self.y + self.direction.dy * 10
  )

  for i = 1, collisionCount do
    local collision = collisions[i]

    self.direction = collision.bounce - collision.touch
    self.direction:normalize()

    local otherRect = collision.otherRect

    -- TODO: remove the hardcoded "16" here.
    -- FIguring out where a tile is on the map should probably be the job of the map class
    local mapX = math.floor((otherRect.x + otherRect.width / 2) / 16) + 1
    local mapY = math.floor((otherRect.y + otherRect.height / 2) / 16) + 1

    self.map:commit(
      mapX,
      mapY
    )
  end
end
