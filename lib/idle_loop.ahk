#Requires AutoHotkey v2.0

; ======================================
; IDLE LOOP — STATUS ICON UTILITIES
; ======================================

; Wait for an action to complete using status icon state comparison.
; Polls at 50ms. Requires icon to go non-red then back to red.
; Prevents false-triggering on initial idle state before action starts.
; retryFn: optional zero-arg function called if idle 25s before action starts (missed click).
; Returns false only if manually stopped.
WaitForActionComplete(retryFn := "") {
    actionHappened := false
    idleStart := A_TickCount
    Loop {
        if (ShouldStopAction())
            return false
        if (IsStatusIconIdle()) {
            if (actionHappened)
                return true
            if (retryFn != "" && (A_TickCount - idleStart) >= 25000) {
                OutputDebug("[WaitForActionComplete] idle 25s with no action — retrying")
                retryFn()
                idleStart := A_TickCount
            }
        } else {
            actionHappened := true
        }
        Sleep(50)
    }
}

; Run a function in a loop, restarting each time the status icon goes idle.
; Pass any zero-argument function reference: LoopFunctionOnIdle(MyFunc)
; Stop with Ctrl+Esc.
LoopFunctionOnIdle(fn) {
    global stopCurrentAction, manualStop
    stopCurrentAction := false
    manualStop := false

    ToolTip "LoopFunctionOnIdle: running..."
    SetTimer () => ToolTip(), -1500

    Loop {
        fn()
        if (manualStop)
            return
        if (!WaitForActionComplete())
            return
    }
}
