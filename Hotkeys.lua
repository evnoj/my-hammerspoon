local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")

-- to use hyper-' as the global macOS 'minimize' hotkey
hs.hotkey.bind({ "ctrl, cmd, alt" }, "'", function()
    hs.window.focusedWindow():minimize()
end)

-- to use hyper-/ as the global macOS 'hide' command
hs.hotkey.bind({ "ctrl, cmd, alt" }, "/", function()
    hs.application.frontmostApplication():hide()
end)

-- failed experiment to send a string of keys, unknown why not working
-- hs.hotkey.bind({ "ctrl, alt" }, "9", function()
--     os.execute("sleep 5")
--     text = '98bfMqcuXnZJ4vb6pfQrHFaD1iKBbXdApouzmfDOXTF9taapiGDprqnUU1RqiEJbmdtfmeosiniLpGhVw6hP1ruLcbRW6DJLWtyEurZicAPiGwTORcOKv3R1mfVtOxFfhCgyQitMJpXrXtwDhxzyN16H8QwgBbTHfKOyBtgDdDr3wJTuuKuyG6ufcvnTCak704dTeaUV34EQMJ6XU26NBUqsghPQAAA124A8Kfusf8TOw3W1RgVTVcCUFwMgAkPaKOcZNtNDiKNUfO9MetyqvbfriC9nGQfUF4rb1FAm'

--     for i = 1, 10 do
--     -- for i = 1, #text do
--         local c = text:sub(i,i)
--         print(c)

--         if (c ~= string.upper(c)) then
--             hs.eventtap.event.newKeyEvent(c, true):post()
--             hs.eventtap.event.newKeyEvent(c, false):post()
--         else
--             hs.eventtap.event.newKeyEvent(hs.keycodes.map.shift, true):post()
--             hs.eventtap.event.newKeyEvent(c, true):post()
--             hs.eventtap.event.newKeyEvent(c, false):post()
--             hs.eventtap.event.newKeyEvent(hs.keycodes.map.shift, false):post()
--         end
--         os.execute("sleep " .. tonumber(.2))
--    end
-- end)

-- send ctrl+f2 to focus the menubar when it is hidden
-- 2024/08/09: doesnt seem to be working, using shift+cmd+? to show menu bar
-- hs.hotkey.bind({ "shift,cmd,alt" }, "m", function()
--     print("i did it")
--     eventtap.event.newKeyEvent(keycodes.map.ctrl, true):post()
--     eventtap.event.newKeyEvent("f2", true):post()
--     eventtap.event.newKeyEvent("f2", false):post()
--     eventtap.event.newKeyEvent(keycodes.map.ctrl, false):post()
-- end)

-- opens control center, to view currently playing media
-- seems like not working, haven't used
-- hs.hotkey.bind({ "ctrl, cmd, alt"}, "c", function()
--     os.execute("sleep " .. tonumber(.5)) -- if the hyper stuff is held when this executes, it causes issues. TODO: better solution integrating w/ ModifierMods
--     hs.osascript.applescript([[
--         tell application "System Events"
--             key down 63
--             key code 8
--             key up 63
--         end tell
--     ]])
-- end)

hs.hotkey.bind({ "alt" }, "pageup", function()
    eventtap.event.newKeyEvent("home", true):post()
    eventtap.event.newKeyEvent("home", false):post()
end)

hs.hotkey.bind({ "alt" }, "pagedown", function()
    eventtap.event.newKeyEvent("end", true):post()
    eventtap.event.newKeyEvent("end", false):post()
end)
