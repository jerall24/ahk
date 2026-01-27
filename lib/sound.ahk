#Requires AutoHotkey v2.0

; ======================================
; SOUND FUNCTIONS
; ======================================

; Play completion sound - double beep
PlayCompletionSound() {
    SoundBeep(1000, 200)  ; First beep: 1000 Hz, 200ms
    Sleep(100)
    SoundBeep(1200, 200)  ; Second beep: 1200 Hz, 200ms
}

; Play error sound - low beep
PlayErrorSound() {
    SoundBeep(400, 500)  ; Low frequency, longer duration
}
