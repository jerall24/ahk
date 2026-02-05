#Requires AutoHotkey v2.0

; Set mouse coordinates to Screen mode (not Window-relative)
CoordMode "Mouse", "Screen"

; ======================================
; HUMAN-LIKE MOUSE MOVEMENT
; Implements Bezier curves with variable speed and jitter
; ======================================

; Global flag to prevent recursive calls
global isMovingMouse := false

; Main function: Move mouse to target using human-like movement
; Parameters:
;   targetX, targetY - Destination coordinates
;   speed - Movement speed multiplier (0.5 = slower, 2.0 = faster, default 1.0)
;   accuracy - How close to get to target (0.5-2.0, lower = more overshoot, default 1.0)
HumanMouseMove(targetX, targetY, speed := 1.0, accuracy := 1.0) {
    global isMovingMouse

    ; Prevent recursive calls
    if (isMovingMouse) {
        return
    }
    isMovingMouse := true

    ; Show activity indicator
    ShowActivityIndicator()

    ; Get current mouse position
    MouseGetPos(&startX, &startY)

    ; If already at target, don't move
    if (startX = targetX && startY = targetY) {
        isMovingMouse := false
        return
    }

    ; Calculate distance
    distance := Sqrt((targetX - startX)**2 + (targetY - startY)**2)

    ; Generate control points for cubic Bezier curve
    ; This creates the curved path instead of a straight line
    controlPoints := GenerateControlPoints(startX, startY, targetX, targetY)

    ; Calculate number of steps based on distance and speed
    ; More steps = smoother movement, fewer steps = faster but choppier
    ; Balanced for fast movement with slight smoothness
    baseSteps := Max(6, Min(12, Round(distance / 12)))
    steps := Round(baseSteps / speed)

    ; Generate the Bezier curve path
    pathPoints := GenerateBezierPath(startX, startY, controlPoints.cp1x, controlPoints.cp1y,
                                      controlPoints.cp2x, controlPoints.cp2y, targetX, targetY, steps)

    ; Add random jitter to path points
    AddJitterToPath(pathPoints)

    ; Move along the path with variable speed
    MoveAlongPath(pathPoints, speed, accuracy, targetX, targetY)

    ; Hide activity indicator
    HideActivityIndicator()

    ; Release the lock
    isMovingMouse := false
}

; Generate random control points for cubic Bezier curve
; Control points determine the curve shape
GenerateControlPoints(startX, startY, targetX, targetY) {
    ; Calculate vector from start to target
    dx := targetX - startX
    dy := targetY - startY
    distance := Sqrt(dx**2 + dy**2)

    ; Normalize direction
    if (distance > 0) {
        dirX := dx / distance
        dirY := dy / distance
    } else {
        dirX := 0
        dirY := 0
    }

    ; Generate perpendicular vector for curve offset
    perpX := -dirY
    perpY := dirX

    ; Random offset amounts (this creates natural variation in curve shape)
    ; Minimal curve for fast, nearly direct paths
    offsetStrength := Min(distance * 0.15, 40)
    offset1 := Random(-offsetStrength, offsetStrength)
    offset2 := Random(-offsetStrength, offsetStrength)

    ; Control point 1: 1/3 along the path with random perpendicular offset
    cp1x := startX + (dx * 0.33) + (perpX * offset1)
    cp1y := startY + (dy * 0.33) + (perpY * offset1)

    ; Control point 2: 2/3 along the path with random perpendicular offset
    cp2x := startX + (dx * 0.66) + (perpX * offset2)
    cp2y := startY + (dy * 0.66) + (perpY * offset2)

    return {cp1x: cp1x, cp1y: cp1y, cp2x: cp2x, cp2y: cp2y}
}

; Generate points along a cubic Bezier curve
; Uses the standard Bezier formula: B(t) = (1-t)³P₀ + 3(1-t)²tP₁ + 3(1-t)t²P₂ + t³P₃
GenerateBezierPath(x0, y0, x1, y1, x2, y2, x3, y3, steps) {
    path := []

    Loop steps {
        t := A_Index / steps

        ; Cubic Bezier formula
        ; (1-t)³ term
        term0 := (1 - t)**3
        ; 3(1-t)²t term
        term1 := 3 * ((1 - t)**2) * t
        ; 3(1-t)t² term
        term2 := 3 * (1 - t) * (t**2)
        ; t³ term
        term3 := t**3

        ; Calculate point on curve
        x := (term0 * x0) + (term1 * x1) + (term2 * x2) + (term3 * x3)
        y := (term0 * y0) + (term1 * y1) + (term2 * y2) + (term3 * y3)

        path.Push({x: Round(x), y: Round(y)})
    }

    return path
}

; Add random micro-adjustments (jitter) to the path
; This simulates natural hand tremor and imperfect movement
AddJitterToPath(pathPoints) {
    ; With very few steps, minimal jitter to keep it smooth
    for point in pathPoints {
        ; Tiny random offset for subtle variation
        index := A_Index
        totalPoints := pathPoints.Length

        ; Only add jitter to middle points, not start/end
        if (index > 1 && index < totalPoints) {
            ; Very minimal jitter
            if (Random(1, 100) <= 50) {  ; 50% chance
                point.x += Random(-1, 1)
                point.y += Random(-1, 1)
            }
        }
    }
}

; Move mouse along the path with variable speed (acceleration/deceleration)
; Implements Fitts's Law: accelerate at start, decelerate near target
MoveAlongPath(pathPoints, speedMultiplier, accuracy, finalX, finalY) {
    totalPoints := pathPoints.Length

    for point in pathPoints {
        index := A_Index

        ; Calculate speed variation based on position in path
        ; Follows an ease-in-ease-out pattern
        progress := index / totalPoints

        ; Speed curve: slow start, fast middle, slow end
        if (progress < 0.3) {
            ; Acceleration phase (0-30%)
            speedFactor := 0.5 + (progress / 0.3) * 0.5  ; 0.5 to 1.0
        } else if (progress > 0.7) {
            ; Deceleration phase (70-100%)
            remainingProgress := (1.0 - progress) / 0.3
            speedFactor := 0.3 + remainingProgress * 0.7  ; 1.0 to 0.3
        } else {
            ; Cruise phase (30-70%)
            speedFactor := 1.0
        }

        ; Move to point
        MouseMove(point.x, point.y, 0)

        ; Delay between steps for visible smooth movement
        Sleep(2)
    }

    ; No overshoot for maximum speed - just go straight to target
    MouseMove(finalX, finalY, 0)
}

; Wrapper function for clicking with human-like movement
; Moves to target, then clicks
HumanClick(targetX, targetY, button := "left", speed := 1.0, accuracy := 1.0) {
    global currentProfile

    ; Move to target with human-like movement
    HumanMouseMove(targetX, targetY, speed, accuracy)

    ; Check for dry run mode (Debug profile)
    if (currentProfile = "Debug") {
        ToolTip "DRY RUN: Would click " button " at (" targetX ", " targetY ")"
        SetTimer () => ToolTip(), -2000
        return
    }

    ; Brief delay before click
    Sleep(Random(2, 5))

    ; Perform click
    if (button = "left") {
        Click
    } else if (button = "right") {
        Click "Right"
    } else if (button = "middle") {
        Click "Middle"
    }

    ; Brief delay after click
    Sleep(Random(2, 5))
}

; Click in a random position within a rectangle using human-like movement
; NOTE: Coordinates are CLIENT-RELATIVE and will be converted to screen coordinates
HumanClickRandomPixel(x1, y1, x2, y2, button := "left", speed := 1.0) {
    ; Get client position to convert to screen coordinates
    hwnd := WinExist("ahk_exe RuneLite.exe")
    if (hwnd) {
        clientX := 0, clientY := 0, clientW := 0, clientH := 0
        WinGetClientPos(&clientX, &clientY, &clientW, &clientH, hwnd)

        ; Convert client-relative coords to screen coords
        screenX1 := clientX + x1
        screenY1 := clientY + y1
        screenX2 := clientX + x2
        screenY2 := clientY + y2
    } else {
        ; Fallback to treating as screen coords if window not found
        screenX1 := x1
        screenY1 := y1
        screenX2 := x2
        screenY2 := y2
    }

    randomX := Random(screenX1, screenX2)
    randomY := Random(screenY1, screenY2)
    HumanClick(randomX, randomY, button, speed, 1.0)
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global MouseMovementRegistry := Map(
    "HumanMouseMove", {
        name: "HumanMouseMove",
        func: HumanMouseMove,
        description: "Move mouse to coordinates using human-like Bezier curve movement"
    },
    "HumanClick", {
        name: "HumanClick",
        func: HumanClick,
        description: "Click at coordinates with human-like movement"
    },
    "HumanClickRandomPixel", {
        name: "HumanClickRandomPixel",
        func: HumanClickRandomPixel,
        description: "Click random pixel in rectangle with human-like movement"
    }
)
