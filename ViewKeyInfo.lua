-- whenever a key is pressed, sends a notification with the name and keycode of the key that was pressed
local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")
local events   = eventtap.event.types

eventWatcher = eventtap.new({events.flagsChanged, events.keyDown}, function(ev)
    local keyInfo = ev:getKeyCode() .. "," .. keycodes.map[ev:getKeyCode()]
    hs.alert.show(keyInfo) -- 54,rightcmd 55,cmd 59,ctrl 56,shift 60,rightshift 58,alt 61,rightalt 53,escape
end):start()
