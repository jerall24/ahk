#Requires AutoHotkey v2.0

; ======================================
; UI FUNCTIONS
; ======================================

; Click the special attack orb
ClickSpecialAttack() {
    ClickUIElement("special_orb")
}

; Resize window to fixed mode size (812x542)
ResizeToFixedMode() {
    SetClientSize()  ; Uses default size 812x542
}

; Resize window to larger size (1334x1087)
ResizeToLargeMode() {
    SetClientSize(1334, 1087)
}

; Test function to show current time
TestFunction() {
    currentTime := FormatTime(, "HH:mm:ss")
    ToolTip "TEST FUNCTION CALLED! Time: " currentTime
    SetTimer () => ToolTip(), -3000
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global UIFunctionsRegistry := Map(
    "ClickSpecialAttack", {
        name: "ClickSpecialAttack",
        func: ClickSpecialAttack,
        description: "Click special attack orb"
    },
    "ResizeToFixedMode", {
        name: "ResizeToFixedMode",
        func: ResizeToFixedMode,
        description: "Resize window to 812x542 (fixed mode)"
    },
    "ResizeToLargeMode", {
        name: "ResizeToLargeMode",
        func: ResizeToLargeMode,
        description: "Resize window to 1334x1087 (larger)"
    },
    "TestFunction", {
        name: "TestFunction",
        func: TestFunction,
        description: "TEST: Show tooltip with current time"
    }
)
