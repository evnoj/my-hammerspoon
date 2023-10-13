local json = hs.json

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

local floatingSnaps = {
  full = "window --grid 1:1:0:0:1:1",
  leftHalf = "window --grid 2:2:0:0:1:2",
  rightHalf = "window --grid 2:2:1:0:1:2",
  topHalf = "window --grid 2:2:0:0:2:1",
  bottomHalf = "window --grid 2:2:0:1:2:1",
  topLeftCorner = "window --grid 2:2:0:0:1:1",
  topRightCorner = "window --grid 2:2:1:0:1:1",
  bottomLeftCorner = "window --grid 2:2:0:1:1:1",
  bottomRightCorner =  "window --grid 2:2:1:1:1:1"
}

local function floatWarpRight()
  local displayJsonString = hs.execute("/usr/local/bin/yabai -m query --displays --display")
  local displayJson = json.decode(displayJsonString)
  local windowJsonString = hs.execute("/usr/local/bin/yabai -m query --windows --window")
  local windowJson = json.decode(windowJsonString)

  if windowJson.frame.h <= displayJson.frame.h / 2 and windowJson.frame.x == 0 then
    if windowJson.frame.y < displayJson.frame.h / 2 then
      yabai({ "window --grid 2:2:1:0:1:1" })
    else
      yabai({ "window --grid 2:2:1:1:1:1" })
    end
    print('hey hey')
  else
    yabai()
  end
end

hs.hotkey.bind({ "alt" }, "j", function()
  snapLeftHalf()
end)

hs.hotkey.bind({ "alt" }, "l", function()
snapRightHalf()
end)

-- alt("m", { "query --displays --display" })
alt("p", { "window --toggle pip" })
alt("g", { "space --toggle padding", "space --toggle gap" })
alt("r", { "space --rotate 90" })
alt("t", { "window --toggle float", "window --grid 4:4:1:1:2:2" })

-- special characters
alt("'", { "space --layout stack" })
alt(";", { "space --layout bsp" })
