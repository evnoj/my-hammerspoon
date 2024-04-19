midiPipe = hs.application.open("MidiPipe")

local function hideOrWait()
    if hs.window.find("MidiPipe") then
        hs.window.find("MidiPipe"):application():hide()
    else
        hs.timer.doAfter(.5,hideOrWait)
    end
end

hideOrWait()

