-- key is application name
-- value is table where keys are hs.application.watcher event type constants
-- and keys are functions to execute that are passed the hs.application table
local handlers = {}
handlers["Pixelmator Pro Trial"] = {}
handlers["Pixelmator Pro Trial"][hs.application.watcher.launching] = function(app)
    hs.alert("launching pixelmator")
    hs.application.launchOrFocus("/Applications/Inklet.app")
end
handlers["Pixelmator Pro Trial"][hs.application.watcher.terminated] = function(app)
    hs.application.find("inklet"):kill()
end

appWatcher = hs.application.watcher.new(function (name, event, app)
    local handler = handlers[name]
    if handler then
        handler = handler[event]
        if handler then
            handler(app)
        end
    end
end)

appWatcher:start()
