Gui, Add, Edit, vMyEdit w200 Center, 1234567890
Gui, Add, Edit, vMyEdit2 w200 Center, abcdef
Gui, Show,, My GUI #1
return

F1::
Random, col, 111111, 999999
Gui, Color,, %col%
return

F2::
Random, col2, 111111, 999999
Gui, Font, c%col2%
GuiControl, Font, MyEdit
return

ESC::
GuiClose:
ExitApp