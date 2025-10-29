#Requires AutoHotkey v2.0
#Include utils.ahk

; Fixed Mode UI Coordinate Map
; All coordinates are relative to the RuneLite window client area
; Each element has a clickable range: {x1, y1, x2, y2}
global FixedModeUI := Map(
    ; Orbs (right side of game view)
    "health_orb", {x1: 522, y1: 56, x2: 560, y2: 68},
    "prayer_orb", {x1: 521, y1: 89, x2: 562, y2: 101},
    "run_orb", {x1: 531, y1: 121, x2: 569, y2: 134},
    "special_orb", {x1: 551, y1: 145, x2: 596, y2: 158},

    ; Combat styles and tabs
    "combat_tab", {x1: 531, y1: 174, x2: 555, y2: 197},
    "skills_tab", {x1: 564, y1: 174, x2: 588, y2: 196},
    "quests_tab", {x1: 597, y1: 173, x2: 621, y2: 196},
    "inventory_tab", {x1: 630, y1: 172, x2: 655, y2: 198},
    "equipment_tab", {x1: 663, y1: 173, x2: 687, y2: 200},
    "prayer_tab", {x1: 696, y1: 174, x2: 721, y2: 198},
    "spellbook_tab", {x1: 728, y1: 172, x2: 755, y2: 198},

    ; Bank interface elements
    "bank_deposit_inventory", {x1: 425, y1: 296, x2: 458, y2: 328}

)

; Generate inventory slot coordinates (28 slots in 7 rows x 4 columns)
; Each slot has a clickable range with some margin
; Based on measured coordinates: slot 1 (563,216,593,241), slot 2 (605,214,636,241)
GenerateInventorySlots() {
    slots := Map()
    startX := 563  ; First slot x position
    startY := 216  ; First slot y position
    slotWidth := 42  ; 605 - 563 = 42
    slotHeight := 36  ; Estimated from slot height (241-216=25 visible, but actual spacing ~36)

    Loop 28 {
        row := Floor((A_Index - 1) / 4)
        col := Mod(A_Index - 1, 4)
        x1 := startX + (col * slotWidth)
        y1 := startY + (row * slotHeight)
        x2 := startX + (col * slotWidth) + 30  ; Slot width is about 30 pixels
        y2 := startY + (row * slotHeight) + 25  ; Slot height is about 25 pixels
        slots[A_Index] := {x1: x1, y1: y1, x2: x2, y2: y2}
    }
    return slots
}

; Initialize inventory slots
global InventorySlots := GenerateInventorySlots()

; Generate bank slot coordinates (48 slots in 6 rows x 8 columns)
; Based on measured coordinates:
; - First slot (1): 73, 84, 105, 111
; - Last slot row 1 (8): 409, 83, 441, 113
; - First slot row 6 (41): 75, 264, 100, 292
; - Last slot (48): 410, 263, 434, 290
GenerateBankSlots() {
    slots := Map()
    startX := 73      ; First slot x position
    startY := 84      ; First slot y position
    slotWidth := 48   ; Horizontal spacing: (409-73)/7 = 48
    slotHeight := 36  ; Vertical spacing: (264-84)/5 = 36

    Loop 48 {
        row := Floor((A_Index - 1) / 8)
        col := Mod(A_Index - 1, 8)
        x1 := startX + (col * slotWidth)
        y1 := startY + (row * slotHeight)
        x2 := startX + (col * slotWidth) + 28  ; Conservative clickable width
        y2 := startY + (row * slotHeight) + 25  ; Conservative clickable height
        slots[A_Index] := {x1: x1, y1: y1, x2: x2, y2: y2}
    }
    return slots
}

; Initialize bank slots
global BankSlots := GenerateBankSlots()

; Helper function to click a UI element by name (clicks random pixel in range)
ClickUIElement(elementName) {
    if FixedModeUI.Has(elementName) {
        coords := FixedModeUI[elementName]
        ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
        return true
    } else {
        ToolTip "UI element '" elementName "' not found"
        SetTimer () => ToolTip(), -1000
        return false
    }
}

; Helper function to click an inventory slot by number (1-28)
ClickInventorySlot(slotNumber) {
    if (slotNumber >= 1 && slotNumber <= 28) {
        coords := InventorySlots[slotNumber]
        ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
        return true
    } else {
        ToolTip "Invalid inventory slot: " slotNumber " (must be 1-28)"
        SetTimer () => ToolTip(), -1000
        return false
    }
}

; Helper function to click a bank slot by number (1-48)
ClickBankSlot(slotNumber) {
    if (slotNumber >= 1 && slotNumber <= 48) {
        coords := BankSlots[slotNumber]
        ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
        return true
    } else {
        ToolTip "Invalid bank slot: " slotNumber " (must be 1-48)"
        SetTimer () => ToolTip(), -1000
        return false
    }
}

; Helper function to get coordinates for a UI element
GetUICoords(elementName) {
    if FixedModeUI.Has(elementName) {
        return FixedModeUI[elementName]
    }
    return false
}
