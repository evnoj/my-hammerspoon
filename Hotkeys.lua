-- to use alt-h as the global macOS 'hide' command
hs.hotkey.bind({ "alt" }, "h", function()
    hs.application.frontmostApplication():hide()
end)
