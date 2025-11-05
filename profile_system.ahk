#Requires AutoHotkey v2.0

; ======================================
; PROFILE SYSTEM
; Manages dynamic keybinding profiles with persistent storage
; ======================================

; Global profile storage
global CurrentProfile := "Default"
global Profiles := Map()
global ProfileSlots := Map()  ; Stores slots per profile
global ProfilesFilePath := A_ScriptDir "\profiles.json"

; Save profiles to JSON file
SaveProfiles() {
    global Profiles, CurrentProfile, ProfilesFilePath, ProfileSlots
    global capturedBankSlot1, capturedBankSlot2, capturedBankSlot3, capturedBankSlot4
    global capturedInventorySlot1, capturedInventorySlot2
    global capturedConstructionBankSlot

    ; Store current profile's slots before saving
    ProfileSlots[CurrentProfile] := Map(
        "bankSlot1", capturedBankSlot1,
        "bankSlot2", capturedBankSlot2,
        "bankSlot3", capturedBankSlot3,
        "bankSlot4", capturedBankSlot4,
        "inventorySlot1", capturedInventorySlot1,
        "inventorySlot2", capturedInventorySlot2,
        "constructionBankSlot", capturedConstructionBankSlot
    )

    ; Convert Profiles Map to JSON-compatible object
    profilesObj := Map()
    profilesObj["currentProfile"] := CurrentProfile
    profilesObj["profiles"] := Map()

    for profileName, bindings in Profiles {
        profileData := Map()

        ; Save bindings
        bindingsObj := Map()
        for keyName, funcName in bindings {
            bindingsObj[keyName] := funcName
        }
        profileData["bindings"] := bindingsObj

        ; Save slots for this profile
        if (ProfileSlots.Has(profileName)) {
            profileData["slots"] := ProfileSlots[profileName]
        }

        profilesObj["profiles"][profileName] := profileData
    }

    ; Serialize to JSON
    jsonStr := SerializeToJSON(profilesObj)

    try {
        ; Write to file
        FileDelete(ProfilesFilePath)
    }
    FileAppend(jsonStr, ProfilesFilePath, "UTF-8")
}

; Load profiles from JSON file
LoadProfiles() {
    global Profiles, CurrentProfile, ProfilesFilePath, ProfileSlots
    global capturedBankSlot1, capturedBankSlot2, capturedBankSlot3, capturedBankSlot4
    global capturedInventorySlot1, capturedInventorySlot2
    global capturedConstructionBankSlot

    if (!FileExist(ProfilesFilePath)) {
        return false
    }

    try {
        ; Read file
        jsonStr := FileRead(ProfilesFilePath, "UTF-8")

        ; Parse JSON
        profilesObj := DeserializeFromJSON(jsonStr)

        ; Restore current profile
        if (profilesObj.Has("currentProfile")) {
            CurrentProfile := profilesObj["currentProfile"]
        }

        ; Restore profiles
        if (profilesObj.Has("profiles")) {
            Profiles := Map()
            ProfileSlots := Map()

            for profileName, profileData in profilesObj["profiles"] {
                ; Handle old format (just bindings) or new format (object with bindings and slots)
                if (Type(profileData) = "Map" && profileData.Has("bindings")) {
                    ; New format
                    bindings := Map()
                    for keyName, funcName in profileData["bindings"] {
                        bindings[keyName] := funcName
                    }
                    Profiles[profileName] := bindings

                    ; Load slots for this profile
                    if (profileData.Has("slots")) {
                        ProfileSlots[profileName] := profileData["slots"]
                    }
                } else {
                    ; Old format - just bindings directly
                    bindings := Map()
                    for keyName, funcName in profileData {
                        bindings[keyName] := funcName
                    }
                    Profiles[profileName] := bindings
                }
            }
        }

        ; Load slots for current profile into global variables
        LoadCurrentProfileSlots()

        return true
    } catch as err {
        MsgBox("Error loading profiles: " err.Message, "Load Error")
        return false
    }
}

; Load the current profile's slots into global variables
LoadCurrentProfileSlots() {
    global CurrentProfile, ProfileSlots
    global capturedBankSlot1, capturedBankSlot2, capturedBankSlot3, capturedBankSlot4
    global capturedInventorySlot1, capturedInventorySlot2
    global capturedConstructionBankSlot

    if (ProfileSlots.Has(CurrentProfile)) {
        slots := ProfileSlots[CurrentProfile]
        capturedBankSlot1 := slots.Has("bankSlot1") ? Integer(slots["bankSlot1"]) : 0
        capturedBankSlot2 := slots.Has("bankSlot2") ? Integer(slots["bankSlot2"]) : 0
        capturedBankSlot3 := slots.Has("bankSlot3") ? Integer(slots["bankSlot3"]) : 0
        capturedBankSlot4 := slots.Has("bankSlot4") ? Integer(slots["bankSlot4"]) : 0
        capturedInventorySlot1 := slots.Has("inventorySlot1") ? Integer(slots["inventorySlot1"]) : 0
        capturedInventorySlot2 := slots.Has("inventorySlot2") ? Integer(slots["inventorySlot2"]) : 0
        capturedConstructionBankSlot := slots.Has("constructionBankSlot") ? Integer(slots["constructionBankSlot"]) : 0
    } else {
        ; No slots saved for this profile, reset to 0
        capturedBankSlot1 := 0
        capturedBankSlot2 := 0
        capturedBankSlot3 := 0
        capturedBankSlot4 := 0
        capturedInventorySlot1 := 0
        capturedInventorySlot2 := 0
        capturedConstructionBankSlot := 0
    }
}

; Simple JSON serialization for Map objects
SerializeToJSON(obj, indent := 0) {
    indentStr := ""
    Loop indent {
        indentStr .= "  "
    }
    nextIndent := indentStr "  "

    if (Type(obj) = "Map") {
        if (obj.Count = 0) {
            return "{}"
        }

        result := "{`n"
        first := true
        for key, value in obj {
            if (!first) {
                result .= ",`n"
            }
            first := false
            result .= nextIndent '"' key '": ' SerializeToJSON(value, indent + 1)
        }
        result .= "`n" indentStr "}"
        return result
    } else if (Type(obj) = "String") {
        ; Escape special characters
        escaped := StrReplace(obj, "\", "\\")
        escaped := StrReplace(escaped, '"', '\"')
        escaped := StrReplace(escaped, "`n", "\n")
        escaped := StrReplace(escaped, "`r", "\r")
        escaped := StrReplace(escaped, "`t", "\t")
        return '"' escaped '"'
    } else {
        return '"' obj '"'
    }
}

; Simple JSON deserialization to Map objects
DeserializeFromJSON(jsonStr) {
    jsonStr := Trim(jsonStr)

    ; Remove whitespace for parsing
    pos := 1
    return ParseValue(&pos, jsonStr)
}

ParseValue(&pos, jsonStr) {
    ; Skip whitespace
    while (pos <= StrLen(jsonStr) && InStr(" `t`n`r", SubStr(jsonStr, pos, 1))) {
        pos++
    }

    if (pos > StrLen(jsonStr)) {
        return ""
    }

    char := SubStr(jsonStr, pos, 1)

    if (char = "{") {
        return ParseObject(&pos, jsonStr)
    } else if (char = '"') {
        return ParseString(&pos, jsonStr)
    }

    return ""
}

ParseObject(&pos, jsonStr) {
    obj := Map()
    pos++  ; Skip opening {

    ; Skip whitespace
    while (pos <= StrLen(jsonStr) && InStr(" `t`n`r", SubStr(jsonStr, pos, 1))) {
        pos++
    }

    ; Check for empty object
    if (SubStr(jsonStr, pos, 1) = "}") {
        pos++
        return obj
    }

    Loop {
        ; Skip whitespace
        while (pos <= StrLen(jsonStr) && InStr(" `t`n`r", SubStr(jsonStr, pos, 1))) {
            pos++
        }

        ; Parse key
        if (SubStr(jsonStr, pos, 1) != '"') {
            break
        }
        key := ParseString(&pos, jsonStr)

        ; Skip whitespace and colon
        while (pos <= StrLen(jsonStr) && InStr(" `t`n`r:", SubStr(jsonStr, pos, 1))) {
            pos++
        }

        ; Parse value
        value := ParseValue(&pos, jsonStr)
        obj[key] := value

        ; Skip whitespace
        while (pos <= StrLen(jsonStr) && InStr(" `t`n`r", SubStr(jsonStr, pos, 1))) {
            pos++
        }

        ; Check for comma or end
        char := SubStr(jsonStr, pos, 1)
        if (char = ",") {
            pos++
        } else if (char = "}") {
            pos++
            break
        } else {
            break
        }
    }

    return obj
}

ParseString(&pos, jsonStr) {
    pos++  ; Skip opening quote
    result := ""

    Loop {
        if (pos > StrLen(jsonStr)) {
            break
        }

        char := SubStr(jsonStr, pos, 1)

        if (char = '"') {
            pos++
            break
        } else if (char = "\") {
            pos++
            if (pos <= StrLen(jsonStr)) {
                nextChar := SubStr(jsonStr, pos, 1)
                if (nextChar = "n") {
                    result .= "`n"
                } else if (nextChar = "r") {
                    result .= "`r"
                } else if (nextChar = "t") {
                    result .= "`t"
                } else if (nextChar = "\") {
                    result .= "\"
                } else if (nextChar = '"') {
                    result .= '"'
                } else {
                    result .= nextChar
                }
                pos++
            }
        } else {
            result .= char
            pos++
        }
    }

    return result
}

; Initialize default profile (empty bindings)
InitializeProfiles() {
    global Profiles

    ; Try to load from file first
    if (LoadProfiles()) {
        ToolTip "Profiles loaded from file"
        SetTimer () => ToolTip(), -1000
        return
    }

    ; If no file exists, create default profile
    Profiles["Default"] := Map()
    SaveProfiles()

    ; Each profile is a Map of keyname -> function name
    ; Example: Profiles["Default"]["Numpad1"] := "ClickCyanCentroid"
}

; Get current profile's bindings
GetCurrentBindings() {
    global Profiles, CurrentProfile
    return Profiles[CurrentProfile]
}

; Bind a function to a key in the current profile
BindFunctionToKey(keyName, functionName) {
    global Profiles, CurrentProfile

    if (!FunctionRegistry.Has(functionName)) {
        ToolTip "Function '" functionName "' not found in registry!"
        SetTimer () => ToolTip(), -2000
        return false
    }

    Profiles[CurrentProfile][keyName] := functionName
    SaveProfiles()  ; Auto-save after binding
    return true
}

; Get function bound to a key in current profile
GetBoundFunction(keyName) {
    global Profiles, CurrentProfile
    bindings := Profiles[CurrentProfile]

    if (bindings.Has(keyName)) {
        return bindings[keyName]
    }
    return ""
}

; Execute function bound to a key
ExecuteBoundFunction(keyName) {
    functionName := GetBoundFunction(keyName)

    if (functionName = "") {
        ToolTip "No function bound to " keyName
        SetTimer () => ToolTip(), -1000
        return false
    }

    if (!FunctionRegistry.Has(functionName)) {
        ToolTip "Function '" functionName "' not found!"
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Show which function is being executed (debug)
    ToolTip "Executing: " functionName
    SetTimer () => ToolTip(), -1000

    ; Execute the function
    funcInfo := FunctionRegistry[functionName]
    funcInfo.func.Call()
    return true
}

; Create a new profile
CreateProfile(profileName) {
    global Profiles

    if (Profiles.Has(profileName)) {
        ToolTip "Profile '" profileName "' already exists!"
        SetTimer () => ToolTip(), -2000
        return false
    }

    Profiles[profileName] := Map()
    SaveProfiles()  ; Auto-save after creating
    ToolTip "Profile '" profileName "' created!"
    SetTimer () => ToolTip(), -2000
    return true
}

; Switch to a profile
SwitchProfile(profileName) {
    global Profiles, CurrentProfile

    if (!Profiles.Has(profileName)) {
        ToolTip "Profile '" profileName "' not found!"
        SetTimer () => ToolTip(), -2000
        return false
    }

    ; Save current profile's slots before switching
    SaveProfiles()

    ; Switch profile
    CurrentProfile := profileName

    ; Load new profile's slots
    LoadCurrentProfileSlots()

    ; Save again to update current profile
    SaveProfiles()

    ToolTip "Switched to profile: " profileName
    SetTimer () => ToolTip(), -2000
    return true
}

; Get list of all profile names
GetProfileNames() {
    global Profiles
    names := []
    for name in Profiles {
        names.Push(name)
    }
    return names
}

; Delete a profile (cannot delete Default or current profile)
DeleteProfile(profileName) {
    global Profiles, CurrentProfile

    if (profileName = "Default") {
        ToolTip "Cannot delete Default profile!"
        SetTimer () => ToolTip(), -2000
        return false
    }

    if (profileName = CurrentProfile) {
        ToolTip "Cannot delete current profile! Switch profiles first."
        SetTimer () => ToolTip(), -2000
        return false
    }

    if (!Profiles.Has(profileName)) {
        ToolTip "Profile '" profileName "' not found!"
        SetTimer () => ToolTip(), -2000
        return false
    }

    Profiles.Delete(profileName)
    SaveProfiles()  ; Auto-save after deleting
    ToolTip "Profile '" profileName "' deleted!"
    SetTimer () => ToolTip(), -2000
    return true
}

; Show profile management GUI
ShowProfileManager() {
    global Profiles, CurrentProfile

    profileGui := Gui("+AlwaysOnTop", "Profile Manager")
    profileGui.SetFont("s10", "Segoe UI")

    ; Current profile display
    profileGui.Add("Text", "x10 y10", "Current Profile:")
    profileGui.Add("Text", "x120 y10 w200 cBlue", CurrentProfile)

    ; Profile list
    profileGui.Add("Text", "x10 y40", "Available Profiles:")
    profileNames := GetProfileNames()
    profileList := profileGui.Add("ListBox", "x10 y60 w300 h150", profileNames)

    ; Select current profile in list
    for index, name in profileNames {
        if (name = CurrentProfile) {
            profileList.Choose(index)
            break
        }
    }

    ; Buttons
    btnSwitch := profileGui.Add("Button", "x10 y220 w90", "Switch")
    btnNew := profileGui.Add("Button", "x110 y220 w90", "New")
    btnDelete := profileGui.Add("Button", "x210 y220 w90", "Delete")
    btnClose := profileGui.Add("Button", "x10 y250 w290", "Close")

    ; Button handlers
    btnSwitch.OnEvent("Click", (*) => SwitchSelectedProfile())
    btnNew.OnEvent("Click", (*) => CreateNewProfile())
    btnDelete.OnEvent("Click", (*) => DeleteSelectedProfile())
    btnClose.OnEvent("Click", (*) => profileGui.Destroy())

    SwitchSelectedProfile(*) {
        selectedIndex := profileList.Value
        if (selectedIndex > 0 && selectedIndex <= profileNames.Length) {
            SwitchProfile(profileNames[selectedIndex])
            profileGui.Destroy()
        }
    }

    CreateNewProfile(*) {
        ; Hide the profile manager temporarily so input box appears in front
        profileGui.Hide()
        newName := InputBox("Enter new profile name:", "Create Profile", "w250 h100")

        if (newName.Result = "OK" && newName.Value != "") {
            if (CreateProfile(newName.Value)) {
                profileGui.Destroy()
                ShowProfileManager()  ; Refresh the GUI
            } else {
                profileGui.Show()  ; Show again if creation failed
            }
        } else {
            profileGui.Show()  ; Show again if cancelled
        }
    }

    DeleteSelectedProfile(*) {
        selectedIndex := profileList.Value
        if (selectedIndex > 0 && selectedIndex <= profileNames.Length) {
            selectedProfile := profileNames[selectedIndex]
            result := MsgBox("Delete profile '" selectedProfile "'?", "Confirm Delete", "YesNo Icon?")
            if (result = "Yes") {
                if (DeleteProfile(selectedProfile)) {
                    profileGui.Destroy()
                    ShowProfileManager()  ; Refresh the GUI
                }
            }
        }
    }

    profileGui.Show()
}

; Initialize profiles on script start
InitializeProfiles()
