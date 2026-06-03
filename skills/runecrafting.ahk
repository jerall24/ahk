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

; Fallback click rect for dark altar when color isn't visible (too far away)
global RC_DARK_ALTAR_FB_X1 := 125, RC_DARK_ALTAR_FB_Y1 := 140
global RC_DARK_ALTAR_FB_X2 := 137, RC_DARK_ALTAR_FB_Y2 := 154

; Soul altar color — same marker color as dark altar but always in different frames
global RC_SOUL_ALTAR_COLOR := 0xFFB700

; Color clicked mid-run toward soul altar (at ~12750ms mark along the path)
global RC_SOUL_PATH_MID_COLOR := 0x7DFF00

; Agility shortcut from soul altar back to essence mine
global RC_SOUL_SHORTCUT_COLOR := 0xFF4D00

; Minimap midpoint clicked en route to soul altar (client-relative)
global RC_SOUL_PATH_X1 := 397, RC_SOUL_PATH_Y1 := 114
global RC_SOUL_PATH_X2 := 408, RC_SOUL_PATH_Y2 := 120

; Fallback click rect for soul altar when color isn't visible
global RC_SOUL_ALTAR_FB_X1 := 400, RC_SOUL_ALTAR_FB_Y1 := 281
global RC_SOUL_ALTAR_FB_X2 := 429, RC_SOUL_ALTAR_FB_Y2 := 302

; Inventory slot background colors used to detect empty slots
global RC_INV_BG_COLORS := [0x4B423A, 0x453C33, 0x483E35, 0x494035, 0x514941]

; Write a timestamped line to log/rc.log and OutputDebug (for real-time viewing in DebugView)
RCLog(msg) {
    logPath := A_ScriptDir "\log\rc.log"
    timestamp := FormatTime(, "HH:mm:ss")
    line := "[" timestamp "] " msg
    FileAppend(line "`n", logPath)
    OutputDebug(line)
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

; Click a color target and retry if the result is yellow (already queued).
; Use this when the character has arrived and the click must register as a new action.
; Returns false if the color isn't found at all.
ClickColorEnsureRed(color, maxRetries := 4) {
    retryCount := 0
    Loop {
        if (!GdipClickColorInGameView(color, 5, 0, 0, 0))
            return false
        MouseGetPos(&clickX, &clickY)
        result := CheckClickResult(clickX, clickY)
        RCLog("ClickColorEnsureRed: color=0x" Format("{:06X}", color) " result=" result " attempt=" retryCount + 1)
        if (result = "yellow" && retryCount < maxRetries) {
            retryCount++
            Sleep(1000)
            continue
        }
        return true
    }
}

; Click the dark altar. If the color isn't visible (too far), clicks the fallback rect,
; waits 15200ms for the character to get closer, then clicks the color.
; Returns false if cancelled during the wait.
ClickDarkAltar() {
    global RC_DARK_ALTAR_COLOR
    global RC_DARK_ALTAR_FB_X1, RC_DARK_ALTAR_FB_Y1, RC_DARK_ALTAR_FB_X2, RC_DARK_ALTAR_FB_Y2

    if (!ClickRandomPixelOfColor(RC_DARK_ALTAR_COLOR)) {
        RCLog("ClickDarkAltar: color not found — clicking fallback rect, waiting 15200ms")
        ClickRandomPixel(RC_DARK_ALTAR_FB_X1, RC_DARK_ALTAR_FB_Y1, RC_DARK_ALTAR_FB_X2, RC_DARK_ALTAR_FB_Y2)
        Sleep(15200)
        if (ShouldStopAction()) {
            RCLog("ClickDarkAltar: stopped during fallback wait")
            return false
        }
        RCLog("ClickDarkAltar: clicking dark altar color after wait")
        MoveMouseToGameView()
        ScrollWheel("up",  10)
        ClickColorEnsureRed(RC_DARK_ALTAR_COLOR)
        ScrollWheel("down", 20)
    }
    return true
}

; Mine dense essence blocks until inventory is full, then click the agility shortcut.
; Resets cancel state on entry so re-running after a cancel works cleanly.
MineFullInventoryDenseEssenceBlocks() {
    global RC_ROCK_COLOR, RC_AGILITY_SHORTCUT_COLOR
    global stopCurrentAction, manualStop
    stopCurrentAction := false
    manualStop := false
    specialAttackClicked := false
    isFirstClick := true

    RCLog("MineFullInventory: start")

    Loop {
        if (ShouldStopAction()) {
            RCLog("MineFullInventory: stopped by user")
            return
        }

        if (IsInventorySlot28Occupied()) {
            RCLog("MineFullInventory: slot28 full — clicking agility shortcut")
            MoveMouseToGameView()
            ScrollWheel("up", 7)
            ClickColorEnsureRed(RC_AGILITY_SHORTCUT_COLOR)
            RCLogStatus("MineFullInventory: post-shortcut click")
            ScrollWheel("down", 20)
            return
        } else if (IsStatusIconIdle()) {
            RCLog("MineFullInventory: icon=RED idle — sleeping 2s then clicking rock")
            if (!GdipClickColorInGameView(RC_ROCK_COLOR, 5)) {
                RCLog("MineFullInventory: rock color not found — stopping")
                return
            }
            if (isFirstClick) {
                Sleep(Random(1900, 2100))
                isFirstClick := false
            }
            if (!specialAttackClicked) {
                ClickSpecialAttack()
                specialAttackClicked := true
            }
            RCLog("MineFullInventory: rock clicked — mining")
            Sleep(Random(2900, 3000))
        } else {
            RCLog("MineFullInventory: icon=GREEN mining in progress — waiting")
        }

        Sleep(Random(2500, 3500))
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

    if (!WaitForActionComplete())
        return

    ClickDarkAltar()
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
    MineFullInventoryDenseEssenceBlocks()
    if (manualStop) {
        RCLog("PrepareZeahRC: stopped after step 1 (mine 1)")
        return
    }

    ; Step 2: Travel through shortcut → wait for idle on other side
    RCLog("PrepareZeahRC: [2] shortcut clicked — 2s buffer before polling idle")
    Sleep(2000)
    if (ShouldStopAction()) {
        RCLog("PrepareZeahRC: [2] stopped during 2s buffer")
        return
    }
    RCLog("PrepareZeahRC: [2] waiting to cross to other side")
    MoveMouseToGameView()
    ScrollWheel("up", 7)
    if (!WaitForActionComplete(() => ClickColorEnsureRed(RC_AGILITY_SHORTCUT_COLOR))) {
        RCLog("PrepareZeahRC: [2] stopped while waiting for shortcut cross")
        return
    }
    RCLogStatus("PrepareZeahRC: [2] shortcut crossed")
    ScrollWheel("down", 20)

    ; Step 3: Click altar → run there → imbue (green→red)
    RCLog("PrepareZeahRC: [3] clicking dark altar")
    if (!ClickDarkAltar()) {
        RCLog("PrepareZeahRC: [3] stopped during dark altar click")
        return
    }
    RCLog("PrepareZeahRC: [3] altar clicked — waiting to arrive")
    if (!WaitForActionComplete(() => ClickDarkAltar())) {
        RCLog("PrepareZeahRC: [3] stopped while waiting for altar imbue")
        return
    }
    RCLogStatus("PrepareZeahRC: [3] altar imbue complete")

    ; Step 4: Click shortcut back into mine, immediately start consecrating
    RCLog("PrepareZeahRC: [4] clicking shortcut back into mine")
    ClickColorEnsureRed(RC_AGILITY_SHORTCUT_COLOR)
    RCLogStatus("PrepareZeahRC: [4] shortcut clicked")
    RCLog("PrepareZeahRC: [4] starting RapidClick2 consecration")
    RapidClick2InventorySpots()
    
    ; Step 5: Wait for consecration to finish and character idle
    RCLog("PrepareZeahRC: [5] waiting for consecration to finish")
    if (!WaitForRapidClick2Done()) {
        RCLog("PrepareZeahRC: [5] stopped while waiting for consecration")
        return
    }
    RCLogStatus("PrepareZeahRC: [5] consecration done — idle")
    MoveMouseToGameView()
    ScrollWheel("up",  20)

    ; Step 6: Cross shortcut out of mine → wait for idle on other side
    RCLog("PrepareZeahRC: [6] clicking shortcut out of mine")
    ClickColorEnsureRed(RC_AGILITY_SHORTCUT_COLOR)
    RCLogStatus("PrepareZeahRC: [6] shortcut clicked")
    RCLog("PrepareZeahRC: [6] waiting to cross to other side")
    if (!WaitForActionComplete(() => ClickColorEnsureRed(RC_AGILITY_SHORTCUT_COLOR))) {
        RCLog("PrepareZeahRC: [6] stopped while waiting for shortcut cross")
        return
    }
    RCLogStatus("PrepareZeahRC: [6] shortcut crossed")
    Sleep(Random(50, 150))
    ScrollWheel("down", 20)

    ; Step 7: Mine second inventory (ends by clicking shortcut)
    RCLog("PrepareZeahRC: [7] mining second inventory")
    MineFullInventoryDenseEssenceBlocks()
    if (manualStop) {
        RCLog("PrepareZeahRC: [7] stopped after mine 2")
        return
    }

    ; Step 8: Travel through shortcut → wait for idle on other side
    RCLog("PrepareZeahRC: [8] shortcut clicked — 2s buffer before polling idle")
    Sleep(2000)
    if (ShouldStopAction()) {
        RCLog("PrepareZeahRC: [8] stopped during 2s buffer")
        return
    }
    MoveMouseToGameView()
    ScrollWheel("up", 7)
    RCLog("PrepareZeahRC: [8] waiting to cross to other side")
    if (!WaitForActionComplete(() => ClickColorEnsureRed(RC_AGILITY_SHORTCUT_COLOR))) {
        RCLog("PrepareZeahRC: [8] stopped while waiting for shortcut cross")
        return
    }
    ScrollWheel("down", 20)
    RCLogStatus("PrepareZeahRC: [8] shortcut crossed")

    ; Step 9: Click altar — end
    RCLog("PrepareZeahRC: [9] clicking dark altar — end of prep")
    ClickDarkAltar()
    RCLog("PrepareZeahRC: === COMPLETE ===")
}

; Run from dark altar to soul altar, bind runes, and return to essence mine.
; Start position: at dark altar (PrepareZeahRCInventory just clicked it, character still running).
; End position: idle at essence mine entrance.
RunToAndCraftSoulRunes() {
    global RC_SOUL_ALTAR_COLOR, RC_SOUL_PATH_MID_COLOR, RC_SOUL_SHORTCUT_COLOR, RC_AGILITY_SHORTCUT_COLOR
    global RC_SOUL_PATH_X1, RC_SOUL_PATH_Y1, RC_SOUL_PATH_X2, RC_SOUL_PATH_Y2
    global RC_SOUL_ALTAR_FB_X1, RC_SOUL_ALTAR_FB_Y1, RC_SOUL_ALTAR_FB_X2, RC_SOUL_ALTAR_FB_Y2

    RCLog("SoulRunes: === START ===")

    ; Step 1: Wait for arrival at dark altar, then click path midpoint toward soul altar
    RCLog("SoulRunes: [1] waiting for idle at dark altar")
    if (!WaitForActionComplete(() => ClickDarkAltar())) {
        RCLog("SoulRunes: [1] stopped waiting for dark altar idle")
        return
    }
    RCLogStatus("SoulRunes: [1] arrived at dark altar")
    RCLog("SoulRunes: [1] clicking path midpoint to soul altar")
    ClickRandomPixel(RC_SOUL_PATH_X1, RC_SOUL_PATH_Y1, RC_SOUL_PATH_X2, RC_SOUL_PATH_Y2)

    ; Step 2: Wait 12750ms en route, then click soul altar to queue entry
    RCLog("SoulRunes: [2] waiting 12750ms en route")
    Sleep(12750)
    if (ShouldStopAction()) {
        RCLog("SoulRunes: [2] stopped during travel sleep")
        return
    }
    RCLog("SoulRunes: [2] clicking mid-path color (0x7DFF00)")
    ClickRandomPixelOfColor(RC_SOUL_PATH_MID_COLOR)

    ; Step 3: Wait 11300ms approaching altar
    RCLog("SoulRunes: [3] waiting 11300ms approaching soul altar")
    Sleep(11300)
    if (ShouldStopAction()) {
        RCLog("SoulRunes: [3] stopped during approach sleep")
        return
    }

    ; Step 4: Click soul altar — color or fallback rect. Re-click after 30s if not red.
    RCLog("SoulRunes: [4] clicking soul altar (color or fallback)")
    clickedRed := false
    if (ClickRandomPixelOfColor(RC_SOUL_ALTAR_COLOR)) {
        MouseGetPos(&cx, &cy)
        result := CheckClickResult(cx, cy)
        RCLog("SoulRunes: [4] soul altar color click result=" result)
        clickedRed := (result = "red")
    } else {
        RCLog("SoulRunes: [4] soul altar color not found — using fallback rect")
        ClickRandomPixel(RC_SOUL_ALTAR_FB_X1, RC_SOUL_ALTAR_FB_Y1, RC_SOUL_ALTAR_FB_X2, RC_SOUL_ALTAR_FB_Y2)
        MouseGetPos(&cx, &cy)
        result := CheckClickResult(cx, cy)
        RCLog("SoulRunes: [4] fallback click result=" result)
        clickedRed := (result = "red")
    }
    if (!clickedRed) {
        RCLog("SoulRunes: [4] not red — waiting 30000ms to arrive then re-clicking")
        Sleep(30000)
        if (ShouldStopAction()) {
            RCLog("SoulRunes: [4] stopped during 30s arrival wait")
            return
        }
        RCLog("SoulRunes: [4] re-clicking soul altar after wait")
        ClickColorEnsureRed(RC_SOUL_ALTAR_COLOR)
    }

    ; Step 5: Wait for green→red (soul altar binding complete)
    RCLog("SoulRunes: [5] waiting for soul altar binding to complete")
    if (!WaitForActionComplete(() => ClickColorEnsureRed(RC_SOUL_ALTAR_COLOR))) {
        RCLog("SoulRunes: [5] stopped waiting for binding idle")
        return
    }
    RCLogStatus("SoulRunes: [5] binding complete — idle")

    ; Step 6: Consecrate essence
    RCLog("SoulRunes: [6] starting RapidClick2 consecration")
    RapidClick2InventorySpots()

    ; Step 7: Wait for consecration to finish, then click soul altar to start running back
    RCLog("SoulRunes: [7] waiting for consecration to finish")
    if (!WaitForRapidClick2Done()) {
        RCLog("SoulRunes: [7] stopped during consecration")
        return
    }
    RCLogStatus("SoulRunes: [7] consecration done — idle")
    RCLog("SoulRunes: [7] clicking soul altar to begin return run")
    ClickColorEnsureRed(RC_SOUL_ALTAR_COLOR)

    ; Step 8: Wait for green→red (running out of altar)
    RCLog("SoulRunes: [8] waiting for idle after leaving soul altar")
    if (!WaitForActionComplete(() => ClickColorEnsureRed(RC_SOUL_ALTAR_COLOR))) {
        RCLog("SoulRunes: [8] stopped waiting for post-altar idle")
        return
    }
    RCLogStatus("SoulRunes: [8] out of soul altar — idle")

    ; Step 9: Click agility shortcut back to essence mine
    RCLog("SoulRunes: [9] clicking soul shortcut toward essence mine")
    ; ClickColorEnsureRed(RC_SOUL_SHORTCUT_COLOR)
    GdipClickColorInGameView(RC_SOUL_SHORTCUT_COLOR, 5, 0, 0, 0)

    ; Step 10: Wait 23500ms (run stalls midway)
    RCLog("SoulRunes: [10] waiting 23500ms during run to mine")
    Sleep(23500)
    if (ShouldStopAction()) {
        RCLog("SoulRunes: [10] stopped during run sleep")
        return
    }

    ; Step 11: Re-click shortcut (run stalled)
    RCLog("SoulRunes: [11] re-clicking soul shortcut (run stalled)")
    MoveMouseToGameView()
    ScrollWheel("up",  13)
    ClickColorEnsureRed(RC_SOUL_SHORTCUT_COLOR)
    Sleep(Random(100,200))
    ScrollWheel("down", 20)

    ; Step 12: Wait until green→red
    RCLog("SoulRunes: [12] waiting for idle after shortcut")
    if (!WaitForActionComplete(() => ClickColorEnsureRed(RC_SOUL_SHORTCUT_COLOR))) {
        RCLog("SoulRunes: [12] stopped waiting for shortcut idle")
        return
    }
    RCLogStatus("SoulRunes: [12] shortcut crossed — idle")

    ; Step 13: Click essence mine agility shortcut
    RCLog("SoulRunes: [13] clicking essence mine agility shortcut")
    ClickColorEnsureRed(RC_AGILITY_SHORTCUT_COLOR)

    RCLog("SoulRunes: [14] waiting for idle at essence mine entrance")
    if (!WaitForActionComplete(() => ClickColorEnsureRed(RC_AGILITY_SHORTCUT_COLOR))) {
        RCLog("SoulRunes: [14] stopped waiting for mine entry idle")
        return
    }
    RCLogStatus("SoulRunes: [14] at essence mine — idle")
    RCLog("SoulRunes: === COMPLETE ===")
}

; Full single-pass Zeah RC run. Start and end position: essence mine.
; Call via LoopCompleteZeahRun to loop continuously.
CompleteZeahRun() {
    global manualStop

    RCLog("CompleteZeahRun: === START ===")
    PrepareZeahRCInventory()
    if (manualStop) {
        RCLog("CompleteZeahRun: stopped during prep phase")
        return
    }
    RunToAndCraftSoulRunes()
    if (manualStop) {
        RCLog("CompleteZeahRun: stopped during soul runes phase")
        return
    }
    RCLog("CompleteZeahRun: === COMPLETE ===")
}

; Loop CompleteZeahRun continuously. Restarts immediately after each run ends.
; Stop with Ctrl+Escape. Bind this key instead of CompleteZeahRun for a continuous loop.
LoopCompleteZeahRun() {
    global stopCurrentAction, manualStop
    stopCurrentAction := false
    manualStop := false

    Loop {
        CompleteZeahRun()
        if (manualStop)
            return
    }
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
    "RunToAndCraftSoulRunes", {
        name: "RunToAndCraftSoulRunes",
        func: RunToAndCraftSoulRunes,
        description: "Run from dark altar to soul altar, bind runes, return to essence mine"
    },
    "CompleteZeahRun", {
        name: "CompleteZeahRun",
        func: CompleteZeahRun,
        description: "Full single-pass Zeah RC run (mine → prep → soul altar → mine). Use LoopCompleteZeahRun to loop."
    },
    "LoopCompleteZeahRun", {
        name: "LoopCompleteZeahRun",
        func: LoopCompleteZeahRun,
        description: "Loop CompleteZeahRun continuously until Ctrl+Escape. Bind this for a full RC loop."
    }
)
