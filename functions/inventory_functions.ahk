#Requires AutoHotkey v2.0

; ======================================
; INVENTORY FUNCTIONS
; ======================================

; Click captured inventory slot 1, then slot 2, then press space
; Uses globally captured slots from Ctrl+NumpadDot
ClickCapturedInventorySlots() {
    global capturedInventorySlot1, capturedInventorySlot2

    ; Check if slots have been captured
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

; Click inventory slot 1, then slot 5 (one row down), then press space
ClickInventorySlot1And5() {
    ; Click first inventory slot
    ClickInventorySlot(1)
    Sleep(Random(100, 200))

    ; Click slot one row down (slot 5 - 4 columns per row)
    ClickInventorySlot(5)
    Sleep(Random(750, 1000))

    Send("{Space}")
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global InventoryFunctionsRegistry := Map(
    "ClickCapturedInventorySlots", {
        name: "ClickCapturedInventorySlots",
        func: ClickCapturedInventorySlots,
        description: "Click captured inventory slots 1 & 2, then space"
    },
    "ClickInventorySlot1And5", {
        name: "ClickInventorySlot1And5",
        func: ClickInventorySlot1And5,
        description: "Click inventory slot 1 & 5, then space"
    }
)
