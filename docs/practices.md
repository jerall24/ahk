# AHK Project — Development Practices

> **These practices are non-negotiable defaults.** If a situation seems to call for deviating from them, stop and ask for explicit permission before proceeding. Do not silently work around them.

## Coordinate System

**The contract: all function inputs use client-relative coordinates.**

Client-relative means relative to the RuneLite game client area — top-left of the game window (excluding title bar and borders) is `(0, 0)`.

### CoordMode

In AHK v2, `CoordMode` is **thread-level** — each hotkey fires in a new thread with default settings (Screen for everything). Setting it at script load time does not affect hotkey threads.

To make AHK's built-in pixel functions respect client-relative coordinates, every function that calls `PixelSearch` or `PixelGetColor` sets this at the top:

```ahk
CoordMode "Pixel", "Client"
```

Mouse movement stays in Screen mode (the AHK default), so `HumanClick` and `MouseMove` always take screen coordinates.

This means:
- You pass client-relative coords into everything
- AHK pixel functions work natively in client space
- Click functions convert to screen coords internally before moving the mouse

### The Conversion Pattern

Every click function that accepts coordinates does the conversion **once, internally**:

```ahk
WinGetClientPos(&clientX, &clientY, , , WinExist("ahk_exe RuneLite.exe"))
screenX := clientX + x1
screenY := clientY + y1
; then click at screenX, screenY
```

**Never convert at the call site. Never pass screen coords into a click function.**

### Capture Tools

Both capture tools output **client-relative** coordinates:

- `CaptureCoordinates` (F11) — outputs `x1, y1, x2, y2` client-relative rectangle
- `CaptureRectangleColors` — outputs `x1, y1, x2, y2, [colors]` client-relative, formatted for `WaitForAnyColorInRect`
- `CapturePixelAndColor` — outputs `x, y, color` client-relative

If you paste captured coordinates into a click function, they are correct as-is.
If you paste them into a wait function, they are also correct as-is (CoordMode "Pixel", "Client").

### GDIP Functions

GDIP functions (`GdipClickRandomPixelOfColor`, `GdipClickAnyColor`) do their own conversion manually and also accept client-relative input. Do not mix up `GdipClickRandomPixelOfColor` (client-relative) with `GdipClickAnyColor` (screen coords) — the latter is a legacy inconsistency to be fixed.

---

## Screen Access API — Use These, Don't Invent New Ones

**This is the most important rule for writing skill code.**

All screen capture, pixel detection, and color-based clicking goes through the library functions below. Do **not** call `PixelSearch`, `PixelGetColor`, `WinGetClientPos`, `MouseMove`, or `Click` directly in skill or game code. Do not write custom coordinate conversion logic. These problems are already solved.

### Checking whether a color exists in a region

```ahk
; Returns true/false immediately
ColorExistsInRect(x1, y1, x2, y2, color, variation := 5)   ; lib/color.ahk
```

### Waiting for a color to appear / disappear

```ahk
WaitForColorInRect(x1, y1, x2, y2, color, timeoutMs)        ; lib/wait.ahk
WaitForColorNotInRect(x1, y1, x2, y2, color, timeoutMs)     ; lib/wait.ahk
WaitForAnyColorInRect(x1, y1, x2, y2, colors, timeoutMs)    ; lib/wait.ahk  (colors = array)
WaitForPixelColor(x, y, color, timeoutMs)                    ; lib/wait.ahk
```

### Clicking a pixel of a specific color

```ahk
; Near the character (fast, scoped search):
GdipClickColorNearCharacter(color, variation := 5)           ; lib/gdip_pixel.ahk

; Full game view:
GdipClickColorInGameView(color, variation := 5)              ; lib/gdip_pixel.ahk

; Arbitrary rect (client-relative):
GdipClickRandomPixelOfColor(color, x1, y1, x2, y2)          ; lib/gdip_pixel.ahk
ClickRandomPixelOfColor(color, x1, y1, x2, y2)              ; lib/color.ahk

; Nearest matching pixel expanding from character outward:
ClickNearestColorFromArray(colorsArray)                      ; lib/pixel.ahk
```

### Clicking a known rectangle

```ahk
ClickRandomPixel(x1, y1, x2, y2)                            ; lib/color.ahk
HumanClickRandomPixel(x1, y1, x2, y2)                       ; lib/mouse.ahk
```

### Capturing coordinates and colors from the screen

Use the in-game capture tools (bind via Ctrl+NumpadEnter):
- `CaptureRectangleColors` — captures a rect + its dominant colors, copies result to clipboard
- `CaptureCoordinates` — captures a rect, copies client-relative coords to clipboard
- `CapturePixelAndColor` — captures a single point + its color

---

## Function Layers

```
Skill code (agility.ahk, prayer.ahk, etc.)
    calls → ClickObstacleWithVerification / ClickRandomPixel / ClickUIElement
                calls → HumanClick (screen coords)
                            calls → HumanMouseMove → MouseMove
```

- **Skill code** passes client-relative coords or slot numbers
- **Mid-layer** (`ClickRandomPixel`, `ClickUIElement`, etc.) converts once to screen
- **HumanClick** and **HumanMouseMove** always take screen coords

---

## UI Slot Coordinates

All slot/UI coordinates are defined client-relative in:
- `ui/modes/fixed_mode.ahk` — `FixedModeUI`, `InventorySlots`, `BankSlots`
- `ui/modes/medium_mode.ahk` — `MediumModeUI`, `MediumInventorySlots`, `MediumBankSlots`

Use `ClickUIElement("element_name")` for named UI elements.
Use `ClickInventorySlotNumber(n)` / `ClickBankSlotNumber(n)` for slots.
Do not hardcode slot coordinates in skill files — reference the slot maps.

---

## Mouse Movement

All clicks go through `HumanClick` → `HumanMouseMove` (Bezier curve, variable speed).
Do not call `MouseMove` or `Click` directly in skill/game code.
The `speed` parameter on `ClickRandomPixel` / `HumanClickRandomPixel` controls movement speed (1.0 = default, 3.0 = fast for repetitive actions like bones on altar).
