#Requires AutoHotkey v2.0

; ======================================
; SAILING FUNCTIONS
; ======================================

; Global variables to store captured sailing salvage inventory slots
global capturedSailingSalvageSlot1 := 0
global capturedSailingSalvageSlot2 := 0

; Capture two inventory slot positions for sailing salvage
CaptureSailingSalvageSlots() {
    global capturedSailingSalvageSlot1, capturedSailingSalvageSlot2

    ToolTip "Click on first salvage inventory item..."

    ; Wait for first right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x1, &y1)
    slot1 := GetInventorySlotAtCoordinate(x1, y1)

    if (slot1 = 0) {
        ToolTip "First click not in an inventory slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    ToolTip "First slot captured: " slot1 "`nClick on second salvage inventory item..."
    Sleep(250)

    ; Wait for second right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x2, &y2)
    slot2 := GetInventorySlotAtCoordinate(x2, y2)

    if (slot2 = 0) {
        ToolTip "Second click not in an inventory slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Store the captured slots
    capturedSailingSalvageSlot1 := slot1
    capturedSailingSalvageSlot2 := slot2

    ; Save to profile
    SaveProfiles()

    ; Show confirmation
    ToolTip "Sailing salvage slots captured!`nSlot 1: " capturedSailingSalvageSlot1 "`nSlot 2: " capturedSailingSalvageSlot2
    SetTimer () => ToolTip(), -3000

    return true
}

; Drop all items from first captured slot through to second captured slot
; Automatically holds shift and clicks each slot
; Press F12 to stop at any time
DropSalvageInventory() {
    global capturedSailingSalvageSlot1, capturedSailingSalvageSlot2

    ; Check if slots have been captured
    if (capturedSailingSalvageSlot1 = 0 || capturedSailingSalvageSlot2 = 0) {
        ToolTip "No salvage slots captured! Use CaptureSailingSalvageSlots first."
        SetTimer () => ToolTip(), -2000
        return
    }

    ; Ensure slot1 is smaller than slot2
    startSlot := Min(capturedSailingSalvageSlot1, capturedSailingSalvageSlot2)
    endSlot := Max(capturedSailingSalvageSlot1, capturedSailingSalvageSlot2)

    ; Hold shift down at the beginning
    Send("{Shift down}")
    Sleep(Random(50, 100))

    ; Click each inventory slot from start to end
    Loop endSlot - startSlot + 1 {
        ; Check if F12 is pressed to stop
        if GetKeyState("F12", "P") {
            Send("{Shift up}")
            ToolTip "Salvage drop stopped by F12"
            SetTimer () => ToolTip(), -2000
            return
        }

        currentSlot := startSlot + A_Index - 1
        ClickInventorySlot(currentSlot)
        Sleep(Random(50, 100))
    }

    ; Release shift at the end
    Send("{Shift up}")

    ToolTip "Dropped salvage inventory (slots " startSlot " to " endSlot ")"
    SetTimer () => ToolTip(), -2000
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global SailingRegistry := Map(
    "CaptureSailingSalvageSlots", {
        name: "CaptureSailingSalvageSlots",
        func: CaptureSailingSalvageSlots,
        description: "Capture two inventory slots for sailing salvage (right-click on first, then second)"
    },
    "DropSalvageInventory", {
        name: "DropSalvageInventory",
        func: DropSalvageInventory,
        description: "Drop all items from first captured salvage slot to second (shift-click each slot)"
    }
)
