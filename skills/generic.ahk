#Requires AutoHotkey v2.0

; ======================================
; GENERIC PROCESSING FUNCTIONS
; ======================================

; Global variable for captured bank rectangle
global fullInv1ItemBankRect := {x1: 0, y1: 0, x2: 0, y2: 0}

; Capture the bank rectangle for ProcessFullInventory1Item
CaptureFullInv1ItemRect() {
    global fullInv1ItemBankRect

    pt1 := CapturePoint("Move mouse to TOP-LEFT corner of bank rectangle, then press OK")
    pt2 := CapturePoint("Move mouse to BOTTOM-RIGHT corner of bank rectangle, then press OK")
    x1 := pt1.x
    y1 := pt1.y
    x2 := pt2.x
    y2 := pt2.y
    ScreenToClient(&x1, &y1)
    ScreenToClient(&x2, &y2)
    fullInv1ItemBankRect := {x1: x1, y1: y1, x2: x2, y2: y2}

    SaveProfiles()

    ToolTip "Bank rectangle captured!`n(" fullInv1ItemBankRect.x1 "," fullInv1ItemBankRect.y1 ") to (" fullInv1ItemBankRect.x2 "," fullInv1ItemBankRect.y2 ")"
    SetTimer () => ToolTip(), -3000
}

; Full inventory cycle with a single bank item
; 1. Click randomly in bank rectangle
; 2. Deposit inventory
; 3. Click captured bank slot 1
; 4. Press Escape
; 5. Click inventory slots 1 and 2
; 6. Press Enter
ProcessFullInventory1Item() {
    global fullInv1ItemBankRect, capturedBankSlot1, capturedInventorySlot1, capturedInventorySlot2

    if (fullInv1ItemBankRect.x1 = 0) {
        ToolTip "Bank rectangle not captured! Use CaptureFullInv1ItemRect first."
        SetTimer () => ToolTip(), -2000
        return
    }
    if (capturedBankSlot1 = 0) {
        ToolTip "No bank slot captured! Use Ctrl+Numpad0 first."
        SetTimer () => ToolTip(), -2000
        return
    }
    if (capturedInventorySlot1 = 0 || capturedInventorySlot2 = 0) {
        ToolTip "No inventory slots captured! Use Ctrl+NumpadDot first."
        SetTimer () => ToolTip(), -2000
        return
    }

    ; Step 1: Click bank
    ToolTip ""
    HumanClickRandomPixel(fullInv1ItemBankRect.x1, fullInv1ItemBankRect.y1, fullInv1ItemBankRect.x2, fullInv1ItemBankRect.y2, "left", 1.0)
    Sleep(Random(600, 900))

    ; Step 2: Deposit inventory
    ClickUIElement("bank_deposit_inventory")
    Sleep(Random(150, 250))

    ; Step 3: Click bank slot 1
    ClickBankSlot(capturedBankSlot1)
    Sleep(Random(700, 900))

    ; Step 4: Press Escape
    Send("{Escape}")
    Sleep(Random(600, 900))

    ; Step 5: Click inventory slots 1 and 2
    ClickInventorySlot(capturedInventorySlot1)
    Sleep(Random(100, 200))
    ClickInventorySlot(capturedInventorySlot2)
    Sleep(Random(600, 900))

    ; Step 6: Press Enter
    Send("{Space}")
}

WorldHopRight() {
    Send("^+{Right}")
}

WorldHopLeft() {
    Send("^+{Left}")
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global GenericRegistry := Map(
    "CaptureFullInv1ItemRect", {
        name: "CaptureFullInv1ItemRect",
        func: CaptureFullInv1ItemRect,
        description: "Capture bank rectangle for ProcessFullInventory1Item - saves to profile"
    },
    "ProcessFullInventory1Item", {
        name: "ProcessFullInventory1Item",
        func: ProcessFullInventory1Item,
        description: "Bank rect click > Deposit > Withdraw slot 1 > Esc > Inv slots 1&2 > Enter"
    },
    "WorldHopRight", {
        name: "WorldHopRight",
        func: WorldHopRight,
        description: "Hop to next world (Ctrl+Shift+Right)"
    },
    "WorldHopLeft", {
        name: "WorldHopLeft",
        func: WorldHopLeft,
        description: "Hop to previous world (Ctrl+Shift+Left)"
    }
)
