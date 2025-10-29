#Requires AutoHotkey v2.0

; ======================================
; HERBLORE FUNCTIONS
; ======================================

; Herblore banking and processing cycle
; 1. Click cyan cluster centroid
; 2. Deposit inventory and withdraw bank items (old Numpad8)
; 3. Click captured inventory slots and space (old Numpad3)
ProcessHerblore() {
    global capturedBankSlot1, capturedBankSlot2
    global capturedInventorySlot1, capturedInventorySlot2

    ; Step 1: Click cyan cluster centroid and wait
    if !ClickRandomPixelOfColorCentroid(0xFF00CA, 0, 0, true) {
        ClickRandomPixelOfColorCentroid(0xFF00CA, 0, 0, false)
    }
    Sleep(Random(500, 600))

    ; Step 2: Old Numpad8 actions - Bank deposit and withdrawal
    ; Check if bank slots have been captured
    if (capturedBankSlot1 = 0 || capturedBankSlot2 = 0) {
        ToolTip "No bank slots captured! Use Ctrl+Numpad0 first."
        SetTimer () => ToolTip(), -2000
        return
    }

    ; Click deposit inventory button first
    ClickUIElement("bank_deposit_inventory")
    Sleep(Random(100, 200))

    ; Click first captured bank slot
    ClickBankSlot(capturedBankSlot1)
    Sleep(Random(100, 200))

    ; Click second captured bank slot
    ClickBankSlot(capturedBankSlot2)
    Sleep(Random(750, 1000))

    Send("{Escape}")

    ; Step 3: Wait before inventory actions
    Sleep(Random(100, 200))

    ; Step 4: Old Numpad3 actions - Inventory slot clicking
    ; Check if inventory slots have been captured
    if (capturedInventorySlot1 = 0 || capturedInventorySlot2 = 0) {
        ToolTip "No inventory slots captured! Use Ctrl+NumpadDot first."
        SetTimer () => ToolTip(), -2000
        return
    }

    ; Click first captured inventory slot
    ClickInventorySlot(capturedInventorySlot1)
    Sleep(Random(100, 200))

    ; Click second captured inventory slot
    ClickInventorySlot(capturedInventorySlot2)
    Sleep(Random(750, 1000))

    Send("{Space}")
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global HerbloreRegistry := Map(
    "ProcessHerblore", {
        name: "ProcessHerblore",
        func: ProcessHerblore,
        description: "Click cyan centroid, bank (deposit + withdraw slots 1&2), click inventory slots 1&2, space"
    }
)
