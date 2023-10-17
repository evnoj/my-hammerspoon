local midi           = require("hs.midi")
local eventtap       = require("hs.eventtap")
local events         = eventtap.event.types

local modifiers      = eventtap.event.newScrollEvent({ 0, 0 }, { "ctrl", "alt", "cmd" })
local flags          = modifiers:getFlags()

local vMidiDevice    = midi.newVirtualSource("HammerspoonMidi") -- this is a virtual midi source  set up in Audio Midi Setup native macOS app
local midiDataTables = {
    down = {
        channel = 0,
        controllerValue = 63
    },
    up = {
        channel = 0,
        controllerValue = 65
    }
}


local function tableLength(T)
    if type(T) == 'table' then
        local count = 0
        for _ in pairs(T) do count = count + 1 end
        return count
    else
        return false
    end
end

local function sameMods(mods)
    if type(mods) ~= type(flags) then return false end
    if type(mods) ~= 'table' then return false end
    if tableLength(mods) ~= tableLength(flags) then return false end

    for key1, value1 in pairs(mods) do
        local value2 = flags[key1]
        if value1 ~= value2 then
            return false
        end
    end

    return true
end

midiScrollWatcher = eventtap.new({ eventtap.event.types.scrollWheel }, function(event)
    local currentMods = event:getFlags()
    if sameMods(currentMods) then
        local direction = event:getProperty(hs.eventtap.event.properties.scrollWheelEventFixedPtDeltaAxis1)
        if direction > 0 then
            vMidiDevice:sendCommand('controlChange', midiDataTables.up)
        elseif direction < 0 then
            vMidiDevice:sendCommand('controlChange', midiDataTables.down)
        end
        return true
    end
    return false
end):start()
