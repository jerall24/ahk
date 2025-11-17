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

    ; Save to profile
    SaveProfiles()

    ; Show confirmation
    ToolTip "Construction bank slot captured!`nSlot: " capturedConstructionBankSlot
    SetTimer () => ToolTip(), -3000

    return true
}

; PvP World plank making cycle
; Withdraws materials, builds, and returns to bank
PvPWorldPlankMake() {
    global capturedConstructionBankSlot

    ClickConstructionBank()
    if (!WaitForPixelColor(420, 96, 0xAC884D, 8000)) {
        ToolTip "Bank interface did not open - aborting"
        SetTimer () => ToolTip(), -2000
        return
    }

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

    ; Step 3: Teleport to house
    ClickRandomPixel(609, 270, 627, 288)

    ; Step 4: Wait for screen to turn black, then wait for it to NOT be black
    ; Continue even if timeout is reached
    WaitForPixelColor(395, 259, 0x000000, 5000)  ; Wait for black screen
    WaitForPixelColorNot(395, 259, 0x000000, 5000)  ; Wait for screen to load

    ; Step 5: Hit F9
    Send("{F9}")
    Sleep(Random(100, 200))

    ; Step 6: Click house options
    ClickRandomPixel(644, 381, 681, 417)

    ; Step 7: Wait for run energy red to go away, then wait and click
    Sleep(Random(500, 700))
    WaitForPixelColorNot(633, 390, 0x912320, 1000)
    ClickRandomPixel(557, 389, 726, 415)

    ; Step 8: Send 1, space, 1, space sequence
    WaitForPixelColorNot(16, 463, 0x4B4A49, 1000)
    Sleep(Random(200, 300))
    Send("{1}")
    WaitForPixelColor(46, 426, 0x4C1004, 1000)
    Sleep(Random(200, 300))
    Send("{Space}")
    WaitForPixelColorNot(46, 426, 0x4C1004, 1000)
    Sleep(Random(200, 300))
    Send("{1}")
    WaitForPixelColor(46, 426, 0x4C1004, 1000)
    Sleep(Random(200, 300))
    Send("{Space}")
    Sleep(Random(200, 300))

    ; Step 9: Send an F1 event
    Send("{F1}")
    Sleep(Random(600, 800))

    ; Step 10: Click in coordinates: 656, 272, 673, 288
    ; Only click if the wait succeeds
    if (WaitForPixelColor(16, 463, 0x4B4A49, 1000)) {
        ToolTip ""  ; Clear any tooltips before clicking
        ClickRandomPixel(656, 272, 673, 288)
    } else {
        ToolTip "Final wait failed - skipping final click"
        SetTimer () => ToolTip(), -2000
    }
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
    "PvPWorldPlankMake", {
        name: "PvPWorldPlankMake",
        func: PvPWorldPlankMake,
        description: "PvP World plank making: withdraw materials, build planks, return to bank"
    },
    "ClickConstructionBank", {
        name: "ClickConstructionBank",
        func: ClickConstructionBank,
        description: "Click centroid of cyan pixel cluster for construction navigation"
    }
)
