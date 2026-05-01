#Requires AutoHotkey v2.0

; ======================================
; RUNECRAFTING FUNCTIONS
; ======================================

; Status icon region (client-relative) — bottom-right of game screen
global RC_STATUS_X1 := 499, RC_STATUS_Y1 := 321
global RC_STATUS_X2 := 507, RC_STATUS_Y2 := 330

; Status icon colors: red = idle, green = active
global RC_STATUS_RED   := [0xE02D2D, 0xE32828, 0xDE2F2F, 0xE12B2B, 0xE22929]
global RC_STATUS_GREEN := [0x32C850, 0x32C74F]

; Dense essence rock click target color
global RC_ROCK_COLOR := 0xF1FF00

; Essence mine agility shortcut color
global RC_AGILITY_SHORTCUT_COLOR := 0xFF8700

; Dark altar color (run to dark altar)
global RC_DARK_ALTAR_COLOR := 0xFF0087

; Inventory slot background colors used to detect empty slots
global RC_INV_BG_COLORS := [0x4B423A, 0x453C33, 0x483E35, 0x494035, 0x514941]

; Write a timestamped line to log/rc.log (Windows path via AHK)
RCLog(msg) {
    logPath := A_ScriptDir "\log\rc.log"
    timestamp := FormatTime(, "HH:mm:ss")
    FileAppend("[" timestamp "] " msg "`n", logPath)
}

; Sample and log the current status icon state (RED / GREEN / UNKNOWN + raw color)
RCLogStatus(context := "") {
    global RC_STATUS_X1, RC_STATUS_Y1, RC_STATUS_X2, RC_STATUS_Y2
    global RC_STATUS_RED, RC_STATUS_GREEN

    CoordMode "Pixel", "Client"
    midX := Round((RC_STATUS_X1 + RC_STATUS_X2) / 2)
    midY := Round((RC_STATUS_Y1 + RC_STATUS_Y2) / 2)
    rawColor := Format("0x{:06X}", PixelGetColor(midX, midY))

    isRed := false
    for color in RC_STATUS_RED {
        if (ColorExistsInRect(RC_STATUS_X1, RC_STATUS_Y1, RC_STATUS_X2, RC_STATUS_Y2, color)) {
            isRed := true
            break
        }
    }
    isGreen := false
    if (!isRed) {
        for color in RC_STATUS_GREEN {
            if (ColorExistsInRect(RC_STATUS_X1, RC_STATUS_Y1, RC_STATUS_X2, RC_STATUS_Y2, color)) {
                isGreen := true
                break
            }
        }
    }

    state := isRed ? "RED" : (isGreen ? "GREEN" : "UNKNOWN")
    prefix := (context != "") ? context ": " : ""
    RCLog(prefix "icon=" state " raw=" rawColor)
}

; Returns true if the status icon is red (character idle)
IsStatusIconIdle() {
    global RC_STATUS_X1, RC_STATUS_Y1, RC_STATUS_X2, RC_STATUS_Y2, RC_STATUS_RED

    for color in RC_STATUS_RED {
        if (ColorExistsInRect(RC_STATUS_X1, RC_STATUS_Y1, RC_STATUS_X2, RC_STATUS_Y2, color))
            return true
    }
    return false
}

; Returns true if inventory slot 28 contains an item (inventory is full).
; Requires two consecutive positive reads to prevent false positives from bad captures.
IsInventorySlot28Occupied() {
    global RC_INV_BG_COLORS
    if (FindLastOccupiedSlotInRange(28, 28, RC_INV_BG_COLORS) != 28)
        return false
    Sleep(100)
    return FindLastOccupiedSlotInRange(28, 28, RC_INV_BG_COLORS) = 28
}

; Show what colors FindLastOccupiedSlotInRange actually sees in slot 28.
; Use this to verify RC_INV_BG_COLORS matches your RuneLite theme.
DebugSlot28() {
    global RC_INV_BG_COLORS

    hwnd := WinExist("RuneLite ahk_class SunAwtFrame")
    if (!hwnd) {
        ToolTip "RuneLite not found"
        SetTimer () => ToolTip(), -2000
        return
    }

    clientX := 0, clientY := 0
    WinGetClientPos(&clientX, &clientY, , , hwnd)

    slotMap := IsFixedMode() ? InventorySlots : MediumInventorySlots
    s := slotMap[28]

    ; Sample center of slot 28
    CoordMode "Pixel", "Client"
    midX := Round((s.x1 + s.x2) / 2)
    midY := Round((s.y1 + s.y2) / 2)
    c1 := Format("0x{:06X}", PixelGetColor(s.x1 + 4, s.y1 + 3))
    c2 := Format("0x{:06X}", PixelGetColor(midX, midY))
    c3 := Format("0x{:06X}", PixelGetColor(s.x2 - 4, s.y2 - 3))

    occupied := FindLastOccupiedSlotInRange(28, 28, RC_INV_BG_COLORS) = 28

    msg := "Slot 28: " (occupied ? "OCCUPIED" : "empty") "`n"
        . "Slot rect: (" s.x1 "," s.y1 ")-(" s.x2 "," s.y2 ")`n"
        . "Colors — TL:" c1 "  C:" c2 "  BR:" c3
    ToolTip msg
    SetTimer () => ToolTip(), -8000
}

; Click the agility shortcut with yellow-click retry (same pattern as agility obstacles).
; Returns false if color not found.
ClickAgilityShortcut(maxRetries := 2) {
    global RC_AGILITY_SHORTCUT_COLOR
    retryCount := 0
    Loop {
        if (!ClickRandomPixelOfColor(RC_AGILITY_SHORTCUT_COLOR))
            return false
        MouseGetPos(&clickX, &clickY)
        result := CheckClickResult(clickX, clickY)
        if (result = "yellow" && retryCount < maxRetries) {
            retryCount++
            Sleep(150)
            continue
        }
        return true
    }
}

; Mine dense essence blocks until inventory is full, then click the agility shortcut.
; Resets cancel state on entry so re-running after a cancel works cleanly.
MineFullInventoryDenseEssenceBlocks() {
    global RC_ROCK_COLOR, RC_AGILITY_SHORTCUT_COLOR
    global stopCurrentAction, manualStop
    stopCurrentAction := false
    manualStop := false

    ToolTip "Dense essence: starting..."
    SetTimer () => ToolTip(), -2000
    RCLog("MineFullInventory: start")

    Loop {
        if (ShouldStopAction()) {
            RCLog("MineFullInventory: stopped by user")
            ToolTip "Dense essence: stopped"
            SetTimer () => ToolTip(), -3000
            return
        }

        if (IsInventorySlot28Occupied()) {
            RCLog("MineFullInventory: inventory full, clicking shortcut")
            ClickAgilityShortcut()
            RCLogStatus("MineFullInventory post-shortcut")
            ToolTip "Dense essence: done, shortcut clicked"
            SetTimer () => ToolTip(), -3000
            return
        } else if (IsStatusIconIdle()) {
            RCLog("MineFullInventory: idle detected, clicking rock")
            Sleep(2000)
            if (!GdipClickColorInGameView(RC_ROCK_COLOR, 5)) {
                RCLog("MineFullInventory: yellow rock not found, stopping")
                ToolTip "Dense essence: yellow rock not found, stopping"
                SetTimer () => ToolTip(), -3000
                return
            }
            RCLog("MineFullInventory: rock clicked")
            Sleep(3000)
        }

        Sleep(Random(2500, 3500))
    }
}

; Wait for an action to complete using state comparison.
; Polls at 50ms. Sets actionHappened when icon goes non-red (green/active).
; Only returns true once icon returns to red AND the action was observed.
; This prevents false-triggering on the initial idle state after a click.
; Returns false only if manually stopped.
WaitForActionComplete() {
    actionHappened := false
    pollCount := 0
    RCLogStatus("WaitForActionComplete start")
    Loop {
        if (ShouldStopAction()) {
            RCLog("WaitForActionComplete: stopped by user")
            return false
        }
        if (IsStatusIconIdle()) {
            if (actionHappened) {
                RCLog("WaitForActionComplete: done (idle after action)")
                return true
            } else {
                ; Log every 2s (40 polls × 50ms) while still waiting for action
                if (Mod(pollCount, 40) = 0)
                    RCLogStatus("WaitForActionComplete still-idle poll=" pollCount)
            }
        } else {
            if (!actionHappened) {
                RCLogStatus("WaitForActionComplete action-detected")
                actionHappened := true
            }
        }
        pollCount++
        Sleep(50)
    }
}

; Wait for RapidClick2InventorySpots to self-stop (slot 2 empty), then wait for idle.
WaitForRapidClick2Done() {
    global isRapidClick2Spots
    Loop {
        if (ShouldStopAction())
            return false
        if (!isRapidClick2Spots)
            break
        Sleep(200)
    }
    return WaitForActionComplete()
}

; Mine one full inventory and end by clicking the dark altar.
; Useful for testing individual phases. Resets cancel state on entry.
Process1ZeahInventory() {
    global RC_DARK_ALTAR_COLOR
    global stopCurrentAction, manualStop, isRapidClick2Spots
    stopCurrentAction := false
    manualStop := false
    isRapidClick2Spots := false

    MineFullInventoryDenseEssenceBlocks()
    if (manualStop)
        return

    ToolTip "Process1ZeahInventory: waiting for obstacle crossing..."
    if (!WaitForActionComplete())
        return

    ToolTip "Process1ZeahInventory: running to dark altar..."
    ClickRandomPixelOfColor(RC_DARK_ALTAR_COLOR)
    ToolTip "Process1ZeahInventory: complete"
    SetTimer () => ToolTip(), -4000
}

; Full Zeah RC preparation sequence. Start position: essence mine.
; Steps mirror exact in-game timing based on status icon:
;  1.  Mine until full → click shortcut (red)
;  2.  Run to shortcut (red) → do shortcut (green) → wait for red
;  3.  Click altar (red) → run to altar (red) → imbue (green→red)
;  4.  Click shortcut (red) → immediately start RapidClick2 (icon goes green)
;  5.  Wait for RapidClick2 done + idle (red)
;  6.  Click shortcut (green) → wait for red
;  7.  Mine second inventory → click shortcut (red)
;  8.  Run to shortcut (red) → do shortcut (green) → wait for red
;  9.  Click altar — end
; Resets cancel state on entry so re-running after a cancel works cleanly.
PrepareZeahRCInventory() {
    global RC_DARK_ALTAR_COLOR
    global stopCurrentAction, manualStop, isRapidClick2Spots
    stopCurrentAction := false
    manualStop := false
    isRapidClick2Spots := false

    RCLog("PrepareZeahRC: === START ===")

    ; Step 1: Mine first inventory (ends by clicking shortcut)
    RCLog("PrepareZeahRC: step 1 - mining first inventory")
    ToolTip "PrepareZeahRC: mining first inventory..."
    MineFullInventoryDenseEssenceBlocks()
    if (manualStop) {
        RCLog("PrepareZeahRC: stopped after step 1 (mine 1)")
        return
    }

    ; Step 2: Run to shortcut (red) → do shortcut (green) → red
    RCLog("PrepareZeahRC: step 2 - waiting for shortcut crossing")
    ToolTip "PrepareZeahRC: waiting for shortcut crossing..."
    if (!WaitForActionComplete()) {
        RCLog("PrepareZeahRC: stopped during step 2 wait")
        return
    }

    ; Step 3: Click altar → run there (red) → imbue (green→red)
    RCLog("PrepareZeahRC: step 3 - clicking dark altar")
    ToolTip "PrepareZeahRC: running to dark altar..."
    ClickRandomPixelOfColor(RC_DARK_ALTAR_COLOR)
    RCLog("PrepareZeahRC: step 3 - waiting to arrive and imbue")
    ToolTip "PrepareZeahRC: waiting to arrive and imbue..."
    if (!WaitForActionComplete()) {
        RCLog("PrepareZeahRC: stopped during step 3 wait")
        return
    }

    ; Step 4: Click shortcut, immediately start RapidClick2 (no wait)
    RCLog("PrepareZeahRC: step 4 - clicking shortcut + starting RapidClick2")
    ToolTip "PrepareZeahRC: shortcut + consecrating..."
    ClickAgilityShortcut()
    RCLogStatus("PrepareZeahRC step4 post-shortcut")
    RapidClick2InventorySpots()

    ; Step 5: Wait for consecration to finish and character idle
    RCLog("PrepareZeahRC: step 5 - waiting for consecration + idle")
    ToolTip "PrepareZeahRC: waiting for consecration..."
    if (!WaitForRapidClick2Done()) {
        RCLog("PrepareZeahRC: stopped during step 5 wait")
        return
    }

    ; Step 6: Click shortcut (green) → wait for red
    RCLog("PrepareZeahRC: step 6 - crossing shortcut back")
    ToolTip "PrepareZeahRC: crossing shortcut..."
    ClickAgilityShortcut()
    RCLogStatus("PrepareZeahRC step6 post-shortcut")
    if (!WaitForActionComplete()) {
        RCLog("PrepareZeahRC: stopped during step 6 wait")
        return
    }

    ; Step 7: Mine second inventory (ends by clicking shortcut)
    RCLog("PrepareZeahRC: step 7 - mining second inventory")
    ToolTip "PrepareZeahRC: mining second inventory..."
    MineFullInventoryDenseEssenceBlocks()
    if (manualStop) {
        RCLog("PrepareZeahRC: stopped after step 7 (mine 2)")
        return
    }

    ; Step 8: Run to shortcut (red) → do shortcut (green) → red
    RCLog("PrepareZeahRC: step 8 - waiting for shortcut crossing")
    ToolTip "PrepareZeahRC: waiting for shortcut crossing..."
    if (!WaitForActionComplete()) {
        RCLog("PrepareZeahRC: stopped during step 8 wait")
        return
    }

    ; Step 9: Click altar — end
    RCLog("PrepareZeahRC: step 9 - clicking dark altar (end)")
    ToolTip "PrepareZeahRC: running to dark altar..."
    ClickRandomPixelOfColor(RC_DARK_ALTAR_COLOR)
    RCLog("PrepareZeahRC: === COMPLETE ===")
    ToolTip "PrepareZeahRCInventory: complete"
    SetTimer () => ToolTip(), -4000
}

; Sample the status icon region and report what colors are actually there.
; Shows: detected state, actual colors at 3 sample points, and the screen coords used.
; Bind this to a key to verify the status icon coordinates are correct.
DebugStatusIcon() {
    global RC_STATUS_X1, RC_STATUS_Y1, RC_STATUS_X2, RC_STATUS_Y2
    global RC_STATUS_RED, RC_STATUS_GREEN

    CoordMode "Pixel", "Client"
    midX := Round((RC_STATUS_X1 + RC_STATUS_X2) / 2)
    midY := Round((RC_STATUS_Y1 + RC_STATUS_Y2) / 2)
    c1 := Format("0x{:06X}", PixelGetColor(RC_STATUS_X1, RC_STATUS_Y1))
    c2 := Format("0x{:06X}", PixelGetColor(midX, midY))
    c3 := Format("0x{:06X}", PixelGetColor(RC_STATUS_X2, RC_STATUS_Y2))

    detectedRed := false
    for color in RC_STATUS_RED {
        if (ColorExistsInRect(RC_STATUS_X1, RC_STATUS_Y1, RC_STATUS_X2, RC_STATUS_Y2, color)) {
            detectedRed := true
            break
        }
    }
    detectedGreen := false
    for color in RC_STATUS_GREEN {
        if (ColorExistsInRect(RC_STATUS_X1, RC_STATUS_Y1, RC_STATUS_X2, RC_STATUS_Y2, color)) {
            detectedGreen := true
            break
        }
    }

    state := detectedRed ? "RED (idle)" : (detectedGreen ? "GREEN (active)" : "UNKNOWN")

    msg := "Status icon: " state "`n"
        . "Client rect: (" RC_STATUS_X1 "," RC_STATUS_Y1 ")-(" RC_STATUS_X2 "," RC_STATUS_Y2 ")`n"
        . "Colors — TL:" c1 "  C:" c2 "  BR:" c3
    ToolTip msg
    SetTimer () => ToolTip(), -8000
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global RunecraftingRegistry := Map(
    "MineFullInventoryDenseEssenceBlocks", {
        name: "MineFullInventoryDenseEssenceBlocks",
        func: MineFullInventoryDenseEssenceBlocks,
        description: "Mine dense essence until inventory full, then click agility shortcut"
    },
    "Process1ZeahInventory", {
        name: "Process1ZeahInventory",
        func: Process1ZeahInventory,
        description: "Mine one full inventory, cross obstacle, click dark altar (end)"
    },
    "PrepareZeahRCInventory", {
        name: "PrepareZeahRCInventory",
        func: PrepareZeahRCInventory,
        description: "Full Zeah RC prep: mine x2, consecrate at altar, end at dark altar"
    },
    "DebugStatusIcon", {
        name: "DebugStatusIcon",
        func: DebugStatusIcon,
        description: "Show status icon state (red/green/unknown) + actual pixel colors for debugging"
    },
    "DebugSlot28", {
        name: "DebugSlot28",
        func: DebugSlot28,
        description: "Show slot 28 occupied state + actual pixel colors to verify RC_INV_BG_COLORS"
    }
)
