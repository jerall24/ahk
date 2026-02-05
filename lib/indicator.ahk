#Requires AutoHotkey v2.0

; ======================================
; ACTIVITY INDICATOR
; Changes cursor to custom precision cursor when AHK is active
; ======================================

global IndicatorActive := false
global CustomCursorPath := A_ScriptDir "\assets\precision.cur"

; Show activity indicator - change cursor
ShowActivityIndicator() {
    global IndicatorActive, CustomCursorPath

    if (IndicatorActive) {
        return  ; Already active
    }

    ; Load and set custom cursor for the arrow (normal) cursor
    hCursor := DllCall("LoadCursorFromFile", "Str", CustomCursorPath, "Ptr")
    if (hCursor) {
        ; OCR_NORMAL = 32512 (standard arrow cursor)
        DllCall("SetSystemCursor", "Ptr", hCursor, "UInt", 32512)
        IndicatorActive := true
    }
}

; Hide activity indicator - restore default cursor
HideActivityIndicator() {
    global IndicatorActive

    if (!IndicatorActive) {
        return
    }

    ; Restore system cursors to defaults
    DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0)  ; SPI_SETCURSORS
    IndicatorActive := false
}
