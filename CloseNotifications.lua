-- Close all visible notifications in Notification Center.
hs.hotkey.bind({ "ctrl", "cmd", "alt" }, "x", function()
    hs.osascript.applescriptFromFile(
        os.getenv("HOME") .. "/.hammerspoon/scripts/CloseNotifications-15.1.applescript"
    )
end)
