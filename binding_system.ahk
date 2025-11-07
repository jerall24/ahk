#Requires AutoHotkey v2.0

; ======================================
; BINDING SYSTEM
; Handles dynamic keybinding with fuzzy search GUI
; ======================================

; Global flag to indicate we're in binding mode
global IsBindingMode := false
global BindingFunctionName := ""

; Show function selection GUI with fuzzy search
ShowFunctionSelector(keyToBindCallback) {
    global FunctionRegistry

    ; Store current matches for reference
    currentMatches := GetFunctionNames()

    selectorGui := Gui("+AlwaysOnTop", "Select Function to Bind")
    selectorGui.SetFont("s10", "Segoe UI")

    ; Search box
    selectorGui.Add("Text", "x10 y10", "Search:")
    searchBox := selectorGui.Add("Edit", "x10 y30 w400")

    ; Function list
    functionList := selectorGui.Add("ListBox", "x10 y60 w400 h300", currentMatches)

    ; Description box
    selectorGui.Add("Text", "x10 y370", "Description:")
    descBox := selectorGui.Add("Text", "x10 y390 w400 h60 Border", "")

    ; Buttons
    btnBind := selectorGui.Add("Button", "x10 y460 w190 Default", "Bind")
    btnCancel := selectorGui.Add("Button", "x220 y460 w190", "Cancel")

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

    ; Filter list as user types
    searchBox.OnEvent("Change", (*) => FilterList())

    FilterList(*) {
        query := searchBox.Value
        matches := FuzzySearchFunctions(query)
        currentMatches := matches

        ; Clear and repopulate list
        functionList.Delete()
        for match in matches {
            functionList.Add([match])
        }

        ; Select first item
        if (matches.Length > 0) {
            functionList.Choose(1)
            UpdateDescription()
        } else {
            descBox.Text := ""
        }
    }

    ; Bind button handler
    btnBind.OnEvent("Click", (*) => BindSelectedFunction())

    BindSelectedFunction(*) {
        selectedIndex := functionList.Value
        if (selectedIndex > 0 && selectedIndex <= currentMatches.Length) {
            selectedName := currentMatches[selectedIndex]
            selectorGui.Destroy()
            keyToBindCallback(selectedName)
        }
    }

    ; Cancel button handler
    btnCancel.OnEvent("Click", (*) => selectorGui.Destroy())

    ; Escape key handler
    selectorGui.OnEvent("Escape", (*) => selectorGui.Destroy())

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

    ToolTip "Press a numpad key to bind '" functionName "' to..."

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
