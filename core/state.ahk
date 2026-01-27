#Requires AutoHotkey v2.0

; ======================================
; STATE MANAGEMENT
; ======================================

SetDefaultMouseSpeed 4

; Global toggle variable
global scriptEnabled := false

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
    WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_exe RuneLite.exe")
    A_Clipboard := winX ", " winY ", " winWidth ", " winHeight
    ToolTip "Window position copied: " winX ", " winY ", " winWidth ", " winHeight
    SetTimer () => ToolTip(), -3000
}
