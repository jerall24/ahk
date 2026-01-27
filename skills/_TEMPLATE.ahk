#Requires AutoHotkey v2.0

; ======================================
; SKILL NAME FUNCTIONS
; Template for creating new skill function files
; ======================================

; Example function - replace with your actual skill functions
ExampleSkillFunction() {
    ToolTip "Example skill function called!"
    SetTimer () => ToolTip(), -1000
}

; Another example function
AnotherSkillFunction() {
    ToolTip "Another example!"
    SetTimer () => ToolTip(), -1000
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
; IMPORTANT: Replace "SkillName" with your actual skill name (e.g., Woodcutting, Mining, Fishing)
; The registry variable name should be: global <SkillName>Registry := Map(...)

global SkillNameRegistry := Map(
    "ExampleSkillFunction", {
        name: "ExampleSkillFunction",
        func: ExampleSkillFunction,
        description: "Example function description"
    },
    "AnotherSkillFunction", {
        name: "AnotherSkillFunction",
        func: AnotherSkillFunction,
        description: "Another example function"
    }
)

; ======================================
; HOW TO ADD THIS FILE TO THE REGISTRY:
; ======================================
; 1. Save this file in the skills/ folder (e.g., skills/woodcutting.ahk)
; 2. Open main.ahk
; 3. Add this line in the Skills section:
;    #Include skills\woodcutting.ahk
; 4. Open core/function_registry.ahk
; 5. Add your registry variable to the skillRegistries array:
;    skillRegistries := [
;        WoodcuttingRegistry,
;    ]
; 6. Reload the script and your functions will be available!
