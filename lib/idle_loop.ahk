#Requires AutoHotkey v2.0

; ======================================
; IDLE LOOP — STATUS ICON UTILITIES
; ======================================

; Wait for an action to complete using status icon state comparison.
; Polls at 50ms. Requires icon to go non-red then back to red.
; Prevents false-triggering on initial idle state before action starts.
; Returns false only if manually stopped.
WaitForActionComplete() {
    actionHappened := false
    Loop {
        if (ShouldStopAction())
            return false
        if (IsStatusIconIdle()) {
            if (actionHappened)
                return true
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
