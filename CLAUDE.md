# AHK Project - AutoHotkey Game Automation

## Project Overview

**Purpose:** AutoHotkey scripts for game automation and workflow optimization.

**Tech Stack:** AutoHotkey v2
**Location:** `/mnt/c/Users/jeral/ahk` (Windows NTFS filesystem via WSL2)
**Repository:** `jerall24/ahk` on GitHub

**Entry Point:** `main.ahk`

## Project Structure

```
ahk/
├── main.ahk                   # Entry point
├── general.ahk                # General utilities
├── config/                    # Configuration files
│   ├── profiles.json          # User profiles
│   ├── state.json             # Application state
│   └── drop_debug.log         # Debug logs for drop functionality
├── core/                      # Core systems
│   ├── binding system
│   ├── profile management
│   └── function registry
├── lib/                       # Utility libraries
│   ├── mouse, pixel, color
│   ├── wait, capture, sound
├── game/                      # Game interaction
│   ├── bank management
│   └── inventory handling
├── ui/                        # UI elements and mode definitions
└── skills/                    # Skill-specific automation
    ├── herblore, construction
    ├── sailing, cooking
```

## UI Modes

**Fixed Mode:** 812x542 window
**Medium Mode:** 1050x725 window

All functions should be mode-aware using `IsFixedMode()` to handle different window sizes.

## Development Guidelines

### AutoHotkey Conventions

**Variables:**
- Use descriptive PascalCase for globals
- camelCase for local variables
- Constants in UPPER_CASE

**Functions:**
- Clear, action-oriented names
- Document expected window mode if mode-specific
- Return meaningful values or throw errors

**Coordinates:**
- Always document which UI mode coordinates are for
- Use relative positioning when possible
- Test in both Fixed and Medium modes

### Debugging

**Drop Functionality:**
- Check `config/drop_debug.log` for:
  - Timestamps
  - Mouse coordinates
  - Shift key states
  - Click positions

**Pixel Detection:**
- Document color values and expected positions
- Account for slight variations in lighting/rendering
- Test with actual game screenshots

### File System Notes

**Important:** This project lives on the Windows NTFS filesystem (`/mnt/c/`), accessed via WSL2:
- Git line endings should be configured for Windows (CRLF)
- File permissions may behave differently than native Linux
- Use Windows paths when referencing files in AHK scripts
- WSL2 path: `/mnt/c/Users/jeral/ahk`
- Windows path: `C:\Users\jeral\ahk`

## Testing

**Manual Testing:**
1. Load script in AutoHotkey
2. Test in both UI modes
3. Verify pixel detection accuracy
4. Check timing and delays

**Debugging:**
- Use `OutputDebug` for real-time logging
- Check drop_debug.log for persistent logs
- Use MsgBox for interactive debugging

## GitHub Integration

Repository is configured with GitHub MCP server for easy commits and PR management.

**Workflow:**
1. Make changes locally
2. Test in AutoHotkey
3. Commit via Claude Code
4. Push to GitHub

## Memory

See `MEMORY.md` for agent-maintained project learnings and patterns.

---

**Philosophy:** Automation should be reliable, mode-aware, and easy to debug. Document timing assumptions and coordinate dependencies.
