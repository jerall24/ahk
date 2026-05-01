#Requires AutoHotkey v2.0

; ======================================
; INVENTORY FUNCTIONS
; ======================================

; Cycle click state
global isCyclingInventory1And5 := false
global cycleInventoryStep := 0

; Fast altar-style click state (slots 1 and 5)
global isRapidClickingInventory1And5 := false
global rapidClickInventoryStep := 0

; Fast click state for captured inventory spots
global isRapidClick2Spots := false
global rapidClick2SpotsStep := 0
global rapidClick2SpotsIterations := 0

; Mouse speed for altar-style inventory click (higher = faster)
global RAPID_INV_SPEED := 3.0

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

; Click each inventory slot 1-28 sequentially
; Uses 10% faster mouse speed for small movements (mode-aware)
ClickEachInventorySlot() {
    ; Save current mouse speed and set 10% faster (default 4 -> 3)
    SetDefaultMouseSpeed 3

    Loop 28 {
        ClickInventorySlotNumber(A_Index)
        Sleep(Random(50, 100))
    }

    ; Restore default mouse speed
    SetDefaultMouseSpeed 4
}

; Timer callback for cycle click inventory 1 and 5
CycleInventory1And5Tick() {
    global isCyclingInventory1And5, cycleInventoryStep

    if (!isCyclingInventory1And5) {
        SetTimer(CycleInventory1And5Tick, 0)
        ToolTip "CycleClickInventory1And5 OFF"
        SetTimer () => ToolTip(), -2000
        return
    }

    if (cycleInventoryStep = 0) {
        ; Click inventory slot 1
        ClickInventorySlotNumber(1)
        cycleInventoryStep := 1
        ; Schedule next tick quickly for slot 5
        SetTimer(CycleInventory1And5Tick, -Random(235, 330))
    } else {
        ; Click inventory slot 5, wait, then press space
        ClickInventorySlotNumber(5)
        Sleep(Random(750, 1000))
        Send("{Space}")
        cycleInventoryStep := 0
        ; Schedule next tick after processing wait
        SetTimer(CycleInventory1And5Tick, -Random(12734, 14140))
    }
}

; Toggle cycling inventory click on/off
CycleClickInventory1And5() {
    global isCyclingInventory1And5, cycleInventoryStep

    if (isCyclingInventory1And5) {
        isCyclingInventory1And5 := false
        return
    }

    isCyclingInventory1And5 := true
    cycleInventoryStep := 0
    ToolTip "CycleClickInventory1And5 ON"
    SetTimer () => ToolTip(), -1500

    ; Start the timer-based loop
    SetTimer(CycleInventory1And5Tick, -1)
}

; Timer callback for altar-style click between inventory slots 1 and 5
RapidClickInventory1And5Tick() {
    global isRapidClickingInventory1And5, rapidClickInventoryStep, RAPID_INV_SPEED

    if (!isRapidClickingInventory1And5) {
        SetTimer(RapidClickInventory1And5Tick, 0)
        ToolTip "RapidClickInventory1And5 OFF"
        SetTimer () => ToolTip(), -2000
        return
    }

    if (rapidClickInventoryStep = 0) {
        if (IsFixedMode()) {
            coords := InventorySlots[1]
        } else {
            coords := MediumInventorySlots[1]
        }
        ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2, false, 3, RAPID_INV_SPEED)
        rapidClickInventoryStep := 1
    } else {
        if (IsFixedMode()) {
            coords := InventorySlots[5]
        } else {
            coords := MediumInventorySlots[5]
        }
        ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2, false, 3, RAPID_INV_SPEED)
        rapidClickInventoryStep := 0
    }

    SetTimer(RapidClickInventory1And5Tick, -Random(80, 150))
}

; Toggle altar-style fast click between inventory slots 1 and 5
RapidClickInventory1And5() {
    global isRapidClickingInventory1And5, rapidClickInventoryStep

    if (isRapidClickingInventory1And5) {
        isRapidClickingInventory1And5 := false
        return
    }

    isRapidClickingInventory1And5 := true
    rapidClickInventoryStep := 0
    ToolTip "RapidClickInventory1And5 ON"
    SetTimer () => ToolTip(), -1500

    SetTimer(RapidClickInventory1And5Tick, -1)
}

; Timer callback for rapid click between the two captured inventory spots
RapidClick2SpotsTick() {
    global isRapidClick2Spots, rapidClick2SpotsStep, rapidClick2SpotsIterations, RAPID_INV_SPEED
    global capturedInventorySlot1, capturedInventorySlot2

    ; Only stop at the start of a new cycle so slot1→slot2 always completes together
    if (!isRapidClick2Spots && rapidClick2SpotsStep = 0) {
        SetTimer(RapidClick2SpotsTick, 0)
        return
    }

    slotMap := IsFixedMode() ? InventorySlots : MediumInventorySlots
    slotNum := (rapidClick2SpotsStep = 0) ? capturedInventorySlot1 : capturedInventorySlot2
    coords := slotMap[slotNum]
    ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2, false, 3, RAPID_INV_SPEED)
    rapidClick2SpotsStep := (rapidClick2SpotsStep = 0) ? 1 : 0

    ; After each full cycle (slot2 just clicked, step back to 0), check if slot2 is empty
    if (rapidClick2SpotsStep = 0) {
        rapidClick2SpotsIterations++
        if (rapidClick2SpotsIterations >= 20) {
            bgColors := [0x4B423A, 0x453C33, 0x483E35, 0x494035, 0x514941]
            if (FindLastOccupiedSlotInRange(capturedInventorySlot2, capturedInventorySlot2, bgColors) < capturedInventorySlot2) {
                isRapidClick2Spots := false
                SetTimer(RapidClick2SpotsTick, 0)
                return
            }
        }
    }

    SetTimer(RapidClick2SpotsTick, -Random(53, 100))
}

; Toggle rapid click between the two captured inventory spots (on/off)
; Capture the two spots first with CaptureInventorySlots (Ctrl+NumpadDot)
RapidClick2InventorySpots() {
    global isRapidClick2Spots, rapidClick2SpotsStep
    global capturedInventorySlot1, capturedInventorySlot2

    if (isRapidClick2Spots) {
        isRapidClick2Spots := false
        return
    }

    if (capturedInventorySlot1 = 0 || capturedInventorySlot2 = 0) {
        ToolTip "No inventory slots captured! Use Ctrl+NumpadDot first."
        SetTimer () => ToolTip(), -2000
        return
    }

    isRapidClick2Spots := true
    rapidClick2SpotsStep := 0
    rapidClick2SpotsIterations := 0
    SetTimer(RapidClick2SpotsTick, -1)
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
    },
    "ClickEachInventorySlot", {
        name: "ClickEachInventorySlot",
        func: ClickEachInventorySlot,
        description: "Click all 28 inventory slots sequentially (10% faster mouse, mode-aware)"
    },
    "CycleClickInventory1And5", {
        name: "CycleClickInventory1And5",
        func: CycleClickInventory1And5,
        description: "Cycle: click slot 1, slot 5, space, wait for processing, repeat (toggle on/off)"
    },
    "RapidClickInventory1And5", {
        name: "RapidClickInventory1And5",
        func: RapidClickInventory1And5,
        description: "Fast altar-style toggle: click slot 1 and slot 5 rapidly, no space (toggle on/off)"
    },
    "RapidClick2InventorySpots", {
        name: "RapidClick2InventorySpots",
        func: RapidClick2InventorySpots,
        description: "Fast toggle: rapidly alternate between two captured inventory slots (toggle on/off)"
    }
)
