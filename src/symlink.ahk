#NoTrayIcon
#SingleInstance,force
#Include symlink.inc.ahk
#Include symlink.def.inc.ahk
#Include symlink.lang.inc.ahk

base_name := RegExReplace(A_ScriptName, "(.+?)(\.[^.]*$|$)", "$1")
name_ini := base_name . ".ini"
if (FileExist(name_ini)) {
	ini := ReadINI(name_ini) ; overwrites symlink.def.inc.ahk
}
lang_ini := base_name . ".lang." . ini.wnd.lang . ".ini"
if (FileExist(lang_ini)) {
	lang := ReadINI(lang_ini) ; overwrites symlink.lang.inc.ahk
}

Gui, Add, Text, x12 y15 w40 h20 vLAB_LNK, % lang.window.link . ":"
Gui, Add, Text, x12 y45 w40 h20 vLAB_SRC, % lang.window.target . ":"
Gui, Add, Text, x12 y72 w40 h20 , CMD:
Gui, Add, Edit, x52 y13 w490 h20 vEDIT_LNK gonChange_EDIT_LNK, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\link3.txt
Gui, Add, Edit, x52 y43 w490 h20 vEDIT_SRC gonChange_EDIT_SRC, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\target.txt
if (A_Args[1])
	GuiControl,, EDIT_LNK, % A_Args[1]
if (A_Args[2])
	GuiControl,, EDIT_SRC, % A_Args[2]
Gui, Add, Edit, x52 y73 w520 h80 vEDIT_CMD
build_cmd()
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

Menu, menu_popup, Add, % lang.menu.alwaysontop, onClickMenu_alwaysontop
Menu, menu_popup, % ini.wnd.top ? "Check" : "UnCheck", % lang.menu.alwaysontop

Gui, Show,, % "Symlink Creator (Admin mode: " . (A_IsAdmin ? "Yes" : "No") . ")"
; WinMove instead of Gui, Show size params because of incosistency of size values (borders, etc...)
; Gui > Show, w: -16px
; Gui > Show, h: -35px
WinMove, A,, ini.pos.x, ini.pos.y, ini.pos.w, ini.pos.h
WinSet, AlwaysOnTop, % ini.wnd.top, A
return

GuiEscape:
ButtonClose:
GuiClose:
WinGetPos tmpX, tmpY, tmpW, tmpH, A
ini.pos
:= { x: tmpX
   , y: tmpY
   , w: tmpW ; Gui > Show: -16px
   , h: tmpH} ; Gui > Show: -35px
WriteINI(ini, name_ini)
ExitApp

onClickMenu_alwaysontop:
ini.wnd.top := ini.wnd.top ? 0 : 1
WinSet, AlwaysOnTop, % ini.wnd.top, A
Menu, menu_popup, % ini.wnd.top ? "Check" : "UnCheck", % lang.menu.alwaysontop
return

;===========================
; onContextMenu:
GuiContextMenu:
Menu, menu_popup, Show
return

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

dir_def := dir_root := "C:\"
edit_id := StrReplace(A_GuiControl, "BTN", "EDIT")
edit_txt := RTrim(%edit_id%, "\") ; extract variable reference

Loop { ; find the nearest valid path (going UPward)
	if (!edit_txt) ; empty edit, go with defaults
		break

	path_info := FileExist(edit_txt) ; path is found !!!
	if (path_info) {
		dir_out := edit_txt

		if (InStr(path_info, "D")) {
			dir_root :=  dir_out
		}
		else {
			dir_root :=  path_get_parent(dir_out) ; find root dir for a File/FolderSelect() modal
		}
		
		break
	}
	edit_txt := RegExReplace(edit_txt, "[^\\]+\\?$") ; remove last dir from path string
}

if (RAD_FILE || RAD_FILE_H)
	FileSelectFile, dir_out, 32, % dir_root
else
	FileSelectFolder, dir_out, % "*" . dir_root, 3

; save new path - if not empty
if (dir_out) { 
	GuiControl,, % edit_id , % dir_out
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
Gui, Submit, NoHide

errors := build_cmd(true)

if (!errors) {
	if (FileExist(EDIT_LNK)) {
		MsgBox, 305, Confirm Delete, Replace %EDIT_LNK%?
		IfMsgBox Cancel
			return
	}
	
	output := RunWaitMany(EDIT_CMD)
	if (output)
		MsgBox, 64, Output, % output
	else
		MsgBox, 48, No output, Try to run this program with Administrator privileges.
}

return

;###################################################################################################
; FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS 
;###################################################################################################

;===========================
; validate user input, optionally show error msg or update cmd line
build_cmd(out_msg := false, out_cmd := true) {
	global RAD_FILE, RAD_DIR, RAD_FILE_H, RAD_DIR_H, EDIT_LNK, EDIT_SRC, EDIT_CMD
	Gui, Submit, NoHide
	
	new_cmd := ""
	errors := 0
	is_dir := RAD_DIR || RAD_DIR_H
	fs_type := is_dir ? "directory" : "file"
	
	new_lnk := EDIT_LNK
	new_src := EDIT_SRC
	
	apply_control("LAB_LNK", "+cDefault")
	apply_control("LAB_SRC", "+cDefault")
	
	;===========================
	; MAIN checks...
	if (new_lnk != "" && new_src != "" && new_lnk == new_src) {
		apply_control("LAB_LNK", "+cRed")
		apply_control("LAB_SRC", "+cRed")
		_msg(out_msg, "Error", "The <link> and <target> are the same!")
		errors++
		return errors
	}

	;===========================
	; LINK checks...
	if (new_lnk != "")
	{
		if (path_exist(is_dir, new_lnk))
		{
			if (check_isempty(is_dir, new_lnk))
			{
				_cmd(out_cmd, new_cmd, cmd_remove(is_dir, new_lnk))
			}
			else
			{
				apply_control("LAB_LNK", "+cRed")
				_msg(out_msg, "Error", "The <link:" . fs_type . "> is not empty:`n" . new_lnk)
				errors++
			}
		}
		else if (FileExist(new_lnk)) ; path exists but its different type: file <=> dir
		{
			apply_control("LAB_LNK", "+cRed")
			_msg(out_msg, "Error", "The <link:" . fs_type . "> is overriding existing:`n" . new_lnk)
			errors++
		}
		else 
		{
			parent_lnk := path_get_parent(new_lnk)
			
			if (RTrim(new_lnk, "\") == parent_lnk) {
				apply_control("LAB_LNK", "+cRed")
				_msg(out_msg, "Error", "The <link> name is missing")
				errors++
			}
			else {
				; create parent folder if not exists
				if (parent_lnk && !path_exist(true, parent_lnk)) {
					apply_control("LAB_LNK", "+cGreen")
					_msg(out_msg, "Info", "The <link> directory path will be created:`n" . parent_lnk)
					_cmd(out_cmd, new_cmd, "MKDIR " . parent_lnk)
				}
			}
			
		}
	}
	else
	{
		;apply_control("LAB_LNK", "+cRed")
		_msg(out_msg, "Error", "The <link> path is empty!")
		errors++
	}
	
	;===========================
	; TARGET checks...
	if (new_src != "")
	{
		if (!path_exist(is_dir, new_src)) {
			apply_control("LAB_SRC", "+cRed")
			_msg(out_msg, "Warning", "The <target:" . fs_type . "> path doesn't exist:`n" . new_src)
			errors++
		}
	}
	else
	{
		;apply_control("LAB_LNK", "+cRed")
		_msg(out_msg, "Error", "The <target> path is empty!")
		errors++
	}

	
	;===========================
	; MKLINE cmd
	if (out_cmd) {
		switch := !RAD_FILE   ? switch : " "
		switch := !RAD_DIR    ? switch : " /D"
		switch := !RAD_FILE_H ? switch : " /H"
		switch := !RAD_DIR_H  ? switch : " /J"

		new_cmd .= "MKLINK" . switch . " """ . new_lnk . """ """ . new_src . """"
		GuiControl,, EDIT_CMD , % new_cmd
		;Gui, Submit, NoHide
	}
	
	return errors
}

