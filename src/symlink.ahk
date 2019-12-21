#NoTrayIcon
#SingleInstance,force
#Include symlink.inc.ahk

Gui, Add, Text, x12 y15 w40 h20 vLAB_LNK, Link:
Gui, Add, Text, x12 y45 w40 h20 vLAB_SRC, Target:
Gui, Add, Text, x12 y72 w40 h20 , CMD:
Gui, Add, Edit, x52 y13 w490 h20 vEDIT_LNK gonChange_EDIT_LNK, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\link3.txt
Gui, Add, Edit, x52 y43 w490 h20 vEDIT_SRC gonChange_EDIT_SRC, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\target.txt
Gui, Add, Edit, x52 y73 w520 h80 vEDIT_CMD
Gui, Add, Button, x552 y13 w20 h20 vBTN_LNK gonClick_BTN_LNK hwndBTN_LNK,
Gui, Add, Button, x552 y43 w20 h20 vBTN_SRC gonClick_BTN_SRC hwndBTN_SRC,
GuiButtonIcon(BTN_LNK, "imageres.dll", 4)
GuiButtonIcon(BTN_SRC, "imageres.dll", 4)
Gui, Add, Radio, x52  y163 w40 h20 vRAD_FILE   gonClick_RAD_FILE  ,  File
Gui, Add, Radio, x102 y163 w60 h20 vRAD_DIR    gonClick_RAD_DIR    Checked, Dir (/D)
Gui, Add, Radio, x172 y163 w80 h20 vRAD_FILE_H gonClick_RAD_FILE_H, Hard File (/H)
Gui, Add, Radio, x272 y163 w90 h20 vRAD_DIR_H  gonClick_RAD_DIR_H , Hard Dir (/J)
Gui, Add, Button, x362 y163 w100 h30 vBTN_OK, &OK
Gui, Add, Button, Default x472 y163 w100 h30 , &Close

build_cmd()
Gui, Show, w584 h206, Symlink Creator
return

GuiEscape:
ButtonClose:
GuiClose:
ExitApp

;===========================
; Drop & Down explorer files onto editboxes
GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
	if (A_GuiControl = "EDIT_LNK" or A_GuiControl = "EDIT_SRC")
		GuiControl,, %A_GuiControl%, % FileArray[1]
}

onClick_RAD_FILE:
onClick_RAD_DIR:
onClick_RAD_FILE_H:
onClick_RAD_DIR_H:
is_filelink := A_GuiControl = "RAD_FILE" || A_GuiControl = "RAD_FILE_H"
icon_browse := is_filelink ? 3 : 4
GuiButtonIcon(BTN_LNK, "imageres.dll", icon_browse)
GuiButtonIcon(BTN_SRC, "imageres.dll", icon_browse)
build_cmd()
return

onChange_EDIT_LNK: ; gonChange_EDIT_LNK
onChange_EDIT_SRC: ; gonChange_EDIT_SRC
build_cmd()
return

;==============================================================================================
; Browse for a file or folder
onClick_BTN_LNK:
onClick_BTN_SRC:
Gui, +OwnDialogs
Gui, Submit, NoHide

dir := "C:\"
edit_id := StrReplace(A_GuiControl, "BTN", "EDIT")
edit_txt := path_validate(%edit_id%) ; extract variable reference

Loop { ; find the nearest valid path (going UPward)
	if (!edit_txt) ; empty edit, go with defaults
		break

	path_info := FileExist(edit_txt) ; path is found !!!
	if (path_info) {
		dir := edit_txt

		if (InStr(path_info, "D")) {
			root_dir :=  dir
		}
		else {
			root_dir :=  path_get_parent(dir) ; find root dir for a File/FolderSelect() modal
		}
		
		break
	}
	edit_txt := RegExReplace(edit_txt, "[^\\]+\\?$")
}

if (RAD_FILE || RAD_FILE_H)
	FileSelectFile, dir, 3, % root_dir
else
	FileSelectFolder, dir, % "*" . root_dir, 3

; save new path - if not empty
if (dir) { 
	GuiControl,, % edit_id , % dir
}

build_cmd()
return

;###################################################################################################
; OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK
;###################################################################################################

; validate and run
ButtonOK:
global EDIT_LNK, EDIT_SRC, EDIT_CMD
Gui, +OwnDialogs

errors := build_cmd(true)

if (!errors) {
	if (FileExist(EDIT_LNK)) {
		MsgBox, 305, Confirm Delete, Replace %EDIT_LNK%?
		IfMsgBox Cancel
			return
	}
	
	output := RunWait_output(EDIT_CMD)
	MsgBox output: %output%
}

return

