#Requires AutoHotkey v2.0

; ======================================
; CAPTURE FUNCTIONS
; ======================================

; Pause until user confirms, then return mouse position in screen coords
; Usage: pt := CapturePoint("Move mouse to TOP-LEFT corner, then press OK")
;        use pt.x, pt.y
CapturePoint(prompt) {
    MsgBox(prompt)
    MouseGetPos(&x, &y)
    return {x: x, y: y}
}

; Convert screen coords to client-relative in-place
ScreenToClient(&x, &y) {
    hwnd := WinExist("ahk_exe RuneLite.exe")
    if (hwnd) {
        WinGetClientPos(&clientX, &clientY, , , hwnd)
        x -= clientX
        y -= clientY
    }
}

; Global variables to store captured bank slots
global capturedBankSlot1 := 0
global capturedBankSlot2 := 0
global capturedBankSlot3 := 0
global capturedBankSlot4 := 0

; Global variables to store captured inventory slots
global capturedInventorySlot1 := 0
global capturedInventorySlot2 := 0

; Global variable for construction bank slot (will be overridden by LoadProfiles if saved)
global capturedConstructionBankSlot := 0

; Function to capture coordinates for a rectangular area
; Outputs CLIENT-RELATIVE coordinates
CaptureCoordinates() {
    pt1 := CapturePoint("Move mouse to TOP-LEFT corner, then press OK")
    pt2 := CapturePoint("Move mouse to BOTTOM-RIGHT corner, then press OK")
    x1 := pt1.x
    y1 := pt1.y
    x2 := pt2.x
    y2 := pt2.y
    ScreenToClient(&x1, &y1)
    ScreenToClient(&x2, &y2)

    coordString := x1 ", " y1 ", " x2 ", " y2
    A_Clipboard := coordString
    ToolTip "Copied (client-relative): " coordString
    SetTimer () => ToolTip(), -2000
}

; Capture single pixel coordinates and color
; Outputs CLIENT-RELATIVE coordinates
CapturePixelAndColor() {
    pt := CapturePoint("Move mouse to pixel to capture, then press OK")
    x := pt.x
    y := pt.y
    CoordMode "Pixel", "Screen"
    color := PixelGetColor(x, y)
    ScreenToClient(&x, &y)

    captureString := x ", " y ", " color
    A_Clipboard := captureString
    ToolTip "Copied (client-relative): " captureString
    SetTimer () => ToolTip(), -2000
}

; Capture rectangle and find most prominent colors
; Output formatted for WaitForAnyColorInRect function
CaptureRectangleColors(maxColors := 5, sampleStep := 2) {
    pt1 := CapturePoint("Move mouse to TOP-LEFT corner of rectangle, then press OK")
    pt2 := CapturePoint("Move mouse to BOTTOM-RIGHT corner of rectangle, then press OK")
    x1 := pt1.x
    y1 := pt1.y
    x2 := pt2.x
    y2 := pt2.y

    ; Ensure x1,y1 is top-left and x2,y2 is bottom-right
    if (x1 > x2) {
        temp := x1
        x1 := x2
        x2 := temp
    }
    if (y1 > y2) {
        temp := y1
        y1 := y2
        y2 := temp
    }

    ToolTip "Analyzing colors in rectangle..."

    ; Sample colors in the rectangle (screen coords)
    CoordMode "Pixel", "Screen"
    colorCounts := Map()

    ; Sample every few pixels to speed up analysis
    x := x1
    while (x <= x2) {
        y := y1
        while (y <= y2) {
            try {
                color := PixelGetColor(x, y)
                if (colorCounts.Has(color)) {
                    colorCounts[color] := colorCounts[color] + 1
                } else {
                    colorCounts[color] := 1
                }
            }
            y += sampleStep
        }
        x += sampleStep
    }

    ; Sort colors by frequency
    colorArray := []
    for color, count in colorCounts {
        colorArray.Push({color: color, count: count})
    }

    ; Simple bubble sort by count (descending)
    Loop colorArray.Length {
        i := A_Index
        Loop colorArray.Length - i {
            j := A_Index
            if (colorArray[j].count < colorArray[j + 1].count) {
                temp := colorArray[j]
                colorArray[j] := colorArray[j + 1]
                colorArray[j + 1] := temp
            }
        }
    }

    ; Get top N colors
    topColors := []
    Loop Min(maxColors, colorArray.Length) {
        topColors.Push(colorArray[A_Index].color)
    }

    ScreenToClient(&x1, &y1)
    ScreenToClient(&x2, &y2)

    ; Format for WaitForAnyColorInRect / ClickRandomPixel
    ; Result: x1, y1, x2, y2, [0xCOLOR1, 0xCOLOR2, ...] (all client-relative)
    colorList := "["
    Loop topColors.Length {
        if (A_Index > 1)
            colorList .= ", "
        colorList .= Format("0x{:06X}", topColors[A_Index])
    }
    colorList .= "]"

    outputString := x1 ", " y1 ", " x2 ", " y2 ", " colorList
    ToolTip "Captured (client-relative) with " topColors.Length " colors:`n" outputString
    Sleep(100)
    A_Clipboard := outputString
    SetTimer () => ToolTip(), -1000
}

; Helper function to determine which bank slot a coordinate falls within
GetBankSlotAtCoordinate(x, y) {
    Loop 48 {
        coords := BankSlots[A_Index]
        if (x >= coords.x1 && x <= coords.x2 && y >= coords.y1 && y <= coords.y2) {
            return A_Index
        }
    }
    return 0  ; Not found in any slot
}

; Helper function to determine which inventory slot a coordinate falls within
GetInventorySlotAtCoordinate(x, y) {
    Loop 28 {
        coords := InventorySlots[A_Index]
        if (x >= coords.x1 && x <= coords.x2 && y >= coords.y1 && y <= coords.y2) {
            return A_Index
        }
    }
    return 0  ; Not found in any slot
}

; Function to capture two bank slot positions
CaptureBankSlots() {
    global capturedBankSlot1, capturedBankSlot2

    pt1 := CapturePoint("Move mouse to first bank item, then press OK")
    x1 := pt1.x
    y1 := pt1.y
    ScreenToClient(&x1, &y1)
    slot1 := GetBankSlotAtCoordinate(x1, y1)

    if (slot1 = 0) {
        ToolTip "First click not in a bank slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    pt2 := CapturePoint("Slot " slot1 " captured.`nMove mouse to second bank item, then press OK")
    x2 := pt2.x
    y2 := pt2.y
    ScreenToClient(&x2, &y2)
    slot2 := GetBankSlotAtCoordinate(x2, y2)

    if (slot2 = 0) {
        ToolTip "Second click not in a bank slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Store the captured slots
    capturedBankSlot1 := slot1
    capturedBankSlot2 := slot2

    ; Save to profile
    SaveProfiles()

    ; Show confirmation
    ToolTip "Bank slots captured!`nSlot 1: " capturedBankSlot1 "`nSlot 2: " capturedBankSlot2
    SetTimer () => ToolTip(), -3000

    return true
}

; Function to capture four bank slot positions
CaptureFourBankSlots() {
    global capturedBankSlot1, capturedBankSlot2, capturedBankSlot3, capturedBankSlot4

    pt1 := CapturePoint("Move mouse to first bank item, then press OK")
    cx1 := pt1.x
    cy1 := pt1.y
    ScreenToClient(&cx1, &cy1)
    slot1 := GetBankSlotAtCoordinate(cx1, cy1)

    if (slot1 = 0) {
        ToolTip "First click not in a bank slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    pt2 := CapturePoint("Slot 1: " slot1 "`nMove mouse to second bank item, then press OK")
    cx2 := pt2.x
    cy2 := pt2.y
    ScreenToClient(&cx2, &cy2)
    slot2 := GetBankSlotAtCoordinate(cx2, cy2)

    if (slot2 = 0) {
        ToolTip "Second click not in a bank slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    pt3 := CapturePoint("Slots 1,2: " slot1 "," slot2 "`nMove mouse to third bank item, then press OK")
    cx3 := pt3.x
    cy3 := pt3.y
    ScreenToClient(&cx3, &cy3)
    slot3 := GetBankSlotAtCoordinate(cx3, cy3)

    if (slot3 = 0) {
        ToolTip "Third click not in a bank slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    pt4 := CapturePoint("Slots 1-3: " slot1 "," slot2 "," slot3 "`nMove mouse to fourth bank item, then press OK")
    cx4 := pt4.x
    cy4 := pt4.y
    ScreenToClient(&cx4, &cy4)
    slot4 := GetBankSlotAtCoordinate(cx4, cy4)

    if (slot4 = 0) {
        ToolTip "Fourth click not in a bank slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Store the captured slots
    capturedBankSlot1 := slot1
    capturedBankSlot2 := slot2
    capturedBankSlot3 := slot3
    capturedBankSlot4 := slot4

    ; Save to profile
    SaveProfiles()

    ; Show confirmation
    ToolTip "4 Bank slots captured!`nSlots: " slot1 ", " slot2 ", " slot3 ", " slot4
    SetTimer () => ToolTip(), -4000

    return true
}

; Function to capture two inventory slot positions
CaptureInventorySlots() {
    global capturedInventorySlot1, capturedInventorySlot2

    pt1 := CapturePoint("Move mouse to first inventory item, then press OK")
    x1 := pt1.x
    y1 := pt1.y
    ScreenToClient(&x1, &y1)
    slot1 := GetInventorySlotAtCoordinate(x1, y1)

    if (slot1 = 0) {
        ToolTip "First click not in an inventory slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    pt2 := CapturePoint("Slot " slot1 " captured.`nMove mouse to second inventory item, then press OK")
    x2 := pt2.x
    y2 := pt2.y
    ScreenToClient(&x2, &y2)
    slot2 := GetInventorySlotAtCoordinate(x2, y2)

    if (slot2 = 0) {
        ToolTip "Second click not in an inventory slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Store the captured slots
    capturedInventorySlot1 := slot1
    capturedInventorySlot2 := slot2

    ; Save to profile
    SaveProfiles()

    ; Show confirmation
    ToolTip "Inventory slots captured!`nSlot 1: " capturedInventorySlot1 "`nSlot 2: " capturedInventorySlot2
    SetTimer () => ToolTip(), -3000

    return true
}

; Function to capture time between clicks
CaptureClickTime() {
    ; Wait for first click
    KeyWait("LButton", "D")
    startTime := A_TickCount

    Sleep(200)

    ; Wait for second click
    KeyWait("LButton", "D")
    endTime := A_TickCount

    ; Calculate time difference
    timeDiff := endTime - startTime

    ; Copy to clipboard
    A_Clipboard := timeDiff

    ; Show tooltip confirmation
    ToolTip "Time between clicks: " timeDiff "ms"
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
}

; Testing Hotkey for CaptureCoordinates
F11:: {
    CaptureCoordinates()
}

; Hotkey to get and display the color under the mouse
F8:: {
    color := GetPixelColorUnderMouse()
    A_Clipboard := color
}
