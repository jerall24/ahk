#Requires AutoHotkey v2.0

; ======================================
; PIXEL AND COLOR FUNCTIONS
; ======================================

; Click centroid of cyan pixel cluster near character, fallback to full view
ClickCyanCentroid() {
    if !ClickRandomPixelOfColorCentroid(0xFF00CA, 0, 0, true) {
        ClickRandomPixelOfColorCentroid(0xFF00CA, 0, 0, false)
    }
}

; Click random cyan pixel in full game view
ClickRandomCyan() {
    ClickRandomPixelOfColor(0xFF00CA, 0, 0, false)
}

; Click closest amethyst using predefined colors
ClickClosestAmethyst() {
    amethystColors := [0x976F81, 0x846170, 0x987082, 0xB18197, 0xB885A1]
    return ClickNearestColorFromArray(amethystColors)
}

; Click nearest pixel matching any color in the provided array
; Searches in expanding radius from character position (275, 193)
; Maximum search boundary is (523, 367)
ClickNearestColorFromArray(colorArray) {
    ; Show indicator during search
    ShowActivityIndicator()

    charX := 275
    charY := 193
    maxX := 523
    maxY := 367
    colorVariation := 5
    stepSize := 15  ; Search in 15-pixel increments for speed

    ; Calculate maximum search radius based on boundaries
    maxRadius := Max(maxX - charX, maxY - charY, charX, charY)

    ; Search in expanding rings from character position
    prevRadius := 0
    radius := stepSize

    Loop {
        if (radius > maxRadius) {
            break
        }

        ; Define bounds for current ring
        outerX1 := Max(0, charX - radius)
        outerY1 := Max(0, charY - radius)
        outerX2 := Min(maxX, charX + radius)
        outerY2 := Min(maxY, charY + radius)

        ; Search the new ring only (4 rectangles: top, bottom, left, right strips)
        innerX1 := Max(0, charX - prevRadius)
        innerY1 := Max(0, charY - prevRadius)
        innerX2 := Min(maxX, charX + prevRadius)
        innerY2 := Min(maxY, charY + prevRadius)

        ; Search for each color in the array
        for color in colorArray {
            ; Top strip
            if (outerY1 < innerY1 && PixelSearch(&foundX, &foundY, outerX1, outerY1, outerX2, innerY1 - 1, color, colorVariation)) {
                ClickRandomPixel(foundX - 5, foundY - 5, foundX + 5, foundY + 5)
                return true
            }

            ; Bottom strip
            if (outerY2 > innerY2 && PixelSearch(&foundX, &foundY, outerX1, innerY2 + 1, outerX2, outerY2, color, colorVariation)) {
                ClickRandomPixel(foundX - 5, foundY - 5, foundX + 5, foundY + 5)
                return true
            }

            ; Left strip (excluding corners already checked)
            if (outerX1 < innerX1 && PixelSearch(&foundX, &foundY, outerX1, innerY1, innerX1 - 1, innerY2, color, colorVariation)) {
                ClickRandomPixel(foundX - 5, foundY - 5, foundX + 5, foundY + 5)
                return true
            }

            ; Right strip (excluding corners already checked)
            if (outerX2 > innerX2 && PixelSearch(&foundX, &foundY, innerX2 + 1, innerY1, outerX2, innerY2, color, colorVariation)) {
                ClickRandomPixel(foundX - 5, foundY - 5, foundX + 5, foundY + 5)
                return true
            }
        }

        prevRadius := radius
        radius += stepSize
    }

    ; No matching color found
    HideActivityIndicator()
    return false
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global PixelFunctionsRegistry := Map(
    "ClickCyanCentroid", {
        name: "ClickCyanCentroid",
        func: ClickCyanCentroid,
        description: "Click centroid of cyan pixel cluster (near char first, then full view)"
    },
    "ClickRandomCyan", {
        name: "ClickRandomCyan",
        func: ClickRandomCyan,
        description: "Click random cyan pixel in full game view"
    },
    "ClickClosestAmethyst", {
        name: "ClickClosestAmethyst",
        func: ClickClosestAmethyst,
        description: "Click closest amethyst from character position"
    },
    "ClickNearestColorFromArray", {
        name: "ClickNearestColorFromArray",
        func: ClickNearestColorFromArray,
        description: "Click nearest pixel from character matching any color in array (expands search radius)"
    }
)
