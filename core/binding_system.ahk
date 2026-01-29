#Requires AutoHotkey v2.0

; ======================================
; BINDING SYSTEM
; Handles dynamic keybinding with fuzzy search GUI
; ======================================

; Global flag to indicate we're in binding mode
global IsBindingMode := false
global BindingFunctionName := ""

; Get functions by category
GetFunctionsByCategory(category) {
    functions := []

    if (category = "All") {
        return GetFunctionNames()
    } else if (category = "UI Elements") {
        ; Add special selectors first
        functions.Push("[Select Bank Slot...]")
        functions.Push("[Select Inventory Slot...]")
        functions.Push("[Select Drop Slot...]")
        ; Then add other UI element functions
        for name in UIElementFunctionsRegistry {
            if (name != "[Select Bank Slot...]" && name != "[Select Inventory Slot...]" && name != "[Select Drop Slot...]") {
                functions.Push(name)
            }
        }
    } else if (category = "Bank") {
        for name in BankFunctionsRegistry {
            functions.Push(name)
        }
    } else if (category = "Inventory") {
        for name in InventoryFunctionsRegistry {
            functions.Push(name)
        }
    } else if (category = "Mouse") {
        for name in MouseMovementRegistry {
            functions.Push(name)
        }
    } else if (category = "Pixel") {
        for name in PixelFunctionsRegistry {
            functions.Push(name)
        }
    } else if (category = "Skills") {
        ; Combine all skill registries
        for name in HerbloreRegistry {
            functions.Push(name)
        }
        for name in ConstructionRegistry {
            functions.Push(name)
        }
        for name in SailingRegistry {
            functions.Push(name)
        }
        for name in CookingRegistry {
            functions.Push(name)
        }
    } else if (category = "UI/Utility") {
        for name in UIFunctionsRegistry {
            functions.Push(name)
        }
        for name in UtilityFunctionsRegistry {
            functions.Push(name)
        }
    }

    return functions
}

; Show function selection GUI with fuzzy search and tabs
ShowFunctionSelector(keyToBindCallback) {
    global FunctionRegistry

    ; Available categories
    categories := ["All", "UI Elements", "Bank", "Inventory", "Skills", "Mouse", "Pixel", "UI/Utility"]
    currentCategoryIndex := 1

    ; Store current matches for reference
    currentMatches := GetFunctionsByCategory(categories[currentCategoryIndex])

    selectorGui := Gui("+AlwaysOnTop", "Select Function to Bind")
    selectorGui.SetFont("s10", "Segoe UI")

    ; Tab indicator
    selectorGui.Add("Text", "x10 y10", "Category (Tab/Shift+Tab to switch):")
    categoryLabel := selectorGui.Add("Text", "x10 y30 w400 cBlue", "[ " categories[currentCategoryIndex] " ]")

    ; Search box
    selectorGui.Add("Text", "x10 y55", "Search:")
    searchBox := selectorGui.Add("Edit", "x10 y75 w400")

    ; Function list
    functionList := selectorGui.Add("ListBox", "x10 y105 w400 h250", currentMatches)

    ; Description box
    selectorGui.Add("Text", "x10 y365", "Description:")
    descBox := selectorGui.Add("Text", "x10 y385 w400 h50 Border", "")

    ; Buttons
    btnBind := selectorGui.Add("Button", "x10 y445 w190 Default", "Bind")
    btnCancel := selectorGui.Add("Button", "x220 y445 w190", "Cancel")

    ; Update description when selection changes
    functionList.OnEvent("Change", (*) => UpdateDescription())

    ; Enable double-click or Enter on the list to bind
    functionList.OnEvent("DoubleClick", (*) => BindSelectedFunction())

    UpdateDescription(*) {
        selectedIndex := functionList.Value
        if (selectedIndex > 0 && selectedIndex <= currentMatches.Length) {
            selectedName := currentMatches[selectedIndex]
            if (FunctionRegistry.Has(selectedName)) {
                funcInfo := FunctionRegistry[selectedName]
                descBox.Text := funcInfo.description
            }
        }
    }

    ; Update the function list based on category and search
    RefreshList(*) {
        query := searchBox.Value
        baseFunctions := GetFunctionsByCategory(categories[currentCategoryIndex])

        if (query = "") {
            currentMatches := baseFunctions
        } else {
            ; Filter with fuzzy search
            currentMatches := []
            queryLower := StrLower(query)

            ; Exact matches first
            for name in baseFunctions {
                if (StrLower(name) = queryLower) {
                    currentMatches.Push(name)
                }
            }

            ; Starts with
            for name in baseFunctions {
                if (InStr(StrLower(name), queryLower) = 1 && !HasValue(currentMatches, name)) {
                    currentMatches.Push(name)
                }
            }

            ; Contains
            for name in baseFunctions {
                if (InStr(StrLower(name), queryLower) && !HasValue(currentMatches, name)) {
                    currentMatches.Push(name)
                }
            }
        }

        ; Clear and repopulate list
        functionList.Delete()
        for match in currentMatches {
            functionList.Add([match])
        }

        ; Select first item
        if (currentMatches.Length > 0) {
            functionList.Choose(1)
            UpdateDescription()
        } else {
            descBox.Text := ""
        }
    }

    ; Filter list as user types
    searchBox.OnEvent("Change", (*) => RefreshList())

    ; Switch category
    SwitchCategory(direction) {
        currentCategoryIndex := currentCategoryIndex + direction

        ; Wrap around
        if (currentCategoryIndex < 1) {
            currentCategoryIndex := categories.Length
        } else if (currentCategoryIndex > categories.Length) {
            currentCategoryIndex := 1
        }

        ; Update label
        categoryLabel.Text := "[ " categories[currentCategoryIndex] " ]"

        ; Clear search and refresh list
        searchBox.Value := ""
        RefreshList()
    }

    ; Add arrow key navigation from search box
    selectorGui.OnEvent("Close", (*) => selectorGui.Destroy())

    ; Hotkey handlers for navigation
    HotIfWinActive("ahk_id " selectorGui.Hwnd)
    Hotkey("Down", (*) => NavigateList(1), "On")
    Hotkey("Up", (*) => NavigateList(-1), "On")
    Hotkey("Enter", (*) => BindSelectedFunction(), "On")
    Hotkey("Tab", (*) => SwitchCategory(1), "On")
    Hotkey("+Tab", (*) => SwitchCategory(-1), "On")
    HotIfWinActive()

    NavigateList(direction) {
        selectedIndex := functionList.Value
        newIndex := selectedIndex + direction

        ; Wrap around
        if (newIndex < 1) {
            newIndex := currentMatches.Length
        } else if (newIndex > currentMatches.Length) {
            newIndex := 1
        }

        if (currentMatches.Length > 0) {
            functionList.Choose(newIndex)
            UpdateDescription()
        }
    }

    ; Bind button handler
    btnBind.OnEvent("Click", (*) => BindSelectedFunction())

    BindSelectedFunction(*) {
        selectedIndex := functionList.Value
        if (selectedIndex > 0 && selectedIndex <= currentMatches.Length) {
            selectedName := currentMatches[selectedIndex]
            CleanupAndDestroy()

            ; Check for special selectors that need grid picker
            if (selectedName = "[Select Bank Slot...]") {
                ShowSlotGridPicker("bank", keyToBindCallback)
            } else if (selectedName = "[Select Inventory Slot...]") {
                ShowSlotGridPicker("inventory", keyToBindCallback)
            } else if (selectedName = "[Select Drop Slot...]") {
                ShowSlotGridPicker("drop", keyToBindCallback)
            } else {
                keyToBindCallback(selectedName)
            }
        }
    }

    ; Cancel button handler
    btnCancel.OnEvent("Click", (*) => CleanupAndDestroy())

    ; Escape key handler
    selectorGui.OnEvent("Escape", (*) => CleanupAndDestroy())

    ; Cleanup function to disable hotkeys and destroy GUI
    CleanupAndDestroy() {
        HotIfWinActive("ahk_id " selectorGui.Hwnd)
        Hotkey("Down", "Off")
        Hotkey("Up", "Off")
        Hotkey("Enter", "Off")
        Hotkey("Tab", "Off")
        Hotkey("+Tab", "Off")
        HotIfWinActive()
        selectorGui.Destroy()
    }

    ; Show first description
    if (currentMatches.Length > 0) {
        functionList.Choose(1)
        UpdateDescription()
    }

    selectorGui.Show()
}

; Enter binding mode - select function then wait for key press
EnterBindingMode() {
    ToolTip "Select a function to bind..."
    SetTimer () => ToolTip(), -2000

    ; Show function selector GUI
    ShowFunctionSelector((selectedFunction) => WaitForKeyPress(selectedFunction))
}

; Wait for user to press a numpad key to bind the function to
WaitForKeyPress(functionName) {
    global CurrentProfile, IsBindingMode, BindingFunctionName

    ; Enter binding mode
    IsBindingMode := true
    BindingFunctionName := functionName

    ToolTip "Press a numpad key (with optional Shift) to bind '" functionName "' to..."

    ; Timeout after 10 seconds
    SetTimer(() => CancelBinding(), -10000)
}

; Called when a bindable key is pressed during binding mode
HandleBindingKeyPress(pressedKey) {
    global CurrentProfile, IsBindingMode, BindingFunctionName

    if (!IsBindingMode) {
        return false  ; Not in binding mode, don't handle
    }

    ; Exit binding mode immediately
    IsBindingMode := false
    funcName := BindingFunctionName
    BindingFunctionName := ""

    ; Check if key already has binding
    existingFunc := GetBoundFunction(pressedKey)
    if (existingFunc != "") {
        ; Confirm overwrite
        result := MsgBox(
            "Key '" pressedKey "' is already bound to '" existingFunc "'`n`nOverwrite with '" funcName "'?",
            "Confirm Overwrite",
            "YesNo Icon?"
        )

        if (result = "No") {
            ToolTip "Binding cancelled"
            SetTimer () => ToolTip(), -1000
            return true
        }
    }

    ; Bind the function
    if (BindFunctionToKey(pressedKey, funcName)) {
        ToolTip "Bound '" funcName "' to " pressedKey " in profile '" CurrentProfile "'"
        SetTimer () => ToolTip(), -3000
    }

    return true  ; Handled in binding mode
}

; Cancel handler
CancelBinding() {
    global IsBindingMode, BindingFunctionName

    if (!IsBindingMode) {
        return
    }

    IsBindingMode := false
    BindingFunctionName := ""

    ToolTip "Binding cancelled (timeout)"
    SetTimer () => ToolTip(), -1000
}

; ======================================
; GRID SLOT PICKER
; Shows a visual grid for selecting bank/inventory slots
; ======================================

ShowSlotGridPicker(slotType, keyToBindCallback) {
    ; Determine grid dimensions based on type and mode
    if (slotType = "bank") {
        cols := 8
        if (IsFixedMode()) {
            rows := 6
            maxSlots := 48
        } else {
            rows := 11
            maxSlots := 88
        }
        title := "Select Bank Slot"
        funcPrefix := "ClickBankSlot"
    } else if (slotType = "inventory") {
        cols := 4
        rows := 7
        maxSlots := 28
        title := "Select Inventory Slot"
        funcPrefix := "ClickInvSlot"
    } else if (slotType = "drop") {
        cols := 4
        rows := 7
        maxSlots := 28
        title := "Select Drop Slot"
        funcPrefix := "DropInvSlot"
    } else {
        return  ; Unknown type
    }

    ; Current selection
    currentSlot := 1

    ; Cell size for display
    cellWidth := 45
    cellHeight := 30
    padding := 5

    ; Calculate window size
    gridWidth := cols * cellWidth + padding * 2
    gridHeight := rows * cellHeight + padding * 2 + 60  ; Extra for title and instructions

    gridGui := Gui("+AlwaysOnTop", title)
    gridGui.SetFont("s10", "Segoe UI")

    ; Instructions
    gridGui.Add("Text", "x" padding " y" padding " w" (gridWidth - padding * 2), "Arrow keys to navigate, Enter to select, Esc to cancel")

    ; Create grid of text controls
    slotControls := Map()

    Loop rows {
        row := A_Index
        Loop cols {
            col := A_Index
            slotNum := (row - 1) * cols + col

            if (slotNum > maxSlots) {
                break
            }

            x := padding + (col - 1) * cellWidth
            y := 30 + padding + (row - 1) * cellHeight

            ; Create slot display
            ctrl := gridGui.Add("Text", "x" x " y" y " w" (cellWidth - 2) " h" (cellHeight - 2) " Center Border", slotNum)
            slotControls[slotNum] := ctrl
        }
    }

    ; Update visual selection
    UpdateSelection() {
        for num, ctrl in slotControls {
            if (num = currentSlot) {
                ctrl.Opt("Background0078D7")  ; Blue highlight
                ctrl.SetFont("cWhite Bold")
            } else {
                ctrl.Opt("BackgroundDefault")
                ctrl.SetFont("cBlack Norm")
            }
        }
    }

    ; Initial selection
    UpdateSelection()

    ; Navigation
    NavigateGrid(dx, dy) {
        currentCol := Mod(currentSlot - 1, cols) + 1
        currentRow := Floor((currentSlot - 1) / cols) + 1

        newCol := currentCol + dx
        newRow := currentRow + dy

        ; Wrap horizontally
        if (newCol < 1) {
            newCol := cols
        } else if (newCol > cols) {
            newCol := 1
        }

        ; Wrap vertically
        if (newRow < 1) {
            newRow := rows
        } else if (newRow > rows) {
            newRow := 1
        }

        newSlot := (newRow - 1) * cols + newCol

        ; Ensure slot is valid
        if (newSlot >= 1 && newSlot <= maxSlots) {
            currentSlot := newSlot
            UpdateSelection()
        }
    }

    ; Confirm selection
    ConfirmSelection() {
        selectedFunc := funcPrefix currentSlot
        CleanupGridAndDestroy()
        keyToBindCallback(selectedFunc)
    }

    ; Hotkey handlers
    HotIfWinActive("ahk_id " gridGui.Hwnd)
    Hotkey("Left", (*) => NavigateGrid(-1, 0), "On")
    Hotkey("Right", (*) => NavigateGrid(1, 0), "On")
    Hotkey("Up", (*) => NavigateGrid(0, -1), "On")
    Hotkey("Down", (*) => NavigateGrid(0, 1), "On")
    Hotkey("Enter", (*) => ConfirmSelection(), "On")
    HotIfWinActive()

    ; Escape handler
    gridGui.OnEvent("Escape", (*) => CleanupGridAndDestroy())
    gridGui.OnEvent("Close", (*) => CleanupGridAndDestroy())

    ; Cleanup function
    CleanupGridAndDestroy() {
        HotIfWinActive("ahk_id " gridGui.Hwnd)
        Hotkey("Left", "Off")
        Hotkey("Right", "Off")
        Hotkey("Up", "Off")
        Hotkey("Down", "Off")
        Hotkey("Enter", "Off")
        HotIfWinActive()
        gridGui.Destroy()
    }

    gridGui.Show("w" gridWidth " h" gridHeight)
}
