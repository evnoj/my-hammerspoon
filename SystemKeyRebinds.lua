local bindings = {
    hide = {
        ogMods = { "alt" },
        ogKey = "h",
        ogKeycode = 4,
        newMods = { "cmd" },
        newKey = "h",
        newKeycode = 4,
        exclusive = true
    }
}

local function processBinding(event, bind)
    if (event:getKeyCode() == bind.ogKeycode and ((bind.exclusive and event:getFlags():containExactly(bind.ogMods) or (not bind.exclusive and event:getFlags():contain(bind.ogMods))))) then
        local flags = event:getFlags()

        for i,mod in ipairs(bind.ogMods) do
            flags[mod] = false
        end

        for i,mod in ipairs(bind.newMods) do
            flags[mod] = true
        end

        event:setFlags(flags)
        event:setKeyCode(bind.newKeycode)

        return true, event
    else
        return false
    end
end
