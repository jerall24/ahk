#Requires AutoHotkey v2.0

; ======================================
; BANK FUNCTIONS (Mode-aware)
; ======================================

; Withdraw equipment items from specific bank slots
; Slots: 2, 9, 10, 11, 17, 18, 19, 26, 33, 34, 35
WithdrawEquipmentFromBank() {
    equipmentSlots := [2, 9, 10, 11, 17, 18, 19, 26, 33, 34, 35]

    for slot in equipmentSlots {
        if (ShouldStopAction())
            return false
        ClickBankSlotNumber(slot)
        Sleep(Random(100, 200))
    }
    return true
}

; Equip items from inventory
; Press F4, click inventory slots 1-11, press F4
EquipFromInventory() {
    Send("{F4}")
    Sleep(Random(100, 200))

    Loop 11 {
        if (ShouldStopAction()) {
            Send("{F4}")  ; Close equipment tab before exiting
            return false
        }
        ClickInventorySlotNumber(A_Index)
        Sleep(Random(100, 200))
    }

    Send("{F4}")
    Sleep(Random(100, 200))
    return true
}

; Withdraw items for inventory from bank
; Slots: 5-8, 13-16, 21-24, 29-32, 37-40, 45-48, 53-56
; In fixed mode: scrolls to access 53-56
; In medium mode: no scroll needed (11 rows = 88 slots)
WithdrawForInventory() {
    ; First batch of slots (always accessible in both modes)
    inventorySlots := [5, 6, 7, 8, 13, 14, 15, 16, 21, 22, 23, 24, 29, 30, 31, 32, 37, 38, 39, 40, 45, 46, 47, 48]

    for slot in inventorySlots {
        if (ShouldStopAction())
            return false
        ClickBankSlotNumber(slot)
        Sleep(Random(100, 200))
    }

    ; Handle slots 53-56 based on mode
    if (IsFixedMode()) {
        ; Fixed mode: need to scroll down to access row 7
        BankScrollDown()
        Sleep(Random(150, 250))

        ; After scrolling, slots 53-56 are now in row 6 position (columns 5-8)
        scrolledSlots := [45, 46, 47, 48]
        for slot in scrolledSlots {
            if (ShouldStopAction())
                return false
            ClickBankSlotNumber(slot)
            Sleep(Random(100, 200))
        }
    } else {
        ; Medium mode: slots 53-56 are directly accessible
        finalSlots := [53, 54, 55, 56]
        for slot in finalSlots {
            if (ShouldStopAction())
                return false
            ClickBankSlotNumber(slot)
            Sleep(Random(100, 200))
        }
    }
    return true
}

; Prepare full loadout: withdraw equipment, equip it, then withdraw inventory items
PrepareFullLoadout() {
    if (!WithdrawEquipmentFromBank())
        return false
    Sleep(Random(200, 350))

    if (!EquipFromInventory())
        return false
    Sleep(Random(200, 350))

    if (!WithdrawForInventory())
        return false
    return true
}

; Scroll down one row in the bank interface
BankScrollDown() {
    Send("{WheelDown}")
}

; Click deposit inventory button, then captured bank slot 1, then slot 2, then press escape
; Uses globally captured slots from Ctrl+Numpad0
; Mode-aware: uses appropriate UI and bank slot functions
DepositAndWithdrawFromBank() {
    global capturedBankSlot1, capturedBankSlot2

    ; Check if slots have been captured
    if (capturedBankSlot1 = 0 || capturedBankSlot2 = 0) {
        ToolTip "No bank slots captured! Use Ctrl+Numpad0 first."
        SetTimer () => ToolTip(), -2000
        return
    }

    ; Click deposit inventory button first (mode-aware)
    ClickBankDepositInventory()
    Sleep(Random(100, 200))

    ; Click first captured bank slot (mode-aware)
    ClickBankSlotNumber(capturedBankSlot1)
    Sleep(Random(100, 200))

    ; Click second captured bank slot (mode-aware)
    ClickBankSlotNumber(capturedBankSlot2)
    Sleep(Random(750, 1000))

    Send("{Escape}")
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global BankFunctionsRegistry := Map(
    "DepositAndWithdrawFromBank", {
        name: "DepositAndWithdrawFromBank",
        func: DepositAndWithdrawFromBank,
        description: "Deposit inventory, click bank slots 1 & 2, then escape (mode-aware)"
    },
    "WithdrawEquipmentFromBank", {
        name: "WithdrawEquipmentFromBank",
        func: WithdrawEquipmentFromBank,
        description: "Withdraw equipment from bank slots 2, 9-11, 17-19, 26, 33-35 (mode-aware)"
    },
    "EquipFromInventory", {
        name: "EquipFromInventory",
        func: EquipFromInventory,
        description: "Press F4, click inventory slots 1-11, press F4 (mode-aware)"
    },
    "WithdrawForInventory", {
        name: "WithdrawForInventory",
        func: WithdrawForInventory,
        description: "Withdraw from bank slots 5-8, 13-16, 21-24, 29-32, 37-40, 45-48, 53-56 (mode-aware)"
    },
    "PrepareFullLoadout", {
        name: "PrepareFullLoadout",
        func: PrepareFullLoadout,
        description: "Withdraw equipment, equip it, then withdraw inventory items (mode-aware)"
    },
    "BankScrollDown", {
        name: "BankScrollDown",
        func: BankScrollDown,
        description: "Scroll down one row in the bank"
    }
)
