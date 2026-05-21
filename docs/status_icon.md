# Status Icon — Character Activity Detection

The status icon is a small in-game indicator (RuneLite overlay) that reflects whether the character is actively performing an action. It's the primary clock signal for all multi-step automation: rather than hardcoding `Sleep` durations, we watch this icon to know when the game has finished processing each action.

## Location (Fixed Mode)

```
Client-relative region: (499, 321) → (507, 330)
```

Captured via `CaptureCoordinates`. Do not hardcode these — if they ever drift, recapture and update the constants in `runecrafting.ahk`.

## States

| State   | Meaning                                   | Icon color |
|---------|-------------------------------------------|------------|
| RED     | Idle — character has stopped animating    | Red        |
| GREEN   | Active — character is doing something     | Green      |
| UNKNOWN | Neither detected — transient or off-screen | —         |

The icon transitions: **RED → GREEN** when an action starts, **GREEN → RED** when it completes. Automation waits for RED after triggering an action to confirm it finished.

## Color Constants (defined in `skills/runecrafting.ahk`)

```ahk
global RC_STATUS_X1 := 499, RC_STATUS_Y1 := 321
global RC_STATUS_X2 := 507, RC_STATUS_Y2 := 330
global RC_STATUS_RED   := [0xE02D2D, 0xE32828, 0xDE2F2F, 0xE12B2B, 0xE22929]
global RC_STATUS_GREEN := [0x32C850, 0x32C74F]
```

Multiple red shades exist because anti-aliasing and lighting cause slight variance. Each is checked via `ColorExistsInRect` with variation=5.

## Core API

**`IsStatusIconIdle()`** — `skills/runecrafting.ahk`
Returns `true` if any red shade is found in the icon region. Call this when you need an immediate snapshot.

**`WaitForActionComplete()`** — `lib/idle_loop.ahk`
Polls at 50ms. Waits for GREEN then RED in sequence. Returns `false` only if manually stopped.

```ahk
; The actionHappened flag prevents false-triggering when called while already idle.
; It requires the icon to go non-red first, then come back red.
```

**`LoopFunctionOnIdle(fn)`** — `lib/idle_loop.ahk`
Runs `fn()` repeatedly, waiting for idle between each call. Stop with Ctrl+Esc.

## Typical Usage Pattern

```ahk
; Trigger an action
ClickRandomPixelOfColor(SOME_COLOR)

; Wait for it to complete before continuing
if (!WaitForActionComplete())
    return  ; user cancelled

; Next action
```

For polling-based waits (checking a condition before deciding the next step):

```ahk
Loop {
    if (ShouldStopAction())
        return
    if (IsInventoryFull())
        break
    if (IsStatusIconIdle())
        ClickNextThing()
    Sleep(Random(2500, 3500))
}
```

## Adding Status Icon Support to a New Skill

1. The color constants and `IsStatusIconIdle()` live in `runecrafting.ahk` — they're global and available everywhere.
2. Call `WaitForActionComplete()` between sequential steps.
3. Use `IsStatusIconIdle()` only for conditional branching within a poll loop — not as a step-completion gate (use `WaitForActionComplete()` for that).

## Debugging

**`DebugStatusIcon()`** — bind to a key, shows current state + raw pixel colors at 3 sample points. Use this to verify the coordinates are still correct after a UI change.

**`RCLogStatus(context)`** — writes state + raw color to `log/rc.log` with a context label. Sprinkle into multi-step sequences to trace where timing breaks.
