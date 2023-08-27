-- 2nd arg to hs.menubar.new defines an 'autosaveName' that allows menu bar item to remember position
caffeine = hs.menubar.new(true, 'caffeine')

IconActiveWhite = hs.image.imageFromPath("~/.hammerspoon/assets/CaffeineActiveWhite.png")
IconInactiveWhite = hs.image.imageFromPath("~/.hammerspoon/assets/CaffeineInactiveWhite.png")

IconActiveWhite = IconActiveWhite:setSize({w=22,h=22})
IconInactiveWhite = IconInactiveWhite:setSize({w=22,h=22})

function setCaffeineDisplay(state)
    if state then
        -- caffeine:setTitle("AWAKE")
        caffeine:setIcon(IconActiveWhite)
    else
        -- caffeine:setTitle("SLEEPY")
        caffeine:setIcon(IconInactiveWhite)
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

hs.hotkey.bind({ "ctrl", "cmd", "alt" }, "1", function()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end)
