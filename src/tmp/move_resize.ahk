#NoTrayIcon
#SingleInstance,force

; initial sizes
_edW := 400

;Gui, TreeBox: New,, TreeBox
Gui, +Resize +MinSize +HwndhWndGui

Gui, Add, Text, w40       vLAB_LNK, test1:
Gui, Add, Text,           vLAB_SRC, test2:
Gui, Add, Edit, ys w%_edW% vEDIT_LNK ;, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\link3.txt
Gui, Add, Edit,    w%_edW% vEDIT_SRC ;, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\target.txt

Gui, Add, Radio, xp y+m, test1
Gui, Add, Radio, xp x+m, test2
Gui, Add, Radio, xp x+m, test3
Gui, Add, Radio, xp x+m, test4

Gui, Add, Button, xp x+m w100 h30 hwndhWnd_BTN_OK vBTN_OK , OK
Gui, Add, Button, xp x+m w100 h30 hwndhWnd_BTN_CL vBTN_CL Default , Close

Gui, Show,, Symlink Creator v0

; get initial button positions
ControlGetPos, _btnOkX,,,,, ahk_id %hWnd_BTN_OK%
ControlGetPos, _btnClX,,,,, ahk_id %hWnd_BTN_CL%

return

GuiSize:
if (!initGuiW) {
	initGuiW := A_GuiWidth
	initGuiH := A_GuiHeight
	Gui, % "+MaxSizex" A_GuiHeight ; block Gui height
}
offX := A_GuiWidth - initGuiW
;GuiControl,, EDIT_SRC , % "_btnOkX: " _btnOkX ", hWnd_BTN_OK: " hWnd_BTN_OK
;GuiControl,, EDIT_SRC , % "hWndGui: " hWndGui ", _guiW: " _guiW ",  _guiH: " _guiH ", initGuiW: " initGuiW ",  initGuiH: " initGuiH ",  A_GuiWidth: " A_GuiWidth ",  A_GuiHeight: " A_GuiHeight
;GuiControl,, hWnd , % "A_GuiWidth: " A_GuiWidth ",  A_GuiHeight: " A_GuiHeight
GuiControl, Move, EDIT_SRC, % "w" offX + _edW
GuiControl, Move, EDIT_LNK, % "w" offX + _edW
GuiControl, movedraw, BTN_OK, % "x" offX + _btnOkX ; auto redraw
GuiControl, movedraw, BTN_CL, % "x" offX + _btnClX ; auto redraw
return


GuiClose:
GuiEscape:
ExitApp
