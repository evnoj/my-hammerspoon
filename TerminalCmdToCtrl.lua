local eventtap = hs.eventtap
local eventTypes = eventtap.event.types
local keycodes = hs.keycodes.map
local windowFilter = hs.window.filter


local function cmd2CtrlEventHandler(event)
  local flags = event:getFlags()
  local keycode = event:getKeyCode()

  if flags.cmd then
    flags.cmd = false
    flags.ctrl = true
  end

  if keycode == keycodes.cmd then
    keycode = keycodes.ctrl
  elseif keycode == keycodes.rightcmd then
    keycode = keycodes.rightctrl
  end

  event:setKeyCode(keycode)
  event:setFlags(flags)

  return false
end

local cmd2CtrlEventTapObj = eventtap.new({
  eventTypes.flagsChanged,
  eventTypes.keyDown,
  eventTypes.keyUp
}, cmd2CtrlEventHandler)

TerminalFocusFilter = windowFilter.new('Terminal'):subscribe({
  [windowFilter.windowFocused] = function() cmd2CtrlEventTapObj:start() end,
  [windowFilter.windowUnfocused] = function() cmd2CtrlEventTapObj:stop() end
})
