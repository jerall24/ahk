#Requires AutoHotkey v2.0

; ======================================
; STATE MANAGEMENT
; ======================================

SetDefaultMouseSpeed 4

; Global toggle variable
global scriptEnabled := false

; Kill switch - stops current action when Ctrl+Esc is pressed
global stopCurrentAction := false
global manualStop := false  ; Set when user manually cancels (vs natural failure)

; Cancel the current action (sets flags and shows tooltip)
CancelAction() {
    global stopCurrentAction, manualStop, isRapidClick2Spots
    stopCurrentAction := true
    manualStop := true
    isRapidClick2Spots := false
    ToolTip "Action cancelled"
    SetTimer () => ToolTip(), -1000
}

; Check if action should stop (also resets the flag)
ShouldStopAction() {
    global stopCurrentAction
    if (stopCurrentAction) {
        stopCurrentAction := false
        return true
    }
    return false
}

; State file path and UI mode
global StateFilePath := A_ScriptDir "\config\state.json"
global CurrentUIMode := "fixed"  ; Default to fixed mode

; Save state to JSON file
SaveState() {
    global StateFilePath, CurrentUIMode

    jsonStr := "{`n  `"uiMode`": `"" CurrentUIMode "`"`n}"

    try {
        FileDelete(StateFilePath)
    }
    FileAppend(jsonStr, StateFilePath, "UTF-8")
}

; Load state from JSON file
LoadState() {
    global StateFilePath, CurrentUIMode

    if (!FileExist(StateFilePath)) {
        CurrentUIMode := "fixed"
        return false
    }

    try {
        jsonStr := FileRead(StateFilePath, "UTF-8")

        ; Simple parsing for uiMode
        if (RegExMatch(jsonStr, '"uiMode"\s*:\s*"(\w+)"', &match)) {
            CurrentUIMode := match[1]
        }
        return true
    } catch {
        CurrentUIMode := "fixed"
        return false
    }
}

; Set UI mode and save
SetUIMode(mode) {
    global CurrentUIMode
    CurrentUIMode := mode
    SaveState()
    ToolTip "UI Mode: " mode
    SetTimer () => ToolTip(), -1000
}

; Get current UI mode
GetUIMode() {
    global CurrentUIMode
    return CurrentUIMode
}

; Check if in fixed mode
IsFixedMode() {
    global CurrentUIMode
    return CurrentUIMode = "fixed"
}

; Check if in medium mode
IsMediumMode() {
    global CurrentUIMode
    return CurrentUIMode = "medium"
}

; Load state on script start
LoadState()

; Toggle script on/off with F12
F12:: {
    global scriptEnabled
    scriptEnabled := !scriptEnabled

    ; Update tray icon based on state
    if (scriptEnabled) {
        TraySetIcon("assets\icons8-runescape-32-active.ico")
    } else {
        TraySetIcon("assets\icons8-runescape-32-inactive.ico")
    }

    ToolTip "Script " (scriptEnabled ? "Enabled" : "Disabled")
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
}

; Reload script with Alt+F12
!F12:: {
    ToolTip "Reloading script..."
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
    Sleep(1000)
    Reload()
}

; Get window position (F10 hotkey)
F10:: {
    WinGetPos(&winX, &winY, &winWidth, &winHeight, "RuneLite ahk_class SunAwtFrame")
    A_Clipboard := winX ", " winY ", " winWidth ", " winHeight
    ToolTip "Window position copied: " winX ", " winY ", " winWidth ", " winHeight
    SetTimer () => ToolTip(), -3000
}

; ======================================
; STATUS ICON DETECTION (GLOBAL)
; ======================================

; Status icon region (client-relative) — bottom-right of game screen
; This is a RuneLite overlay that shows character activity state
global STATUS_ICON_X1 := 499
global STATUS_ICON_Y1 := 321
global STATUS_ICON_X2 := 507
global STATUS_ICON_Y2 := 330

; Status icon colors: red = idle, green = active
; Multiple red shades due to anti-aliasing and lighting variations
global STATUS_ICON_RED   := [0xE02D2D, 0xE32828, 0xDE2F2F, 0xE12B2B, 0xE22929, 0xDC3232]
global STATUS_ICON_GREEN := [0x32C850, 0x32C74F]

; Returns true if the status icon is red (character idle)
IsStatusIconIdle() {
    global STATUS_ICON_X1, STATUS_ICON_Y1, STATUS_ICON_X2, STATUS_ICON_Y2
    global STATUS_ICON_RED

    for color in STATUS_ICON_RED {
        if (ColorExistsInRect(STATUS_ICON_X1, STATUS_ICON_Y1, STATUS_ICON_X2, STATUS_ICON_Y2, color))
            return true
    }
    return false
}
