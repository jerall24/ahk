#Requires AutoHotkey v2.0

; ======================================
; UTILITY FUNCTIONS
; Helper functions for capturing coordinates, colors, etc.
; ======================================

; Capture single pixel coordinates and color on right-click
CapturePixelAndColorWrapper() {
    CapturePixelAndColor()
}

; Capture rectangular area coordinates
CaptureCoordinatesWrapper() {
    CaptureCoordinates()
}

; Capture four bank slots
CaptureFourBankSlotsWrapper() {
    CaptureFourBankSlots()
}

; Capture rectangle and find most prominent colors
CaptureRectangleColorsWrapper() {
    CaptureRectangleColors()
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global UtilityFunctionsRegistry := Map(
    "CapturePixelAndColor", {
        name: "CapturePixelAndColor",
        func: CapturePixelAndColorWrapper,
        description: "Right-click to capture pixel coordinates and color to clipboard"
    },
    "CaptureCoordinates", {
        name: "CaptureCoordinates",
        func: CaptureCoordinatesWrapper,
        description: "Right-click twice to capture rectangular area coordinates"
    },
    "CaptureFourBankSlots", {
        name: "CaptureFourBankSlots",
        func: CaptureFourBankSlotsWrapper,
        description: "Right-click 4 times to capture bank slots 1-4 for 4-ingredient herblore"
    },
    "CaptureRectangleColors", {
        name: "CaptureRectangleColors",
        func: CaptureRectangleColorsWrapper,
        description: "Right-click twice to capture rectangle with top 5 most prominent colors"
    }
)
