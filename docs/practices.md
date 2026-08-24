# AHK Project — Development Practices

> **These practices are non-negotiable defaults.** If a situation seems to call for deviating from them, stop and ask for explicit permission before proceeding. Do not silently work around them.

## Quick Reference

**Clicking a color marker in game view:**
```ahk
GdipClickColorInGameView(0x0000FF, 5, 0, 0, 3)
```

**Clicking a color within specific coordinates:**
```ahk
GdipClickRandomPixelOfColor(0xFF0000, 306, 115, 311, 129, 5, 0, 0, 2, 3)
```

**Clicking a fixed region (no color search):**
```ahk
ClickRandomPixel(306, 115, 311, 129)
```

**Waiting for action to complete:**
```ahk
ClickSomething()
if (!WaitForActionComplete())
    return  ; user cancelled
```

**Checking if idle immediately:**
```ahk
if (IsStatusIconIdle())
    ClickNextThing()
```

---

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

**RULE: Always use Gdip functions for color-based clicking. They avoid edge-clicking and use surroundRadius to ensure solid color regions.**

```ahk
; Full game view (most common - use this as default):
GdipClickColorInGameView(color, variation := 5, marginX := 0, marginY := 0, surroundRadius := 3)
  → lib/gdip_pixel.ahk
  → Searches entire game view (4, 2, 514, 335)
  → Avoids clicking edges via surroundRadius check
  → Example: GdipClickColorInGameView(0x0000FF, 5, 0, 0, 3)

; Specific region (when you have exact coordinates):
GdipClickRandomPixelOfColor(color, x1, y1, x2, y2, variation := 5, marginX := 0, marginY := 0, maxRetries := 2, surroundRadius := 3)
  → lib/gdip_pixel.ahk
  → Searches within client-relative rect (x1, y1, x2, y2)
  → Avoids edges, verifies color matches
  → Example: GdipClickRandomPixelOfColor(0xFF0000, 306, 115, 311, 129, 5, 0, 0, 2, 3)

; Nearest matching pixel expanding from character outward:
ClickNearestColorFromArray(colorsArray)
  → lib/pixel.ahk
  → Searches in expanding rings from character position
  → Use for mining/woodcutting when you want closest resource
```

**DO NOT USE:** `ClickRandomPixelOfColor` (legacy, clicks edges, no surround check)

### Clicking a known rectangle (no color search)

**Use when you have exact coordinates and don't need color verification:**

```ahk
ClickRandomPixel(x1, y1, x2, y2, nearMouse := false, radius := 3, speed := 1.0)
  → lib/color.ahk
  → Clicks random pixel in client-relative rect
  → Use for UI elements, inventory slots, fixed regions
  → Example: ClickRandomPixel(306, 115, 311, 129)
```

**When to use which:**
- **Need to click a color marker?** → `GdipClickColorInGameView` or `GdipClickRandomPixelOfColor`
- **Have exact rect coordinates, no color search?** → `ClickRandomPixel`
- **Clicking inventory/bank slots?** → `ClickInventorySlot(n)` / `ClickBankSlotNumber(n)`

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

## Action Timing and Idle Detection

**RULE: Never use hardcoded `Sleep()` to wait for actions to complete. Always use status icon detection.**

The status icon is a RuneLite overlay at the bottom-right of the game view that shows character state:
- **RED** = idle (action complete)
- **GREEN** = active (action in progress)

### Primary timing function

```ahk
WaitForActionComplete(retryFn := "")
  → lib/idle_loop.ahk
  → Polls status icon at 50ms intervals
  → Waits for icon to go GREEN (action started) then RED (action finished)
  → Returns false only if manually stopped (Ctrl+Escape)
  → Example:
      ClickRandomPixelOfColor(ROCK_COLOR)
      if (!WaitForActionComplete())
          return  ; user cancelled
```

### Immediate status check

```ahk
IsStatusIconIdle()
  → core/state.ahk (global)
  → Returns true/false immediately
  → Use for conditional branching in poll loops
  → Example:
      if (IsStatusIconIdle())
          ClickNextRock()
```

### When to use hardcoded Sleep()

**Only use `Sleep()` for:**
1. **UI delays** - waiting for dialogs to appear (e.g., 1500ms after clicking furnace)
2. **Input spacing** - brief delays between key presses (e.g., 100-250ms after clicking inventory)
3. **Retry delays** - waiting before retrying a failed click (e.g., 1000ms)

**Never use `Sleep()` for:**
- Waiting for character to finish walking
- Waiting for smithing/crafting/cooking to complete
- Waiting for combat actions to finish
- Any action that shows character animation

### Status icon configuration

Coordinates and colors are defined globally in `core/state.ahk`:
```ahk
global STATUS_ICON_X1 := 499, STATUS_ICON_Y1 := 321
global STATUS_ICON_X2 := 507, STATUS_ICON_Y2 := 330
global STATUS_ICON_RED   := [0xE02D2D, 0xE32828, 0xDE2F2F, 0xE12B2B, 0xE22929, 0xDC3232]
global STATUS_ICON_GREEN := [0x32C850, 0x32C74F]
```

See `docs/status_icon.md` for detailed documentation.

---

## Mouse Movement

All clicks go through `HumanClick` → `HumanMouseMove` (Bezier curve, variable speed).
Do not call `MouseMove` or `Click` directly in skill/game code.
The `speed` parameter on `ClickRandomPixel` / `HumanClickRandomPixel` controls movement speed (1.0 = default, 3.0 = fast for repetitive actions like bones on altar).
