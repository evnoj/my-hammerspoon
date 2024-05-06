-- midiPipe = hs.application.open("MidiPipe")
local function hideOrWait()
    if hs.application.find("MidiPipe") then
        hs.application.find("MidiPipe"):hide()
        -- midiPipe:hide()
    else
        hs.timer.doAfter(.5,hideOrWait)
        hs.alert.show('looped')
    end
end

hideOrWait()

