﻿


;-------------------------------------------------------------------------------
BetterBox(Title := "", Prompt := "", Default := "", Pos := -1) {
;-------------------------------------------------------------------------------
    ; custom input box allows to choose the position of the text insertion point
    ; return the entered text
    ;---------------------------------------------------------------------------
    ; Title is the title for the GUI
    ; Prompt is the text to display
    ; Default is the text initially shown in the edit control
    ; Pos is the position of the text insertion point
    ;   Pos =  0  => at the start of the string
    ;   Pos =  1  => after the first character of the string
    ;   Pos = -1  => at the end of the string

    static Result ; used as a GUI control variable

    ; create GUI
    Gui, BetterBox: New,, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text,, %Prompt%
    Gui, Add, Edit, w290 vResult, %Default%
    Gui, Add, Button, x80 w80 Default, &OK
    Gui, Add, Button, x+m wp, &Cancel
    Gui, Show

    ; main wait loop
    Gui, +LastFound
    SendMessage, 0xB1, %Pos%, %Pos%, Edit1 ; EM_SETSEL
    WinWaitClose

return Result


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    BetterBoxButtonOK: ; "OK" button
        Gui, Submit ; get Result from GUI
        Gui, Destroy
    return

    BetterBoxButtonCancel: ; "Cancel" button
    BetterBoxGuiClose:     ; {Alt+F4} pressed, [X] clicked
    BetterBoxGuiEscape:    ; {Esc} pressed
        Result := "BetterBox_Cancel"
        Gui, Destroy
    return
}
