#Requires AutoHotkey v2.0

; ======================================
; SMITHING FUNCTIONS
; ======================================

; Bank click color (opens bank when nearby)
global SM_BANK_COLOR := 0x0A00FF

; Furnace/anvil color (starts smithing action)
global SM_FURNACE_COLOR := 0xFF0000

; Bank open indicator pixel (client-relative) — use CapturePixelAndColor to recapture if this bank differs
global SM_BANK_INDICATOR_X     := 354
global SM_BANK_INDICATOR_Y     := 323
global SM_BANK_INDICATOR_COLOR := 0x831F1D

SmithLog(msg) {
    logPath := A_ScriptDir "\log\smithing.log"
    timestamp := FormatTime(, "HH:mm:ss")
    line := "[" timestamp "] " msg
    FileAppend(line "`n", logPath)
    OutputDebug(line)
}

; Wait up to timeoutMs for the bank interface to open. Returns false on timeout.
WaitForSmithBankOpen(timeoutMs := 8000) {
    global SM_BANK_INDICATOR_X, SM_BANK_INDICATOR_Y, SM_BANK_INDICATOR_COLOR
    return WaitForPixelColor(SM_BANK_INDICATOR_X, SM_BANK_INDICATOR_Y, SM_BANK_INDICATOR_COLOR, timeoutMs)
}

; One smithing cycle. Called with the bank already open.
; Deposits, withdraws slot 46, exits, clicks furnace, waits, spaces, waits idle, opens bank.
; Returns false if stopped or bank fails to open.
SmithCycle() {
    global SM_BANK_COLOR, SM_FURNACE_COLOR

    ; Step 1: Deposit inventory
    SmithLog("SmithCycle: [1] depositing inventory")
    ClickBankDepositInventory()
    Sleep(Random(150, 250))

    if (ShouldStopAction()) {
        SmithLog("SmithCycle: stopped after deposit")
        return false
    }

    ; Step 2: Withdraw from bank slot 46
    SmithLog("SmithCycle: [2] clicking bank slot 46")
    ClickBankSlotNumber(46)
    Sleep(Random(150, 250))

    ; Step 3: Exit bank
    SmithLog("SmithCycle: [3] exiting bank")
    Send("{Escape}")
    Sleep(Random(300, 500))

    if (ShouldStopAction()) {
        SmithLog("SmithCycle: stopped after bank exit")
        return false
    }

    ; Step 4: Click furnace/anvil
    SmithLog("SmithCycle: [4] clicking furnace")
    GdipClickColorInGameView(SM_FURNACE_COLOR)

    ; Step 5: Wait for smithing dialog to appear
    SmithLog("SmithCycle: [5] waiting for dialog")
    Sleep(Random(4500, 5000))

    if (ShouldStopAction()) {
        SmithLog("SmithCycle: stopped during furnace wait")
        return false
    }

    ; Step 6: Press space to confirm smithing
    SmithLog("SmithCycle: [6] pressing space")
    Send("{Space}")

    ; Step 7: Wait until status icon is idle (smithing complete)
    SmithLog("SmithCycle: [7] waiting for idle")
    if (!WaitForActionComplete()) {
        SmithLog("SmithCycle: stopped while waiting for idle")
        return false
    }
    SmithLog("SmithCycle: [7] idle — smithing done")

    ; Step 8: Click bank to open it
    SmithLog("SmithCycle: [8] clicking bank")
    GdipClickColorInGameView(SM_BANK_COLOR)

    ; Step 9: Wait for bank to open (4.5–5s travel + bank load)
    SmithLog("SmithCycle: [9] waiting for bank to open")
    if (!WaitForSmithBankOpen(8000)) {
        SmithLog("SmithCycle: [9] bank did not open in time — stopping")
        ToolTip "Smithing: bank did not open"
        SetTimer () => ToolTip(), -3000
        return false
    }

    SmithLog("SmithCycle: bank open — cycle complete")
    return true
}

; Loop smithing cycles continuously until stopped (Ctrl+Escape).
; Start position: standing near the bank.
LoopSmithing() {
    global stopCurrentAction, manualStop
    stopCurrentAction := false
    manualStop := false

    SmithLog("LoopSmithing: === START ===")
    ToolTip "Smithing: starting..."
    SetTimer () => ToolTip(), -2000

    ; Open bank for the first cycle
    SmithLog("LoopSmithing: clicking bank to open")
    GdipClickColorInGameView(SM_BANK_COLOR)
    if (!WaitForSmithBankOpen(8000)) {
        SmithLog("LoopSmithing: bank did not open — aborting")
        ToolTip "Smithing: bank did not open"
        SetTimer () => ToolTip(), -3000
        return
    }
    SmithLog("LoopSmithing: bank open — entering cycle")

    Loop {
        if (ShouldStopAction()) {
            SmithLog("LoopSmithing: stopped")
            ToolTip "Smithing: stopped"
            SetTimer () => ToolTip(), -3000
            return
        }

        if (!SmithCycle()) {
            SmithLog("LoopSmithing: cycle failed — stopping")
            return
        }
    }
}

; Cannonball smelting color (blue marker to click)
global SM_CANNONBALL_COLOR := 0x0000FF

; Furnace click region for cannonball smelting (client-relative)
; Must be captured before first use via CaptureCannonballFurnaceRect
global cannonballFurnaceRect := {x1: 0, y1: 0, x2: 0, y2: 0}

; Capture the furnace rectangle for cannonball smelting
CaptureCannonballFurnaceRect() {
    global cannonballFurnaceRect

    pt1 := CapturePoint("Move mouse to TOP-LEFT corner of furnace (red area), then press OK")
    pt2 := CapturePoint("Move mouse to BOTTOM-RIGHT corner of furnace (red area), then press OK")
    x1 := pt1.x
    y1 := pt1.y
    x2 := pt2.x
    y2 := pt2.y
    ScreenToClient(&x1, &y1)
    ScreenToClient(&x2, &y2)
    cannonballFurnaceRect := {x1: x1, y1: y1, x2: x2, y2: y2}

    SaveProfiles()

    ToolTip "Furnace rectangle captured!`n(" cannonballFurnaceRect.x1 "," cannonballFurnaceRect.y1 ") to (" cannonballFurnaceRect.x2 "," cannonballFurnaceRect.y2 ")"
    SetTimer () => ToolTip(), -3000
}

; One cannonball smelting cycle.
; Clicks blue marker, waits 1.5s, presses space after 600ms, waits idle,
; clicks inventory slot 1, clicks furnace, waits 1.5s, presses 3.
; Returns false if stopped.
SmeltCannonballsCycle() {
    global SM_CANNONBALL_COLOR, cannonballFurnaceRect

    ; Check if furnace rect has been captured
    if (cannonballFurnaceRect.x1 = 0) {
        SmithLog("SmeltCannonballs: furnace rect not captured!")
        ToolTip "Furnace rectangle not captured! Use CaptureCannonballFurnaceRect first."
        SetTimer () => ToolTip(), -3000
        return false
    }

    ; Step 1: Click blue marker (0x0000FF) - using GdipClickColorInGameView to avoid edge-clicking
    SmithLog("SmeltCannonballs: [1] clicking blue marker")
    if (!GdipClickColorInGameView(SM_CANNONBALL_COLOR, 5, 0, 0, 3)) {
        SmithLog("SmeltCannonballs: [1] blue marker not found — stopping")
        ToolTip "Cannonballs: blue marker not found"
        SetTimer () => ToolTip(), -3000
        return false
    }

    ; Step 1.5: Wait 1500ms
    SmithLog("SmeltCannonballs: [1.5] waiting 1500ms")
    Sleep(Random(1900, 2100))

    if (ShouldStopAction()) {
        SmithLog("SmeltCannonballs: stopped after initial wait")
        return false
    }

    ; Step 2: Press space after ~600ms
    SmithLog("SmeltCannonballs: [2] waiting 600ms then pressing space")
    Sleep(Random(550, 650))
    Send("{Space}")

    ; Step 3: Wait until idle
    SmithLog("SmeltCannonballs: [3] waiting for idle")

    ; Debug: Log status icon state before waiting
    CoordMode "Pixel", "Client"
    global STATUS_ICON_X1, STATUS_ICON_Y1, STATUS_ICON_X2, STATUS_ICON_Y2
    midX := Round((STATUS_ICON_X1 + STATUS_ICON_X2) / 2)
    midY := Round((STATUS_ICON_Y1 + STATUS_ICON_Y2) / 2)
    preColor := Format("0x{:06X}", PixelGetColor(midX, midY))
    SmithLog("SmeltCannonballs: [3] status icon pre-wait color at (" midX "," midY "): " preColor)

    if (!WaitForActionComplete()) {
        SmithLog("SmeltCannonballs: stopped while waiting for idle")
        return false
    }

    ; Debug: Log status icon state after completing
    postColor := Format("0x{:06X}", PixelGetColor(midX, midY))
    SmithLog("SmeltCannonballs: [3] idle — action complete, post-wait color: " postColor)

    if (ShouldStopAction()) {
        SmithLog("SmeltCannonballs: stopped after idle")
        return false
    }

    ; Step 4: Left click inventory slot 1
    SmithLog("SmeltCannonballs: [4] clicking inventory slot 1")
    ClickInventorySlot(1)
    Sleep(Random(150, 250))

    if (ShouldStopAction()) {
        SmithLog("SmeltCannonballs: stopped after inventory click")
        return false
    }

    ; Step 5: Click in furnace region (no color search, just random click)
    SmithLog("SmeltCannonballs: [5] clicking furnace region")
    ClickRandomPixel(cannonballFurnaceRect.x1, cannonballFurnaceRect.y1, cannonballFurnaceRect.x2, cannonballFurnaceRect.y2)

    ; Step 6: Wait ~1500ms
    SmithLog("SmeltCannonballs: [6] waiting 1500ms")
    Sleep(Random(1900, 2100))

    if (ShouldStopAction()) {
        SmithLog("SmeltCannonballs: stopped during furnace wait")
        return false
    }

    ; Step 7: Press 3
    SmithLog("SmeltCannonballs: [7] pressing 3")
    Send("{3}")
    Sleep(Random(100, 200))

    SmithLog("SmeltCannonballs: cycle complete — returning to step 1")
    return true
}

; Loop cannonball smelting cycles continuously until stopped (Ctrl+Escape).
; Start position: standing near furnace with materials.
LoopSmeltCannonballs() {
    global stopCurrentAction, manualStop
    stopCurrentAction := false
    manualStop := false

    SmithLog("LoopSmeltCannonballs: === START ===")
    ToolTip "Cannonballs: starting..."
    SetTimer () => ToolTip(), -2000

    Loop {
        if (ShouldStopAction()) {
            SmithLog("LoopSmeltCannonballs: stopped")
            ToolTip "Cannonballs: stopped"
            SetTimer () => ToolTip(), -3000
            return
        }

        if (!SmeltCannonballsCycle()) {
            SmithLog("LoopSmeltCannonballs: cycle failed — stopping")
            return
        }
    }
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global SmithingRegistry := Map(
    "LoopSmithing", {
        name: "LoopSmithing",
        func: LoopSmithing,
        description: "Bank(0x0A00FF) → deposit → slot 46 → esc → furnace(0xFF0000) → 4.5-5s → space → idle → repeat"
    },
    "SmithCycle", {
        name: "SmithCycle",
        func: SmithCycle,
        description: "One smithing cycle (bank must already be open): deposit → slot 46 → furnace → space → idle"
    },
    "CaptureCannonballFurnaceRect", {
        name: "CaptureCannonballFurnaceRect",
        func: CaptureCannonballFurnaceRect,
        description: "Capture furnace rectangle for cannonball smelting - saves to profile"
    },
    "LoopSmeltCannonballs", {
        name: "LoopSmeltCannonballs",
        func: LoopSmeltCannonballs,
        description: "Cannonball smelting loop: blue(0x0000FF) → 1.5s → space(600ms) → idle → inv1 → furnace rect → 1.5s → press3 → repeat"
    },
    "SmeltCannonballsCycle", {
        name: "SmeltCannonballsCycle",
        func: SmeltCannonballsCycle,
        description: "One cannonball smelting cycle: blue marker → space → idle → inv1 → furnace → 3 (requires furnace rect)"
    }
)
