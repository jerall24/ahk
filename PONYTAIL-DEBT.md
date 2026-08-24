# Ponytail Debt Ledger

Technical shortcuts and deferred improvements tracked with upgrade triggers.

---

## Code Duplication

**main.ahk:151-495** - Numpad hotkey handlers with duplicated shift-detection pattern
- **Ceiling:** 15+ duplicated blocks with identical shift-detection logic for each numpad key
- **Upgrade:** When hotkey abstraction layer is added or dynamic binding system supports shift modifiers natively
- **Impact:** Maintenance burden - changes to hotkey logic must be replicated across all blocks

---

## Mode Dependencies

**Multiple files** - Functions assume mode but don't validate or document mode requirements
- **Ceiling:** Functions use `IsFixedMode()` ternary checks throughout without explicit validation
- **Upgrade:** When mode validation layer is added or mode-agnostic coordinate system implemented
- **Files affected:**
  - `game/inventory.ahk` - Slot coordinate lookups
  - `lib/` functions - Mixed mode-aware and mode-agnostic functions
  - `skills/*.ahk` - Various skill automations
- **Impact:** Potential runtime errors if functions are called in unsupported modes

**lib/wait.ahk:9** - Default random interval pattern
- **Ceiling:** `Random(0, 50)` may create detectable patterns in timing
- **Upgrade:** When anti-pattern randomization or variable distribution ranges are implemented

**game/inventory.ahk:189** - Iteration threshold before slot state check
- **Ceiling:** Hardcoded 20 iteration count before checking if slot is empty
- **Upgrade:** When proper timing heuristics or dynamic threshold calculation is added

**game/inventory.ahk:21** - Fixed rapid inventory speed
- **Ceiling:** `RAPID_INV_SPEED := 3.0` is global constant, not per-profile tunable
- **Upgrade:** When per-profile speed tuning system is implemented

---

## Summary

**Total markers:** 5
**No-trigger count:** 0

All shortcuts have clear upgrade paths defined.
