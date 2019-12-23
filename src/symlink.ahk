#NoTrayIcon
#SingleInstance,force
#Include symlink.inc.ahk
#Include symlink.def.inc.ahk
#Include symlink.lang.inc.ahk

base_name := RegExReplace(A_ScriptName, "(.+?)(\.[^.]*$|$)", "$1")
; user settings - overwrites symlink.def.inc.ahk
name_ini := base_name . ".ini"
ini  := merge_from_ini(ini,  name_ini)
; user lang - overwrites symlink.lang.inc.ahk
lang_ini := base_name . ".lang." . ini.wnd.lang . ".ini"
lang := merge_from_ini(lang, lang_ini)

Gui, Add, Text, x10 y15 w40 h20 vLAB_LNK, % lang.window.link . ":"
Gui, Add, Edit, x52 y13 w490 h20 vEDIT_LNK gonChange_EDIT_LNK, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\link3.txt

Gui, Add, Text, x10 y45 w40 h20 vLAB_SRC, % lang.window.target . ":"
Gui, Add, Edit, x52 y43 w490 h20 vEDIT_SRC gonChange_EDIT_SRC, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\target.txt
; get command line args
if (A_Args[1])
	GuiControl,, EDIT_LNK, % A_Args[1]
if (A_Args[2])
	GuiControl,, EDIT_SRC, % A_Args[2]

Gui, Add, Text, x10 y72 w40 h20 , % lang.window.cmd . ":"
Gui, Add, Edit, x52 y73 w520 h80 vEDIT_CMD ReadOnly 

Gui, Add, Button, x552 y13 w20 h20 vBTN_LNK gonClick_BTN_LNK hwndBTN_LNK,
Gui, Add, Button, x552 y43 w20 h20 vBTN_SRC gonClick_BTN_SRC hwndBTN_SRC,
GuiButtonIcon(BTN_LNK, "imageres.dll", 4)
GuiButtonIcon(BTN_SRC, "imageres.dll", 4)
; select last radio button
for key, val in ini.rad {
	ch%key% := val ; Checked1 - selected, Checked0 - unselected
	chSum += val
}
if (!chSum)
	chRAD_DIR := 1 ; go with default
Gui, Add, Radio, x52  y163  w40 h20 vRAD_FILE   gonClick_RAD_FILE  	Checked%chRAD_FILE%		, % lang.window.mkFile
Gui, Add, Radio, x92  y163  w70 h20 vRAD_DIR    gonClick_RAD_DIR    Checked%chRAD_DIR%		, % lang.window.mkDir
Gui, Add, Radio, x166 y163 w96  h20 vRAD_FILE_H gonClick_RAD_FILE_H	Checked%chRAD_FILE_H%	, % lang.window.mkFileH
Gui, Add, Radio, x262 y163 w100 h20 vRAD_DIR_H  gonClick_RAD_DIR_H 	Checked%chRAD_DIR_H%	, % lang.window.mkDirH

Gui, Add, Button, x362 y163 w100 h30 vBTN_OK gonClick_BTN_OK, % lang.window.btnok
Gui, Add, Button, Default x472 y163 w100 h30 gonClick_BTN_CLOSE, % lang.window.btnclose

Gui, Add, Picture, x10 y121 w32 h32, ..\res\shell32.dll,16769.ico ; only linked!

Menu, menu_popup, Add, % lang.menu.alwaysOnTop, onClickMenu_alwaysOnTop
Menu, menu_popup, Add, % lang.menu.swapLinkTarget, onClickMenu_swapLinkTarget
Menu, menu_popup, % ini.wnd.top ? "Check" : "UnCheck", % lang.menu.alwaysontop
build_cmd()

Gui, Show,, % "Symlink Creator (" . lang.window.adminmode . ": " . (A_IsAdmin ? lang.window.yes : lang.window.no) . ")"
; WinMove instead of Gui, Show size params because of incosistency of size values (borders, etc...)
; Gui > Show, w: -16px
; Gui > Show, h: -35px
WinMove, A,, ini.pos.x, ini.pos.y, ini.pos.w, ini.pos.h
WinSet, AlwaysOnTop, % ini.wnd.top, A

OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x2A1, "WM_MOUSEHOVER")
return

WM_LBUTTONDOWN(wParam, lParam)
{
    X := lParam & 0xFFFF
    Y := lParam >> 16
    if A_GuiControl
        Ctrl := "`n(in control " . A_GuiControl . ")"
    ToolTip You left-clicked in Gui window #%A_Gui% at client coordinates %X%x%Y%.%Ctrl%
}

WM_MouseOver()
{
	global old_GuiControl, LAB_LNK ; define as global so it survives untill next MOUSEMOVE
	global Tooltip
	If A_GuiControl = LAB_LNK
		Tooltip = New Script
	If A_GuiControl = OpenPic
		Tooltip = Open
	If A_GuiControl = SavePic
		Tooltip = Save Script
	If A_GuiControl = TestPic
		Tooltip = Test Script
	If A_GuiControl = FindPic
		Tooltip = Find/Replace
	If A_GuiControl = PrefsPic
		Tooltip = Preferences
	If A_GuiControl = HelpPic
		Tooltip = AHK Help
	If A_GuiControl =     ; mouse is over nothing
		Tooltip =
	If A_GuiControl = MainEdit ; mouse is over mainedit
		Tooltip =
	Tooltip, %tooltip%
	SetTimer, RemoveToolTip, 5000
	if A_Guicontrol = %Old_GuiControl% ; the mouse is above the same thing it was last MOUSEMOVE
		return
}

ToolTip, Timed ToolTip`nThis will be displayed for 5 seconds.
SetTimer, RemoveToolTip, -5000
return

RemoveToolTip:
ToolTip
return


GuiClose:
GuiEscape:
onClick_BTN_CLOSE:
save_pos()
save_rad()
WriteINI(ini, name_ini)
ExitApp

onClickMenu_alwaysOnTop:
ini.wnd.top := ini.wnd.top ? 0 : 1
WinSet, AlwaysOnTop, % ini.wnd.top, A
Menu, menu_popup, % ini.wnd.top ? "Check" : "UnCheck", % lang.menu.alwaysontop
return

onClickMenu_swapLinkTarget:
Gui, Submit, NoHide
tmp := EDIT_LNK
GuiControl,, EDIT_LNK , % EDIT_SRC
GuiControl,, EDIT_SRC , % EDIT_LNK
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
onClick_BTN_OK:
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
build_cmd(show_msg := false, show_cmd := true) {
	global RAD_FILE, RAD_DIR, RAD_FILE_H, RAD_DIR_H, EDIT_LNK, EDIT_SRC, EDIT_CMD, lang
	Gui, Submit, NoHide
	
	new_cmd := ""
	errors := 0
	is_dir := RAD_DIR || RAD_DIR_H
	fs_type := is_dir ? lang.window.dir : lang.window.file
	
	new_lnk := EDIT_LNK
	new_src := EDIT_SRC
	
	apply_control("LAB_LNK", "+cDefault")
	apply_control("LAB_SRC", "+cDefault")
	
	;===========================
	; "The <link> and <target> are the same!"
	if (new_lnk != "" && new_src != "" && new_lnk == new_src) {
		apply_control("LAB_LNK", "+cRed")
		apply_control("LAB_SRC", "+cRed")
		_msg(show_msg, "error", printf(lang.msg.sameLinkTarget))
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
				_cmd(show_cmd, new_cmd, cmd_remove(is_dir, new_lnk))
			}
			; <link> is not empty
			else
			{
				apply_control("LAB_LNK", "+cRed")
				_msg(show_msg, "error", printf(lang.msg.notEmptyLink, fs_type, new_lnk))
				errors++
			}
		}
		; path exists but its different type: file <=> dir
		else if (FileExist(new_lnk))
		{
			apply_control("LAB_LNK", "+cRed")
			_msg(show_msg, "error", printf(lang.msg.overrideLink, fs_type, new_lnk))
			errors++
		}
		else 
		{
			parent_lnk := path_get_parent(new_lnk)
			
			; The <link> name is missing - path ending with \
			if (RTrim(new_lnk, "\") == parent_lnk) {
				apply_control("LAB_LNK", "+cRed")
				_msg(show_msg, "error", printf(lang.msg.missingLink, fs_type, new_lnk))
				errors++
			}
			else {
				; create parent folder if not exists
				if (parent_lnk && !path_exist(true, parent_lnk)) {
					apply_control("LAB_LNK", "+cGreen")
					_msg(show_msg, "info", printf(lang.msg.newPathLink, fs_type, new_lnk))
					_cmd(show_cmd, new_cmd, "MKDIR " . parent_lnk)
				}
			}
			
		}
	}
	else
	{
		;apply_control("LAB_LNK", "+cRed")
		_msg(show_msg, "error", printf(lang.msg.emptyLink, fs_type, new_lnk))
		errors++
	}
	
	;===========================
	; TARGET checks...
	if (new_src != "")
	{
		if (!path_exist(is_dir, new_src)) {
			apply_control("LAB_SRC", "+cRed")
			_msg(show_msg, "warning", printf(lang.msg.missingTarget, fs_type, new_src))
			errors++
		}
	}
	else
	{
		;apply_control("LAB_LNK", "+cRed")
		_msg(show_msg, "error", printf(lang.msg.emptyTarget, fs_type, new_src))
		errors++
	}

	
	;===========================
	; MKLINE cmd
	if (show_cmd) {
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

