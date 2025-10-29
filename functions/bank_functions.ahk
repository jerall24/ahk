#Requires AutoHotkey v2.0

; ======================================
; BANK FUNCTIONS
; ======================================

; Click deposit inventory button, then captured bank slot 1, then slot 2, then press escape
; Uses globally captured slots from Ctrl+Numpad0
DepositAndWithdrawFromBank() {
    global capturedBankSlot1, capturedBankSlot2

    ; Check if slots have been captured
    if (capturedBankSlot1 = 0 || capturedBankSlot2 = 0) {
        ToolTip "No bank slots captured! Use Ctrl+Numpad0 first."
        SetTimer () => ToolTip(), -2000
        return
    }

    ; Click deposit inventory button first
    ClickUIElement("bank_deposit_inventory")
    Sleep(Random(100, 200))

    ; Click first captured bank slot
    ClickBankSlot(capturedBankSlot1)
    Sleep(Random(100, 200))

    ; Click second captured bank slot
    ClickBankSlot(capturedBankSlot2)
    Sleep(Random(750, 1000))

    Send("{Escape}")
}

; ======================================
; FUNCTION REGISTRY FOR THIS FILE
; ======================================
global BankFunctionsRegistry := Map(
    "DepositAndWithdrawFromBank", {
        name: "DepositAndWithdrawFromBank",
        func: DepositAndWithdrawFromBank,
        description: "Deposit inventory, click bank slots 1 & 2, then escape"
    }
)
