#Requires AutoHotkey v2.0

; ======================================
; THIEVING FUNCTIONS
; ======================================

; Inventory background colors (empty slot), shared with runecrafting/sailing.
global THIEVING_INV_BG_COLORS := [0x4B423A, 0x453C33, 0x483E35, 0x494035, 0x514941]

; If inventory slot 28 is occupied, left-click slots 9-28: capture the current
; mouse position first, click the range, then move back so the loop can resume.
DropInventoryIfFull() {
    global THIEVING_INV_BG_COLORS

    if (FindLastOccupiedSlotInRange(28, 28, THIEVING_INV_BG_COLORS) != 28)
        return

    MouseGetPos(&returnX, &returnY)

    Loop 20 {
        if (ShouldStopAction())
            break
        ClickInventorySlot(8 + A_Index)
        Sleep(Random(50, 100))
    }

    HumanMouseMove(returnX, returnY)
}

; Left-click at the current mouse position and check the click result.
; Returns true only if a red X appeared (successful pickpocket target click).
; Returns false on a yellow X (walk click, non-interactable), no X detected,
; or if the action was manually cancelled (Ctrl+Esc).
PickpocketClick() {
    if (ShouldStopAction())
        return false

    MouseGetPos(&clickX, &clickY)
    HumanClick(clickX, clickY)

    if (ShouldStopAction())
        return false

    result := CheckClickResult(clickX, clickY)
    if (result != "red")
        return false

    return InterruptibleSleep(Random(300, 450))
}

; PickpocketClick() with the slot-28 drop mechanic in front of it.
Pickpocket() {
    if (ShouldStopAction())
        return false

    DropInventoryIfFull()
    if (ShouldStopAction())
        return false

    return PickpocketClick()
}

; Loop Pickpocket() until a non-red result appears (missed/failed click) or
; Ctrl+Esc is pressed. A single cancel ends the loop immediately - Pickpocket()
; itself checks the kill switch between every blocking step, so no stale
; in-flight click or sleep can swallow the first Ctrl+Esc press.
LoopPickpocket() {
    global manualStop
    manualStop := false

    ToolTip "Pickpocket: starting..."
    SetTimer () => ToolTip(), -2000

    Loop {
        if (!Pickpocket()) {
            if (manualStop) {
                ToolTip "Pickpocket: stopped (Ctrl+Esc)"
            } else {
                ToolTip "Pickpocket: stopped (missed click)"
            }
            SetTimer () => ToolTip(), -3000
            return
        }
    }
}

; ======================================
; ARDOUGNE KNIGHT VARIANT
; ======================================

; Periodic click region (client-relative) - clicked every ~30-40s
global ARDY_KNIGHT_PERIODIC_X1 := 692
global ARDY_KNIGHT_PERIODIC_Y1 := 306
global ARDY_KNIGHT_PERIODIC_X2 := 728
global ARDY_KNIGHT_PERIODIC_Y2 := 337

; Press F1, click the periodic region (692,306 - 728,337), then press Escape.
; Saves and restores the mouse position around it so the loop resumes
; clicking where it left off.
ClickArdyKnightPeriodicRegion() {
    global ARDY_KNIGHT_PERIODIC_X1, ARDY_KNIGHT_PERIODIC_Y1, ARDY_KNIGHT_PERIODIC_X2, ARDY_KNIGHT_PERIODIC_Y2

    MouseGetPos(&returnX, &returnY)

    Send("{F1}")
    Sleep(Random(500, 650))

    ClickRandomPixel(ARDY_KNIGHT_PERIODIC_X1, ARDY_KNIGHT_PERIODIC_Y1, ARDY_KNIGHT_PERIODIC_X2, ARDY_KNIGHT_PERIODIC_Y2)
    Sleep(Random(150, 250))

    Send("{Escape}")
    Sleep(Random(150, 250))

    HumanMouseMove(returnX, returnY)
}

; Click inventory slot 1, saving and restoring the mouse position around it.
; Uses the shared InventorySlots map (confirmed correct via CaptureCoordinates:
; 565,216,586,237, matching the map's 563,216,593,241).
    ClickArdyKnightInventorySlot1() {
        MouseGetPos(&returnX, &returnY)
        Sleep(Random(150, 250))
    ClickInventorySlot(1)
    HumanMouseMove(returnX, returnY)
}

; Loop PickpocketClick() until a non-red result appears or Ctrl+Esc is
; pressed. In addition to pickpocketing, on the side:
;   - once at the start: click inventory slot 1
;   - every ~30-40s: click the periodic region (692,306 - 728,337)
;   - every ~3 minutes: click inventory slot 1
; No slot-28 drop mechanic (unlike LoopPickpocket).
LoopThieveArdyKnight() {
    global manualStop
    manualStop := false

    periodicIntervalMs := Random(30000, 40000) ; for the shadow veil spell
    slot1IntervalMs := 1.5 * 60 * 1000 ; bringing it down to 1.5 minutes since sometimes it wouldn't work and we'd be stuck not pping

    ToolTip "ThieveArdyKnight: starting..."
    SetTimer () => ToolTip(), -2000

    ClickArdyKnightInventorySlot1()
    Sleep(Random(150, 250))
    if (ShouldStopAction()) {
        ToolTip "ThieveArdyKnight: stopped (Ctrl+Esc)"
        SetTimer () => ToolTip(), -3000
        return
    }

    lastPeriodicClick := A_TickCount
    lastSlot1Click := A_TickCount

    Loop {
        if (ShouldStopAction()) {
            ToolTip "ThieveArdyKnight: stopped (Ctrl+Esc)"
            SetTimer () => ToolTip(), -3000
            return
        }

        ; if (A_TickCount - lastPeriodicClick >= periodicIntervalMs) {
        ;     ClickArdyKnightPeriodicRegion()
        ;     lastPeriodicClick := A_TickCount
        ;     periodicIntervalMs := Random(30000, 40000)
        ;     if (ShouldStopAction()) {
        ;         ToolTip "ThieveArdyKnight: stopped (Ctrl+Esc)"
        ;         SetTimer () => ToolTip(), -3000
        ;         return
        ;     }
        ; }

        if (A_TickCount - lastSlot1Click >= slot1IntervalMs) {
            ClickArdyKnightInventorySlot1()
            lastSlot1Click := A_TickCount
            if (ShouldStopAction()) {
                ToolTip "ThieveArdyKnight: stopped (Ctrl+Esc)"
                SetTimer () => ToolTip(), -3000
                return
            }
        }

        if (!PickpocketClick()) {
            if (manualStop) {
                ToolTip "ThieveArdyKnight: stopped (Ctrl+Esc)"
            } else {
                ToolTip "ThieveArdyKnight: stopped (missed click)"
            }
            SetTimer () => ToolTip(), -3000
            return
        }
    }
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global ThievingRegistry := Map(
    "Pickpocket", {
        name: "Pickpocket",
        func: Pickpocket,
        description: "Left-click inv 9-28 if slot 28 full, left-click current mouse position, sleep 600-900ms, stop on yellow X"
    },
    "LoopPickpocket", {
        name: "LoopPickpocket",
        func: LoopPickpocket,
        description: "Loop Pickpocket until yellow X (stun) or Ctrl+Esc"
    },
    "LoopThieveArdyKnight", {
        name: "LoopThieveArdyKnight",
        func: LoopThieveArdyKnight,
        description: "Loop pickpocket (no slot-28 drop); clicks inv slot 1 at start, every ~30-40s F1 > click 692,306-728,337 > Esc, every 3min click inv slot 1"
    }
)
