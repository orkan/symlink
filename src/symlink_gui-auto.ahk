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
Gui, Show, w590 h235, Symlink Test
Gui, Submit, NoHide
return

onChange_EDIT_LNK:
onChange_EDIT_SRC:
return

ButtonOK:
global EDIT_LNK, EDIT_SRC, EDIT_CMD
Gui, +OwnDialogs
Gui, Submit, NoHide

new_lnk := "D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\linbv\"
parent_lnk := path_get_parent(new_lnk)

if (RTrim(parent_lnk, "\") == parent_lnk)
{
MsgBox, takie same!
}

MsgBox % "new_lnk: " . new_lnk . "`n parent_lnk: " . parent_lnk


return


