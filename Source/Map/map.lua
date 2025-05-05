local Display <const> = playdate.display
local Graphics <const> = playdate.graphics
local Tilemap <const> = playdate.graphics.tilemap
local Sprite <const> = playdate.graphics.sprite

local function createImagetable(tileSizeX, tileSizeY)
  local day = Graphics.image.new(tileSizeX, tileSizeY, Graphics.kColorWhite)
  local night = Graphics.image.new(tileSizeX, tileSizeY, Graphics.kColorBlack)

  local imageTable = Graphics.imagetable.new(2)
  imageTable:setImage(1, day)
  imageTable:setImage(2, night)

  return imageTable
end

local function getInitialIndex(x, y, tileCountX, tileCountY)
  local index = 1

  if (y > tileCountY / 2) then
    index = 2
  end

  return index
end

local function createInitialTileData(tileCountX, tileCountY)
  local tileData = {}

  for y = 1, tileCountY do
    for x = 1, tileCountX do
      local index = getInitialIndex(x, y, tileCountX, tileCountY)
      table.insert(tileData, index)
    end
  end

  return tileData
end

local function createCollisionSprites(tileCountX, tileCountY, tileSizeX, tileSizeY)
  local sprites = {};

  for y = 1, tileCountY do
    for x = 1, tileCountX do
      local sprite = Sprite.addEmptyCollisionSprite(
        (x - 1) * tileSizeX,
        (y - 1) * tileSizeY,
        tileSizeX,
        tileSizeY
      )

      sprite:setGroups(getInitialIndex(x, y, tileCountX, tileCountY))

      table.insert(sprites, sprite)
    end
  end

  return sprites
end

local function addWallCollisionSprite(x, y, width, height)
  local sprite = Sprite.addEmptyCollisionSprite(x, y, width, height)
  sprite:setGroups(3)
  return sprite
end

class('Map').extends()

function Map:init(tileSizeX, tileSizeY, tileCountX, tileCountY)
  self.tilemap = Tilemap.new()

  self.tileCountX = tileCountX
  self.tileCountY = tileCountY

  self.tilemap:setImageTable(createImagetable(tileSizeX, tileSizeY))
  self.tilemap:setSize(tileCountX, tileCountY)
  self.tilemap:setTiles(createInitialTileData(tileCountX, tileCountY), tileCountX)
  self.pendingInverts = {}

  self.collisionSprites = createCollisionSprites(tileCountX, tileCountY, tileSizeX, tileSizeY)

  addWallCollisionSprite(
    -tileSizeX,
    -tileSizeY,
    tileSizeX,
    (tileCountY + 2) * tileSizeY
  )

  addWallCollisionSprite(
    tileCountX * tileSizeX,
    -tileSizeY,
    tileSizeX,
    (tileCountY + 2) * tileSizeY
  )

  addWallCollisionSprite(
    0,
    -tileSizeY,
    tileCountX * tileSizeX,
    tileSizeY
  )

  addWallCollisionSprite(
    0,
    tileCountY * tileSizeY,
    tileCountX * tileSizeX,
    tileSizeY
  )
end

function Map:draw()
  Graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
  self.tilemap:draw(0, 0)
end

function Map:rebase()
  self.pendingInverts = {}
end

function Map:commit(x, y)
  table.insert(self.pendingInverts, { x, y })
end

function Map:merge()
  for _, commit in pairs(self.pendingInverts) do
    local tileStatePosition = commit[1] + ((commit[2] - 1) * self.tileCountX)
    local index = self.tilemap:getTileAtPosition(commit[1], commit[2]);

    if (index ~= nil) then
      if (index == 1) then
        index = 2
      elseif (index == 2) then
        index = 1
      end

      local collisionSprite =  self.collisionSprites[tileStatePosition]

      if (#collisionSprite:overlappingSprites() == 0) then
        self.tilemap:setTileAtPosition(commit[1], commit[2], index)
        collisionSprite:setGroups(index)
      end
    end

  end
end
