#Requires AutoHotkey v2.0

#Include text_replacements.ahk

Pause:: {
    Send("{Media_Play_Pause}")
}

!Right:: {
    Send("{Media_Next}")
}

!Left:: {
    Send("{Media_Prev}")
}

PgUp:: {
    currentVolume := Round(SoundGetVolume())
    newVolume := Min(currentVolume + 5, 100)
    SoundSetVolume(newVolume)
    ToolTip "Volume: " newVolume "%"
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
}

PgDn:: {
    currentVolume := Round(SoundGetVolume())
    newVolume := Max(currentVolume - 5, 0)
    SoundSetVolume(newVolume)
    ToolTip "Volume: " newVolume "%"
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
}

; Disabling CTRL+Escape to open start menu
^Esc::return

!+R::Run("C:\Users\jeral\AppData\Local\RuneLite\RuneLite.exe")