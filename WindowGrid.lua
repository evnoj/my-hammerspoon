local grid = require("hs.grid")
local window = require("hs.window")
local timer = require("hs.timer")

-- to enable snapping to a corner by pressing 2 keys in short sequence
local timeThreshold = .3
local timeOfLastSnap = 0.0
local positionLastSet

-- To easily layout windows on the screen, we use hs.grid to create
-- a 4x4 grid. If you want to use a more detailed grid, simply
-- change its dimension here
local GRID_SIZE = 2
local HALF_GRID_SIZE = GRID_SIZE / 2

grid.setGrid(GRID_SIZE .. 'x' .. GRID_SIZE)
grid.setMargins({ 0, 0 })
window.animationDuration = 0

local screenPositions       = {}
screenPositions.full        = {
    x = 0,
    y = 0,
    w = GRID_SIZE,
    h = GRID_SIZE
}
screenPositions.left        = {
    x = 0,
    y = 0,
    w = HALF_GRID_SIZE,
    h = GRID_SIZE
}
screenPositions.right       = {
    x = HALF_GRID_SIZE,
    y = 0,
    w = HALF_GRID_SIZE,
    h = GRID_SIZE
}
screenPositions.top         = {
    x = 0,
    y = 0,
    w = GRID_SIZE,
    h = HALF_GRID_SIZE
}
screenPositions.bottom      = {
    x = 0,
    y = HALF_GRID_SIZE,
    w = GRID_SIZE,
    h = HALF_GRID_SIZE
}
screenPositions.topLeft     = {
    x = 0,
    y = 0,
    w = HALF_GRID_SIZE,
    h = HALF_GRID_SIZE
}
screenPositions.topRight    = {
    x = HALF_GRID_SIZE,
    y = 0,
    w = HALF_GRID_SIZE,
    h = HALF_GRID_SIZE
}
screenPositions.bottomLeft  = {
    x = 0,
    y = HALF_GRID_SIZE,
    w = HALF_GRID_SIZE,
    h = HALF_GRID_SIZE
}
screenPositions.bottomRight = {
    x = HALF_GRID_SIZE,
    y = HALF_GRID_SIZE,
    w = HALF_GRID_SIZE,
    h = HALF_GRID_SIZE
}

-- This function will move either the specified or the focuesd
-- window to the requested screen position
local function moveWindowToPosition(screenPosition)
    local focusedWindow = window.focusedWindow()
    grid.set(focusedWindow, screenPosition)
    positionLastSet = screenPosition
    timeOfLastSnap = timer.secondsSinceEpoch()
end

hs.hotkey.bind({ "alt" }, "l", function()
    if timer.secondsSinceEpoch() - timeOfLastSnap < timeThreshold then
        if positionLastSet == screenPositions.top then
            moveWindowToPosition(screenPositions.topRight)
        elseif positionLastSet == screenPositions.bottom then
            moveWindowToPosition(screenPositions.bottomRight)
        end
    else
        moveWindowToPosition(screenPositions.right)
    end
end)

hs.hotkey.bind({ "alt" }, "j", function()
    if timer.secondsSinceEpoch() - timeOfLastSnap < timeThreshold then
        if positionLastSet == screenPositions.top then
            moveWindowToPosition(screenPositions.topLeft)
        elseif positionLastSet == screenPositions.bottom then
            moveWindowToPosition(screenPositions.bottomLeft)
        end
    else
        moveWindowToPosition(screenPositions.left)
    end
end)

hs.hotkey.bind({ "alt" }, "i", function()
    if timer.secondsSinceEpoch() - timeOfLastSnap < timeThreshold then
        if positionLastSet == screenPositions.right then
            moveWindowToPosition(screenPositions.topRight)
        elseif positionLastSet == screenPositions.left then
            moveWindowToPosition(screenPositions.topLeft)
        end
    else
        moveWindowToPosition(screenPositions.top)
    end
end)

hs.hotkey.bind({ "alt" }, "k", function()
    if timer.secondsSinceEpoch() - timeOfLastSnap < timeThreshold then
        if positionLastSet == screenPositions.right then
            moveWindowToPosition(screenPositions.bottomRight)
        elseif positionLastSet == screenPositions.left then
            moveWindowToPosition(screenPositions.bottomLeft)
        end
    else
        moveWindowToPosition(screenPositions.bottom)
    end
end)

hs.hotkey.bind({ "alt" }, ";", function()
    moveWindowToPosition(screenPositions.full)
end)
