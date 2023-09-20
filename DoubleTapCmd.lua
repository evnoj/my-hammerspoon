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

-- key we want to detect
key            = "cmd"

-- how quickly must the two single ctrl taps occur?
timeFrame      = .5

-- what to do when the double tap of ctrl occurs
action         = function()
    notify.new({ title = "Hammerspoon", informativeText = key .. " double tap detected" }):send()
end


-- Synopsis:

-- what we're looking for is 4 events within a set time period and no intervening other key events:
--  flagsChanged with only ctrl = true
--  flagsChanged with all = false
--  flagsChanged with only ctrl = true
--  flagsChanged with all = false


local timeFirstControl, firstDown, secondDown = 0, false, false

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
    timeFirstControl, firstDown, secondDown = 0, false, false
end

-- the actual workhorse

eventWatcher = eventtap.new({ events.flagsChanged, events.keyDown }, function(ev)
    if ev:getType() == events.flagsChanged then
        -- if it's been too long; previous state doesn't matter
        if not secondDown and (timer.secondsSinceEpoch() - timeFirstControl) > timeFrame then
            timeFirstControl, firstDown, secondDown = 0, false, false
        end
        if noFlags(ev) and firstDown and secondDown then -- key up and we've seen two, so do action
            hs.alert.show("double tap lifted")
            -- if action then action() end
            -- local newEvent = hs.eventtap.event.newKeyEvent(hs.keycodes.map["ctrl"], true)
            -- newEvent:setType(hs.eventtap.event.types.keyUp)
            -- newEvent:setFlags(event:getFlags())

            -- -- Post the "B" key event
            -- newEvent:post()
            reset()
            -- return true
        elseif not noFlags(ev) and onlyKey(ev) then
            if not firstDown then -- ctrl down and it's a first
                firstDown = true
                timeFirstControl = timer.secondsSinceEpoch()
            else -- ctrl down and it's the second
                secondDown = true
                hs.alert.show("double tap activated")
                -- local newEvent = hs.eventtap.event.newKeyEvent(hs.keycodes.map["ctrl"], true)
                -- newEvent:setType(hs.eventtap.event.types.keyDown)
                -- newEvent:setFlags(event:getFlags())

                -- -- Post the "B" key event
                -- newEvent:post()
                -- return true
            end
        elseif not noFlags(ev) then -- otherwise reset and start over
            reset()
        end
    else -- it was a key press, so not a lone ctrl char -- we don't care about it
        reset()
    end
    return false
end):start()
