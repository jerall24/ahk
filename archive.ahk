; ======================================
; ARCHIVED HOTKEYS
; ======================================

; Numpad1 - Full fishing cycle: teleport to crafting guild, deposit fish in deposit box, teleport to QP guild, click fishing spot
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

; Numpad2 - Right-click 10 pixels above the current mouse position
Numpad2:: {
    if !areHotkeysEnabled(){
        Send("{2}")
        return
    }

    SendEvent "{Click 0 -10 R}"
}

; ======================================
; ARCHIVED FUNCTIONS (Removed from main scripts)
; ======================================

; F6 - Capture rectangular area coordinates with two right-clicks
; Note: Moved to archive as part of scalable keybind refactor
F6_CaptureCoordinates() {
    if (!areHotkeysEnabled())
        return

    CaptureCoordinates()
}

; NumpadDot - Click random cyan pixel (0xFF00CA) in full game view
; Note: Moved to archive as part of scalable keybind refactor
NumpadDot_ClickRandomCyan() {
    if !areHotkeysEnabled(){
        Send("{.}")
        return
    }

    ClickRandomPixelOfColor(0xFF00CA, 0, 0, false)
}

; NumpadEnter - Loop 100 times: click, short wait, click, longer wait (fishing pattern)
; Note: Moved to archive as part of scalable keybind refactor
NumpadEnter_FishingLoop() {
    if !areHotkeysEnabled(){
        Send("{Enter}")
        return
    }

    Loop 100 {
        if areHotkeysEnabled(){
            ; Show progress
            ToolTip "Click Loop: " A_Index " / 100"

            ; First click
            Click
            ; Short wait (100-200ms based on your 0.11-0.16s pattern)
            Sleep(Random(100, 200))

            ; Second click
            Click
            ; Longer wait (3000-7000ms based on your 3.55-7.09s pattern)
            Sleep(Random(3000, 7000))
        }
    }

    ; Clear tooltip when done
    ToolTip
}
