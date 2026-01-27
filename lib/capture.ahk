#Requires AutoHotkey v2.0

; ======================================
; CAPTURE FUNCTIONS
; ======================================

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
CaptureCoordinates() {
    ; Wait for first right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x1, &y1)

    sleep(250)

    ; Wait for second right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x2, &y2)

    ; Format coordinates as string
    coordString := x1 ", " y1 ", " x2 ", " y2

    ; Copy to clipboard
    A_Clipboard := coordString

    ; Show tooltip confirmation
    ToolTip "Coordinates copied: " coordString
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
}

; Capture single pixel coordinates and color on right-click
CapturePixelAndColor() {
    ToolTip "Right-click on a pixel to capture coordinates and color..."

    ; Wait for right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x, &y)

    ; Get the color at that pixel
    color := PixelGetColor(x, y)

    ; Format as: x, y, color
    captureString := x ", " y ", " color

    ; Copy to clipboard
    A_Clipboard := captureString

    ; Show tooltip confirmation
    ToolTip "Copied: " captureString
    SetTimer () => ToolTip(), -2000
}

; Capture rectangle and find most prominent colors
; Output formatted for WaitForAnyColorInRect function
CaptureRectangleColors(maxColors := 5, sampleStep := 2) {
    ToolTip "Right-click on TOP-LEFT corner of rectangle..."

    ; Wait for first right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x1, &y1)

    ; Clear tooltip immediately, then show next instruction
    ToolTip
    Sleep(50)
    ToolTip "Top-left captured. Now right-click on BOTTOM-RIGHT corner..."
    Sleep(200)
    ToolTip  ; Clear tooltip before second click

    ; Wait for second right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x2, &y2)

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

    ; Sample colors in the rectangle
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

    ; Format for WaitForAnyColorInRect
    ; Result: x1, y1, x2, y2, [0xCOLOR1, 0xCOLOR2, ...]
    colorList := "["
    Loop topColors.Length {
        if (A_Index > 1) {
            colorList .= ", "
        }
        colorList .= topColors[A_Index]
    }
    colorList .= "]"

    outputString := x1 ", " y1 ", " x2 ", " y2 ", " colorList

    ; Copy to clipboard
    A_Clipboard := outputString

    ; Show confirmation briefly then clear
    ToolTip "Captured rectangle with " topColors.Length " colors (copied to clipboard)"
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

    ToolTip "Click on first bank item..."

    ; Wait for first right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x1, &y1)
    slot1 := GetBankSlotAtCoordinate(x1, y1)

    if (slot1 = 0) {
        ToolTip "First click not in a bank slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    ToolTip "First slot captured: " slot1 "`nClick on second bank item..."
    Sleep(250)

    ; Wait for second right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x2, &y2)
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

    ToolTip "Right-click on first bank item..."

    ; Wait for first right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x1, &y1)
    slot1 := GetBankSlotAtCoordinate(x1, y1)

    if (slot1 = 0) {
        ToolTip "First click not in a bank slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    ToolTip "Slot 1: " slot1 "`nRight-click on second bank item..."
    Sleep(250)

    ; Wait for second right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x2, &y2)
    slot2 := GetBankSlotAtCoordinate(x2, y2)

    if (slot2 = 0) {
        ToolTip "Second click not in a bank slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    ToolTip "Slots 1,2: " slot1 "," slot2 "`nRight-click on third bank item..."
    Sleep(250)

    ; Wait for third right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x3, &y3)
    slot3 := GetBankSlotAtCoordinate(x3, y3)

    if (slot3 = 0) {
        ToolTip "Third click not in a bank slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    ToolTip "Slots 1-3: " slot1 "," slot2 "," slot3 "`nRight-click on fourth bank item..."
    Sleep(250)

    ; Wait for fourth right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x4, &y4)
    slot4 := GetBankSlotAtCoordinate(x4, y4)

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

    ToolTip "Click on first inventory item..."

    ; Wait for first right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x1, &y1)
    slot1 := GetInventorySlotAtCoordinate(x1, y1)

    if (slot1 = 0) {
        ToolTip "First click not in an inventory slot! Try again."
        SetTimer () => ToolTip(), -2000
        return false
    }

    ToolTip "First slot captured: " slot1 "`nClick on second inventory item..."
    Sleep(250)

    ; Wait for second right-click
    KeyWait("RButton", "D")
    MouseGetPos(&x2, &y2)
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
