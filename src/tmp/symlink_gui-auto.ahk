#NoTrayIcon
#SingleInstance, Force
#Include symlink.inc.ahk

base_name := RegExReplace(A_ScriptName, "(.+?)(\.[^.]*$|$)", "$1")
lang_ini := base_name . ".lang.en.ini"
lang := ReadINI("symlink.lang.en.ini")
ini := ReadINI("symlink.ini")

Gui +Resize +MaximizeBox +MinSize590x200

Gui, Add, Text, x12 y15 w40 h20 vLAB_LNK, Link:
Gui, Add, Text, x12 y45 w40 h20 vLAB_SRC, Source:
Gui, Add, Edit, x52 y13 w490 h20 vEDIT_LNK gonChange_EDIT_LNK, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\link.txt
Gui, Add, Edit, x52 y43 w490 h20 vEDIT_SRC gonChange_EDIT_SRC, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\target.txt
Gui, Add, Button, x362 y163 w100 h30 vBTN_OK, &OK
Gui, Show

Menu, menu_popup, Add, % lang.menu.alwaysontop, onClickMenu_alwaysontop
Menu, menu_popup, Add, option 2, MenuHandler
Menu, menu_popup, % ini.wnd_state.alwaysontop ? "Check" : "UnCheck", % lang.menu.alwaysontop

Gui, Submit, NoHide
return


onClickMenu_alwaysontop:
Menu, menu_popup, % (ini.wnd_state.alwaysontop := !ini.wnd_state.alwaysontop) ? "Check" : "UnCheck", % lang.menu.alwaysontop

MsgBox % "alwaysontop: " . ini.wnd_state.alwaysontop
return

GuiContextMenu:
Menu, menu_popup, Show
return

MenuHandler:
onChange_EDIT_LNK:
onChange_EDIT_SRC:
return

ButtonOK:
Gui, +OwnDialogs
Gui, Submit, NoHide

Menu, menu_popup, Show


return


GuiEscape:
ButtonClose:
GuiClose:

ExitApp
