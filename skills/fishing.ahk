#Requires AutoHotkey v2.0

; ======================================
; FISHING FUNCTIONS
; ======================================

; Minnow fishing spot color
global FISH_MINNOW_COLOR := 0x00DDFF
global MIN_LOOP_TIME := 14200
global MAX_LOOP_TIME := 14750

; Fish-eating-minnow indicator: red warning region and click target
global FISH_EATING_INDICATOR := {x1: 207, y1: 56, x2: 254, y2: 82}
global FISH_EATING_CLICK     := {x1: 252, y1: 162, x2: 261, y2: 171}

; Click the minnow fishing spot with yellow-click retry.
; Returns false if the color is not found.
ClickMinnowSpot(maxRetries := 2) {
    global FISH_MINNOW_COLOR
    retryCount := 0
    Loop {
        if (!ClickRandomPixelOfColor(FISH_MINNOW_COLOR))
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

; Click minnow fishing spot and re-click every ~15 seconds.
; If the status icon goes red (idle) before the 15s window expires,
; re-clicks immediately and sleeps the remaining time.
; Resets cancel state on entry so re-running after a cancel works cleanly.
LoopFishMinnows() {
    global stopCurrentAction, manualStop
    global MAX_LOOP_TIME, FISH_EATING_INDICATOR, FISH_EATING_CLICK
    stopCurrentAction := false
    manualStop := false

    ToolTip "Minnow fishing: starting..."
    SetTimer () => ToolTip(), -2000

    Loop {
        if (ShouldStopAction()) {
            ToolTip "Minnow fishing: stopped"
            SetTimer () => ToolTip(), -3000
            return
        }

        clickTime := A_TickCount

        if (!ClickMinnowSpot()) {
            ToolTip "Minnow fishing: spot not found, stopping"
            SetTimer () => ToolTip(), -3000
            return
        }

        fishEatingClicked := false
        Loop {
            if (ShouldStopAction()) {
                ToolTip "Minnow fishing: stopped"
                SetTimer () => ToolTip(), -3000
                return
            }
            elapsed := A_TickCount - clickTime
            if (elapsed >= MAX_LOOP_TIME)
                break
            if (!fishEatingClicked) {
                r := FISH_EATING_INDICATOR, c := FISH_EATING_CLICK
                if (ColorExistsInRect(r.x1, r.y1, r.x2, r.y2, 0xFF0000)) {
                    ClickRandomPixel(c.x1, c.y1, c.x2, c.y2)
                    fishEatingClicked := true
                }
            }

            if (!fishEatingClicked && IsStatusIconIdle()) {
                if (!ClickMinnowSpot()) {
                    ToolTip "Minnow fishing: spot not found, stopping"
                    SetTimer () => ToolTip(), -3000
                    return
                }
                remaining := MAX_LOOP_TIME - elapsed
                if (remaining > 0)
                    Sleep(remaining)
                break
            }
            Sleep(200)
        }
    }
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global FishingRegistry := Map(
    "LoopFishMinnows", {
        name: "LoopFishMinnows",
        func: LoopFishMinnows,
        description: "Click minnow fishing spot (0x00DDFF) every 14-17 seconds until stopped"
    }
)
