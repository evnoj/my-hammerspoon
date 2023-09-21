local notify   = require("hs.notify")
local timer    = require("hs.timer")
local eventtap = require("hs.eventtap")

local events   = eventtap.event.types

-- Save this in your Hammerspoon configuration directiorn (~/.hammerspoon/)
-- You either override timeFrame and action here or after including this file from another, e.g.
--
-- ctrlDoublePress = require("ctrlDoublePress")
-- ctrlDoublePress.timeFrame = 2
-- ctrlDoublePress.action = function()
--    do something special
-- end

-- keycode we want to detect, from hs.keycodes.map
originalKeyCode = 54 -- rightcmd
replacementKeyCode = 59 -- ctrl

-- how quickly must the two single ctrl taps occur?
timeFrame = .5

-- what to do when the double tap of ctrl occurs
action = function()
    notify.new({ title = "Hammerspoon", informativeText = key .. " double tap detected" }):send()
end


-- Synopsis:

-- what we're looking for is 4 events within a set time period and no intervening other key events:
--  flagsChanged with only ctrl = true
--  flagsChanged with all = false
--  flagsChanged with only ctrl = true
--  flagsChanged with all = false


local timeInitiate, stage = 0, 0

-- verify that no keyboard flags are being pressed
local noFlags = function(ev)
    local result = true
    for k, v in pairs(ev:getFlags()) do
        if v then
            result = false
            break
        end
    end
    return result
end

-- verify that *only* the ctrl key flag is being pressed
local onlyKey = function(ev)
    local result = true
    for k, v in pairs(ev:getFlags()) do
        if k ~= key and v then
            result = false
            break
        end
    end
    return result
end

local function reset()
    timeInitiate, stage = nil, nil
end

-- the actual workhorse

eventWatcher = eventtap.new({ events.flagsChanged, events.keyDown }, function(ev)
    -- if in sequence, and not in final stage where the modifier is being held after double tapping, reset if a non-modifer key is pressed or if the time between presses exceeds the threshold
    if stage and stage ~= 3 and (ev:getType() == events.keyDown or timer.secondsSinceEpoch() - timeInitiate > timeFrame) then
        reset()
    elseif ev:getKeyCode() == originalKeyCode then
        if not stage then
            timeInitiate = timer.secondsSinceEpoch()
            stage = 1 -- first press down
        elseif stage == 1 then
            stage = 2 -- lift up from first press
        elseif stage == 2 then
            stage = 3 -- second press down, activate alternative modifier
            hs.alert.show("double tap activated")
            hs.eventtap.event.newKeyEvent(59, true):post()
            return true
        elseif stage == 3 then
            hs.eventtap.event.newKeyEvent(59, false):post()
            reset() -- lift after double-tap was activated, reset to start
            hs.alert.show("double tap lifted")
            return true
        end
    end
    return false
end):start()
