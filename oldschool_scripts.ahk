#Requires AutoHotkey v2.0
#Include utils.ahk
#Include fixed_mode_ui.ahk
#Include function_registry.ahk
#Include profile_system.ahk
#Include binding_system.ahk

; Set initial icon to inactive
TraySetIcon("assets\icons8-runescape-32-inactive.ico")

areHotkeysEnabled() {
    global scriptEnabled
    if (WinActive("ahk_exe RuneLite.exe") && scriptEnabled) {
        return true
    } else {
        ToolTip "Script Disabled"
        SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
        return false
    }
}

; ======================================
; GLOBAL KEYBINDS (Non-rebindable)
; ======================================

; Ctrl+Numpad0 - Capture two bank slots (GLOBAL - not rebindable)
^Numpad0:: {
    CaptureBankSlots()
}

; Ctrl+NumpadDot - Capture two inventory slots (GLOBAL - not rebindable)
^NumpadDot:: {
    CaptureInventorySlots()
}

; ======================================
; DYNAMIC BINDING SYSTEM
; ======================================

; Ctrl+NumpadEnter - Enter binding mode (select function and bind to key)
^NumpadEnter:: {
    EnterBindingMode()
}

; Ctrl+NumpadSub - Open profile manager
^NumpadSub:: {
    ShowProfileManager()
}

; ======================================
; DYNAMIC NUMPAD HOTKEYS
; These execute whatever function is bound in the current profile
; ======================================

; Numpad0
Numpad0:: {
    ; Check if we're in binding mode first
    if (HandleBindingKeyPress("Numpad0")) {
        return  ; Key press was handled by binding system
    }

    ; DEBUG: Always show we got here
    ToolTip "Numpad0 pressed! Checking hotkeys..."
    SetTimer () => ToolTip(), -500

    if !areHotkeysEnabled(){
        Send("{0}")
        return
    }

    ; DEBUG: Show we passed the check
    ToolTip "Hotkeys enabled, executing..."
    SetTimer () => ToolTip(), -500

    ExecuteBoundFunction("Numpad0")
}

; Numpad1
Numpad1:: {
    if (HandleBindingKeyPress("Numpad1")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{1}")
        return
    }
    ExecuteBoundFunction("Numpad1")
}

; Numpad2
Numpad2:: {
    if (HandleBindingKeyPress("Numpad2")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{2}")
        return
    }
    ExecuteBoundFunction("Numpad2")
}

; Numpad3
Numpad3:: {
    if (HandleBindingKeyPress("Numpad3")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{3}")
        return
    }
    ExecuteBoundFunction("Numpad3")
}

; Numpad4
Numpad4:: {
    if (HandleBindingKeyPress("Numpad4")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{4}")
        return
    }
    ExecuteBoundFunction("Numpad4")
}

; Numpad5
Numpad5:: {
    if (HandleBindingKeyPress("Numpad5")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{5}")
        return
    }
    ExecuteBoundFunction("Numpad5")
}

; Numpad6
Numpad6:: {
    if (HandleBindingKeyPress("Numpad6")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{6}")
        return
    }
    ExecuteBoundFunction("Numpad6")
}

; Numpad7
Numpad7:: {
    if (HandleBindingKeyPress("Numpad7")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{7}")
        return
    }
    ExecuteBoundFunction("Numpad7")
}

; Numpad8
Numpad8:: {
    if (HandleBindingKeyPress("Numpad8")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{8}")
        return
    }
    ExecuteBoundFunction("Numpad8")
}

; Numpad9
Numpad9:: {
    if (HandleBindingKeyPress("Numpad9")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{9}")
        return
    }
    ExecuteBoundFunction("Numpad9")
}

; NumpadDot
NumpadDot:: {
    if (HandleBindingKeyPress("NumpadDot")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{.}")
        return
    }
    ExecuteBoundFunction("NumpadDot")
}

; NumpadEnter
NumpadEnter:: {
    if (HandleBindingKeyPress("NumpadEnter")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{Enter}")
        return
    }
    ExecuteBoundFunction("NumpadEnter")
}

; NumpadAdd
$NumpadAdd:: {
    if (HandleBindingKeyPress("NumpadAdd")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{NumpadAdd}")
        return
    }
    ExecuteBoundFunction("NumpadAdd")
}

; NumpadSub
$NumpadSub:: {
    if (HandleBindingKeyPress("NumpadSub")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{NumpadSub}")
        return
    }
    ExecuteBoundFunction("NumpadSub")
}

; NumpadMult
$NumpadMult:: {
    if (HandleBindingKeyPress("NumpadMult")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{NumpadMult}")
        return
    }
    ExecuteBoundFunction("NumpadMult")
}

; NumpadDiv
$NumpadDiv:: {
    if (HandleBindingKeyPress("NumpadDiv")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{NumpadDiv}")
        return
    }
    ExecuteBoundFunction("NumpadDiv")
}

; ======================================
; STATIC KEYBINDS (kept from original)
; ======================================

; Helper function to set RuneLite window size
SetClientSize(width := 812, height := 542) { ; 796 503
    WinGetPos(&winX, &winY, &currentWidth, &currentHeight, "ahk_exe RuneLite.exe")
    WinMove(winX, winY, width, height, "ahk_exe RuneLite.exe")
    ToolTip "Window resized to: " width "x" height
    SetTimer () => ToolTip(), -2000  ; Remove tooltip after 2 seconds
}

; Alt+Numpad1 - Resize RuneLite window to fixed mode size (812x542)
!Numpad1:: {
    SetClientSize()  ; Uses default size 812x542
}

; Alt+Numpad2 - Resize RuneLite window to larger size (1334x1087)
!Numpad2:: {
    SetClientSize(1334, 1087)
}

; Ctrl+F12 - Show help with all available keybinds
^F12:: {
    helpText := "
    (
    === OLDSCHOOL SCRIPTS - DYNAMIC BINDING SYSTEM ===

    GLOBAL KEYBINDS (Non-rebindable):
    Ctrl+Numpad0     - Capture two bank slots
    Ctrl+NumpadDot   - Capture two inventory slots

    BINDING SYSTEM:
    Ctrl+NumpadEnter - Enter binding mode (bind function to key)
    Ctrl+NumpadSub   - Open profile manager

    DYNAMIC KEYS (Bindable):
    Numpad0-9, NumpadDot, NumpadEnter, NumpadAdd, NumpadSub, NumpadMult, NumpadDiv

    STATIC KEYBINDS:
    Alt+Numpad1      - Resize window to 812x542 (fixed mode)
    Alt+Numpad2      - Resize window to 1334x1087 (larger)
    F12              - Toggle script on/off
    Alt+F12          - Reload script
    Ctrl+F12         - Show this help

    AVAILABLE FUNCTIONS:
    - ClickCyanCentroid
    - ClickRandomCyan
    - ClickCapturedInventorySlots
    - ClickInventorySlot1And5
    - DepositAndWithdrawFromBank
    - ClickSpecialAttack
    - ResizeToFixedMode
    - ResizeToLargeMode
    )"

    ToolTip helpText
    SetTimer () => ToolTip(), -15000  ; Remove tooltip after 15 seconds
}
