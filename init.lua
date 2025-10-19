require("hs.ipc") -- enables CLI vs 'hs' command
local CloseNotifications = require('CloseNotifications')
local Caffeine = require('Caffeine')
local ReloadConfig = require('ReloadConfig')
local ModifierMods = require('ModifierMods')
local Hotkeys = require('Hotkeys')
local WindowGrid = require('WindowGrid')
local ScrollToMidi = require("ScrollToMidi")
local UsbWatcher = require("UsbWatcher")
-- local ViewKeyInfo = require('ViewKeyInfo')
local TerminalCmdToCtrl = require('TerminalCmdToCtrl')
-- local scratchpad = require('scratchpad')

-- set active application when it switches for any script to use
activeApp = ""

hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function(window, appName)
    activeApp = window:application():name()
end)

hs.alert.show("hammerspoon loaded")
