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
