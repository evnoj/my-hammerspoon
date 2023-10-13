-- https://www.joshmedeski.com/posts/customizing-yabai-with-lua/

-- Send message(s) to a running instance of yabai.
local function yabai(commands)
  for _, cmd in ipairs(commands) do
    os.execute("/usr/local/bin/yabai -m " .. cmd)
  end
end

local function alt(key, commands)
  hs.hotkey.bind({ "alt" }, key, function()
    yabai(commands)
  end)
end

local function floatWarpRight()
end

-- operations on floating windows
alt("j", { "window --grid 1:2:0:0:1:1" })
alt("l", { "window --grid 1:2:1:0:1:1" })
alt("m", { "space --toggle mission-control" })
alt("p", { "window --toggle pip" })
alt("g", { "space --toggle padding", "space --toggle gap" })
alt("r", { "space --rotate 90" })
alt("t", { "window --toggle float", "window --grid 4:4:1:1:2:2" })

-- special characters
alt("'", { "space --layout stack" })
alt(";", { "space --layout bsp" })
