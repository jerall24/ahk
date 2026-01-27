#Requires AutoHotkey v2.0

; ======================================
; WAIT FUNCTIONS
; ======================================

; Wait until a specific pixel matches the desired color
; Returns true if color matched, false if timed out
WaitForPixelColor(x, y, targetColor, timeout := 5000, checkInterval := Random(0, 50)) {
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
WaitForPixelColorNot(x, y, excludeColor, timeout := 5000, checkInterval := Random(0, 50)) {
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

; Wait until a color appears within a rectangle
; Returns true if color found, false if timed out
WaitForColorInRect(x1, y1, x2, y2, targetColor, timeout := 5000, checkInterval := 50, colorVariation := 5) {
    startTime := A_TickCount

    Loop {
        ; Check if color exists in rectangle
        if (ColorExistsInRect(x1, y1, x2, y2, targetColor, colorVariation)) {
            return true
        }

        ; Check if we've exceeded timeout
        elapsed := A_TickCount - startTime
        if (elapsed >= timeout) {
            ToolTip "Timeout waiting for color in rect (" x1 ", " y1 ", " x2 ", " y2 ")"
            SetTimer () => ToolTip(), -2000
            return false
        }

        ; Wait before checking again
        Sleep(checkInterval)
    }
}

; Wait until a color is NOT present within a rectangle
; Returns true if color disappeared, false if timed out
WaitForColorNotInRect(x1, y1, x2, y2, excludeColor, timeout := 5000, checkInterval := 50, colorVariation := 5) {
    startTime := A_TickCount

    Loop {
        ; Check if color does NOT exist in rectangle
        if (!ColorExistsInRect(x1, y1, x2, y2, excludeColor, colorVariation)) {
            return true
        }

        ; Check if we've exceeded timeout
        elapsed := A_TickCount - startTime
        if (elapsed >= timeout) {
            ToolTip "Timeout waiting for color to disappear from rect (" x1 ", " y1 ", " x2 ", " y2 ")"
            SetTimer () => ToolTip(), -2000
            return false
        }

        ; Wait before checking again
        Sleep(checkInterval)
    }
}

; Wait until ANY color from an array appears within a rectangle
; Returns true if any color found, false if timed out
; colors parameter should be an array of color values: [0xFF0000, 0x00FF00, 0x0000FF]
WaitForAnyColorInRect(x1, y1, x2, y2, colors, timeout := 5000, checkInterval := 50, colorVariation := 5) {
    startTime := A_TickCount

    Loop {
        ; Check each color in the array
        for color in colors {
            if (ColorExistsInRect(x1, y1, x2, y2, color, colorVariation)) {
                return true
            }
        }

        ; Check if we've exceeded timeout
        elapsed := A_TickCount - startTime
        if (elapsed >= timeout) {
            ToolTip "Timeout waiting for any color in rect (" x1 ", " y1 ", " x2 ", " y2 ")"
            SetTimer () => ToolTip(), -2000
            return false
        }

        ; Wait before checking again
        Sleep(checkInterval)
    }
}
