local timer              = require("hs.timer")
local application        = require("hs.application")
local eventtap           = require("hs.eventtap")
local events             = eventtap.event.types
local userdataPropertyId = 42
local userdataTag        = 888

local mappings           = {
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
                kitty = true,
                WezTerm = true
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
            appExceptions = {},
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
            appExceptions = {},
            timeInitiate = nil,
            stage = nil
        }
    },
    kitty = {
        { --rightcmd (sent by capslock when mapped via macOS settings) replace w/ ctrl
            type = "modReplaceWithDoubleTapHold",
            modKeyCodes = {
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
            timeFrame = .5,
            filterOriginalFlag = true,
            keyExceptions = { -- these key combos will not use the replaced modifer when pressed while the key is held, they will use the original. their table value specifies the modifiers that must be held, and should at a minimum include the same modifier in 'flagOriginal', or else the exception will never be triggered. TODO: come up with a good way to not have to do this
                [49] = {      -- space, for cmd+space spotlight
                    cmd = true
                },
                [44] = { -- NOT WORKING: '/', for shift+cmd+? to show help menu for active app, side effect of showing menubar
                    cmd = true,
                    shift = true
                },
                [123] = { -- 123-126 are arrow keys, cmd+alt+shift+arrow is charmstone
                    cmd = true,
                    alt = true,
                    shift = true,
                    fn = true -- for an unkown reason the fn flag is also set when pressing cmd+shift+alt+arrow key, this was discovered by inspecting the generated events
                },
                [124] = {
                    cmd = true,
                    alt = true,
                    shift = true,
                    fn = true
                },
                [125] = {
                    cmd = true,
                    alt = true,
                    shift = true,
                    fn = true
                },
                [126] = {
                    cmd = true,
                    alt = true,
                    shift = true,
                    fn = true
                }

            },
            stage = nil,
            timeInitiate = nil,
            replacementActive = false
        }
    },
    WezTerm = {
        { --rightcmd (sent by capslock when mapped via macOS settings) replace w/ ctrl
            type = "modReplaceWithDoubleTapHold",
            modKeyCodes = {
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
            timeFrame = .5,
            filterOriginalFlag = true,
            keyExceptions = { -- these key combos will not use the replaced modifer when pressed while the key is held, they will use the original. their table value specifies the modifiers that must be held, and should at a minimum include the same modifier in 'flagOriginal', or else the exception will never be triggered. TODO: come up with a good way to not have to do this
                [49] = {      -- space, for cmd+space spotlight
                    cmd = true
                },
                [44] = { -- NOT WORKING: '/', for shift+cmd+? to show help menu for active app, side effect of showing menubar
                    cmd = true,
                    shift = true
                },
                [123] = { -- 123-126 are arrow keys, cmd+alt+shift+arrow is charmstone
                    cmd = true,
                    alt = true,
                    shift = true,
                    fn = true -- for an unkown reason the fn flag is also set when pressing cmd+shift+alt+arrow key, this was discovered by inspecting the generated events
                },
                [124] = {
                    cmd = true,
                    alt = true,
                    shift = true,
                    fn = true
                },
                [125] = {
                    cmd = true,
                    alt = true,
                    shift = true,
                    fn = true
                },
                [126] = {
                    cmd = true,
                    alt = true,
                    shift = true,
                    fn = true
                }

            },
            stage = nil,
            timeInitiate = nil,
            replacementActive = false
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
                eventtap.event.newKeyEvent(keyCode, true):setProperty(userdataPropertyId, userdataTag):post()
            end
            if configData.filterOriginalFlag then
                return true
            end
        elseif configData.stage == 3 then -- lift after double-tap was activated
            for keyCode in pairs(configData.replacementKeyCodes) do
                eventtap.event.newKeyEvent(keyCode, false):setProperty(userdataPropertyId, userdataTag):post()
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

local function doModReplaceWithDoubleTapHoldFlagsChanged(configData, event)
    -- local rand = math.random(1000)
    -- print(rand)
    -- print("flag is cmd: " .. tostring(event:getFlags()["cmd"]))
    -- print("replacementActive: " .. tostring(configData.replacementActive))
    -- print("keycode is" .. tostring(event:getKeyCode()))
    -- print("stage: "..tostring(configData.stage))
    -- if in sequence, and not in final stage where the modifier is being held after double tapping, reset if the time between presses exceeds the threshold
    if configData.stage and configData.stage ~= 3 and (timer.secondsSinceEpoch() - configData.timeInitiate > configData.timeFrame) then
        --     print("reseting double press stage")
        reset(configData)
    end
    if configData.modKeyCodes[event:getKeyCode()] then
        --     print("keycode detected statement entered")
        -- do stuff related to tracking the double press
        if not configData.stage and event:getFlags()[configData.flagOriginal] then -- first press down
            configData.timeInitiate = timer.secondsSinceEpoch()
            configData.stage = 1
        elseif configData.stage == 1 then -- lift up from first press
            configData.stage = 2
        elseif configData.stage == 2 then -- second press down, let the event propagate
            configData.stage = 3
            --         print(tostring(rand) .. "," .. tostring(179))
            return false
        elseif configData.stage == 3 then -- lift after double-tap was activated
            reset(configData)
            --         print(tostring(rand) .. "," .. tostring(183))
            return false
        end

        -- do stuff relating to replacing normal presses
        if not configData.replacementActive and event:getFlags()[configData.flagOriginal] then -- press down
            configData.replacementActive = true
            for keyCode in pairs(configData.replacementKeyCodes) do
                eventtap.event.newKeyEvent(keyCode, true):setProperty(userdataPropertyId, userdataTag):post()
            end
            if configData.filterOriginalFlag then
                --             print(tostring(rand) .. "," .. tostring(195))
                return true
            end
        elseif configData.replacementActive then -- lift
            --         print('lifted statement entered')
            for keyCode in pairs(configData.replacementKeyCodes) do
                eventtap.event.newKeyEvent(keyCode, false):setProperty(userdataPropertyId, userdataTag):post()
            end
            configData.replacementActive = false
            if configData.filterOriginalFlag then
                --             print(tostring(rand) .. "," .. tostring(205))
                return true
            end
        end
    end
    -- print(rand)
    return false
end

local function flagsEqual(tableA, tableB)
    -- print('running flagsequal')
    for flag in pairs(tableA) do
        -- print('tableA:'..flag)
        if not tableB[flag] then
            return false
        end
    end
    for flag in pairs(tableB) do
        -- print('tableB:'..flag)
        if not tableA[flag] then
            return false
        end
    end

    return true
end

local function doModReplaceWithDoubleTapHoldKeyDown(configData, event)
    -- handle the normal replacement
    if configData.replacementActive then
        local flags = event:getFlags()
        local keycode = event:getKeyCode()
        if configData.keyExceptions[keycode] and flagsEqual(configData.keyExceptions[keycode], flags) then
            flags[configData.flagReplacement] = nil
            flags[configData.flagOriginal] = true
        else
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
    end

    -- if in sequence, and not in final stage where the modifier is being held after double tapping, reset if a non-modifer key is pressed
    if configData.stage and configData.stage ~= 3 then
        reset(configData)
    end
    return false
end

local function doModReplaceFlagsChanged(configData, event)
    if configData.modKeyCodes[event:getKeyCode()] then
        if not configData.stage and event:getFlags()[configData.flagOriginal] then -- press down
            configData.stage = 1
            for keyCode in pairs(configData.replacementKeyCodes) do
                eventtap.event.newKeyEvent(keyCode, true):setProperty(userdataPropertyId, userdataTag):post()
            end
            if configData.filterOriginalFlag then
                return true
            end
        elseif configData.stage == 1 then -- lift
            for keyCode in pairs(configData.replacementKeyCodes) do
                eventtap.event.newKeyEvent(keyCode, false):setProperty(userdataPropertyId, userdataTag):post()
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
            eventtap.event.newKeyEvent(configData.pressKeyName, true):setProperty(userdataPropertyId, userdataTag):post()
            eventtap.event.newKeyEvent(configData.pressKeyName, false):setProperty(userdataPropertyId, userdataTag):post()
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
    -- a modifier key instead triggers a different modifier (ex. pressing the cmd key sets the ctrl modifier flag for keypresses generated while the modifier key is held down, instead of setting the cmd modifier flag as it normally would).
    -- doing a double tap on the modifier key and holding it on the 2nd tap will cause the original modifier (the same as the name of the key) to be set (ex. double-tap and holding the cmd key will cause the cmd flag to be set, instead of replacing it with ctrl)
    modReplaceWithDoubleTapHold = {
        flagsChanged = doModReplaceWithDoubleTapHoldFlagsChanged,
        keyDown = doModReplaceWithDoubleTapHoldKeyDown
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
    if ev:getProperty(userdataPropertyId) == userdataTag then
        return false
    end

    local dontPropagate = false
    for i, configData in ipairs(mappings.all) do
        if (not configData.appExceptions[activeApp]) and eventProcessors[configData.type].flagsChanged(configData, ev) then
            dontPropagate = true;
        end
    end

    if mappings[activeApp] then
        for i, configData in ipairs(mappings[activeApp]) do
            result = eventProcessors[configData.type].flagsChanged(configData, ev)
            if result then
                dontPropagate = true;
            end
        end
    end
    return dontPropagate
end):start()

KeyEventWatcher = eventtap.new({ events.keyDown }, function(ev)
    for i, configData in ipairs(mappings.all) do
        if not configData.appExceptions[activeApp] then
            eventProcessors[configData.type].keyDown(configData, ev)
        end
    end

    if mappings[activeApp] then
        for i, configData in ipairs(mappings[activeApp]) do
            eventProcessors[configData.type].keyDown(configData, ev)
        end
    end

    return false
end):start()
