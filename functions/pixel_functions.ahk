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
    }
)
