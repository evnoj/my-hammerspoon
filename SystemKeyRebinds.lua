local eventtap = require("hs.eventtap")
local events   = eventtap.event.types

local bindings = {
    hide = {
        ogMods = { "alt" },
        ogKey = "h",
        ogKeycode = 4,
        newMods = { "cmd" },
        newKey = "h",
        newKeycode = 4,
        exclusive = true
    },
    becauseHide = { -- this lets use use cmd-h as a shortcut in apps, remember that cmd-h actually sends alt-h to the OS
        ogMods = { "cm" },
        ogKey = "h",
        ogKeycode = 4,
        newMods = { "alt" },
        newKey = "h",
        newKeycode = 4,
        exclusive = true
    }
}

local function processBinding(event, bind)
    if (event:getKeyCode() == bind.ogKeycode and ((bind.exclusive and event:getFlags():containExactly(bind.ogMods) or (not bind.exclusive and event:getFlags():contain(bind.ogMods))))) then
        local flags = event:getFlags()

        for i, mod in ipairs(bind.ogMods) do
            flags[mod] = false
        end

        for i, mod in ipairs(bind.newMods) do
            flags[mod] = true
        end

        event:setFlags(flags)
        event:setKeyCode(bind.newKeycode)
        event:post()
        return true
    else
        return false
    end
end

KeypressWatcher = eventtap.new({ events.keyDown }, function(ev)
    for name, bind in pairs(bindings) do
        local found = processBinding(ev, bind)
        if found then
            return true
        end
    end

    return false
end):start()
