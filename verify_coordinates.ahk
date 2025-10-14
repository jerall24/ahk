#Requires AutoHotkey v2.0
#Include fixed_mode_ui.ahk

; Verification Tool for Fixed Mode UI Coordinates
; Press F9 to cycle through all UI elements and verify coordinates

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

; Show startup message
ToolTip "Coordinate Verification Tool Loaded!`nPress Ctrl+Alt+F9 for help"
SetTimer () => ToolTip(), -3000
