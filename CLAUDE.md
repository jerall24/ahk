# Project Instructions

## Debug Logs

When debugging drop functionality, always check the drop debug log:
- Path: `config/drop_debug.log`
- Contains: timestamps, coordinates, shift key states, mouse positions

## Project Structure

- `config/` - Configuration files (profiles.json, state.json)
- `core/` - Core systems (binding, profiles, function registry)
- `lib/` - Utility libraries (mouse, pixel, color, wait, capture, sound)
- `game/` - Game interaction (bank, inventory)
- `ui/` - UI elements and mode definitions
- `skills/` - Skill-specific functions (herblore, construction, sailing, cooking)

## UI Modes

- Fixed mode: 812x542 window
- Medium mode: 1050x725 window
- Functions should be mode-aware using `IsFixedMode()`
