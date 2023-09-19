-- Close all visible notifications in Notification Center.
hs.hotkey.bind({ "ctrl", "cmd", "alt" }, "x", function()
    hs.osascript.javascriptFromFile(
        os.getenv("HOME") .. "/.hammerspoon/scripts/CloseNotifications.js"
    )
end)
