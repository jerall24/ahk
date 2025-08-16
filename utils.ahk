#Requires AutoHotkey v2.0

#Include text_replacements.ahk

SetDefaultMouseSpeed 4

; Toggle script on/off with F12
F12:: {
    global scriptEnabled
    scriptEnabled := !scriptEnabled
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

; Function to get the color of the pixel under the mouse
GetPixelColorUnderMouse() {
    MouseGetPos(&mouseX, &mouseY)
    return PixelGetColor(mouseX, mouseY)
}

; Function to capture coordinates for a rectangular area
CaptureCoordinates() {
    ; Wait for first right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x1, &y1)
    
    sleep(250)

    ; Wait for second right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x2, &y2)
    
    ; Format coordinates as string
    coordString := x1 ", " y1 ", " x2 ", " y2
    
    ; Copy to clipboard
    A_Clipboard := coordString
    
    ; Show tooltip confirmation
    ToolTip "Coordinates copied: " coordString
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
}

; Function to capture time between clicks
CaptureClickTime() {
    ; Wait for first click
    KeyWait("LButton", "D")
    startTime := A_TickCount
    
    Sleep(200)

    ; Wait for second click
    KeyWait("LButton", "D")
    endTime := A_TickCount
    
    ; Calculate time difference
    timeDiff := endTime - startTime
    
    ; Copy to clipboard
    A_Clipboard := timeDiff
    
    ; Show tooltip confirmation
    ToolTip "Time between clicks: " timeDiff "ms"
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
}

; Function to find and click a random pixel of a specific color

ClickRandomPixelOfColor(color, marginX := 0, marginY := 0, near_character := false) {
    ; Get window position and size
    WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_exe RuneLite.exe")
    ; top left corner: -7 3 812 542
    ; further down -10 198 812 542
    fixed_mode_x1_start := 4
    fixed_mode_y1_start := 2
    fixed_mode_x2_end := 514
    fixed_mode_y2_end := 335

    near_character_x1_start := 151
    near_character_y1_start := 88
    near_character_x2_end := 359
    near_character_y2_end := 246
    
    ; Calculate search area with margins
    if (near_character) {
        searchX1 := near_character_x1_start
        searchY1 := near_character_y1_start
        searchX2 := near_character_x2_end
        searchY2 := near_character_y2_end
    } else {
        searchX1 := fixed_mode_x1_start
        searchY1 := fixed_mode_y1_start
        searchX2 := fixed_mode_x2_end
        searchY2 := fixed_mode_y2_end
    }
    
    ToolTip "Searching for color: " color " in area: " searchX1 ", " searchY1 ", " searchX2 ", " searchY2
    SetTimer () => ToolTip(), -2000  ; Remove tooltip after 2 seconds
    
    foundPixels := []
    loopCount := 0
    Loop {
        if (loopCount >= 10)
            break
            
        if PixelSearch(&foundX, &foundY, searchX1, searchY1, searchX2, searchY2, color) {
            foundPixels.Push({x: foundX, y: foundY})
            ; Move the search area to continue finding more pixels
            searchX1 := foundX + 1
            loopCount++
        } else {
            break
        }
    }
    
    if (foundPixels.Length > 0) {
        ToolTip "Found " foundPixels.Length " pixels"
        SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
        randomIndex := Random(1, foundPixels.Length)
        targetX := foundPixels[randomIndex].x + marginX
        targetY := foundPixels[randomIndex].y + marginY
        SendEvent "{Click " targetX " " targetY "}"
        return true
    }
    
    ToolTip "No pixels found"
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
    return false
}

; Function to click a random pixel in a range
ClickRandomPixel(x1, y1, x2, y2) {
    randomX := Random(x1, x2)
    randomY := Random(y1, y2)
    SendEvent "{Click " randomX " " randomY "}"
}

; Testing Hotkey
F11:: {
    CaptureCoordinates()
}

; Example hotkey to get and display the color under the mouse
F8:: {
    color := GetPixelColorUnderMouse()
    A_Clipboard := color
}

F10:: {
    WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_exe RuneLite.exe")
    A_Clipboard := winX ", " winY ", " winWidth ", " winHeight
    ToolTip "Window position copied: " winX ", " winY ", " winWidth ", " winHeight
    SetTimer () => ToolTip(), -3000  ; Remove tooltip after 1 second
}