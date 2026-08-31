-- intercepts bare F1-F12 presses and emits the multimedia action the key has on an Apple
-- keyboard. my external keyboard stays in plain F1-F12 mode because it's shared with other
-- devices, so the translation happens here instead of in the keyboard's firmware.

local eventtap = require("hs.eventtap")
local events   = eventtap.event.types
local props    = eventtap.event.properties
local keycodes = require("hs.keycodes").map
local spaces   = require("hs.spaces")

local M = {}

local function systemKey(name)
    return function()
        eventtap.event.newSystemKeyEvent(name, true):post()
        eventtap.event.newSystemKeyEvent(name, false):post()
    end
end

-- f5/f6 (keyboard backlight) are deliberately absent, so they pass through as plain function keys
local mappings = {
    [keycodes.f1]  = { action = systemKey("BRIGHTNESS_DOWN") },
    [keycodes.f2]  = { action = systemKey("BRIGHTNESS_UP") },
    [keycodes.f3]  = { action = spaces.toggleMissionControl, ignoreAutorepeat = true },
    [keycodes.f4]  = { action = spaces.toggleAppExpose,      ignoreAutorepeat = true },
    [keycodes.f7]  = { action = systemKey("PREVIOUS") },
    [keycodes.f8]  = { action = systemKey("PLAY") },
    [keycodes.f9]  = { action = systemKey("NEXT") },
    [keycodes.f10] = { action = systemKey("MUTE") },
    [keycodes.f11] = { action = systemKey("SOUND_DOWN") },
    [keycodes.f12] = { action = systemKey("SOUND_UP") },
}

-- macOS sets the fn flag on every fkey press whether or not fn is held (same quirk as the
-- arrow keys, see ModifierMods.lua), so fn can't be distinguished here and is ignored
local function isModified(flags)
    return flags.cmd or flags.ctrl or flags.alt or flags.shift
end

M.tap = eventtap.new({ events.keyDown, events.keyUp }, function(ev)
    local mapping = mappings[ev:getKeyCode()]

    -- a held modifier means pass through, so ctrl+f2 (menu bar), ctrl+f3 (dock) and per-app
    -- cmd+fkey bindings keep working
    if not mapping or isModified(ev:getFlags()) then
        return false
    end

    local isAutorepeat = ev:getProperty(props.keyboardEventAutorepeat) ~= 0

    -- holding f11/f12 should keep ramping the volume, but holding f3/f4 would flicker
    -- mission control open and shut
    if ev:getType() == events.keyDown and not (mapping.ignoreAutorepeat and isAutorepeat) then
        mapping.action()
    end

    return true -- swallow the keyUp as well, so nothing sees half an fkey press
end)

hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "f", function()
    if M.tap:isEnabled() then
        M.tap:stop()
        hs.alert.show("turned OFF: intercepting function keys as multimedia keys")
    else
        M.tap:start()
        hs.alert.show("turned ON: intercepting function keys as multimedia keys")
    end
end)

M.tap:start()

return M
