import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "Map/map"
import "Entity/entity"

local Graphics <const> = playdate.graphics
local Sprite <const> = playdate.graphics.sprite
local Timer <const> = playdate.timer
local Display <const> = playdate.display

local TILE_SIZE_X <const> = 16
local TILE_SIZE_Y <const> = 16
local TILE_COUNT_X = Display.getWidth() / TILE_SIZE_X
local TILE_COUNT_Y = Display.getHeight() / TILE_SIZE_Y

print(TILE_COUNT_X, TILE_COUNT_Y)

math.randomseed(playdate.getSecondsSinceEpoch())

local map = nil

function setup()
    map = Map(TILE_SIZE_X, TILE_SIZE_Y, TILE_COUNT_X, TILE_COUNT_Y)

    Sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            map:draw()
        end
    )

    local displayWidth = TILE_COUNT_X * TILE_SIZE_X
    local displayHeight = TILE_COUNT_Y * TILE_SIZE_Y

    local day = Entity(
        displayWidth * 0.5,
        displayHeight * 0.25,
        12,
        12,
        2,
        map
    )

    local night = Entity(
        displayWidth * 0.5,
        displayHeight * 0.75,
        12,
        12,
        1,
        map
    )

    day:add()
    night:add()
end

setup()

function playdate.update()
    Graphics.clear()

    if (map ~= nil) then
        map:rebase()
    end

    Sprite.update()
    Timer.updateTimers()

    if (map ~= nil) then
        map:merge()
    end
end
