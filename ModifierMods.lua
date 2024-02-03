local timer    = require("hs.timer")
local eventtap = require("hs.eventtap")
local events   = eventtap.event.types

local mappings = {
    all = {
        { --rightCmd (which is the cmd that capslock is set to via macOS settings) double tap and hold for ctrl
            type = "doubleTapHoldMod",
            modKeyCodes = {
                [54] = true
            },
            flagOriginal = "cmd",
            replacementKeyCodes = {
                [59] = true --ctrl
            },
            flagReplacement = {
                ctrl = true
            },
            keyCodeThatSetsSameModifier = 55, -- non-right cmd (just cmd)
            timeFrame = .5,
            filterOriginalFlag = true,
            appExceptions = {
                kitty = true
            },
            timeInitiate = nil,
            stage = nil
        },
        { --alt double tap and hold for alt+cmd+ctrl
            type = "doubleTapHoldMod",
            modKeyCodes = {
                [58] = true,
                [61] = true
            },
            flagOriginal = "alt",
            replacementKeyCodes = {
                [59] = true, -- ctrl
                [55] = true, -- cmd
            },
            flagReplacement = {
                alt = true,
                ctrl = true,
                cmd = true
            },
            keyCodeThatSetsSameModifier = nil,
            timeFrame = .5,
            filterOriginalFlag = false,
            timeInitiate = nil,
            stage = nil
        },
        { --shift (left/more accurately non-right) tap for esc
            type = "modTap",
            modKeyCodes = {
                [56] = true
            },
            flagOriginal = "shift",
            pressKeyCode = 53, -- esc
            pressKeyName = "escape",
            timeFrame = .2,
            timeInitiate = nil,
            stage = nil
        }
    },
    kitty = {
        {
            type = "modReplace",
            modKeyCodes {
                [54] = true
            },
            flagOriginal = "cmd",
            replacementKeyCodes = {
                [59] = true
            },
            flagReplacement = {
                ctrl = true
            },
            keyCodeThatSetsSameModifier = 55, -- non-right cmd (just cmd)
            filterOriginalFlag = true,
            stage = nil
        }
    }
}

local function reset(configData)
    configData.timeInitiate = nil
    configData.stage = nil
end

local function doDoubleTapHoldModFlagsChanged(configData, event)
    -- if in sequence, and not in final stage where the modifier is being held after double tapping, reset if the time between presses exceeds the threshold
    if configData.stage and configData.stage ~= 3 and (timer.secondsSinceEpoch() - configData.timeInitiate > configData.timeFrame) then
        reset(configData)
    elseif configData.modKeyCodes[event:getKeyCode()] then
        if not configData.stage and event:getFlags()[configData.flagOriginal] then -- first press down
            configData.timeInitiate = timer.secondsSinceEpoch()
            configData.stage = 1
        elseif configData.stage == 1 then -- lift up from first press
            configData.stage = 2
        elseif configData.stage == 2 then -- second press down, activate alternative modifier
            configData.stage = 3
            for keyCode in pairs(configData.replacementKeyCodes) do
                eventtap.event.newKeyEvent(keyCode, true):post()
            end
            if configData.filterOriginalFlag then
                return true
            end
        elseif configData.stage == 3 then -- lift after double-tap was activated
            for keyCode in pairs(configData.replacementKeyCodes) do
                eventtap.event.newKeyEvent(keyCode, false):post()
            end
            reset(configData)
            if configData.filterOriginalFlag then
                return true
            end
        end
    elseif configData.stage == 3 then -- other modifier key was pressed while double-tap is activated
        local flags = event:getFlags()

        -- when a new event is generated, it sees that the original key is being held down. we want to filter that out, unless we actually press a different keycode that generates the same modifier (i.e. left vs. right modifier)
        -- however, I haven't figured out a way to then detect when it is lifted. It could be accomplished by storing another variable, but I don't think it matters enough to do that
        -- the effect is that if the modifier represented by the original key is set (by pressing a different keycode which generates that modifier) while in stage 3, it won't get released until stage 3 resets
        if configData.filterOriginalFlag and event:getKeyCode() ~= configData.keyCodeThatSetsSameModifier then
            flags[configData.flagOriginal] = nil
        end

        for flag in pairs(configData.flagReplacement) do
            flags[flag] = true
        end
        event:setFlags(flags)
    end
    return false
end

local function doDoubleTapHoldModKeyDown(configData, event)
    -- if in sequence, and not in final stage where the modifier is being held after double tapping, reset if a non-modifer key is pressed
    if configData.stage and configData.stage ~= 3 then
        reset(configData)
    elseif configData.stage == 3 then
        local flags = event:getFlags()

        -- when a new event is generated, it sees that the original key is being held down. we want to filter that out, unless we actually press a different keycode that generates the same modifier (i.e. left vs. right modifier)
        -- however, I haven't figured out a way to then detect when it is lifted. It could be accomplished by storing another variable, but I don't think it matters enough to do that
        -- the effect is that if the modifier represented by the original key is set (by pressing a different keycode which generates that modifier) while in stage 3, it won't get released until stage 3 resets
        if configData.filterOriginalFlag and event:getKeyCode() ~= configData.keyCodeThatSetsSameModifier then
            flags[configData.flagOriginal] = nil
        end

        for flag in pairs(configData.flagReplacement) do
            flags[flag] = true
        end
        event:setFlags(flags)
    end
    return false
end

local function doModReplaceFlagsChanged(configData, event)
    if configData.modKeyCodes[event:getKeyCode()] then
        if not configData.stage and event:getFlags()[configData.flagOriginal] then -- press down
            configData.timeInitiate = timer.secondsSinceEpoch()
            configData.stage = 1
            for keyCode in pairs(configData.replacementKeyCodes) do
                eventtap.event.newKeyEvent(keyCode, true):post()
            end
            if configData.filterOriginalFlag then
                return true
            end
        elseif configData.stage == 1 then -- lift
            for keyCode in pairs(configData.replacementKeyCodes) do
                eventtap.event.newKeyEvent(keyCode, false):post()
            end
            reset(configData)
            if configData.filterOriginalFlag then
                return true
            end
        end
    end
end

local function doModReplaceKeyDown(configData, event)
    if configData.stage == 1 then
        local flags = event:getFlags()

        -- when a new event is generated, it sees that the original key is being held down. we want to filter that out, unless we actually press a different keycode that generates the same modifier (i.e. left vs. right modifier)
        -- however, I haven't figured out a way to then detect when it is lifted. It could be accomplished by storing another variable, but I don't think it matters enough to do that
        -- the effect is that if the modifier represented by the original key is set (by pressing a different keycode which generates that modifier) while in the active stage, it won't get released until the active stage resets
        if configData.filterOriginalFlag and event:getKeyCode() ~= configData.keyCodeThatSetsSameModifier then
            flags[configData.flagOriginal] = nil
        end

        for flag in pairs(configData.flagReplacement) do
            flags[flag] = true
        end
        event:setFlags(flags)
    end
    return false
end

local function doModTapFlagsChanged(configData, event)
    if configData.stage and (timer.secondsSinceEpoch() - configData.timeInitiate > configData.timeFrame) then
        reset(configData)
    elseif configData.modKeyCodes[event:getKeyCode()] then
        if not configData.stage and event:getFlags()[configData.flagOriginal] then -- press down
            configData.timeInitiate = timer.secondsSinceEpoch()
            configData.stage = 1
        elseif configData.stage == 1 then -- lift from press, send replacement keypress
            eventtap.event.newKeyEvent(configData.pressKeyName, true):post()
            eventtap.event.newKeyEvent(configData.pressKeyName, false):post()
            reset(configData)
        end
    end
    return false
end

local function doModTapKeyDown(configData)
    if configData.stage then
        reset(configData)
    end
end

local eventProcessors = {
    modReplace = {
        flagsChanged = doModReplaceFlagsChanged,
        keyDown = doModReplaceKeyDown
    },
    doubleTapHoldMod = {
        flagsChanged = doDoubleTapHoldModFlagsChanged,
        keyDown = doDoubleTapHoldModKeyDown
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
    for i, configData in ipairs(mappings) do
        if eventProcessors[configData.type].flagsChanged(configData, ev) then
            dontPropagate = true;
        end
    end

    return dontPropagate
end):start()

KeyEventWatcher = eventtap.new({ events.keyDown }, function(ev)
    activeApp = hs.application.frontmostApplication()
    for i, configData in ipairs(mappings.all) do
        if not configData.appExceptions[activeApp] then
            eventProcessors[configData.type].keyDown(configData, ev)
        end
    end

    for i, configData in ipairs(mappings[activeApp]) do
        eventProcessors[configData.type].keyDown(configData, ev)
    end
    return false
end):start()
