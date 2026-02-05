#Requires AutoHotkey v2.0

; ======================================
; AGILITY FUNCTIONS
; ======================================

; Agility course obstacle colors
global AGILITY_COLOR_BLUE := 0x001DFF
global AGILITY_COLOR_YELLOW := 0xF1FF00
global AGILITY_COLOR_ORANGE := 0xFF8700

; Interruptible sleep - checks kill switch every 100ms
; Returns false if interrupted, true if completed
InterruptibleSleep(duration) {
    elapsed := 0
    while (elapsed < duration) {
        if (ShouldStopAction())
            return false
        Sleep(100)
        elapsed += 100
    }
    return true
}

; Map click area (south on minimap) - CLIENT-RELATIVE coordinates
; Captured at screen (647, 137, 654, 144) with client at ~(0, 31)
global agilityMapClickX1 := 647
global agilityMapClickY1 := 106
global agilityMapClickX2 := 654
global agilityMapClickY2 := 113

; Timing capture state
global isCapturingTiming := false
global capturedTimestamps := []
global timingCaptureHook := 0

; Click any blue obstacle pixel near character (using Gdip for better accuracy)
ClickBlueObstacle() {
    return GdipClickColorNearCharacter(AGILITY_COLOR_BLUE, 5, 0, 0)
}

; Click any yellow obstacle pixel near character
ClickYellowObstacle() {
    return GdipClickColorNearCharacter(AGILITY_COLOR_YELLOW, 5, 0, 0)
}

; Click any orange obstacle pixel near character
ClickOrangeObstacle() {
    return GdipClickColorNearCharacter(AGILITY_COLOR_ORANGE, 5, 0, 0)
}

; Click south on minimap (within configured rectangle)
ClickSouthOnMap() {
    global agilityMapClickX1, agilityMapClickY1, agilityMapClickX2, agilityMapClickY2

    ; Click random point within the map rectangle
    ClickRandomPixel(agilityMapClickX1, agilityMapClickY1, agilityMapClickX2, agilityMapClickY2)
    return true
}

; Set the map click rectangle for agility course
; Call this with the coordinates you want
SetAgilityMapArea(x1, y1, x2, y2) {
    global agilityMapClickX1, agilityMapClickY1, agilityMapClickX2, agilityMapClickY2
    agilityMapClickX1 := x1
    agilityMapClickY1 := y1
    agilityMapClickX2 := x2
    agilityMapClickY2 := y2
    ToolTip "Agility map area set: " x1 "," y1 " to " x2 "," y2
    SetTimer () => ToolTip(), -2000
}

; Run a single lap of the agility course
; Sequence: blue, yellow, blue, yellow, orange, map south, yellow, blue
; Wait times based on captured timing - 200ms, with +/- 300ms randomness
RunAgilityLap() {
    ; Step 1: Click blue, wait ~5457ms
    if (!ClickBlueObstacle())
        return false
    if (!InterruptibleSleep(Random(5157, 5757)))
        return false

    ; Step 2: Click yellow, wait ~8222ms
    if (!ClickYellowObstacle())
        return false
    if (!InterruptibleSleep(Random(7922, 8522)))
        return false

    ; Step 3: Click blue, wait ~6675ms
    if (!ClickBlueObstacle())
        return false
    if (!InterruptibleSleep(Random(6375, 6975)))
        return false

    ; Step 4: Click yellow, wait ~3706ms
    if (!ClickYellowObstacle())
        return false
    if (!InterruptibleSleep(Random(3406, 4006)))
        return false

    ; Step 5: Click orange, wait ~4331ms
    if (!ClickOrangeObstacle())
        return false
    if (!InterruptibleSleep(Random(4031, 4631)))
        return false

    ; Step 6: Click south on map, wait ~4075ms (added 900ms total before yellow)
    if (!ClickSouthOnMap())
        return false
    if (!InterruptibleSleep(Random(3775, 4375)))
        return false

    ; Step 7: Click yellow, wait ~3675ms
    if (!ClickYellowObstacle())
        return false
    if (!InterruptibleSleep(Random(3375, 3975)))
        return false

    ; Step 8: Click blue, finished
    if (!ClickBlueObstacle())
        return false

    ToolTip "Agility lap complete!"
    SetTimer () => ToolTip(), -2000
    return true
}

; Loop agility laps until stopped with Ctrl+Esc or color not found
LoopAgilityLaps() {
    lapCount := 0

    Loop {
        if (ShouldStopAction()) {
            ToolTip "Agility stopped after " lapCount " laps"
            SetTimer () => ToolTip(), -3000
            return
        }

        if (RunAgilityLap()) {
            lapCount++
            ToolTip "Completed lap " lapCount ", starting next..."
            ; Wait between last click and first click of next lap (~10469ms, ±300ms randomness)
            if (!InterruptibleSleep(Random(10469, 11069)))
                return
        } else {
            ; Lap failed - either interrupted or color not found, stop loop
            ToolTip "Agility stopped after " lapCount " laps (color not found or cancelled)"
            SetTimer () => ToolTip(), -3000
            return
        }
    }
}

; ======================================
; TIMING CAPTURE FUNCTIONS
; ======================================

; Toggle timing capture on/off
; First press: start capturing clicks
; Second press: stop and show results
ToggleTimingCapture() {
    global isCapturingTiming, capturedTimestamps

    if (isCapturingTiming) {
        StopTimingCapture()
    } else {
        StartTimingCapture()
    }
}

; Start capturing click timestamps
StartTimingCapture() {
    global isCapturingTiming, capturedTimestamps

    isCapturingTiming := true
    capturedTimestamps := []

    ; Register the click hook
    Hotkey("~LButton", CaptureClickTimestamp, "On")

    ToolTip "Timing capture STARTED`nClick obstacles, then press keybind again to stop"
    SetTimer () => ToolTip(), -3000
}

; Stop capturing and display results
StopTimingCapture() {
    global isCapturingTiming, capturedTimestamps

    isCapturingTiming := false

    ; Unregister the click hook
    Hotkey("~LButton", CaptureClickTimestamp, "Off")

    ; Calculate and display intervals
    if (capturedTimestamps.Length < 2) {
        ToolTip "Not enough clicks captured (need at least 2)"
        SetTimer () => ToolTip(), -3000
        return
    }

    ; Build results string
    results := "Timing Capture Results:`n"
    results .= "Clicks: " capturedTimestamps.Length "`n"
    results .= "================================`n"

    ; Show each click with details
    Loop capturedTimestamps.Length {
        click := capturedTimestamps[A_Index]
        results .= "Click " A_Index ": (" click.x ", " click.y ") " click.color "`n"
    }

    results .= "================================`n"
    results .= "Intervals:`n"

    intervals := []
    Loop capturedTimestamps.Length - 1 {
        interval := capturedTimestamps[A_Index + 1].time - capturedTimestamps[A_Index].time
        intervals.Push(interval)
        results .= "  " A_Index " -> " (A_Index + 1) ": " interval "ms`n"
    }

    ; Calculate stats
    total := 0
    minInterval := intervals[1]
    maxInterval := intervals[1]

    for interval in intervals {
        total += interval
        if (interval < minInterval)
            minInterval := interval
        if (interval > maxInterval)
            maxInterval := interval
    }

    avgInterval := Round(total / intervals.Length)

    results .= "================================`n"
    results .= "Min: " minInterval "ms | Max: " maxInterval "ms | Avg: " avgInterval "ms`n"

    ; Copy to clipboard for easy reference
    A_Clipboard := results

    ToolTip results "`n(Copied to clipboard)"
    SetTimer () => ToolTip(), -15000
}

; Callback for click capture
CaptureClickTimestamp(ThisHotkey) {
    global isCapturingTiming, capturedTimestamps

    if (isCapturingTiming) {
        MouseGetPos(&mouseX, &mouseY)
        pixelColor := PixelGetColor(mouseX, mouseY)

        capturedTimestamps.Push({
            time: A_TickCount,
            x: mouseX,
            y: mouseY,
            color: pixelColor
        })
        ToolTip "Click " capturedTimestamps.Length " captured at " mouseX "," mouseY
        SetTimer () => ToolTip(), -500
    }
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global AgilityRegistry := Map(
    "ClickBlueObstacle", {
        name: "ClickBlueObstacle",
        func: ClickBlueObstacle,
        description: "Click blue agility obstacle closest to character"
    },
    "ClickYellowObstacle", {
        name: "ClickYellowObstacle",
        func: ClickYellowObstacle,
        description: "Click yellow agility obstacle closest to character"
    },
    "ClickOrangeObstacle", {
        name: "ClickOrangeObstacle",
        func: ClickOrangeObstacle,
        description: "Click orange agility obstacle closest to character"
    },
    "ClickSouthOnMap", {
        name: "ClickSouthOnMap",
        func: ClickSouthOnMap,
        description: "Click south on minimap (configure area first)"
    },
    "RunAgilityLap", {
        name: "RunAgilityLap",
        func: RunAgilityLap,
        description: "Run single agility lap: blue, yellow, blue, yellow, orange, map, yellow, blue"
    },
    "LoopAgilityLaps", {
        name: "LoopAgilityLaps",
        func: LoopAgilityLaps,
        description: "Loop agility laps until Ctrl+Esc"
    },
    "ToggleTimingCapture", {
        name: "ToggleTimingCapture",
        func: ToggleTimingCapture,
        description: "Start/stop capturing click timing intervals"
    }
)
