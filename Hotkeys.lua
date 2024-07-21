local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")

-- to use hyper-' as the global macOS 'hide' command
hs.hotkey.bind({ "ctrl, cmd, alt" }, "'", function()
    hs.application.frontmostApplication():hide()
end)

-- send ctrl+f2 to focus the menubar when it is hidden
hs.hotkey.bind({ "shift,cmd,alt" }, "m", function()
    print("i did it")
    eventtap.event.newKeyEvent(keycodes.map.ctrl, true):post()
    eventtap.event.newKeyEvent("f2", true):post()
    eventtap.event.newKeyEvent("f2", false):post()
    eventtap.event.newKeyEvent(keycodes.map.ctrl, false):post()
end)
