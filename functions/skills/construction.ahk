#Requires AutoHotkey v2.0

; ======================================
; CONSTRUCTION FUNCTIONS
; ======================================

; Capture a single bank slot for construction materials
CaptureConstructionBankSlot() {
    global capturedConstructionBankSlot

    ToolTip "Right-click on the bank item for construction..."

    ; Wait for right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x1, &y1)
    slot := GetBankSlotAtCoordinate(x1, y1)

    if (slot = 0) {
        ToolTip "Click not in a bank slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Store the captured slot
    capturedConstructionBankSlot := slot

    ; Show confirmation
    ToolTip "Construction bank slot captured!`nSlot: " capturedConstructionBankSlot
    SetTimer () => ToolTip(), -3000

    return true
}

; Full construction processing cycle
; Withdraws materials, builds, and returns to bank
ProcessConstruction() {
    global capturedConstructionBankSlot

    ; Check if bank slot has been captured
    if (capturedConstructionBankSlot = 0) {
        ToolTip "No bank slot captured! Use Ctrl+Numpad0 first."
        SetTimer () => ToolTip(), -2000
        return
    }

    ; Step 1: Click once on the saved bank slot
    ClickBankSlot(capturedConstructionBankSlot)
    Sleep(Random(100, 200))

    ; Step 2: Hit escape
    Send("{Escape}")
    Sleep(Random(100, 200))

    ; Step 3: Click in coordinates: 609, 270, 627, 288
    ClickRandomPixel(609, 270, 627, 288)

    ; Step 4: Wait 500-1000ms
    Sleep(Random(3500, 5000))

    ; Step 5: Hit F9
    Send("{F9}")
    Sleep(Random(100, 200))

    ; Step 6: Click anywhere in coordinates: 644, 381, 681, 417
    ClickRandomPixel(644, 381, 681, 417)

    ; Step 7: Wait 100-200ms and then click anywhere in coordinates: 557, 389, 726, 415
    Sleep(Random(500, 700))
    ClickRandomPixel(557, 389, 726, 415)
    Sleep(Random(500, 700))

    ; Step 8: Send 1, space, 1, space sequence
    Send("{1}")
    Sleep(Random(700, 900))
    Send("{Space}")
    Sleep(Random(700, 900))
    Send("{1}")
    Sleep(Random(700, 900))
    Send("{Space}")
    Sleep(Random(300, 400))

    ; Step 9: Send an F1 event
    Send("{F1}")
    Sleep(Random(200, 400))

    ; Step 10: Click in coordinates: 656, 272, 673, 288
    ClickRandomPixel(656, 272, 673, 288)
}

; Click centroid of cyan pixel cluster for construction
ClickConstructionBank() {
    if !ClickRandomPixelOfColorCentroid(0xFF00CA, 0, 0, true) {
        ClickRandomPixelOfColorCentroid(0xFF00CA, 0, 0, false)
    }
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global ConstructionRegistry := Map(
    "CaptureConstructionBankSlot", {
        name: "CaptureConstructionBankSlot",
        func: CaptureConstructionBankSlot,
        description: "Capture bank slot for construction materials (right-click on item)"
    },
    "ProcessConstruction", {
        name: "ProcessConstruction",
        func: ProcessConstruction,
        description: "Full construction cycle: withdraw materials, build items, return to bank"
    },
    "ClickConstructionBank", {
        name: "ClickConstructionBank",
        func: ClickConstructionBank,
        description: "Click centroid of cyan pixel cluster for construction navigation"
    }
)
