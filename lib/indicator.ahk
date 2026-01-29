#Requires AutoHotkey v2.0

; ======================================
; ACTIVITY INDICATOR
; Shows a small red dot on cursor's right wing when AHK is active
; ======================================

global ActivityIndicator := false
global ActivityIndicatorTimer := 0

; Offset from cursor hotspot (negative Y = above cursor)
global IndicatorOffsetX := 10
global IndicatorOffsetY := 10

; Create the indicator GUI (small red circle)
CreateActivityIndicator() {
    global ActivityIndicator

    ActivityIndicator := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
    ActivityIndicator.BackColor := "FF0000"

    ; Make it circular using region
    size := 6
    ActivityIndicator.Show("w" size " h" size " NoActivate Hide")

    ; Create circular region
    WinSetRegion("0-0 W" size " H" size " E", ActivityIndicator)
}

; Show the indicator and start following cursor
ShowActivityIndicator() {
    global ActivityIndicator

    if (!ActivityIndicator || !WinExist("ahk_id " ActivityIndicator.Hwnd)) {
        CreateActivityIndicator()
    }

    ; Position at cursor and show
    UpdateIndicatorPosition()
    ActivityIndicator.Show("NoActivate")

    ; Start timer to follow cursor
    SetTimer(UpdateIndicatorPosition, 10)
}

; Update indicator position to follow cursor
UpdateIndicatorPosition() {
    global ActivityIndicator, IndicatorOffsetX, IndicatorOffsetY

    if (!ActivityIndicator) {
        return
    }

    ; Save current CoordMode, switch to screen, get position, restore
    prevCoordMode := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    MouseGetPos(&x, &y)
    CoordMode("Mouse", prevCoordMode)

    newX := x + IndicatorOffsetX
    newY := y + IndicatorOffsetY
    ActivityIndicator.Move(newX, newY)
}

; Hide the indicator
HideActivityIndicator() {
    global ActivityIndicator

    ; Stop the follow timer
    SetTimer(UpdateIndicatorPosition, 0)

    if (ActivityIndicator) {
        ActivityIndicator.Hide()
    }
}
