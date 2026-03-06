#Requires AutoHotkey v2.0

; ======================================
; PRAYER FUNCTIONS
; ======================================

; Altar click area (CLIENT-RELATIVE — recapture with F11 if altar clicks are off)
global prayerAltarX1 := 596
global prayerAltarY1 := 544
global prayerAltarX2 := 706
global prayerAltarY2 := 605

; Toggle state and step tracker
global isUsingBonesOnAltar := false
global bonesOnAltarStep := 0  ; 0 = click bones, 1 = click altar

; Mouse speed for bones on altar (higher = faster movement)
global BONES_ALTAR_SPEED := 3.0

; Timer callback for bones on altar loop
BonesOnAltarTick() {
    global isUsingBonesOnAltar, bonesOnAltarStep

    if (!isUsingBonesOnAltar) {
        SetTimer(BonesOnAltarTick, 0)
        ToolTip "UseBonesOnAltar OFF"
        SetTimer () => ToolTip(), -2000
        return
    }

    if (bonesOnAltarStep = 0) {
        ; Click inventory slot 28 (bones) with fast mouse speed
        if (IsFixedMode()) {
            coords := InventorySlots[28]
        } else {
            coords := MediumInventorySlots[28]
        }
        ClickRandomPixel(coords.x1, coords.y1, coords.x2, coords.y2, false, 3, BONES_ALTAR_SPEED)
        bonesOnAltarStep := 1
    } else {
        ; Click altar with fast mouse speed
        ClickRandomPixel(prayerAltarX1, prayerAltarY1, prayerAltarX2, prayerAltarY2, false, 3, BONES_ALTAR_SPEED)
        bonesOnAltarStep := 0
    }

    ; Schedule next tick with randomized delay
    SetTimer(BonesOnAltarTick, -Random(80, 150))
}

; Toggle bones on altar on/off
UseBonesOnAltar() {
    global isUsingBonesOnAltar, bonesOnAltarStep

    if (isUsingBonesOnAltar) {
        isUsingBonesOnAltar := false
        return
    }

    isUsingBonesOnAltar := true
    bonesOnAltarStep := 0
    ToolTip "UseBonesOnAltar ON"
    SetTimer () => ToolTip(), -1500

    ; Start the timer-based loop (first tick immediate)
    SetTimer(BonesOnAltarTick, -1)
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global PrayerRegistry := Map(
    "UseBonesOnAltar", {
        name: "UseBonesOnAltar",
        func: UseBonesOnAltar,
        description: "Repeatedly use bones on altar (slot 8 -> altar) until stopped"
    }
)
