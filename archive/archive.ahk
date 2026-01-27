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

; ======================================
; COORDINATE VERIFICATION TOOL
; Archived from verify_coordinates.ahk
; ======================================

; #Requires AutoHotkey v2.0
; #Include fixed_mode_ui.ahk

; Verification Tool for Fixed Mode UI Coordinates
; Press F9 to cycle through all UI elements and verify coordinates

/*
global currentIndex := 0
global elementNames := []
global isVerifying := false

; Build list of all element names
for elementName in FixedModeUI {
    elementNames.Push(elementName)
}

; Add inventory slots to the list
Loop 28 {
    elementNames.Push("inventory_slot_" A_Index)
}

; Add bank slots to the list
Loop 48 {
    elementNames.Push("bank_slot_" A_Index)
}

; F9 - Cycle through and verify coordinates
F9:: {
    global currentIndex, elementNames, isVerifying

    if (!WinActive("ahk_exe RuneLite.exe")) {
        ToolTip "RuneLite window not active!"
        SetTimer () => ToolTip(), -2000
        return
    }

    isVerifying := true
    currentIndex++

    if (currentIndex > elementNames.Length) {
        currentIndex := 1
    }

    elementName := elementNames[currentIndex]

    ; Get coordinates
    if (InStr(elementName, "inventory_slot_")) {
        slotNum := StrReplace(elementName, "inventory_slot_", "")
        coords := InventorySlots[Integer(slotNum)]
    } else if (InStr(elementName, "bank_slot_")) {
        slotNum := StrReplace(elementName, "bank_slot_", "")
        coords := BankSlots[Integer(slotNum)]
    } else {
        coords := FixedModeUI[elementName]
    }

    ; Move mouse to the center of the coordinate range (without clicking)
    centerX := (coords.x1 + coords.x2) // 2
    centerY := (coords.y1 + coords.y2) // 2
    MouseMove(centerX, centerY, 0)

    ; Show tooltip with element info
    ToolTip "Element: " elementName "`nRange: (" coords.x1 ", " coords.y1 ") to (" coords.x2 ", " coords.y2 ")`nCenter: (" centerX ", " centerY ")`n`nPress F9 for next`nPress Shift+F9 to click`nPress Ctrl+F9 to copy coords"
}

; Shift+F9 - Click current element
+F9:: {
    global currentIndex, elementNames

    if (currentIndex = 0 || currentIndex > elementNames.Length) {
        ToolTip "Press F9 first to select an element"
        SetTimer () => ToolTip(), -1000
        return
    }

    elementName := elementNames[currentIndex]

    if (InStr(elementName, "inventory_slot_")) {
        slotNum := StrReplace(elementName, "inventory_slot_", "")
        ClickInventorySlot(Integer(slotNum))
    } else if (InStr(elementName, "bank_slot_")) {
        slotNum := StrReplace(elementName, "bank_slot_", "")
        ClickBankSlot(Integer(slotNum))
    } else {
        ClickUIElement(elementName)
    }

    ToolTip "Clicked: " elementName
    SetTimer () => ToolTip(), -1000
}

; Ctrl+F9 - Copy current coordinates to clipboard
^F9:: {
    global currentIndex, elementNames

    if (currentIndex = 0 || currentIndex > elementNames.Length) {
        ToolTip "Press F9 first to select an element"
        SetTimer () => ToolTip(), -1000
        return
    }

    elementName := elementNames[currentIndex]

    if (InStr(elementName, "inventory_slot_")) {
        slotNum := StrReplace(elementName, "inventory_slot_", "")
        coords := InventorySlots[Integer(slotNum)]
    } else if (InStr(elementName, "bank_slot_")) {
        slotNum := StrReplace(elementName, "bank_slot_", "")
        coords := BankSlots[Integer(slotNum)]
    } else {
        coords := FixedModeUI[elementName]
    }

    A_Clipboard := '"{x1: ' coords.x1 ', y1: ' coords.y1 ', x2: ' coords.x2 ', y2: ' coords.y2 '}"'
    ToolTip "Coordinates copied to clipboard!`n" elementName ": {x1: " coords.x1 ", y1: " coords.y1 ", x2: " coords.x2 ", y2: " coords.y2 "}"
    SetTimer () => ToolTip(), -2000
}

; Alt+F9 - Test all inventory slots (visual sweep)
!F9:: {
    if (!WinActive("ahk_exe RuneLite.exe")) {
        ToolTip "RuneLite window not active!"
        SetTimer () => ToolTip(), -2000
        return
    }

    ToolTip "Testing all 28 inventory slots..."
    SetTimer () => ToolTip(), -1000

    Loop 28 {
        coords := InventorySlots[A_Index]
        centerX := (coords.x1 + coords.x2) // 2
        centerY := (coords.y1 + coords.y2) // 2
        MouseMove(centerX, centerY, 2)
        Sleep(100)
    }

    ToolTip "Inventory slot test complete!"
    SetTimer () => ToolTip(), -2000
}

; Shift+Alt+F9 - Test all bank slots (visual sweep)
+!F9:: {
    if (!WinActive("ahk_exe RuneLite.exe")) {
        ToolTip "RuneLite window not active!"
        SetTimer () => ToolTip(), -2000
        return
    }

    ToolTip "Testing all 48 bank slots..."
    SetTimer () => ToolTip(), -1000

    Loop 48 {
        coords := BankSlots[A_Index]
        centerX := (coords.x1 + coords.x2) // 2
        centerY := (coords.y1 + coords.y2) // 2
        MouseMove(centerX, centerY, 2)
        Sleep(50)
    }

    ToolTip "Bank slot test complete!"
    SetTimer () => ToolTip(), -2000
}

; Ctrl+Alt+F9 - Show help
^!F9:: {
    helpText := "
    (
    Fixed Mode UI Coordinate Verification Tool
    ==========================================

    F9              - Cycle through UI elements
    Shift+F9        - Click current element
    Ctrl+F9         - Copy coordinates to clipboard
    Alt+F9          - Test all inventory slots (visual sweep)
    Shift+Alt+F9    - Test all bank slots (visual sweep)
    Ctrl+Alt+F9     - Show this help

    Elements included:
    - Health, Prayer, Run, Special Attack orbs
    - All tabs (Combat, Skills, Quests, etc.)
    - All 28 inventory slots
    - All 48 bank slots
    - Combat styles/options
    )"

    ToolTip helpText
    SetTimer () => ToolTip(), -5000
}
*/
