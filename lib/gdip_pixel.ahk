#Requires AutoHotkey v2.0

; ======================================
; GDIP-BASED PIXEL SEARCH FUNCTIONS
; Fast pixel searching using GDI+ bitmap operations
; ======================================

; Include the Gdip library
#Include Gdip_All.ahk

; Global Gdip token (initialized once)
global gdipToken := 0

; Initialize GDI+ on script load
InitGdip() {
    global gdipToken
    if (gdipToken = 0) {
        gdipToken := Gdip_Startup()
        if (gdipToken = 0) {
            MsgBox "Failed to initialize GDI+"
            return false
        }
    }
    return true
}

; Shutdown GDI+ (call on script exit if needed)
ShutdownGdip() {
    global gdipToken
    if (gdipToken != 0) {
        Gdip_Shutdown(gdipToken)
        gdipToken := 0
    }
}

; Initialize on include
InitGdip()

; ======================================
; LOGGING
; ======================================

global GdipLogFile := A_ScriptDir "\config\gdip_debug.log"

; Log a message to the debug file
GdipLog(message) {
    global GdipLogFile
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    try {
        FileAppend(timestamp " | " message "`n", GdipLogFile)
    }
}

; Clear the log file
GdipLogClear() {
    global GdipLogFile
    try {
        FileDelete(GdipLogFile)
    }
    GdipLog("=== Log cleared ===")
}

; ======================================
; HELPER FUNCTIONS
; ======================================

; Get RuneLite window handle and FULL WINDOW position
; (Gdip_BitmapFromHWND captures full window including title bar)
GetRuneLiteWindow(&winX, &winY, &winW, &winH) {
    hwnd := WinExist("ahk_exe RuneLite.exe")
    if (!hwnd) {
        return 0
    }

    ; Get full window position (including title bar and borders)
    WinGetPos(&winX, &winY, &winW, &winH, hwnd)
    return hwnd
}

; ======================================
; MAIN PIXEL SEARCH FUNCTION
; ======================================

; Find all pixels matching a color in a region and click a well-distributed one
; Returns true if found and clicked, false otherwise
;
; color: Target color in 0xRRGGBB format
; x1, y1, x2, y2: Search region in SCREEN coordinates (same as PixelSearch default)
; colorVariation: Tolerance for color matching (0-255 per channel)
; marginX, marginY: Offset to apply to final click position
; maxRetries: Maximum number of retries if verification fails (default 2)
GdipClickRandomPixelOfColor(color, x1, y1, x2, y2, colorVariation := 5, marginX := 0, marginY := 0, maxRetries := 2) {
    ; Retry loop for verification
    retryCount := 0
    Loop {
        result := GdipClickRandomPixelOfColor_Internal(color, x1, y1, x2, y2, colorVariation, marginX, marginY)

        ; If successful or max retries reached, return
        if (result || retryCount >= maxRetries) {
            return result
        }

        ; Increment retry counter and try again
        retryCount++
        GdipLog("Verification failed, retrying (" retryCount "/" maxRetries ")...")
        Sleep(100)  ; Brief delay before retry
    }
}

; Internal function that does the actual work
GdipClickRandomPixelOfColor_Internal(color, x1, y1, x2, y2, colorVariation := 5, marginX := 0, marginY := 0) {
    ; Show activity indicator
    ShowActivityIndicator()

    GdipLog("--- GdipClickRandomPixelOfColor START ---")
    GdipLog("Target color: " Format("0x{:06X}", color) " | Search region: (" x1 "," y1 ")-(" x2 "," y2 ") | Variation: " colorVariation)

    ; Get RuneLite window CLIENT area position (where the game renders)
    hwnd := WinExist("ahk_exe RuneLite.exe")
    if (!hwnd) {
        HideActivityIndicator()
        GdipLog("ERROR: RuneLite window not found")
        ToolTip "RuneLite window not found"
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Get window and client positions
    winX := 0, winY := 0, winW := 0, winH := 0
    WinGetPos(&winX, &winY, &winW, &winH, hwnd)

    clientX := 0, clientY := 0, clientW := 0, clientH := 0
    WinGetClientPos(&clientX, &clientY, &clientW, &clientH, hwnd)

    ; Calculate title bar and border sizes
    titleBarHeight := clientY - winY
    borderWidth := clientX - winX

    GdipLog("Window: (" winX "," winY ") | Client: (" clientX "," clientY ") | Title bar: " titleBarHeight " | Border: " borderWidth)

    ; The search coordinates (x1, y1, x2, y2) are CLIENT-RELATIVE
    ; Convert to absolute screen coordinates for capture
    screenSearchX1 := clientX + x1
    screenSearchY1 := clientY + y1
    screenSearchX2 := clientX + x2
    screenSearchY2 := clientY + y2
    w := x2 - x1
    h := y2 - y1
    GdipLog("Client search: (" x1 "," y1 ")-(" x2 "," y2 ") -> Screen: (" screenSearchX1 "," screenSearchY1 ")-(" screenSearchX2 "," screenSearchY2 ")")

    ; Capture ONLY the search region from screen
    pBitmap := Gdip_BitmapFromScreen(screenSearchX1 "|" screenSearchY1 "|" w "|" h)
    if (pBitmap = -1 || pBitmap = 0) {
        HideActivityIndicator()
        GdipLog("ERROR: Failed to capture screen region")
        ToolTip "Failed to capture screen"
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Get actual bitmap dimensions (should match w x h)
    bitmapW := Gdip_GetImageWidth(pBitmap)
    bitmapH := Gdip_GetImageHeight(pBitmap)
    GdipLog("Bitmap captured: " bitmapW "x" bitmapH " (expected " w "x" h ")")

    ; Verify bitmap coordinates match screen coordinates
    testX := Min(10, bitmapW - 1)
    testY := Min(10, bitmapH - 1)
    if (testX >= 0 && testY >= 0) {
        testStride := ""
        testScan0 := ""
        testBitmapData := ""
        if (Gdip_LockBits(pBitmap, testX, testY, 1, 1, &testStride, &testScan0, &testBitmapData) = 0) {
            testArgb := Gdip_GetLockBitPixel(testScan0, 0, 0, testStride)
            testColor := Format("0x{:06X}", testArgb & 0xFFFFFF)
            Gdip_UnlockBits(pBitmap, &testBitmapData)

            ; Bitmap (testX, testY) should correspond to screen (screenSearchX1 + testX, screenSearchY1 + testY)
            actualScreenX := screenSearchX1 + testX
            actualScreenY := screenSearchY1 + testY
            actualScreenColor := PixelGetColor(actualScreenX, actualScreenY)

            GdipLog("VERIFY: Bitmap(" testX "," testY ")=" testColor " vs Screen(" actualScreenX "," actualScreenY ")=" actualScreenColor)
            if (testColor = actualScreenColor) {
                GdipLog("✓ Coordinate system verified!")
            } else {
                GdipLog("✗ WARNING: Coordinates don't match!")
            }
        }
    }

    ; Lock the entire bitmap
    Stride := ""
    Scan0 := ""
    BitmapData := ""

    if (Gdip_LockBits(pBitmap, 0, 0, bitmapW, bitmapH, &Stride, &Scan0, &BitmapData) != 0) {
        Gdip_DisposeImage(pBitmap)
        HideActivityIndicator()
        GdipLog("ERROR: Failed to lock bitmap")
        ToolTip "Failed to lock bitmap"
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Extract target RGB components
    targetR := (color >> 16) & 0xFF
    targetG := (color >> 8) & 0xFF
    targetB := color & 0xFF

    ; Collect all matching pixels
    matchingPixels := []

    ; Scan the entire bitmap (it's already just our search region)
    stepSize := 2  ; Check every 2nd pixel for speed

    y := 0
    while (y < bitmapH) {
        x := 0
        while (x < bitmapW) {
            ; Get pixel color (ARGB format)
            argb := Gdip_GetLockBitPixel(Scan0, x, y, Stride)

            ; Extract RGB (ignore alpha)
            pixelR := (argb >> 16) & 0xFF
            pixelG := (argb >> 8) & 0xFF
            pixelB := argb & 0xFF

            ; Check if color matches within tolerance
            if (Abs(pixelR - targetR) <= colorVariation
                && Abs(pixelG - targetG) <= colorVariation
                && Abs(pixelB - targetB) <= colorVariation) {
                ; Convert bitmap coords to screen coords
                ; Bitmap (0,0) = screen (screenSearchX1, screenSearchY1)
                screenX := screenSearchX1 + x
                screenY := screenSearchY1 + y

                ; Log first pixel found for debugging
                if (matchingPixels.Length = 0) {
                    GdipLog("FIRST pixel: bitmap(" x "," y ") + searchStart(" screenSearchX1 "," screenSearchY1 ") = screen(" screenX "," screenY ")")
                }
                matchingPixels.Push({x: screenX, y: screenY})
            }
            x += stepSize
        }
        y += stepSize
    }

    ; Unlock and dispose bitmap
    Gdip_UnlockBits(pBitmap, &BitmapData)
    Gdip_DisposeImage(pBitmap)

    ; Check if any pixels found
    if (matchingPixels.Length = 0) {
        HideActivityIndicator()
        GdipLog("ERROR: No pixels found for color")
        ToolTip "No pixels found for color: " Format("0x{:06X}", color)
        SetTimer () => ToolTip(), -2000
        return false
    }

    GdipLog("Found " matchingPixels.Length " matching pixels")

    ; Log some example pixels (first 5)
    exampleCount := Min(5, matchingPixels.Length)
    Loop exampleCount {
        p := matchingPixels[A_Index]
        GdipLog("  Example pixel " A_Index ": (" p.x "," p.y ")")
    }

    ; Find bounding box of all matching pixels
    minX := matchingPixels[1].x
    maxX := matchingPixels[1].x
    minY := matchingPixels[1].y
    maxY := matchingPixels[1].y

    for pixel in matchingPixels {
        if (pixel.x < minX) {
            minX := pixel.x
        }
        if (pixel.x > maxX) {
            maxX := pixel.x
        }
        if (pixel.y < minY) {
            minY := pixel.y
        }
        if (pixel.y > maxY) {
            maxY := pixel.y
        }
    }

    GdipLog("Bounding box: (" minX "," minY ")-(" maxX "," maxY ")")

    ; Shrink bounding box inward by 25% to avoid edges
    width := maxX - minX
    height := maxY - minY
    shrinkX := Round(width * 0.25)
    shrinkY := Round(height * 0.25)

    innerMinX := minX + shrinkX
    innerMaxX := maxX - shrinkX
    innerMinY := minY + shrinkY
    innerMaxY := maxY - shrinkY

    GdipLog("Shrunk box: (" innerMinX "," innerMinY ")-(" innerMaxX "," innerMaxY ")")

    ; If box is too small after shrinking, use center
    if (innerMinX >= innerMaxX || innerMinY >= innerMaxY) {
        targetX := Round((minX + maxX) / 2) + marginX
        targetY := Round((minY + maxY) / 2) + marginY
        GdipLog("Box too small, using center")
    } else {
        ; Click random point inside shrunk box
        targetX := Random(innerMinX, innerMaxX) + marginX
        targetY := Random(innerMinY, innerMaxY) + marginY
    }

    ; PRE-CLICK VERIFICATION: Instead of checking live screen (which changes),
    ; verify by clicking one of the actual detected blue pixels
    ; Pick a random pixel from the middle third of the matchingPixels array
    verifyIndex := Round(matchingPixels.Length / 3) + Random(0, Round(matchingPixels.Length / 3))
    verifyPixel := matchingPixels[verifyIndex]

    ; Use the verified pixel position instead of the shrunk bounding box
    targetX := verifyPixel.x + marginX
    targetY := verifyPixel.y + marginY

    GdipLog("✓ Using verified pixel from detection (index " verifyIndex "/" matchingPixels.Length ")")
    GdipLog("  Original target was: (" targetX - marginX "," targetY - marginY "), now using detected pixel")

    ; Log mouse position before click
    MouseGetPos(&beforeX, &beforeY)
    GdipLog("========================================")
    GdipLog("ABSOLUTE SCREEN COORDINATES:")
    GdipLog("  Mouse BEFORE: (" beforeX "," beforeY ")")
    GdipLog("  Click TARGET: (" targetX "," targetY ") [margin: " marginX "," marginY "]")
    GdipLog("  Window at: (" winX "," winY ")")
    GdipLog("  Client at: (" clientX "," clientY ")")

    ; Perform the click
    HumanClick(targetX, targetY, "left", 1.0, 1.0)

    ; Log where mouse ended up
    MouseGetPos(&actualX, &actualY)
    GdipLog("  Mouse ACTUAL: (" actualX "," actualY ")")
    GdipLog("  Offset from target: (" (actualX - targetX) "," (actualY - targetY) ")")
    GdipLog("========================================")
    GdipLog("--- GdipClickRandomPixelOfColor END ---")

    return true
}

; ======================================
; SEARCH WITH MULTIPLE COLORS
; ======================================

; Find and click pixel matching any of the provided colors
; colors: Array of colors in 0xRRGGBB format
; Returns true if found and clicked, false otherwise
GdipClickAnyColor(colors, x1, y1, x2, y2, colorVariation := 5, marginX := 0, marginY := 0) {
    ; Show activity indicator
    ShowActivityIndicator()

    ; Get RuneLite window client area position
    hwnd := WinExist("ahk_exe RuneLite.exe")
    if (!hwnd) {
        HideActivityIndicator()
        ToolTip "RuneLite window not found"
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Get window position to convert screen coords to window coords
    winX := 0, winY := 0, winW := 0, winH := 0
    WinGetPos(&winX, &winY, &winW, &winH, hwnd)

    ; Convert screen search coordinates to window-relative coordinates
    winSearchX1 := x1 - winX
    winSearchY1 := y1 - winY
    winSearchX2 := x2 - winX
    winSearchY2 := y2 - winY
    w := x2 - x1
    h := y2 - y1

    ; Capture the entire window
    pBitmap := Gdip_BitmapFromHWND(hwnd)
    if (pBitmap = -1 || pBitmap = 0) {
        HideActivityIndicator()
        ToolTip "Failed to capture window"
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Get actual bitmap dimensions
    bitmapW := Gdip_GetImageWidth(pBitmap)
    bitmapH := Gdip_GetImageHeight(pBitmap)

    ; Lock the entire bitmap
    Stride := ""
    Scan0 := ""
    BitmapData := ""

    if (Gdip_LockBits(pBitmap, 0, 0, bitmapW, bitmapH, &Stride, &Scan0, &BitmapData) != 0) {
        Gdip_DisposeImage(pBitmap)
        HideActivityIndicator()
        return false
    }

    ; Pre-extract RGB components for all target colors
    targetColors := []
    for color in colors {
        targetColors.Push({
            r: (color >> 16) & 0xFF,
            g: (color >> 8) & 0xFF,
            b: color & 0xFF
        })
    }

    ; Collect all matching pixels
    matchingPixels := []
    stepSize := 2

    ; Clamp search region to bitmap bounds
    searchStartX := Max(0, winSearchX1)
    searchStartY := Max(0, winSearchY1)
    searchEndX := Min(bitmapW, winSearchX2)
    searchEndY := Min(bitmapH, winSearchY2)

    y := searchStartY
    while (y < searchEndY) {
        x := searchStartX
        while (x < searchEndX) {
            argb := Gdip_GetLockBitPixel(Scan0, x, y, Stride)
            pixelR := (argb >> 16) & 0xFF
            pixelG := (argb >> 8) & 0xFF
            pixelB := argb & 0xFF

            ; Check against all target colors
            for tc in targetColors {
                if (Abs(pixelR - tc.r) <= colorVariation
                    && Abs(pixelG - tc.g) <= colorVariation
                    && Abs(pixelB - tc.b) <= colorVariation) {
                    ; Convert window coords back to screen coords
                    matchingPixels.Push({x: winX + x, y: winY + y})
                    break  ; Found a match, no need to check other colors
                }
            }
            x += stepSize
        }
        y += stepSize
    }

    ; Cleanup
    Gdip_UnlockBits(pBitmap, &BitmapData)
    Gdip_DisposeImage(pBitmap)

    if (matchingPixels.Length = 0) {
        HideActivityIndicator()
        ToolTip "No pixels found for any of " colors.Length " colors"
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Find bounding box and click inside
    minX := matchingPixels[1].x, maxX := matchingPixels[1].x
    minY := matchingPixels[1].y, maxY := matchingPixels[1].y

    for pixel in matchingPixels {
        if (pixel.x < minX) {
            minX := pixel.x
        }
        if (pixel.x > maxX) {
            maxX := pixel.x
        }
        if (pixel.y < minY) {
            minY := pixel.y
        }
        if (pixel.y > maxY) {
            maxY := pixel.y
        }
    }

    ; Shrink and click
    width := maxX - minX, height := maxY - minY
    shrinkX := Round(width * 0.25), shrinkY := Round(height * 0.25)
    innerMinX := minX + shrinkX, innerMaxX := maxX - shrinkX
    innerMinY := minY + shrinkY, innerMaxY := maxY - shrinkY

    if (innerMinX >= innerMaxX || innerMinY >= innerMaxY) {
        targetX := Round((minX + maxX) / 2) + marginX
        targetY := Round((minY + maxY) / 2) + marginY
    } else {
        targetX := Random(innerMinX, innerMaxX) + marginX
        targetY := Random(innerMinY, innerMaxY) + marginY
    }

    HumanClick(targetX, targetY, "left", 1.0, 1.0)
    return true
}

; ======================================
; CONVENIENCE WRAPPERS
; ======================================

; Search near character (uses game view area from FixedModeUI)
GdipClickColorNearCharacter(color, colorVariation := 5, marginX := 0, marginY := 0) {
    ; Near character search area (expanded)
    x1 := 100, y1 := 35, x2 := 460, y2 := 335
    return GdipClickRandomPixelOfColor(color, x1, y1, x2, y2, colorVariation, marginX, marginY)
}

; Search full game view
GdipClickColorInGameView(color, colorVariation := 5, marginX := 0, marginY := 0) {
    ; Full game view area
    x1 := 4, y1 := 2, x2 := 514, y2 := 335
    return GdipClickRandomPixelOfColor(color, x1, y1, x2, y2, colorVariation, marginX, marginY)
}
