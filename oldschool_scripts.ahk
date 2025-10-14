#Requires AutoHotkey v2.0
#Include utils.ahk
#Include fixed_mode_ui.ahk

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

; Example hotkey to capture coordinates (using F6 as an example)
F6:: {
    if (!areHotkeysEnabled())
        return
    
    CaptureCoordinates()
}


Numpad1:: {
    if !areHotkeysEnabled(){
        Send("{1}")
        return
    } 

    ; Go to equipment page
    Send("{F4}")
    Sleep(Random(100, 200))
    ; Teleport crafting guild
    ClickRandomPixel(585, 251, 614, 280)

    ; Go back to inventory
    Sleep(Random(2500, 3000))
    Send("{Escape}")
    
    ; Open bank deposit box
    ClickRandomPixelOfColor(0xFF00CA, 0, 10)
    Sleep(Random(2000, 2500))
    ; Click(250, 250)
    
    ; Deposit fish
    ClickRandomPixel(369, 100, 399, 122)
    ; Sleep(Random(100, 200))
    
    ; Empty barrel
    ClickRandomPixel(372, 67, 397, 90)
    ; Sleep(Random(100, 200))
    
    Send("{Escape}")
    Sleep(Random(800, 1000))
    
    ; Teleport qp cape
    ClickRandomPixel(568, 216, 586, 240)

    ; Wait for tele to finish
    Sleep(Random(2250, 2500))
    ClickRandomPixelOfColor(0xFF00CA, 0, 10)

    ; Wait for tele to finish
    Sleep(Random(8000, 8500))
    ; Click fishing spot
    ClickRandomPixelOfColor(0xFF00CA, 0, 0)
}

Numpad2:: {
    if !areHotkeysEnabled(){
        Send("{2}")
        return
    }

    SendEvent "{Click 0 -10 R}"
}

Numpad0:: {
    if !areHotkeysEnabled(){
        Send("{0}")
        return
    }

    if !ClickRandomPixelOfColor(0xFF00CA, 0, 0, true) {
        ClickRandomPixelOfColor(0xFF00CA, 0, 0, false)
    }
}

; Ctrl+Numpad0 - Capture two bank slot positions
^Numpad0:: {
    CaptureBankSlots()
}

; Ctrl+NumpadDot - Capture two inventory slot positions
^NumpadDot:: {
    CaptureInventorySlots()
}

NumpadDot:: {
    if !areHotkeysEnabled(){
        Send("{.}")
        return
    }

    ClickRandomPixelOfColor(0xFF00CA, 0, 0, false)
}

; Function to set RuneLite window size
SetClientSize(width := 812, height := 542) { ; 796 503
    WinGetPos(&winX, &winY, &currentWidth, &currentHeight, "ahk_exe RuneLite.exe")
    WinMove(winX, winY, width, height, "ahk_exe RuneLite.exe")
    ToolTip "Window resized to: " width "x" height
    SetTimer () => ToolTip(), -2000  ; Remove tooltip after 2 seconds
}

; Hotkey to set window size (example: Alt+1 for default size)
!Numpad1:: {
    SetClientSize()  ; Uses default size 812x542
}

; Hotkey to set window size (example: Alt+1 for default size)
!Numpad2:: {
    SetClientSize(1334, 1087)  ; Uses default size 812x542
}

Numpad3::{
    if !areHotkeysEnabled(){
        Send("{3}")
        return
    }

    ClickRandomPixel(566, 216, 591, 239)
    MouseGetPos(&currentX, &currentY)
    SendEvent "{Click " (currentX + 0) " " (currentY + 31) "}"
    Sleep(Random(750, 1000))
    Send("{Space}")
}

; Function to check if color at specific coordinates matches expected color
CheckColorAtCoordinates(x, y, expectedColor) {
    try {
        currentColor := PixelGetColor(x, y)
        return (currentColor = expectedColor)
    } catch Error as e {
        ToolTip "Error checking color: " e.message
        SetTimer () => ToolTip(), -2000
        return false
    }
}

Numpad4:: {
    if !areHotkeysEnabled(){
        Send("{4}")
        return
    }
    
    ; Get window position and size
    WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_exe RuneLite.exe")
    
    ; Your specified coordinates and color (relative to window)
    relativeX := -3
    relativeY := 0
    expectedColor := 0x1E95B3
    
    ; Convert to absolute screen coordinates
    absoluteX := winX + relativeX
    absoluteY := winY + relativeY
    
    ; Move mouse to the coordinates being checked
    MouseMove(absoluteX, absoluteY, 0)
    
    ; Check if the color matches
    colorMatches := CheckColorAtCoordinates(absoluteX, absoluteY, expectedColor)
    
    ; Display result as tooltip
    result := colorMatches ? "TRUE" : "FALSE"
    currentColor := PixelGetColor(absoluteX, absoluteY)
    
    ToolTip "Color Match: " result "`nExpected: " Format("0x{:06X}", expectedColor) "`nActual: " Format("0x{:06X}", currentColor) "`nWindow: (" winX ", " winY ") + Relative: (" relativeX ", " relativeY ") = Absolute: (" absoluteX ", " absoluteY ")"
    SetTimer () => ToolTip(), -3000  ; Remove tooltip after 3 seconds
}

Numpad5:: {
    if !areHotkeysEnabled(){
        Send("{5}")
        return
    }

    ; Click special attack orb
    ClickUIElement("special_orb")
}

; TEST: Numpad6 - Test centroid-based clicking
Numpad6:: {
    if !areHotkeysEnabled(){
        Send("{6}")
        return
    }

    ; Test the new centroid function (compares to Numpad0's behavior)
    if !ClickRandomPixelOfColorCentroid(0xFF00CA, 0, 0, true) {
        ClickRandomPixelOfColorCentroid(0xFF00CA, 0, 0, false)
    }
}


