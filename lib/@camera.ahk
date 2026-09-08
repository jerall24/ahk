#Requires AutoHotkey v2.0

; ======================================
; CAMERA CONTROL FUNCTIONS
; ======================================

; MoveCameraAngle - Adjust camera angle by specified direction and notches
; @param angle - Direction: "up", "down", "left", "right"
; @param notches - Number of arrow key presses (default: 1)
; @returns true on success, false on invalid direction
MoveCameraAngle(angle, notches := 1) {
    angle := StrLower(Trim(angle))

    ; Validate direction
    if (!angle || !InStr("up,down,left,right", angle)) {
        return false
    }

    ; Press the corresponding arrow key the specified number of times
    Loop notches {
        switch angle {
            case "up":
                ToolTip "New angle: " angle " " notches " times"
                SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
                Send("{Up}")
            case "down":
                Send("{Down}")
            case "left":
                Send("{Left}")
            case "right":
                Send("{Right}")
        }
        Sleep(50)  ; Small delay between presses for reliability
    }

    return true
}

; MouseMoveCameraAngle - Adjust camera angle using middle mouse button drag
; @param angle - Direction: "up", "down", "left", "right"
; @param distance - Distance to move mouse in pixels (default: 100)
; @returns true on success, false on invalid direction
MouseMoveCameraAngle(angle, distance := 100) {
    angle := StrLower(Trim(angle))

    ; Validate direction
    if (!angle || !InStr("up,down,left,right", angle)) {
        return false
    }

    ; Set coordinate mode to screen (following codebase convention)
    CoordMode "Mouse", "Screen"

    ; Get current mouse position
    MouseGetPos(&startX, &startY)

    ; Calculate target position based on direction
    targetX := startX
    targetY := startY

    switch angle {
        case "down":
            targetY := startY - distance
        case "up":
            targetY := startY + distance
        case "right":
            targetX := startX - distance
        case "left":
            targetX := startX + distance
            }

    ToolTip "Moving from (" startX ", " startY ") to (" targetX ", " targetY ")"
    SetTimer () => ToolTip(), -3000 ; Remove tooltip after 1 second
    ; Perform the middle mouse drag
    Click "Middle Down"
    Sleep(50)
    MouseMove(targetX, targetY, 10)  ; Speed: 10 (0=instant, 100=slow)
    Sleep(50)
    Click "Middle Up"
    Sleep(50)

    ; Return mouse to starting position
    MouseMove(startX, startY, 10)


    return true
}
