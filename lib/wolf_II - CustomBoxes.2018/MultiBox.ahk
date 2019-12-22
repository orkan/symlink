﻿


;-------------------------------------------------------------------------------
MultiBox(Title := "", Prompt := "", Default := "") {
;-------------------------------------------------------------------------------
    ; show a multi-line input box
    ; return the entered text
    ;---------------------------------------------------------------------------
    ; Title is the title for the GUI
    ; Prompt is the text to display
    ; Default is shown in the edit control

    static Result ; used as a GUI control variable

    ; create GUI
    Gui, MultiBox: New,, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text,, %Prompt%
    Gui, Add, Edit, w640 r10 vResult, %Default%
    Gui, Add, Button, w80 Default, &OK
    Gui, Add, Button, x+m wp, &Cancel
    Gui, Show

    ; main wait loop
    Gui, +LastFound
    SendMessage, 0xB1, -1,, Edit1 ; EM_SETSEL
    WinWaitClose

return Result


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    MultiBoxButtonOK: ; "OK" button, {Enter} pressed
        Gui, Submit ; get Result from GUI
        Gui, Destroy
    return

    MultiBoxButtonCancel: ; "Cancel" button
    MultiBoxGuiClose:     ; {Alt+F4} pressed, [X] clicked
    MultiBoxGuiEscape:    ; {Esc} pressed
        Result := "MultiBox_Cancel"
        Gui, Destroy
    return
}
