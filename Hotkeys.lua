-- to use alt-h as the global macOS 'hide' command
hs.hotkey.bind({ "alt" }, "h", function()
    print('sup')
    hs.application.frontmostApplication():hide()
end)
