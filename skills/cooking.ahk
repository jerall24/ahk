#Requires AutoHotkey v2.0

; ======================================
; COOKING FUNCTIONS
; ======================================

; Global variables for captured cooking rectangles
global cookingRect1 := {x1: 0, y1: 0, x2: 0, y2: 0}
global cookingRect2 := {x1: 0, y1: 0, x2: 0, y2: 0}

; Capture two rectangles for cooking (fire/range and cooking interface)
; Similar to bank/inventory slot capture system
CaptureCookingRectangles() {
    global cookingRect1, cookingRect2

    ; Capture first rectangle (bank)
    pt1 := CapturePoint("Move mouse to TOP-LEFT corner of first rectangle (bank), then press OK")
    pt2 := CapturePoint("Move mouse to BOTTOM-RIGHT corner of first rectangle (bank), then press OK")
    cookingRect1 := {x1: pt1.x, y1: pt1.y, x2: pt2.x, y2: pt2.y}

    ; Capture second rectangle (fire/range)
    pt3 := CapturePoint("Move mouse to TOP-LEFT corner of second rectangle (fire/range), then press OK")
    pt4 := CapturePoint("Move mouse to BOTTOM-RIGHT corner of second rectangle (fire/range), then press OK")
    cookingRect2 := {x1: pt3.x, y1: pt3.y, x2: pt4.x, y2: pt4.y}

    ; Save to profile
    SaveProfiles()

    ToolTip "Cooking rectangles captured and saved!`nRect1 (Bank): (" cookingRect1.x1 "," cookingRect1.y1 ") to (" cookingRect1.x2 "," cookingRect1.y2 ")`nRect2 (Fire/Range): (" cookingRect2.x1 "," cookingRect2.y1 ") to (" cookingRect2.x2 "," cookingRect2.y2 ")"
    SetTimer () => ToolTip(), -4000
}

; Main cooking cycle function
; 1. Click randomly in first rectangle (bank) with natural movement
; 2. Wait for bank interface
; 3. Deposit inventory (empty it)
; 4. Click bank slot 24 (withdraw food)
; 5. Hit Escape
; 6. Click randomly in second rectangle (fire/range)
; 7. Hit Space
ProcessCooking() {
    global cookingRect1, cookingRect2

    ; Validate rectangles have been captured
    if (cookingRect1.x1 = 0 || cookingRect2.x1 = 0) {
        ToolTip "Cooking rectangles not captured! Use capture function first."
        SetTimer () => ToolTip(), -2000
        return
    }

    ; Step 1: Click randomly in first rectangle (bank) with natural human movement
    ToolTip ""  ; Clear any lingering tooltips
    HumanClickRandomPixel(cookingRect1.x1, cookingRect1.y1, cookingRect1.x2, cookingRect1.y2, "left", 1.0)
    Sleep(Random(600, 900))

    ; Step 2: Deposit inventory (empty it)
    ClickUIElement("bank_deposit_inventory")
    Sleep(Random(150, 250))

    ; Step 3: Click bank slot 24 (withdraw food)
    ClickBankSlot(24)
    Sleep(Random(600, 900))

    ; Step 4: Hit Escape
    Send("{Escape}")
    Sleep(Random(200, 400))

    ; Step 5: Click randomly in second rectangle (fire/range) with natural movement
    ToolTip ""  ; Clear any lingering tooltips
    HumanClickRandomPixel(cookingRect2.x1, cookingRect2.y1, cookingRect2.x2, cookingRect2.y2, "left", 1.0)
    Sleep(Random(600, 900))

    ; Step 6: Hit Space
    Send("{Space}")
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global CookingRegistry := Map(
    "CaptureCookingRectangles", {
        name: "CaptureCookingRectangles",
        func: CaptureCookingRectangles,
        description: "Capture two rectangles for cooking (bank and fire/range) - saves to profile"
    },
    "ProcessCooking", {
        name: "ProcessCooking",
        func: ProcessCooking,
        description: "Bank>Deposit>Withdraw slot 24>Esc>Fire/Range>Space (natural movement)"
    }
)
