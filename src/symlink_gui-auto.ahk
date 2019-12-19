#NoTrayIcon
#SingleInstance

Gui +Resize +MaximizeBox +MinSize590x200

Gui, Add, Text, x12 y15 w40 h20 vLAB_LNK, Link:
Gui, Add, Text, x12 y45 w40 h20 vLAB_SRC, Source:
Gui, Add, Edit, x52 y13 w490 h20 vEDIT_LNK gonChange_EDIT_LNK
Gui, Add, Edit, x52 y43 w490 h20 vEDIT_SRC gonChange_EDIT_SRC
Gui, Add, Button, x362 y163 w100 h30 vBTN_OK, &OK

;WinSet, AlwaysOnTop, On
Gui, Show, w590 h235, Symlink Test

;SetWorkArea(200,100,1000,600) 
SetWorkArea(0,0,2000,2000) 
return

onChange_EDIT_LNK:
;Gui, Submit, NoHide
;GuiControl +cDefault +Redraw, EDIT_SRC
;MsgBox % "gMyEdit changed A_GuiControl: " . A_GuiControl . ",  A_GuiControl(extract): " . %A_GuiControl%
return

onChange_EDIT_SRC:
Gui, Submit, NoHide
MsgBox %EDIT_LNK% == %EDIT_SRC%
apply_control("EDIT_SRC", EDIT_LNK == EDIT_SRC ? "+cRed" : "+cDefault")
return

ButtonOK:
WinGetPos, X, Y, Width, Height, A  ; "A" to get the active window's pos.
MsgBox, The active window is at %X%`,%Y%. Dimensions: %Width% x %Height%
return

apply_control(el, set) {
MsgBox el: %el% set: %set% 
GuiControl %set% +Redraw, %el%
}


      ; maximized windows not to cover (not on-top, right edge) taskbar



SetWorkArea(left,top,right,bottom) { ; set main monitor work area; windows are not resized!

   VarSetCapacity(area,16)

   NumPut(left,  area, 0) ; left

   NumPut(top,   area, 4) ; top

   NumPut(right, area, 8) ; right

   NumPut(bottom,area,12) ; bottom

   DllCall("SystemParametersInfo", UInt,0x2F, UInt,0, UInt,&area, UInt,0) ; SPI_SETWORKAREA

}