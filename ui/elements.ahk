#Requires AutoHotkey v2.0

; ======================================
; UI ELEMENT CLICK FUNCTIONS
; Mode-aware functions that click UI elements based on current UI mode
; ======================================

; ======================================
; BANK SLOT CLICK FUNCTIONS (Mode-aware)
; ======================================

; Generic bank slot click function
ClickBankSlotNumber(slotNumber) {
    if (IsFixedMode()) {
        if (slotNumber >= 1 && slotNumber <= 48) {
            coords := BankSlots[slotNumber]
            ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
            return true
        }
    } else {
        if (slotNumber >= 1 && slotNumber <= 88) {
            coords := MediumBankSlots[slotNumber]
            ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
            return true
        }
    }
    return false
}

; Generate individual bank slot functions (1-88 to cover both modes)
ClickBankSlot1() => ClickBankSlotNumber(1)
ClickBankSlot2() => ClickBankSlotNumber(2)
ClickBankSlot3() => ClickBankSlotNumber(3)
ClickBankSlot4() => ClickBankSlotNumber(4)
ClickBankSlot5() => ClickBankSlotNumber(5)
ClickBankSlot6() => ClickBankSlotNumber(6)
ClickBankSlot7() => ClickBankSlotNumber(7)
ClickBankSlot8() => ClickBankSlotNumber(8)
ClickBankSlot9() => ClickBankSlotNumber(9)
ClickBankSlot10() => ClickBankSlotNumber(10)
ClickBankSlot11() => ClickBankSlotNumber(11)
ClickBankSlot12() => ClickBankSlotNumber(12)
ClickBankSlot13() => ClickBankSlotNumber(13)
ClickBankSlot14() => ClickBankSlotNumber(14)
ClickBankSlot15() => ClickBankSlotNumber(15)
ClickBankSlot16() => ClickBankSlotNumber(16)
ClickBankSlot17() => ClickBankSlotNumber(17)
ClickBankSlot18() => ClickBankSlotNumber(18)
ClickBankSlot19() => ClickBankSlotNumber(19)
ClickBankSlot20() => ClickBankSlotNumber(20)
ClickBankSlot21() => ClickBankSlotNumber(21)
ClickBankSlot22() => ClickBankSlotNumber(22)
ClickBankSlot23() => ClickBankSlotNumber(23)
ClickBankSlot24() => ClickBankSlotNumber(24)
ClickBankSlot25() => ClickBankSlotNumber(25)
ClickBankSlot26() => ClickBankSlotNumber(26)
ClickBankSlot27() => ClickBankSlotNumber(27)
ClickBankSlot28() => ClickBankSlotNumber(28)
ClickBankSlot29() => ClickBankSlotNumber(29)
ClickBankSlot30() => ClickBankSlotNumber(30)
ClickBankSlot31() => ClickBankSlotNumber(31)
ClickBankSlot32() => ClickBankSlotNumber(32)
ClickBankSlot33() => ClickBankSlotNumber(33)
ClickBankSlot34() => ClickBankSlotNumber(34)
ClickBankSlot35() => ClickBankSlotNumber(35)
ClickBankSlot36() => ClickBankSlotNumber(36)
ClickBankSlot37() => ClickBankSlotNumber(37)
ClickBankSlot38() => ClickBankSlotNumber(38)
ClickBankSlot39() => ClickBankSlotNumber(39)
ClickBankSlot40() => ClickBankSlotNumber(40)
ClickBankSlot41() => ClickBankSlotNumber(41)
ClickBankSlot42() => ClickBankSlotNumber(42)
ClickBankSlot43() => ClickBankSlotNumber(43)
ClickBankSlot44() => ClickBankSlotNumber(44)
ClickBankSlot45() => ClickBankSlotNumber(45)
ClickBankSlot46() => ClickBankSlotNumber(46)
ClickBankSlot47() => ClickBankSlotNumber(47)
ClickBankSlot48() => ClickBankSlotNumber(48)
ClickBankSlot49() => ClickBankSlotNumber(49)
ClickBankSlot50() => ClickBankSlotNumber(50)
ClickBankSlot51() => ClickBankSlotNumber(51)
ClickBankSlot52() => ClickBankSlotNumber(52)
ClickBankSlot53() => ClickBankSlotNumber(53)
ClickBankSlot54() => ClickBankSlotNumber(54)
ClickBankSlot55() => ClickBankSlotNumber(55)
ClickBankSlot56() => ClickBankSlotNumber(56)
ClickBankSlot57() => ClickBankSlotNumber(57)
ClickBankSlot58() => ClickBankSlotNumber(58)
ClickBankSlot59() => ClickBankSlotNumber(59)
ClickBankSlot60() => ClickBankSlotNumber(60)
ClickBankSlot61() => ClickBankSlotNumber(61)
ClickBankSlot62() => ClickBankSlotNumber(62)
ClickBankSlot63() => ClickBankSlotNumber(63)
ClickBankSlot64() => ClickBankSlotNumber(64)
ClickBankSlot65() => ClickBankSlotNumber(65)
ClickBankSlot66() => ClickBankSlotNumber(66)
ClickBankSlot67() => ClickBankSlotNumber(67)
ClickBankSlot68() => ClickBankSlotNumber(68)
ClickBankSlot69() => ClickBankSlotNumber(69)
ClickBankSlot70() => ClickBankSlotNumber(70)
ClickBankSlot71() => ClickBankSlotNumber(71)
ClickBankSlot72() => ClickBankSlotNumber(72)
ClickBankSlot73() => ClickBankSlotNumber(73)
ClickBankSlot74() => ClickBankSlotNumber(74)
ClickBankSlot75() => ClickBankSlotNumber(75)
ClickBankSlot76() => ClickBankSlotNumber(76)
ClickBankSlot77() => ClickBankSlotNumber(77)
ClickBankSlot78() => ClickBankSlotNumber(78)
ClickBankSlot79() => ClickBankSlotNumber(79)
ClickBankSlot80() => ClickBankSlotNumber(80)
ClickBankSlot81() => ClickBankSlotNumber(81)
ClickBankSlot82() => ClickBankSlotNumber(82)
ClickBankSlot83() => ClickBankSlotNumber(83)
ClickBankSlot84() => ClickBankSlotNumber(84)
ClickBankSlot85() => ClickBankSlotNumber(85)
ClickBankSlot86() => ClickBankSlotNumber(86)
ClickBankSlot87() => ClickBankSlotNumber(87)
ClickBankSlot88() => ClickBankSlotNumber(88)

; ======================================
; INVENTORY SLOT CLICK FUNCTIONS (Mode-aware)
; ======================================

; Generic inventory slot click function
ClickInventorySlotNumber(slotNumber) {
    if (slotNumber >= 1 && slotNumber <= 28) {
        if (IsFixedMode()) {
            coords := InventorySlots[slotNumber]
        } else {
            coords := MediumInventorySlots[slotNumber]
        }
        ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
        return true
    }
    return false
}

; Generate individual inventory slot functions (1-28)
ClickInvSlot1() => ClickInventorySlotNumber(1)
ClickInvSlot2() => ClickInventorySlotNumber(2)
ClickInvSlot3() => ClickInventorySlotNumber(3)
ClickInvSlot4() => ClickInventorySlotNumber(4)
ClickInvSlot5() => ClickInventorySlotNumber(5)
ClickInvSlot6() => ClickInventorySlotNumber(6)
ClickInvSlot7() => ClickInventorySlotNumber(7)
ClickInvSlot8() => ClickInventorySlotNumber(8)
ClickInvSlot9() => ClickInventorySlotNumber(9)
ClickInvSlot10() => ClickInventorySlotNumber(10)
ClickInvSlot11() => ClickInventorySlotNumber(11)
ClickInvSlot12() => ClickInventorySlotNumber(12)
ClickInvSlot13() => ClickInventorySlotNumber(13)
ClickInvSlot14() => ClickInventorySlotNumber(14)
ClickInvSlot15() => ClickInventorySlotNumber(15)
ClickInvSlot16() => ClickInventorySlotNumber(16)
ClickInvSlot17() => ClickInventorySlotNumber(17)
ClickInvSlot18() => ClickInventorySlotNumber(18)
ClickInvSlot19() => ClickInventorySlotNumber(19)
ClickInvSlot20() => ClickInventorySlotNumber(20)
ClickInvSlot21() => ClickInventorySlotNumber(21)
ClickInvSlot22() => ClickInventorySlotNumber(22)
ClickInvSlot23() => ClickInventorySlotNumber(23)
ClickInvSlot24() => ClickInventorySlotNumber(24)
ClickInvSlot25() => ClickInventorySlotNumber(25)
ClickInvSlot26() => ClickInventorySlotNumber(26)
ClickInvSlot27() => ClickInventorySlotNumber(27)
ClickInvSlot28() => ClickInventorySlotNumber(28)

; ======================================
; DROP INVENTORY SLOT FUNCTIONS
; ======================================

; Drop a single inventory slot by shift-clicking (mode-aware)
; Ensures shift is released even if click fails
DropInventorySlotNumber(slotNumber) {
    if (slotNumber < 1 || slotNumber > 28) {
        return false
    }

    try {
        Send("{Shift down}")
        Sleep(Random(30, 60))
        ClickInventorySlotNumber(slotNumber)
        Sleep(Random(30, 60))
    } finally {
        Send("{Shift up}")
    }

    return true
}

; Generate individual drop slot functions (1-28)
DropInvSlot1() => DropInventorySlotNumber(1)
DropInvSlot2() => DropInventorySlotNumber(2)
DropInvSlot3() => DropInventorySlotNumber(3)
DropInvSlot4() => DropInventorySlotNumber(4)
DropInvSlot5() => DropInventorySlotNumber(5)
DropInvSlot6() => DropInventorySlotNumber(6)
DropInvSlot7() => DropInventorySlotNumber(7)
DropInvSlot8() => DropInventorySlotNumber(8)
DropInvSlot9() => DropInventorySlotNumber(9)
DropInvSlot10() => DropInventorySlotNumber(10)
DropInvSlot11() => DropInventorySlotNumber(11)
DropInvSlot12() => DropInventorySlotNumber(12)
DropInvSlot13() => DropInventorySlotNumber(13)
DropInvSlot14() => DropInventorySlotNumber(14)
DropInvSlot15() => DropInventorySlotNumber(15)
DropInvSlot16() => DropInventorySlotNumber(16)
DropInvSlot17() => DropInventorySlotNumber(17)
DropInvSlot18() => DropInventorySlotNumber(18)
DropInvSlot19() => DropInventorySlotNumber(19)
DropInvSlot20() => DropInventorySlotNumber(20)
DropInvSlot21() => DropInventorySlotNumber(21)
DropInvSlot22() => DropInventorySlotNumber(22)
DropInvSlot23() => DropInventorySlotNumber(23)
DropInvSlot24() => DropInventorySlotNumber(24)
DropInvSlot25() => DropInventorySlotNumber(25)
DropInvSlot26() => DropInventorySlotNumber(26)
DropInvSlot27() => DropInventorySlotNumber(27)
DropInvSlot28() => DropInventorySlotNumber(28)

; ======================================
; ORB AND TAB CLICK FUNCTIONS
; ======================================

; Click health orb
ClickHealthOrb() {
    if (IsFixedMode()) {
        coords := FixedModeUI["health_orb"]
    } else {
        coords := MediumModeUI["health_orb"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click prayer orb
ClickPrayerOrb() {
    if (IsFixedMode()) {
        coords := FixedModeUI["prayer_orb"]
    } else {
        coords := MediumModeUI["prayer_orb"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click run orb
ClickRunOrb() {
    if (IsFixedMode()) {
        coords := FixedModeUI["run_orb"]
    } else {
        coords := MediumModeUI["run_orb"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click special attack orb
ClickSpecialOrb() {
    if (IsFixedMode()) {
        coords := FixedModeUI["special_orb"]
    } else {
        coords := MediumModeUI["special_orb"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click combat tab
ClickCombatTab() {
    if (IsFixedMode()) {
        coords := FixedModeUI["combat_tab"]
    } else {
        coords := MediumModeUI["combat_tab"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click skills tab
ClickSkillsTab() {
    if (IsFixedMode()) {
        coords := FixedModeUI["skills_tab"]
    } else {
        coords := MediumModeUI["skills_tab"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click quests tab
ClickQuestsTab() {
    if (IsFixedMode()) {
        coords := FixedModeUI["quests_tab"]
    } else {
        coords := MediumModeUI["quests_tab"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click inventory tab
ClickInventoryTab() {
    if (IsFixedMode()) {
        coords := FixedModeUI["inventory_tab"]
    } else {
        coords := MediumModeUI["inventory_tab"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click equipment tab
ClickEquipmentTab() {
    if (IsFixedMode()) {
        coords := FixedModeUI["equipment_tab"]
    } else {
        coords := MediumModeUI["equipment_tab"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click prayer tab
ClickPrayerTab() {
    if (IsFixedMode()) {
        coords := FixedModeUI["prayer_tab"]
    } else {
        coords := MediumModeUI["prayer_tab"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click spellbook tab
ClickSpellbookTab() {
    if (IsFixedMode()) {
        coords := FixedModeUI["spellbook_tab"]
    } else {
        coords := MediumModeUI["spellbook_tab"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click bank deposit inventory button
ClickBankDepositInventory() {
    if (IsFixedMode()) {
        coords := FixedModeUI["bank_deposit_inventory"]
    } else {
        coords := MediumModeUI["bank_deposit_inventory"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; Click bank deposit equipment button
ClickBankDepositEquipment() {
    if (IsFixedMode()) {
        coords := FixedModeUI["bank_deposit_equipment"]
    } else {
        coords := MediumModeUI["bank_deposit_equipment"]
    }
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2)
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global UIElementFunctionsRegistry := Map(
    ; Special selectors (handled by binding system grid picker)
    "[Select Bank Slot...]", {
        name: "[Select Bank Slot...]",
        func: (*) => "",
        description: "Opens grid to select a specific bank slot to bind"
    },
    "[Select Inventory Slot...]", {
        name: "[Select Inventory Slot...]",
        func: (*) => "",
        description: "Opens grid to select a specific inventory slot to bind"
    },
    "[Select Drop Slot...]", {
        name: "[Select Drop Slot...]",
        func: (*) => "",
        description: "Opens grid to select a specific drop slot to bind"
    },
    "ClickHealthOrb", {
        name: "ClickHealthOrb",
        func: ClickHealthOrb,
        description: "Click health orb (mode-aware)"
    },
    "ClickPrayerOrb", {
        name: "ClickPrayerOrb",
        func: ClickPrayerOrb,
        description: "Click prayer orb (mode-aware)"
    },
    "ClickRunOrb", {
        name: "ClickRunOrb",
        func: ClickRunOrb,
        description: "Click run orb (mode-aware)"
    },
    "ClickSpecialOrb", {
        name: "ClickSpecialOrb",
        func: ClickSpecialOrb,
        description: "Click special attack orb (mode-aware)"
    },
    "ClickCombatTab", {
        name: "ClickCombatTab",
        func: ClickCombatTab,
        description: "Click combat tab (mode-aware)"
    },
    "ClickSkillsTab", {
        name: "ClickSkillsTab",
        func: ClickSkillsTab,
        description: "Click skills tab (mode-aware)"
    },
    "ClickQuestsTab", {
        name: "ClickQuestsTab",
        func: ClickQuestsTab,
        description: "Click quests tab (mode-aware)"
    },
    "ClickInventoryTab", {
        name: "ClickInventoryTab",
        func: ClickInventoryTab,
        description: "Click inventory tab (mode-aware)"
    },
    "ClickEquipmentTab", {
        name: "ClickEquipmentTab",
        func: ClickEquipmentTab,
        description: "Click equipment tab (mode-aware)"
    },
    "ClickPrayerTab", {
        name: "ClickPrayerTab",
        func: ClickPrayerTab,
        description: "Click prayer tab (mode-aware)"
    },
    "ClickSpellbookTab", {
        name: "ClickSpellbookTab",
        func: ClickSpellbookTab,
        description: "Click spellbook tab (mode-aware)"
    },
    "ClickBankDepositInventory", {
        name: "ClickBankDepositInventory",
        func: ClickBankDepositInventory,
        description: "Click bank deposit inventory button (mode-aware)"
    },
    "ClickBankDepositEquipment", {
        name: "ClickBankDepositEquipment",
        func: ClickBankDepositEquipment,
        description: "Click bank deposit equipment button (mode-aware)"
    }
)

; Add bank slot functions to registry (generated dynamically)
global BankSlotFunctionsRegistry := Map()
global InventorySlotFunctionsRegistry := Map()

; Bank slot function references
global BankSlotFunctions := Map(
    1, ClickBankSlot1, 2, ClickBankSlot2, 3, ClickBankSlot3, 4, ClickBankSlot4,
    5, ClickBankSlot5, 6, ClickBankSlot6, 7, ClickBankSlot7, 8, ClickBankSlot8,
    9, ClickBankSlot9, 10, ClickBankSlot10, 11, ClickBankSlot11, 12, ClickBankSlot12,
    13, ClickBankSlot13, 14, ClickBankSlot14, 15, ClickBankSlot15, 16, ClickBankSlot16,
    17, ClickBankSlot17, 18, ClickBankSlot18, 19, ClickBankSlot19, 20, ClickBankSlot20,
    21, ClickBankSlot21, 22, ClickBankSlot22, 23, ClickBankSlot23, 24, ClickBankSlot24,
    25, ClickBankSlot25, 26, ClickBankSlot26, 27, ClickBankSlot27, 28, ClickBankSlot28,
    29, ClickBankSlot29, 30, ClickBankSlot30, 31, ClickBankSlot31, 32, ClickBankSlot32,
    33, ClickBankSlot33, 34, ClickBankSlot34, 35, ClickBankSlot35, 36, ClickBankSlot36,
    37, ClickBankSlot37, 38, ClickBankSlot38, 39, ClickBankSlot39, 40, ClickBankSlot40,
    41, ClickBankSlot41, 42, ClickBankSlot42, 43, ClickBankSlot43, 44, ClickBankSlot44,
    45, ClickBankSlot45, 46, ClickBankSlot46, 47, ClickBankSlot47, 48, ClickBankSlot48,
    49, ClickBankSlot49, 50, ClickBankSlot50, 51, ClickBankSlot51, 52, ClickBankSlot52,
    53, ClickBankSlot53, 54, ClickBankSlot54, 55, ClickBankSlot55, 56, ClickBankSlot56,
    57, ClickBankSlot57, 58, ClickBankSlot58, 59, ClickBankSlot59, 60, ClickBankSlot60,
    61, ClickBankSlot61, 62, ClickBankSlot62, 63, ClickBankSlot63, 64, ClickBankSlot64,
    65, ClickBankSlot65, 66, ClickBankSlot66, 67, ClickBankSlot67, 68, ClickBankSlot68,
    69, ClickBankSlot69, 70, ClickBankSlot70, 71, ClickBankSlot71, 72, ClickBankSlot72,
    73, ClickBankSlot73, 74, ClickBankSlot74, 75, ClickBankSlot75, 76, ClickBankSlot76,
    77, ClickBankSlot77, 78, ClickBankSlot78, 79, ClickBankSlot79, 80, ClickBankSlot80,
    81, ClickBankSlot81, 82, ClickBankSlot82, 83, ClickBankSlot83, 84, ClickBankSlot84,
    85, ClickBankSlot85, 86, ClickBankSlot86, 87, ClickBankSlot87, 88, ClickBankSlot88
)

; Inventory slot function references
global InventorySlotFunctions := Map(
    1, ClickInvSlot1, 2, ClickInvSlot2, 3, ClickInvSlot3, 4, ClickInvSlot4,
    5, ClickInvSlot5, 6, ClickInvSlot6, 7, ClickInvSlot7, 8, ClickInvSlot8,
    9, ClickInvSlot9, 10, ClickInvSlot10, 11, ClickInvSlot11, 12, ClickInvSlot12,
    13, ClickInvSlot13, 14, ClickInvSlot14, 15, ClickInvSlot15, 16, ClickInvSlot16,
    17, ClickInvSlot17, 18, ClickInvSlot18, 19, ClickInvSlot19, 20, ClickInvSlot20,
    21, ClickInvSlot21, 22, ClickInvSlot22, 23, ClickInvSlot23, 24, ClickInvSlot24,
    25, ClickInvSlot25, 26, ClickInvSlot26, 27, ClickInvSlot27, 28, ClickInvSlot28
)

; Populate bank slot registry
Loop 88 {
    slotNum := A_Index
    funcName := "ClickBankSlot" slotNum
    BankSlotFunctionsRegistry[funcName] := {
        name: funcName,
        func: BankSlotFunctions[slotNum],
        description: "Click bank slot " slotNum " (mode-aware)"
    }
}

; Populate inventory slot registry
Loop 28 {
    slotNum := A_Index
    funcName := "ClickInvSlot" slotNum
    InventorySlotFunctionsRegistry[funcName] := {
        name: funcName,
        func: InventorySlotFunctions[slotNum],
        description: "Click inventory slot " slotNum " (mode-aware)"
    }
}

; Drop slot function references
global DropSlotFunctions := Map(
    1, DropInvSlot1, 2, DropInvSlot2, 3, DropInvSlot3, 4, DropInvSlot4,
    5, DropInvSlot5, 6, DropInvSlot6, 7, DropInvSlot7, 8, DropInvSlot8,
    9, DropInvSlot9, 10, DropInvSlot10, 11, DropInvSlot11, 12, DropInvSlot12,
    13, DropInvSlot13, 14, DropInvSlot14, 15, DropInvSlot15, 16, DropInvSlot16,
    17, DropInvSlot17, 18, DropInvSlot18, 19, DropInvSlot19, 20, DropInvSlot20,
    21, DropInvSlot21, 22, DropInvSlot22, 23, DropInvSlot23, 24, DropInvSlot24,
    25, DropInvSlot25, 26, DropInvSlot26, 27, DropInvSlot27, 28, DropInvSlot28
)

; Drop slot registry
global DropSlotFunctionsRegistry := Map()

; Populate drop slot registry
Loop 28 {
    slotNum := A_Index
    funcName := "DropInvSlot" slotNum
    DropSlotFunctionsRegistry[funcName] := {
        name: funcName,
        func: DropSlotFunctions[slotNum],
        description: "Drop inventory slot " slotNum " (shift-click, mode-aware)"
    }
}
