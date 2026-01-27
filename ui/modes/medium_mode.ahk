#Requires AutoHotkey v2.0

; Medium Mode UI Coordinate Map (1050x725 window)
; All coordinates are relative to the RuneLite window client area
; Each element has a clickable range: {x1, y1, x2, y2}
global MediumModeUI := Map(
    ; Orbs (right side of game view)
    "health_orb", {x1: 796, y1: 60, x2: 838, y2: 72},
    "prayer_orb", {x1: 796, y1: 94, x2: 838, y2: 107},
    "run_orb", {x1: 805, y1: 125, x2: 849, y2: 140},
    "special_orb", {x1: 827, y1: 151, x2: 871, y2: 162},

    ; Combat styles and tabs
    "combat_tab", {x1: 576, y1: 653, x2: 603, y2: 682},
    "skills_tab", {x1: 610, y1: 654, x2: 636, y2: 681},
    "quests_tab", {x1: 643, y1: 653, x2: 669, y2: 681},
    "inventory_tab", {x1: 676, y1: 653, x2: 703, y2: 682},
    "equipment_tab", {x1: 709, y1: 654, x2: 734, y2: 683},
    "prayer_tab", {x1: 742, y1: 653, x2: 768, y2: 682},
    "spellbook_tab", {x1: 775, y1: 653, x2: 801, y2: 681},

    ; Bank interface elements
    "bank_deposit_inventory", {x1: 560, y1: 479, x2: 594, y2: 510},
    "bank_deposit_equipment", {x1: 598, y1: 480, x2: 629, y2: 511}
)

; Generate inventory slot coordinates (28 slots in 7 rows x 4 columns)
; Based on measured coordinates: slot 1 (825, 392, 850, 420)
; Inventory size/shape same as fixed mode, just different position
GenerateMediumInventorySlots() {
    slots := Map()
    startX := 825     ; First slot x position
    startY := 392     ; First slot y position
    slotWidth := 42   ; Horizontal spacing between slots
    slotHeight := 36  ; Vertical spacing between slots

    Loop 28 {
        row := Floor((A_Index - 1) / 4)
        col := Mod(A_Index - 1, 4)
        x1 := startX + (col * slotWidth)
        y1 := startY + (row * slotHeight)
        x2 := startX + (col * slotWidth) + 30  ; Slot clickable width
        y2 := startY + (row * slotHeight) + 25  ; Slot clickable height
        slots[A_Index] := {x1: x1, y1: y1, x2: x2, y2: y2}
    }
    return slots
}

; Initialize medium mode inventory slots
global MediumInventorySlots := GenerateMediumInventorySlots()

; Generate bank slot coordinates (88 slots in 11 rows x 8 columns)
; Based on measured coordinates:
; - Slot 1: 207, 80, 239, 107
; - Slot 8: 543, 79, 574, 110
GenerateMediumBankSlots() {
    slots := Map()
    startX := 207     ; First slot x position
    startY := 80      ; First slot y position
    slotWidth := 48   ; Horizontal spacing: (543-207)/7 = 48
    slotHeight := 36  ; Vertical spacing between rows

    Loop 88 {
        row := Floor((A_Index - 1) / 8)
        col := Mod(A_Index - 1, 8)
        x1 := startX + (col * slotWidth)
        y1 := startY + (row * slotHeight)
        x2 := startX + (col * slotWidth) + 28  ; Slot clickable width
        y2 := startY + (row * slotHeight) + 25  ; Slot clickable height
        slots[A_Index] := {x1: x1, y1: y1, x2: x2, y2: y2}
    }
    return slots
}

; Initialize medium mode bank slots
global MediumBankSlots := GenerateMediumBankSlots()

; Helper function to click a UI element by name (clicks random pixel in range)
ClickMediumUIElement(elementName) {
    if MediumModeUI.Has(elementName) {
        coords := MediumModeUI[elementName]
        ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
        return true
    } else {
        ToolTip "UI element '" elementName "' not found"
        SetTimer () => ToolTip(), -1000
        return false
    }
}

; Helper function to click an inventory slot by number (1-28)
ClickMediumInventorySlot(slotNumber) {
    if (slotNumber >= 1 && slotNumber <= 28) {
        coords := MediumInventorySlots[slotNumber]
        ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
        return true
    } else {
        ToolTip "Invalid inventory slot: " slotNumber " (must be 1-28)"
        SetTimer () => ToolTip(), -1000
        return false
    }
}

; Helper function to click a bank slot by number (1-88)
ClickMediumBankSlot(slotNumber) {
    if (slotNumber >= 1 && slotNumber <= 88) {
        coords := MediumBankSlots[slotNumber]
        ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
        return true
    } else {
        ToolTip "Invalid bank slot: " slotNumber " (must be 1-88)"
        SetTimer () => ToolTip(), -1000
        return false
    }
}

; Helper function to get coordinates for a UI element
GetMediumUICoords(elementName) {
    if MediumModeUI.Has(elementName) {
        return MediumModeUI[elementName]
    }
    return false
}
