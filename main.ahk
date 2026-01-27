#Requires AutoHotkey v2.0

; Core state and configuration
#Include core\state.ahk
#Include config\text_replacements.ahk

; UI mode definitions (must come before other modules that use them)
#Include ui\modes\fixed_mode.ahk
#Include ui\modes\medium_mode.ahk

; Library modules
#Include lib\mouse.ahk
#Include lib\color.ahk
#Include lib\wait.ahk
#Include lib\capture.ahk
#Include lib\sound.ahk

; Game-specific modules
#Include game\bank.ahk
#Include game\inventory.ahk

; UI modules
#Include ui\elements.ahk
#Include ui\resize.ahk

; Skills
#Include skills\herblore.ahk
#Include skills\construction.ahk
#Include skills\sailing.ahk
#Include skills\cooking.ahk

; Function registry (merges all registries)
#Include core\function_registry.ahk

; Profile and binding systems
#Include core\profile_system.ahk
#Include core\binding_system.ahk

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

; Ctrl+NumpadMult - Show current keybinds
^NumpadMult:: {
    ShowKeybinds()
}

; ======================================
; DYNAMIC NUMPAD HOTKEYS
; These execute whatever function is bound in the current profile
; ======================================

; Shift+Numpad0 - Try multiple syntax variations
*+Numpad0::
{
    ToolTip "Shift+Numpad0 detected!"
    SetTimer () => ToolTip(), -1000

    if (HandleBindingKeyPress("+Numpad0")) {
        return
    }
    if !areHotkeysEnabled(){
        SendInput("{Numpad0}")
        return
    }
    ExecuteBoundFunction("+Numpad0")
}

; Numpad0 (regular, no shift)
Numpad0:: {
    ; Check if we're in binding mode first
    if (HandleBindingKeyPress("Numpad0")) {
        return  ; Key press was handled by binding system
    }

    if !areHotkeysEnabled(){
        Send("{0}")
        return
    }

    ExecuteBoundFunction("Numpad0")
}

; Numpad1 (with Shift detection)
Numpad1:: {
    ; Check if Shift is held down
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+Numpad1")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{Numpad1}")
            return
        }
        ExecuteBoundFunction("+Numpad1")
        return
    }

    if (HandleBindingKeyPress("Numpad1")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{1}")
        return
    }
    ExecuteBoundFunction("Numpad1")
}

; Numpad2 (with Shift detection)
Numpad2:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+Numpad2")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{Numpad2}")
            return
        }
        ExecuteBoundFunction("+Numpad2")
        return
    }
    if (HandleBindingKeyPress("Numpad2")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{2}")
        return
    }
    ExecuteBoundFunction("Numpad2")
}

; Numpad3 (with Shift detection)
Numpad3:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+Numpad3")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{Numpad3}")
            return
        }
        ExecuteBoundFunction("+Numpad3")
        return
    }
    if (HandleBindingKeyPress("Numpad3")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{3}")
        return
    }
    ExecuteBoundFunction("Numpad3")
}

; Numpad4 (with Shift detection)
Numpad4:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+Numpad4")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{Numpad4}")
            return
        }
        ExecuteBoundFunction("+Numpad4")
        return
    }
    if (HandleBindingKeyPress("Numpad4")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{4}")
        return
    }
    ExecuteBoundFunction("Numpad4")
}

; Numpad5 (with Shift detection)
Numpad5:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+Numpad5")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{Numpad5}")
            return
        }
        ExecuteBoundFunction("+Numpad5")
        return
    }
    if (HandleBindingKeyPress("Numpad5")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{5}")
        return
    }
    ExecuteBoundFunction("Numpad5")
}

; Numpad6 (with Shift detection)
Numpad6:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+Numpad6")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{Numpad6}")
            return
        }
        ExecuteBoundFunction("+Numpad6")
        return
    }
    if (HandleBindingKeyPress("Numpad6")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{6}")
        return
    }
    ExecuteBoundFunction("Numpad6")
}

; Numpad7 (with Shift detection)
Numpad7:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+Numpad7")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{Numpad7}")
            return
        }
        ExecuteBoundFunction("+Numpad7")
        return
    }
    if (HandleBindingKeyPress("Numpad7")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{7}")
        return
    }
    ExecuteBoundFunction("Numpad7")
}

; Numpad8 (with Shift detection)
Numpad8:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+Numpad8")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{Numpad8}")
            return
        }
        ExecuteBoundFunction("+Numpad8")
        return
    }
    if (HandleBindingKeyPress("Numpad8")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{8}")
        return
    }
    ExecuteBoundFunction("Numpad8")
}

; Numpad9 (with Shift detection)
Numpad9:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+Numpad9")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{Numpad9}")
            return
        }
        ExecuteBoundFunction("+Numpad9")
        return
    }
    if (HandleBindingKeyPress("Numpad9")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{9}")
        return
    }
    ExecuteBoundFunction("Numpad9")
}

; NumpadDot (with Shift detection)
NumpadDot:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+NumpadDot")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{NumpadDot}")
            return
        }
        ExecuteBoundFunction("+NumpadDot")
        return
    }
    if (HandleBindingKeyPress("NumpadDot")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{.}")
        return
    }
    ExecuteBoundFunction("NumpadDot")
}

; NumpadEnter (with Shift detection)
NumpadEnter:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+NumpadEnter")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{NumpadEnter}")
            return
        }
        ExecuteBoundFunction("+NumpadEnter")
        return
    }
    if (HandleBindingKeyPress("NumpadEnter")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{Enter}")
        return
    }
    ExecuteBoundFunction("NumpadEnter")
}

; NumpadAdd (with Shift detection)
$NumpadAdd:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+NumpadAdd")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{NumpadAdd}")
            return
        }
        ExecuteBoundFunction("+NumpadAdd")
        return
    }
    if (HandleBindingKeyPress("NumpadAdd")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{NumpadAdd}")
        return
    }
    ExecuteBoundFunction("NumpadAdd")
}

; NumpadSub (with Shift detection)
$NumpadSub:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+NumpadSub")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{NumpadSub}")
            return
        }
        ExecuteBoundFunction("+NumpadSub")
        return
    }
    if (HandleBindingKeyPress("NumpadSub")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{NumpadSub}")
        return
    }
    ExecuteBoundFunction("NumpadSub")
}

; NumpadMult (with Shift detection)
$NumpadMult:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+NumpadMult")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{NumpadMult}")
            return
        }
        ExecuteBoundFunction("+NumpadMult")
        return
    }
    if (HandleBindingKeyPress("NumpadMult")) {
        return
    }
    if !areHotkeysEnabled(){
        Send("{NumpadMult}")
        return
    }
    ExecuteBoundFunction("NumpadMult")
}

; NumpadDiv (with Shift detection)
$NumpadDiv:: {
    if (GetKeyState("Shift", "P")) {
        if (HandleBindingKeyPress("+NumpadDiv")) {
            return
        }
        if !areHotkeysEnabled(){
            Send("+{NumpadDiv}")
            return
        }
        ExecuteBoundFunction("+NumpadDiv")
        return
    }
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
; MOUSE BUTTON REMAPPING
; ======================================

; Press Shift down with side mouse button in RuneLite
; Release by pressing Shift key on keyboard
XButton1:: {
    if !WinActive("ahk_exe RuneLite.exe") {
        Send("{XButton1}")  ; Send normal back button outside RuneLite
        return
    }

    Send("{Shift down}")
    ToolTip "Shift held (press Shift key to release)"
    SetTimer () => ToolTip(), -1000
}

; ======================================
; STATIC KEYBINDS (kept from original)
; ======================================

; Alt+S - Send Alt+S and Backspace in RuneLite
$!s:: {
    if !WinActive("ahk_exe RuneLite.exe") {
        Send("!s")  ; Send normal Alt+S outside RuneLite
        return
    }

    Send("!s")
    Sleep(50)
    Send("{Backspace}")
}

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
    Ctrl+NumpadMult  - Show current keybinds

    DYNAMIC KEYS (Bindable):
    Numpad0-9, NumpadDot, NumpadEnter, NumpadAdd, NumpadSub, NumpadMult, NumpadDiv

    STATIC KEYBINDS:
    Alt+Numpad1      - Resize window to 812x542 (fixed mode)
    Alt+Numpad2      - Resize window to 1334x1087 (larger)
    Alt+S            - Send Alt+S then Backspace (RuneLite)
    F12              - Toggle script on/off
    Alt+F12          - Reload script
    Ctrl+F12         - Show this help

    AVAILABLE FUNCTIONS:
    Use Ctrl+NumpadEnter to see all available functions
    )"

    ToolTip helpText
    SetTimer () => ToolTip(), -15000  ; Remove tooltip after 15 seconds
}
