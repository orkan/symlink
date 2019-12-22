#NoTrayIcon
#SingleInstance, Force
#Include symlink.inc.ahk

Gui +Resize +MaximizeBox +MinSize590x200

Gui, Add, Text, x12 y15 w40 h20 vLAB_LNK, Link:
Gui, Add, Text, x12 y45 w40 h20 vLAB_SRC, Source:
Gui, Add, Edit, x52 y13 w490 h20 vEDIT_LNK gonChange_EDIT_LNK, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\link.txt
Gui, Add, Edit, x52 y43 w490 h20 vEDIT_SRC gonChange_EDIT_SRC, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\target.txt
Gui, Add, Button, x362 y163 w100 h30 vBTN_OK, &OK
;WinSet, AlwaysOnTop, On

ini_name := RegExReplace(A_ScriptName, "[^\.]+$") . "ini"
ini := ReadINI(ini_name)
Gui, Show

;Gui, Show, % "x" . ini["wnd_position"].appX . "y" . ini["wnd_position"].appY . "w" . ini["wnd_position"].appW . "h" . ini["wnd_position"].appH, Symlink Test
WinMove, A,, ini["wnd_position"].appX, ini["wnd_position"].appY, ini["wnd_position"].appW, ini["wnd_position"].appH

Gui, Submit, NoHide
return

;~ domyslne
;~ appH=235
;~ appW=606
;~ appX=676
;~ appY=403


onChange_EDIT_LNK:
onChange_EDIT_SRC:
return

ButtonOK:
global EDIT_LNK, EDIT_SRC, EDIT_CMD
Gui, +OwnDialogs
Gui, Submit, NoHide

ini := ReadINI(ini_name)

WinMove, A,, ini["wnd_position"].appX, ini["wnd_position"].appY, ini["wnd_position"].appW, ini["wnd_position"].appH

;~ MsgBox % "Always on top: " . ini["wnd_state"].alwaysontop
;~ MsgBox % "appX: " . ini["wnd_position"].appX
return


GuiEscape:
ButtonClose:
GuiClose:
global ini_name

WinGetPos appX, appY, appW, appH, A

ini := []
ini["wnd_position"]
:= { appX: appX
   , appY: appY
   , appW: appW
   , appH: appH}
;~ ini["wnd_position"]
;~ := { appX: appX
   ;~ , appY: appY
   ;~ , appW: appW - 16
   ;~ , appH: appH - 35}

ini["wnd_state"]
:= { minimized:     0
   , maximized:     0
   , alwaysontop:   1 }
WriteINI(ini, ini_name)


ExitApp
