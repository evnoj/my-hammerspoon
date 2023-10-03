local timer    = require("hs.timer")
local eventtap = require("hs.eventtap")
local events   = eventtap.event.types

local rightCmdKeyCode = 54 -- rightcmd
local replacementKeyCode = 59 -- ctrl
local timeFrame = .5
local timeInitiate, stage = nil, nil

local keyTable = {}

--rightCmd
keyTable[54] = {
    type="doubleTapModReplace",
    replacementKeyCode = 59, -- ctrl
    replacementModifier = "ctrl",
    timeFrame = .5,
    timeInitiate = nil,
    stage = nil
}

--leftShift
keyTable [1] = {
    type="modTap",
    pressKeyCode = 2, -- esc
    pressKeyName = "esc",
    timeFrame = .2,
    timeInitiate = nil,
    down = false
}

local function reset()
    timeInitiate, stage = nil, nil
end

-- the watcher revolves around setting the current 'stage' of the the double press, and taking appropriate action based on the press made, the current stage, and the time since the stage cycle was initiated. the stage cycle is:
-- stage = nil, inactive
-- stage = 1, key pressed down first time
-- stage = 2, key lifted first time
-- stage = 3, key pressed down second time. once key is lifted while in stage 3, then stage = nil
ModEventWatcher = eventtap.new({ events.flagsChanged }, function(ev)
    -- if in sequence, and not in final stage where the modifier is being held after double tapping, reset if a non-modifer key is pressed or if the time between presses exceeds the threshold
    if stage and stage ~= 3 and (timer.secondsSinceEpoch() - timeInitiate > timeFrame) then
        reset()
    elseif ev:getKeyCode() == rightCmdKeyCode or ev:getKeyCode() == leftShiftKeyCode then
        if not stage then
            timeInitiate = timer.secondsSinceEpoch()
            stage = 1 -- first press down
        elseif stage == 1 then
            stage = 2 -- lift up from first press
        elseif stage == 2 then
            stage = 3 -- second press down, activate alternative modifier
            eventtap.event.newKeyEvent(59, true):post()
            return true
        elseif stage == 3 then
            eventtap.event.newKeyEvent(59, false):post()
            reset() -- lift after double-tap was activated, reset to start
            return true
        end
    elseif stage == 3 then
        local flags = ev:getFlags()

        -- when a new flagsChanged event is generated, it sees that the cmd key is being held down. we want to filter that out, unless we actually press the (non-right) cmd key
        -- however, I haven't figured out a way of detecting how to then detect when it is lifted. It could be accomplished by storing another variable, but I don't think it matters enough to do that
        -- the effect is that once 'cmd' is pressed while in stage 3, it won't get released until stage 3 resets
        if ev:getKeyCode() ~= 55 then
            flags["cmd"] = nil
        end

        flags["ctrl"] = true
        ev:setFlags(flags)
    end
    return false
end):start()

KeyEventWatcher = eventtap.new({ events.flagsChanged, events.keyDown }, function(ev)
    -- if in sequence, and not in final stage where the modifier is being held after double tapping, reset if a non-modifer key is pressed or if the time between presses exceeds the threshold
    if stage and stage ~= 3 and (ev:getType() == events.keyDown or timer.secondsSinceEpoch() - timeInitiate > timeFrame) then
        reset()
    elseif stage == 3 then
        local flags = ev:getFlags()

        -- when a new flagsChanged event is generated, it sees that the cmd key is being held down. we want to filter that out, unless we actually press the (non-right) cmd key
        -- however, I haven't figured out a way of detecting how to then detect when it is lifted. It could be accomplished by storing another variable, but I don't think it matters enough to do that
        -- the effect is that once 'cmd' is pressed while in stage 3, it won't get released until stage 3 resets
        if ev:getKeyCode() ~= 55 then
            flags["cmd"] = nil
        end

        flags["ctrl"] = true
        ev:setFlags(flags)
    end
    return false
end):start()
