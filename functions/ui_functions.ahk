#Requires AutoHotkey v2.0

; ======================================
; UI FUNCTIONS
; ======================================

; Click the special attack orb
ClickSpecialAttack() {
    ClickUIElement("special_orb")
}

; Resize window to fixed mode size (812x542) and configure settings
ResizeToFixedMode() {
    ; Step 1: Make desired size
    SetClientSize()  ; Uses default size 812x542
    Sleep(Random(150, 250))

    ; Step 2: Check for colors and press F9 if found
    colorsToCheck := [0x5D5447, 0xFFFF00, 0x817462, 0xFFFFFF, 0x6C6153]
    if (WaitForAnyColorInRect(670, 472, 678, 481, colorsToCheck, 1)) {
        Send("{F9}")
        Sleep(Random(200, 350))
    }

    ; Step 3: Click anywhere in coordinates 696, 167, 754, 190
    HumanClickRandomPixel(696, 167, 754, 190)
    Sleep(Random(150, 250))

    ; Step 4: Click anywhere in coordinates 583, 315, 742, 332
    HumanClickRandomPixel(583, 315, 742, 332)
    Sleep(Random(150, 250))

    ; Step 5: Click anywhere in coordinates 584, 335, 724, 348
    HumanClickRandomPixel(584, 335, 724, 348)
    Sleep(Random(100, 200))

    ; Save UI mode state
    SetUIMode("fixed")
}

; Resize window to medium mode size (1050x725) from fixed mode
ResizeToMediumMode() {
    ; Step 1: Check if RuneLite is the active window
    if !WinActive("ahk_exe RuneLite.exe") {
        WinActivate("ahk_exe RuneLite.exe")
        Sleep(Random(200, 350))
    }

    ; Step 2: Check if sidebar is open (width > 796) and close it
    WinGetPos(&winX, &winY, &currentWidth, &currentHeight, "ahk_exe RuneLite.exe")
    ToolTip "Current Width: " currentWidth
    SetTimer () => ToolTip(), -2000  ; Remove tooltip after 2 seconds
    if (currentWidth > 812) {
        Send("^{F10}")  ; Close sidebar with Ctrl+F10
        Sleep(Random(200, 350))
    }

    ; Step 3: Press F9
    Send("{F9}")
    Sleep(Random(200, 350))

    ; Step 4: Click randomly within coordinates 677, 211, 730, 231
    HumanClickRandomPixel(677, 211, 730, 231)
    Sleep(Random(150, 250))

    ; Step 5: Click randomly within coordinates 565, 358, 718, 372
    HumanClickRandomPixel(565, 358, 718, 372)
    Sleep(Random(150, 250))

    ; Step 6: Click randomly within coordinates 565, 409, 701, 418
    HumanClickRandomPixel(565, 409, 701, 418)
    Sleep(Random(150, 250))

    ; Step 7: Resize to medium mode size
    SetClientSize(1050, 725)
    Sleep(Random(100, 200))

    ; Save UI mode state
    SetUIMode("medium")
}

; Resize window to larger size (1334x1087)
ResizeToLargeMode() {
    SetClientSize(1150, 900)
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
    "ResizeToMediumMode", {
        name: "ResizeToMediumMode",
        func: ResizeToMediumMode,
        description: "Resize window to 850x610 (larger)"
    },
    "ResizeToLargeMode", {
        name: "ResizeToLargeMode",
        func: ResizeToLargeMode,
        description: "Resize window to 1150x900 (large mode)"
    },
    "TestFunction", {
        name: "TestFunction",
        func: TestFunction,
        description: "TEST: Show tooltip with current time"
    }
)
