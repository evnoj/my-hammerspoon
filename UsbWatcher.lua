usbWatcher = hs.usb.watcher.new(function (ev)
    if ev.productID == 33688 then -- productID of anker mini TB dock
        if ev.eventType == 'added' then
            hs.execute('~/scripts/shell/midipipe-restart-tx6-modelcycles.sh')
            hs.timer.doAfter(2.4,function ()
                hs.application.find("MidiPipe"):hide()
            end):start()
        elseif ev.eventType == 'removed' then
            hs.execute("~/scripts/shell/find-pid-by-cmd.sh '/Applications/MidiPipe.app/Contents/MacOS/MidiPipe' | xargs kill -s kill")
        end
    end
end)

usbWatcher:start()
