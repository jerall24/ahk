#Requires AutoHotkey v2.0

; ======================================
; FUNCTION REGISTRY
; Merges all individual registries into a single global registry
; Note: All function files are included from main.ahk before this file
; ======================================

; Global function registry - will be populated by merging all individual registries
global FunctionRegistry := Map()

; Merge all registries into the main FunctionRegistry
MergeRegistries() {
    global FunctionRegistry
    global MouseMovementRegistry, PixelFunctionsRegistry, InventoryFunctionsRegistry
    global BankFunctionsRegistry, UIFunctionsRegistry, UtilityFunctionsRegistry
    global UIElementFunctionsRegistry, BankSlotFunctionsRegistry, InventorySlotFunctionsRegistry
    global DropSlotFunctionsRegistry
    global HerbloreRegistry, ConstructionRegistry, SailingRegistry, CookingRegistry

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
        InventorySlotFunctionsRegistry,
        DropSlotFunctionsRegistry
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
