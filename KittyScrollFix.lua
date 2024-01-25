-- kakoune struggles with trackpad scrolling in kitty, because kitty sends horizontal scroll commands when your fingers do any x-axis movement. when kakoune receives horizontal scroll commands, it moves the view to the primary cursor. this makes vertical scrolling on a trackpad difficult
-- this file prevents horizontal scrolling from being sent to kitty

local eventtap = require("hs.eventtap")

ScrollWatcher = eventtap.new({ eventtap.event.types.scrollWheel }, function(ev)
    if ev:getProperty(eventtap.event.properties.scrollWheelEventDeltaAxis2) ~= 0 then
        local loc = ev:location()
        -- iterating through the list of windows is simply too slow
        -- for i, v in ipairs(hs.window.orderedWindows()) do
        --     if v:topLeft().y <= loc.y and v:topLeft().x <= loc.x and (v:topLeft().y + v:size()._h) >= loc.y and (v:topLeft().x + v:size()._w) >= loc.x then
        --         -- print(v:application():name())
        --         break
        --     end
        --     -- print("size width: "..v:size()._w)
        --     -- print("size height: "..v:size()._h)
        --     -- for i,v in pairs(v:size()) do
        --     --     print("i: "..i)
        --     --     print("v: "..v)
        --     -- end
        -- end
    end
    -- print(ev:getProperty(eventtap.event.properties.scrollWheelEventDeltaAxis2))
end):start()
