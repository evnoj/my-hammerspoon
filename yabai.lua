local json = hs.json
local menubarHeight = 25

-- we define this function so that we can use zsh instead of the OS default shell, fish, because fish can be slow. This is copied from hs.execute, the only change is specifying zsh instead of getting the shell from os.getenv("SHELL")
local function execute(command, user_env)
  local f
  if user_env then
    f = io.popen("/bin/zsh"..[[ -l -i -c "]]..command..[["]], 'r')
  else
    f = io.popen(command, 'r')
  end
  local s = f:read('*a')
  local status, exit_type, rc = f:close()
  return s, status, exit_type, rc
end

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
  bottomRightCorner = "window --grid 2:2:1:1:1:1"
}

local function floatWarpRight()
  local displayJsonString = execute("/usr/local/bin/yabai -m query --displays --display")
  local displayJson = json.decode(displayJsonString)
  local windowJsonString = execute("/usr/local/bin/yabai -m query --windows --window")
  local windowJson = json.decode(windowJsonString)

  -- if half height and not a quadrant on the right side
  if windowJson.frame.h <= displayJson.frame.h / 2 and not (windowJson.frame.x >= displayJson.frame.w / 2) then
    if windowJson.frame.y < displayJson.frame.h / 2 then -- if top
      yabai({ floatingSnaps.topRightCorner })
    else
      yabai({ floatingSnaps.bottomRightCorner })
    end
  else
    yabai({ floatingSnaps.rightHalf })
  end
end

local function floatWarpLeft()
  local displayJsonString = execute("/usr/local/bin/yabai -m query --displays --display")
  local displayJson = json.decode(displayJsonString)
  local windowJsonString = execute("/usr/local/bin/yabai -m query --windows --window")
  local windowJson = json.decode(windowJsonString)

  -- if half height and not a quadrant on the left side
  if windowJson.frame.h <= displayJson.frame.h / 2 and not (windowJson.frame.x == 0 and windowJson.frame.w <= displayJson.frame.w / 2) then
    if windowJson.frame.y < displayJson.frame.h / 2 then -- if top
      yabai({ floatingSnaps.topLeftCorner })
    else
      yabai({ floatingSnaps.bottomLeftCorner })
    end
  else
    yabai({ floatingSnaps.leftHalf })
  end
end

local function floatWarpTop()
  local displayJsonString = execute("/usr/local/bin/yabai -m query --displays --display")
  local displayJson = json.decode(displayJsonString)
  local windowJsonString = execute("/usr/local/bin/yabai -m query --windows --window")
  local windowJson = json.decode(windowJsonString)

  -- if snapped left or right and not half-height on top
  if windowJson.frame.w <= displayJson.frame.w / 2 and not (windowJson.frame.h < displayJson.frame.h / 2 and windowJson.frame.y == menubarHeight) then
    if windowJson.frame.x == 0 then -- if left
      yabai({ floatingSnaps.topLeftCorner })
    else
      yabai({ floatingSnaps.topRightCorner })
    end
  else
    yabai({ floatingSnaps.topHalf })
  end
end

local function floatWarpBottom()
  local displayJsonString = execute("/usr/local/bin/yabai -m query --displays --display")
  local displayJson = json.decode(displayJsonString)
  local windowJsonString = execute("/usr/local/bin/yabai -m query --windows --window")
  local windowJson = json.decode(windowJsonString)

  -- if snapped left or right and not half-height on bottom
  if windowJson.frame.w <= displayJson.frame.w / 2 and not (windowJson.frame.h < displayJson.frame.h / 2 and windowJson.frame.y >= displayJson.frame.h / 2) then
    if windowJson.frame.x == 0 then -- if left
      yabai({ floatingSnaps.bottomLeftCorner })
    else
      yabai({ floatingSnaps.bottomRightCorner })
    end
  else
    yabai({ floatingSnaps.bottomHalf })
  end
end

hs.hotkey.bind({ "alt" }, "j", floatWarpLeft)
hs.hotkey.bind({ "alt" }, "l", floatWarpRight)
hs.hotkey.bind({ "alt" }, "i", floatWarpTop)
hs.hotkey.bind({ "alt" }, "k", floatWarpBottom)
hs.hotkey.bind({ "alt" }, ";", function ()
  yabai({floatingSnaps.full})
end)

-- alt("m", { "query --displays --display" })
alt("p", { "window --toggle pip" })
alt("g", { "space --toggle padding", "space --toggle gap" })
alt("r", { "space --rotate 90" })
alt("t", { "window --toggle float", "window --grid 4:4:1:1:2:2" })

-- special characters
-- alt("'", { "space --layout stack" })
-- alt(";", { "space --layout bsp" })
