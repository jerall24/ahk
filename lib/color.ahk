#Requires AutoHotkey v2.0

; ======================================
; COLOR & PIXEL CLICK FUNCTIONS
; ======================================

; Function to get the color of the pixel under the mouse
GetPixelColorUnderMouse() {
    MouseGetPos(&mouseX, &mouseY)
    return PixelGetColor(mouseX, mouseY)
}

; Check if a color exists within a rectangle
; Returns true if color is found, false otherwise
ColorExistsInRect(x1, y1, x2, y2, color, colorVariation := 5) {
    return PixelSearch(&foundX, &foundY, x1, y1, x2, y2, color, colorVariation)
}

; Function to click a random pixel in a range
; NOTE: Coordinates are CLIENT-RELATIVE and will be converted to screen coordinates
; If nearMouse is true, prioritizes clicking within radius pixels of current mouse position
; speed parameter controls mouse movement speed (1.0 = normal, 1.5 = faster)
ClickRandomPixel(x1, y1, x2, y2, nearMouse := false, radius := 3, speed := 1.0) {
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

    if (nearMouse) {
        ; Get current mouse position
        MouseGetPos(&currentX, &currentY)

        ; Check if current mouse is within the target rectangle
        if (currentX >= screenX1 && currentX <= screenX2 && currentY >= screenY1 && currentY <= screenY2) {
            ; Calculate bounds around current position, clamped to rectangle
            nearX1 := Max(screenX1, currentX - radius)
            nearX2 := Min(screenX2, currentX + radius)
            nearY1 := Max(screenY1, currentY - radius)
            nearY2 := Min(screenY2, currentY + radius)

            randomX := Random(nearX1, nearX2)
            randomY := Random(nearY1, nearY2)
        } else {
            ; Mouse not in rectangle, use regular random
            randomX := Random(screenX1, screenX2)
            randomY := Random(screenY1, screenY2)
        }
    } else {
        ; Regular random click anywhere in rectangle
        randomX := Random(screenX1, screenX2)
        randomY := Random(screenY1, screenY2)
    }

    ; Check if RuneLite is in the background before clicking
    wasBackground := !WinActive("ahk_exe RuneLite.exe")

    HumanClick(randomX, randomY, "left", speed, 1.0)

    ; If RuneLite wasn't the active window, alt+tab back to previous window
    if (wasBackground) {
        ReturnToPreviousWindow()
    }
}

; Function to find and click a random pixel of a specific color
ClickRandomPixelOfColor(color, marginX := 0, marginY := 0, near_character := false) {
    ; Show indicator during search
    ShowActivityIndicator()

    ; Get window position and size
    WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_exe RuneLite.exe")
    ; top left corner: -7 3 812 542
    ; further down -10 198 812 542
    fixed_mode_x1_start := 4
    fixed_mode_y1_start := 2
    fixed_mode_x2_end := 514
    fixed_mode_y2_end := 335

    near_character_x1_start := 100
    near_character_y1_start := 35
    near_character_x2_end := 460
    near_character_y2_end := 335

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
        ; Find bounding box of all found pixels
        minX := foundPixels[1].x
        maxX := foundPixels[1].x
        minY := foundPixels[1].y
        maxY := foundPixels[1].y

        for pixel in foundPixels {
            if (pixel.x < minX)
                minX := pixel.x
            if (pixel.x > maxX)
                maxX := pixel.x
            if (pixel.y < minY)
                minY := pixel.y
            if (pixel.y > maxY)
                maxY := pixel.y
        }

        ; Shrink bounding box inward by 25% to avoid edges
        width := maxX - minX
        height := maxY - minY
        shrinkX := Round(width * 0.25)
        shrinkY := Round(height * 0.25)

        innerMinX := minX + shrinkX
        innerMaxX := maxX - shrinkX
        innerMinY := minY + shrinkY
        innerMaxY := maxY - shrinkY

        ; If box is too small after shrinking, just use center
        if (innerMinX >= innerMaxX || innerMinY >= innerMaxY) {
            targetX := Round((minX + maxX) / 2) + marginX
            targetY := Round((minY + maxY) / 2) + marginY
        } else {
            ; Click random point inside shrunk box
            targetX := Random(innerMinX, innerMaxX) + marginX
            targetY := Random(innerMinY, innerMaxY) + marginY
        }

        HumanClick(targetX, targetY, "left", 1.0, 1.0)
        return true
    }

    ; Only show tooltip on failure
    HideActivityIndicator()
    ToolTip "No pixels found for color: " color
    SetTimer () => ToolTip(), -2000
    return false
}

; Function to try clicking any of multiple colors (tries each color in order until one succeeds)
ClickAnyRandomPixelOfColor(colors, marginX := 0, marginY := 0, near_character := false) {
    ; Iterate through the array of colors
    for color in colors {
        ; Try to click this color
        if (ClickRandomPixelOfColor(color, marginX, marginY, near_character)) {
            return true  ; Success - found and clicked this color
        }
    }

    ; None of the colors were found
    ToolTip "No pixels found for any of the " colors.Length " colors"
    SetTimer () => ToolTip(), -2000
    return false
}

; Cluster-based centroid clicking function
; Finds pixels, groups them into clusters (separate objects), picks a random cluster,
; and clicks at the centroid of that cluster
ClickRandomPixelOfColorCentroid(color, marginX := 0, marginY := 0, near_character := false) {
    ; Show indicator during search
    ShowActivityIndicator()

    ; Get window position and size
    WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_exe RuneLite.exe")

    ; Define search areas (same as original function)
    fixed_mode_x1_start := 4
    fixed_mode_y1_start := 2
    fixed_mode_x2_end := 514
    fixed_mode_y2_end := 335

    near_character_x1_start := 100
    near_character_y1_start := 35
    near_character_x2_end := 460
    near_character_y2_end := 335

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
        HideActivityIndicator()
        ToolTip "No pixels found for color: " color
        SetTimer () => ToolTip(), -2000
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

    ; Check if shrinking created an invalid box
    if (innerMinX >= innerMaxX || innerMinY >= innerMaxY) {
        ; Box too small to shrink, just use center
        targetX := Round((minX + maxX) / 2) + marginX
        targetY := Round((minY + maxY) / 2) + marginY

        ; Debug: Show bounding box info only when box is too small
        debugInfo := "BBox: " minX "," minY " to " maxX "," maxY "`n"
        debugInfo .= "Size: " width "x" height "`n"
        debugInfo .= "Shrink: " shrinkX "," shrinkY "`n"
        debugInfo .= "Inner: " innerMinX "," innerMinY " to " innerMaxX "," innerMaxY
        ToolTip "Box too small, clicking center: (" targetX ", " targetY ")`n" debugInfo
        SetTimer () => ToolTip(), -3000
    } else {
        ; Click random point inside the shrunken box
        targetX := Random(innerMinX, innerMaxX) + marginX
        targetY := Random(innerMinY, innerMaxY) + marginY
    }

    ; Click inside the outlined area with human-like movement
    HumanClick(targetX, targetY, "left", 1.0, 1.0)

    return true
}
