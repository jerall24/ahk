#Requires AutoHotkey v2.0

#Include text_replacements.ahk

SetDefaultMouseSpeed 4

; Global toggle variable
global scriptEnabled := false

; Toggle script on/off with F12
F12:: {
    global scriptEnabled
    scriptEnabled := !scriptEnabled

    ; Update tray icon based on state
    if (scriptEnabled) {
        TraySetIcon("assets\icons8-runescape-32-active.ico")
    } else {
        TraySetIcon("assets\icons8-runescape-32-inactive.ico")
    }

    ToolTip "Script " (scriptEnabled ? "Enabled" : "Disabled")
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
}

; Reload script with Alt+F12
!F12:: {
    ToolTip "Reloading script..."
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
    Sleep(1000)
    Reload()
}

; Function to get the color of the pixel under the mouse
GetPixelColorUnderMouse() {
    MouseGetPos(&mouseX, &mouseY)
    return PixelGetColor(mouseX, mouseY)
}

; Wait until a specific pixel matches the desired color
; Returns true if color matched, false if timed out
WaitForPixelColor(x, y, targetColor, timeout := 5000, checkInterval := 50) {
    startTime := A_TickCount

    Loop {
        ; Check current pixel color
        currentColor := PixelGetColor(x, y)

        ; If color matches, return success
        if (currentColor = targetColor) {
            return true
        }

        ; Check if we've exceeded timeout
        elapsed := A_TickCount - startTime
        if (elapsed >= timeout) {
            ToolTip "Timeout waiting for pixel color at (" x ", " y ")"
            SetTimer () => ToolTip(), -2000
            return false
        }

        ; Wait before checking again
        Sleep(checkInterval)
    }
}

; Wait until a specific pixel is NOT a specific color (inverse check)
; Returns true if color changed from excludeColor, false if timed out
WaitForPixelColorNot(x, y, excludeColor, timeout := 5000, checkInterval := 50) {
    startTime := A_TickCount

    Loop {
        ; Check current pixel color
        currentColor := PixelGetColor(x, y)

        ; If color is NOT the excluded color, return success
        if (currentColor != excludeColor) {
            return true
        }

        ; Check if we've exceeded timeout
        elapsed := A_TickCount - startTime
        if (elapsed >= timeout) {
            ToolTip "Timeout waiting for pixel to change from " excludeColor " at (" x ", " y ")"
            SetTimer () => ToolTip(), -2000
            return false
        }

        ; Wait before checking again
        Sleep(checkInterval)
    }
}

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

; Function to find and click a random pixel of a specific color

ClickRandomPixelOfColor(color, marginX := 0, marginY := 0, near_character := false) {
    ; Get window position and size
    WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_exe RuneLite.exe")
    ; top left corner: -7 3 812 542
    ; further down -10 198 812 542
    fixed_mode_x1_start := 4
    fixed_mode_y1_start := 2
    fixed_mode_x2_end := 514
    fixed_mode_y2_end := 335

    near_character_x1_start := 151
    near_character_y1_start := 88
    near_character_x2_end := 359
    near_character_y2_end := 246

    ; Calculate search area with margins
    if (near_character) {
        searchX1 := near_character_x1_start
        searchY1 := near_character_y1_start
        searchX2 := near_character_x2_end
        searchY2 := near_character_y2_end
    } else {
        searchX1 := fixed_mode_x1_start
        searchY1 := fixed_mode_y1_start
        searchX2 := fixed_mode_x2_end
        searchY2 := fixed_mode_y2_end
    }

    ; Color variation for tolerance (0-255, higher = more tolerance)
    colorVariation := 5

    ToolTip "Searching for color: " color " in area: " searchX1 ", " searchY1 ", " searchX2 ", " searchY2
    SetTimer () => ToolTip(), -2000  ; Remove tooltip after 2 seconds

    foundPixels := []
    currentX := searchX1
    currentY := searchY1

    ; Scan the entire area systematically
    Loop {
        if PixelSearch(&foundX, &foundY, currentX, currentY, searchX2, searchY2, color, colorVariation) {
            foundPixels.Push({x: foundX, y: foundY})

            ; Continue searching from the next pixel
            currentX := foundX + 1

            ; If we've reached the end of the current row, move to next row
            if (currentX > searchX2) {
                currentY := foundY + 1
                currentX := searchX1
            }

            ; Stop if we have enough pixels or searched too much
            if (foundPixels.Length >= 20 || currentY > searchY2)
                break
        } else {
            break
        }
    }

    if (foundPixels.Length > 0) {
        ToolTip "Found " foundPixels.Length " pixels"
        SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
        randomIndex := Random(1, foundPixels.Length)
        targetX := foundPixels[randomIndex].x + marginX
        targetY := foundPixels[randomIndex].y + marginY
        HumanClick(targetX, targetY, "left", 1.0, 1.0)
        return true
    }

    ToolTip "No pixels found"
    SetTimer () => ToolTip(), -1000  ; Remove tooltip after 1 second
    return false
}

; Function to click a random pixel in a range
ClickRandomPixel(x1, y1, x2, y2) {
    randomX := Random(x1, x2)
    randomY := Random(y1, y2)
    HumanClick(randomX, randomY, "left", 1.0, 1.0)
}

; NEW: Cluster-based centroid clicking function
; Finds pixels, groups them into clusters (separate objects), picks a random cluster,
; and clicks at the centroid of that cluster
ClickRandomPixelOfColorCentroid(color, marginX := 0, marginY := 0, near_character := false) {
    ; Get window position and size
    WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_exe RuneLite.exe")

    ; Define search areas (same as original function)
    fixed_mode_x1_start := 4
    fixed_mode_y1_start := 2
    fixed_mode_x2_end := 514
    fixed_mode_y2_end := 335

    near_character_x1_start := 151
    near_character_y1_start := 88
    near_character_x2_end := 359
    near_character_y2_end := 246

    ; Calculate search area with margins
    if (near_character) {
        searchX1 := near_character_x1_start
        searchY1 := near_character_y1_start
        searchX2 := near_character_x2_end
        searchY2 := near_character_y2_end
    } else {
        searchX1 := fixed_mode_x1_start
        searchY1 := fixed_mode_y1_start
        searchX2 := fixed_mode_x2_end
        searchY2 := fixed_mode_y2_end
    }

    ; Color variation for tolerance (0-255, higher = more tolerance)
    colorVariation := 5

    ToolTip "Searching for color: " color " (centroid mode)"
    SetTimer () => ToolTip(), -1000

    ; Find all matching pixels
    foundPixels := []
    currentX := searchX1
    currentY := searchY1

    Loop {
        if PixelSearch(&foundX, &foundY, currentX, currentY, searchX2, searchY2, color, colorVariation) {
            foundPixels.Push({x: foundX, y: foundY})

            ; Continue searching from the next pixel
            currentX := foundX + 1

            ; If we've reached the end of the current row, move to next row
            if (currentX > searchX2) {
                currentY := foundY + 1
                currentX := searchX1
            }

            ; Stop if we have enough pixels or searched too much
            if (foundPixels.Length >= 50 || currentY > searchY2)
                break
        } else {
            break
        }
    }

    if (foundPixels.Length = 0) {
        ToolTip "No pixels found"
        SetTimer () => ToolTip(), -1000
        return false
    }

    ; Cluster pixels by proximity
    clusters := []
    clusterThreshold := 5  ; Pixels within 5 units belong to same cluster

    for pixel in foundPixels {
        foundCluster := false

        ; Check if pixel belongs to any existing cluster
        for cluster in clusters {
            ; Check distance to any pixel in the cluster
            for clusterPixel in cluster {
                distance := Sqrt((pixel.x - clusterPixel.x)**2 + (pixel.y - clusterPixel.y)**2)
                if (distance <= clusterThreshold) {
                    cluster.Push(pixel)
                    foundCluster := true
                    break
                }
            }
            if (foundCluster)
                break
        }

        ; If no cluster found, create new cluster
        if (!foundCluster) {
            clusters.Push([pixel])
        }
    }

    ToolTip "Found " clusters.Length " object(s) with " foundPixels.Length " pixels"
    SetTimer () => ToolTip(), -1000

    ; Calculate character center position (always in center of screen)
    characterCenterX := (searchX1 + searchX2) / 2
    characterCenterY := (searchY1 + searchY2) / 2

    ; Find the cluster closest to character center
    closestCluster := ""
    closestDistance := 999999

    for cluster in clusters {
        ; Calculate centroid of this cluster
        sumX := 0
        sumY := 0
        for pixel in cluster {
            sumX += pixel.x
            sumY += pixel.y
        }
        clusterCentroidX := sumX / cluster.Length
        clusterCentroidY := sumY / cluster.Length

        ; Calculate distance from character center
        distance := Sqrt((clusterCentroidX - characterCenterX)**2 + (clusterCentroidY - characterCenterY)**2)

        if (distance < closestDistance) {
            closestDistance := distance
            closestCluster := cluster
        }
    }

    ; Instead of clicking centroid, find bounding box and click inside it
    ; This clicks inside the outlined area, not on the outline edge
    minX := 999999
    maxX := -999999
    minY := 999999
    maxY := -999999

    ; Find bounding box of the cluster
    for pixel in closestCluster {
        if (pixel.x < minX)
            minX := pixel.x
        if (pixel.x > maxX)
            maxX := pixel.x
        if (pixel.y < minY)
            minY := pixel.y
        if (pixel.y > maxY)
            maxY := pixel.y
    }

    ; Shrink the bounding box inward to ensure we click inside the outline
    ; Typically shrink by 20-30% to stay well within the bounds
    width := maxX - minX
    height := maxY - minY
    shrinkX := Round(width * 0.25)
    shrinkY := Round(height * 0.25)

    innerMinX := minX + shrinkX
    innerMaxX := maxX - shrinkX
    innerMinY := minY + shrinkY
    innerMaxY := maxY - shrinkY

    ; Debug: Show bounding box info
    debugInfo := "BBox: " minX "," minY " to " maxX "," maxY "`n"
    debugInfo .= "Size: " width "x" height "`n"
    debugInfo .= "Shrink: " shrinkX "," shrinkY "`n"
    debugInfo .= "Inner: " innerMinX "," innerMinY " to " innerMaxX "," innerMaxY

    ; Check if shrinking created an invalid box
    if (innerMinX >= innerMaxX || innerMinY >= innerMaxY) {
        ; Box too small to shrink, just use center
        targetX := Round((minX + maxX) / 2) + marginX
        targetY := Round((minY + maxY) / 2) + marginY
        ToolTip "Box too small, clicking center: (" targetX ", " targetY ")`n" debugInfo
    } else {
        ; Click random point inside the shrunken box
        targetX := Random(innerMinX, innerMaxX) + marginX
        targetY := Random(innerMinY, innerMaxY) + marginY
        ToolTip "Clicking inside at (" targetX ", " targetY ")`n" debugInfo
    }

    SetTimer () => ToolTip(), -3000

    ; Click inside the outlined area with human-like movement
    HumanClick(targetX, targetY, "left", 1.0, 1.0)

    return true
}

; Testing Hotkey
F11:: {
    CaptureCoordinates()
}

; Example hotkey to get and display the color under the mouse
F8:: {
    color := GetPixelColorUnderMouse()
    A_Clipboard := color
}

F10:: {
    WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_exe RuneLite.exe")
    A_Clipboard := winX ", " winY ", " winWidth ", " winHeight
    ToolTip "Window position copied: " winX ", " winY ", " winWidth ", " winHeight
    SetTimer () => ToolTip(), -3000  ; Remove tooltip after 1 second
}