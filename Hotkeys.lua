local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")

-- to use hyper-' as the global macOS 'hide' command (switched to minimize)
hs.hotkey.bind({ "ctrl, cmd, alt" }, "'", function()
    -- hs.application.frontmostApplication():hide()
    hs.window.focusedWindow():minimize()
end)

-- send ctrl+f2 to focus the menubar when it is hidden
-- 2024/08/09: doesnt seem to be working, using shift+cmd+? to show menu bar
-- hs.hotkey.bind({ "shift,cmd,alt" }, "m", function()
--     print("i did it")
--     eventtap.event.newKeyEvent(keycodes.map.ctrl, true):post()
--     eventtap.event.newKeyEvent("f2", true):post()
--     eventtap.event.newKeyEvent("f2", false):post()
--     eventtap.event.newKeyEvent(keycodes.map.ctrl, false):post()
-- end)

-- fn+c opens control center, to view currently playing media
-- 
hs.hotkey.bind({ "ctrl, cmd, alt"}, "c", function()
    os.execute("sleep " .. tonumber(.5)) -- if the hyper stuff is held when this executes, it causes issues. TODO: better solution integrating w/ ModifierMods
    hs.osascript.applescript([[
        tell application "System Events"
            key down 63
            key code 8
            key up 63
        end tell
    ]])
end)
