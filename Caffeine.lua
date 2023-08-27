caffeine = hs.menubar.new()

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
