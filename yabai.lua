-- https://www.joshmedeski.com/posts/customizing-yabai-with-lua/

local function alt(key, commands)
    hs.hotkey.bind({ "alt" }, key, function()
      yabai(commands)
    end)
  end

  -- alpha
  alt("f", { "window --toggle zoom-fullscreen" })
  alt("l", { "space --focus recent" })
  alt("m", { "space --toggle mission-control" })
  alt("p", { "window --toggle pip" })
  alt("g", { "space --toggle padding", "space --toggle gap" })
  alt("r", { "space --rotate 90" })
  alt("t", { "window --toggle float", "window --grid 4:4:1:1:2:2" })

  -- special characters
  alt("'", { "space --layout stack" })
  alt(";", { "space --layout bsp" })
  alt("tab", { "space --focus recent" })
