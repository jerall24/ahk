#Requires AutoHotkey v2.0

; ======================================
; FUNCTION REGISTRY
; Dynamically imports all function files and merges their registries
; ======================================

; Import all core function files from functions/ folder
#Include functions\mouse_movement.ahk
#Include functions\pixel_functions.ahk
#Include functions\inventory_functions.ahk
#Include functions\bank_functions.ahk
#Include functions\ui_functions.ahk
#Include functions\utility_functions.ahk
#Include functions\ui_element_functions.ahk

; ======================================
; SKILLS INCLUDES
; To add a new skill file:
; 1. Create your .ahk file in functions/skills/ (e.g., woodcutting.ahk)
; 2. In that file, create a global registry: global WoodcuttingRegistry := Map(...)
; 3. Add #Include line below
; 4. Add the registry variable name to skillRegistries array below
; ======================================

; Add your skill files here as you create them:
#Include functions\skills\herblore.ahk
#Include functions\skills\construction.ahk
#Include functions\skills\sailing.ahk
#Include functions\skills\cooking.ahk
; #Include functions\skills\woodcutting.ahk
; #Include functions\skills\mining.ahk
; #Include functions\skills\fishing.ahk

; Global function registry - will be populated by merging all individual registries
global FunctionRegistry := Map()

; Merge all registries into the main FunctionRegistry
MergeRegistries() {
    global FunctionRegistry

    ; Core function registries (always included)
    registriesToMerge := [
        MouseMovementRegistry,
        PixelFunctionsRegistry,
        InventoryFunctionsRegistry,
        BankFunctionsRegistry,
        UIFunctionsRegistry,
        UtilityFunctionsRegistry,
        UIElementFunctionsRegistry,
        BankSlotFunctionsRegistry,
        InventorySlotFunctionsRegistry
    ]

    ; Add your skill registries here (must match the variable names from your skill files)
    skillRegistries := [
        HerbloreRegistry,
        ConstructionRegistry,
        SailingRegistry,
        CookingRegistry,
        ; Add more as you create them:
        ; WoodcuttingRegistry,
        ; MiningRegistry,
        ; FishingRegistry,
    ]

    ; Add skill registries to the merge list if they exist
    for registry in skillRegistries {
        registriesToMerge.Push(registry)
    }

    ; Merge all registries into the main FunctionRegistry
    for registry in registriesToMerge {
        for funcName, funcInfo in registry {
            FunctionRegistry[funcName] := funcInfo
        }
    }
}

; Initialize the registry by merging all sub-registries
MergeRegistries()

; Get list of all function names for fuzzy search
GetFunctionNames() {
    names := []
    for name in FunctionRegistry {
        names.Push(name)
    }
    return names
}

; Fuzzy search function names
FuzzySearchFunctions(query) {
    if (query = "") {
        return GetFunctionNames()
    }

    matches := []
    query := StrLower(query)

    ; First pass: exact matches
    for name in FunctionRegistry {
        if (StrLower(name) = query) {
            matches.Push(name)
        }
    }

    ; Second pass: starts with query
    for name in FunctionRegistry {
        if (InStr(StrLower(name), query) = 1 && !HasValue(matches, name)) {
            matches.Push(name)
        }
    }

    ; Third pass: contains query
    for name in FunctionRegistry {
        if (InStr(StrLower(name), query) && !HasValue(matches, name)) {
            matches.Push(name)
        }
    }

    return matches
}

; Helper function to check if array has value
HasValue(arr, value) {
    for item in arr {
        if (item = value) {
            return true
        }
    }
    return false
}
