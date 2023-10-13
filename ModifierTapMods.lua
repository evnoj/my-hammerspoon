local timer    = require("hs.timer")
local eventtap = require("hs.eventtap")
local events   = eventtap.event.types

local keyTable = {
    { --rightCmd (which is the cmd that capslock is set to via macOS settings)
        type="doubleTapModReplace",
        modKeyCode = 54,
        flagOriginal = "cmd",
        replacementKeyCode = 59, -- ctrl
        flagReplacement = "ctrl",
        keyCodeThatSetsSameModifier = 55, -- non-right cmd (just cmd)
        timeFrame = .5,
        timeInitiate = nil,
        stage = nil
    },
    { --shift (left/more accurately non-right)
        type="modTap",
        modKeyCode = 56,
        pressKeyCode = 53, -- esc
        pressKeyName = "escape",
        timeFrame = .2,
        timeInitiate = nil,
        stage = nil
    }

}

local function reset(configData)
    configData.timeInitiate = nil
    configData.stage = nil
end

local function doDoubleTapModReplaceFlagsChanged(configData, event)
    -- if in sequence, and not in final stage where the modifier is being held after double tapping, reset if the time between presses exceeds the threshold
    if configData.stage and configData.stage ~= 3 and (timer.secondsSinceEpoch() - configData.timeInitiate > configData.timeFrame) then
        reset(configData)
    elseif event:getKeyCode() == configData.modKeyCode then
        if not configData.stage and event:getFlags()[configData.flagOriginal] then -- first press down
            configData.timeInitiate = timer.secondsSinceEpoch()
            configData.stage = 1
        elseif configData.stage == 1 then -- lift up from first press
            configData.stage = 2
        elseif configData.stage == 2 then -- second press down, activate alternative modifier
            configData.stage = 3
            eventtap.event.newKeyEvent(configData.replacementKeyCode, true):post()
            return true
        elseif configData.stage == 3 then -- lift after double-tap was activated
            eventtap.event.newKeyEvent(configData.replacementKeyCode, false):post()
            reset(configData)
            return true
        end
    elseif configData.stage == 3 then -- other modifier key was pressed while double-tap is activated
        local flags = event:getFlags()

        -- when a new event is generated, it sees that the original key is being held down. we want to filter that out, unless we actually press a different keycode that generates the same modifier (i.e. left vs. right modifier)
        -- however, I haven't figured out a way to then detect when it is lifted. It could be accomplished by storing another variable, but I don't think it matters enough to do that
        -- the effect is that if the modifier represented by the original key is set (by pressing a different keycode which generates that modifier) while in stage 3, it won't get released until stage 3 resets
        if event:getKeyCode() ~= configData.keyCodeThatSetsSameModifier then
            flags[configData.flagOriginal] = nil
        end

        flags[configData.flagReplacement] = true
        event:setFlags(flags)
    end
    return false
end

local function doDoubleTapModReplaceKeyDown(configData, event)
    -- if in sequence, and not in final stage where the modifier is being held after double tapping, reset if a non-modifer key is pressed
    if configData.stage and configData.stage ~=3 then
        reset(configData)
    elseif configData.stage == 3 then
        local flags = event:getFlags()

        -- when a new event is generated, it sees that the original key is being held down. we want to filter that out, unless we actually press a different keycode that generates the same modifier (i.e. left vs. right modifier)
        -- however, I haven't figured out a way to then detect when it is lifted. It could be accomplished by storing another variable, but I don't think it matters enough to do that
        -- the effect is that if the modifier represented by the original key is set (by pressing a different keycode which generates that modifier) while in stage 3, it won't get released until stage 3 resets
        if event:getKeyCode() ~= configData.keyCodeThatSetsSameModifier then
            flags[configData.flagOriginal] = nil
        end

        flags[configData.flagReplacement] = true
        event:setFlags(flags)
    end
    return false
end

local function doModTapFlagsChanged(configData, event)
    if configData.stage and (timer.secondsSinceEpoch() - configData.timeInitiate > configData.timeFrame) then
        reset(configData)
    elseif event:getKeyCode() == configData.modKeyCode then
        if not configData.stage then -- press down
            configData.timeInitiate = timer.secondsSinceEpoch()
            configData.stage = 1
        elseif configData.stage == 1 then -- lift from press, send replacement keypress
            eventtap.event.newKeyEvent(configData.pressKeyName, true):post()
            eventtap.event.newKeyEvent(configData.pressKeyName, false):post()
            reset(configData)
        end
    end
end

local function doModTapKeyDown(configData)
    if configData.stage then
        reset(configData)
    end
end

local eventProcessors = {
    doubleTapModReplace = {
        flagsChanged = doDoubleTapModReplaceFlagsChanged,
        keyDown = doDoubleTapModReplaceKeyDown
    },
    modTap = {
        flagsChanged = doModTapFlagsChanged,
        keyDown = doModTapKeyDown
    }
}

-- the watcher revolves around setting the current 'stage' of the the double press, and taking appropriate action based on the press made, the current stage, and the time since the stage cycle was initiated. the stage cycle is:
-- stage = nil, inactive
-- stage = 1, key pressed down first time
-- stage = 2, key lifted first time
-- stage = 3, key pressed down second time. once key is lifted while in stage 3, then stage = nil
ModEventWatcher = eventtap.new({ events.flagsChanged }, function(ev)
    local dontPropagate = false;
    for i,configData in ipairs(keyTable) do
        if eventProcessors[configData.type].flagsChanged(configData, ev) then
            dontPropagate = true;
        end
    end

    return dontPropagate
end):start()

KeyEventWatcher = eventtap.new({ events.keyDown }, function(ev)
    for i,configData in ipairs(keyTable) do
        eventProcessors[configData.type].keyDown(configData, ev)
    end

    return false
end):start()
