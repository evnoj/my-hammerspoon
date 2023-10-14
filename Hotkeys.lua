-- to use alt-h as the global macOS 'hide' command
hs.hotkey.bind({ "alt" }, "h", function()
    hs.application.frontmostApplication():hide()
end)

-- hotkeys for charmstone
hs.hotkey.bind({ "alt" }, "w", function()
    hs.application.frontmostApplication():hide()
end)
