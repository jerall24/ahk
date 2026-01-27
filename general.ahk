#Requires AutoHotkey v2.0

#Include text_replacements.ahk


TraySetIcon("assets\icons8-cog-wheel-32.ico")

CapsLock::Ctrl

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

#!S:: {
    DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 1)
}

; Screen dimmer toggle (overlay method - works with pixel detection)
global dimmerGui := ""
global isDimmed := false

ScrollLock:: {
    global dimmerGui, isDimmed

    if (isDimmed) {
        ; Turn off dimmer
        if (dimmerGui) {
            try dimmerGui.Destroy()
            dimmerGui := ""
        }
        isDimmed := false
        ToolTip "Screen dimmer OFF"
        SetTimer () => ToolTip(), -1000
    } else {
        ; Turn on dimmer
        dimmerGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        dimmerGui.BackColor := "Black"
        dimmerGui.MarginX := 0
        dimmerGui.MarginY := 0

        ; Show fullscreen black overlay with transparency
        dimmerGui.Show("x0 y0 w" A_ScreenWidth " h" A_ScreenHeight " NoActivate")
        WinSetTransparent(235, dimmerGui)  ; 0-255, higher = darker (200 = ~78% dark)

        isDimmed := true
        ToolTip "Screen dimmer ON"
        SetTimer () => ToolTip(), -1000
    }
}

; Function to temporarily hide dimmer for pixel operations
HideDimmerTemporarily() {
    global dimmerGui, isDimmed
    if (isDimmed && dimmerGui) {
        dimmerGui.Hide()
        return true
    }
    return false
}

; Function to restore dimmer after pixel operations
RestoreDimmer(wasHidden) {
    global dimmerGui, isDimmed
    if (wasHidden && isDimmed && dimmerGui) {
        dimmerGui.Show("NoActivate")
    }
}
