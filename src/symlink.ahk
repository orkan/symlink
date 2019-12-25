#NoTrayIcon
#SingleInstance,force
#Include symlink.inc.ahk
#Include symlink.def.inc.ahk
#Include symlink.lang.inc.ahk

base_name := "symlink"
version := "v0.2"

; user settings - overwrites symlink.def.inc.ahk
name_ini := base_name . ".ini"
ini  := merge_from_ini(ini,  name_ini)
; user lang - overwrites symlink.lang.inc.ahk
lang_ini := base_name . ".lang." . ini.wnd.lang . ".ini"
lang := merge_from_ini(lang, lang_ini)

Gui, Add, Text, x10 y15 w40 h20 vLAB_LNK, % lang.window.link . ":"
Gui, Add, Edit, x52 y13 w490 h20 gonChange_EDIT vEDIT_LNK ;, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\link3.txt

Gui, Add, Text, x10 y45 w40 h20 vLAB_SRC, % lang.window.target . ":"
Gui, Add, Edit, x52 y43 w490 h20 gonChange_EDIT vEDIT_SRC ;, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\target.txt
; get command line args (Menu > View > Parameters (Shift+F8))
if (A_Args[1])
	GuiControl,, EDIT_LNK, % A_Args[1]
if (A_Args[2])
	GuiControl,, EDIT_SRC, % A_Args[2]

Gui, Add, Text, x10 y72 w40 h20 , % lang.window.cmd . ":"
Gui, Add, Edit, x52 y73 w520 h80 vEDIT_CMD ReadOnly 

Gui, Add, Button, x552 y13 w20 h20 vBTN_LNK gonClick_BROWSE hwndBTN_LNK,
Gui, Add, Button, x552 y43 w20 h20 vBTN_SRC gonClick_BROWSE hwndBTN_SRC,
GuiButtonIcon(BTN_LNK, "imageres.dll", 4)
GuiButtonIcon(BTN_SRC, "imageres.dll", 4)
; select last radio button
for key, val in ini.rad {
	ch%key% := val ; Checked1 - selected, Checked0 - unselected
	chSum += val
}
if (!chSum)
	chRAD_DIR := 1 ; go with default
Gui, Add, Radio, x52  y163  w40 h20 gonClick_RAD vRAD_FILE   Checked%chRAD_FILE%	, % lang.window.mkFile
Gui, Add, Radio, x92  y163  w70 h20 gonClick_RAD vRAD_DIR    Checked%chRAD_DIR%		, % lang.window.mkDir
Gui, Add, Radio, x166 y163 w96  h20 gonClick_RAD vRAD_FILE_H Checked%chRAD_FILE_H%	, % lang.window.mkFileH
Gui, Add, Radio, x262 y163 w100 h20 gonClick_RAD vRAD_DIR_H  Checked%chRAD_DIR_H%	, % lang.window.mkDirH

Gui, Add, Button, x362 y163 w100 h30 vBTN_OK gonClick_BTN_OK, % lang.window.btnok
Gui, Add, Button, Default x472 y163 w100 h30 gonClick_BTN_CLOSE, % lang.window.btnclose

;Gui, Add, Picture, x10 y121 w32 h32, ..\res\shell32.dll,16769.ico ; only linked!

Menu, menu_popup, Add, % lang.menu.alwaysOnTop, onClickMenu_alwaysOnTop
Menu, menu_popup, Add, % lang.menu.swapLinkTarget, onClickMenu_swapLinkTarget
Menu, menu_popup, % ini.wnd.top ? "Check" : "UnCheck", % lang.menu.alwaysontop
show_cmd()

Gui, Show,, % "Symlink Creator " version " (" lang.window.adminmode ": " (A_IsAdmin ? lang.window.yes : lang.window.no) ")"
; WinMove instead of Gui, Show size params because of incosistency of size values (borders, etc...)
; Gui > Show, w: -16px
; Gui > Show, h: -35px
WinMove, A,, ini.pos.x, ini.pos.y, ini.pos.w, ini.pos.h
WinSet, AlwaysOnTop, % ini.wnd.top, A
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

onClick_RAD:
is_filelink := A_GuiControl = "RAD_FILE" || A_GuiControl = "RAD_FILE_H"
icon_browse := is_filelink ? 3 : 4
GuiButtonIcon(BTN_LNK, "imageres.dll", icon_browse)
GuiButtonIcon(BTN_SRC, "imageres.dll", icon_browse)
show_cmd()
return

onChange_EDIT: ; gonChange_EDIT_LNK
show_cmd()
return

;==============================================================================================
; Browse for a file or folder
onClick_BROWSE:
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

		if (InStr(path_info, "D"))
			dir_root :=  dir_out
		else
			dir_root :=  path_get_parent(dir_out) ; find root dir for a File/FolderSelect() modal

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

result := build_cmd()

if (result.err.Length())
{
	for k, v in result.err {
		_msg(v.msg . (v.src ? ":`n" . v.src : ""), v.cap)
	}
}
else
{
	if (FileExist(EDIT_LNK)) {
		MsgBox, 305, Confirm Delete, Replace %EDIT_LNK%?
		IfMsgBox Cancel
			return
	}
	
	output := RunWaitMany(implode(result.cmd, "`n"))
	if (output)
		_msg(printf(lang.msg.mkOutput, output), "info")
	else
		_msg(printf(lang.msg.mkNoOutput), "error")
}
return

;###################################################################################################
; FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS 
;###################################################################################################
show_cmd() {
	result := build_cmd()
	out := []
	
	if (result.err.Length()) {
		apply_control("EDIT_CMD", "+cRed")
		for k, v in result.err
			out.Push(A_Index . ". " . v.msg)
	}
	else {
		apply_control("EDIT_CMD", "+cDefault")
		out := result.cmd
	}
	
	GuiControl,, EDIT_CMD , % implode(out, "`n")
}
;===========================
; validate user input to output array:
; arr := []
; arr.err
; := [{cap: "error",   msg: "A message", src: "D:\path\to\file1.txt"}
;    ,{cap: "warning", msg: "A message"}
;    ,{cap: "info",    msg: "A message", src: "D:\path\to\file2.txt"}]
; arr.cmd
; := ["cmd1", "cmd2", "cmd3"]
build_cmd() {
	global RAD_FILE, RAD_DIR, RAD_FILE_H, RAD_DIR_H, EDIT_LNK, EDIT_SRC, EDIT_CMD, lang
	Gui, Submit, NoHide
	
	out := {err: [], cmd: []}
	new_lnk := EDIT_LNK
	new_src := EDIT_SRC
	
	is_dir := RAD_DIR || RAD_DIR_H
	fs_type := is_dir ? lang.window.dir : lang.window.file
	
	apply_control("LAB_LNK", "+cDefault")
	apply_control("LAB_SRC", "+cDefault")
	
	;===========================
	; "The <link> and <target> are the same!"
	if (new_lnk != "" && new_src != "" && new_lnk == new_src) {
		apply_control("LAB_LNK", "+cRed")
		apply_control("LAB_SRC", "+cRed")
		out.err.Push({cap: "error", msg: printf(lang.msg.sameLinkTarget)})
		return out
	}

	;===========================
	; LINK checks...
	if (new_lnk != "")
	{
		if (path_exist(is_dir, new_lnk))
		{
			if (check_isempty(is_dir, new_lnk))
			{
				out.cmd.Push(cmd_remove(is_dir, new_lnk))
			}
			else ; <link> is not empty
			{
				apply_control("LAB_LNK", "+cRed")
				out.err.Push({cap: "error", msg: printf(lang.msg.notEmptyLink, fs_type), src: new_lnk})
			}
		}
		else if (FileExist(new_lnk)) ; path exists but its different type: file <=> dir
		{
			apply_control("LAB_LNK", "+cRed")
			out.err.Push({cap: "error", msg: printf(lang.msg.overrideLink, fs_type), src: new_lnk})
		}
		else 
		{
			parent_lnk := path_get_parent(new_lnk)
			
			; The <link> name is missing - path ending with \
			if (RTrim(new_lnk, "\") == parent_lnk) {
				apply_control("LAB_LNK", "+cRed")
				out.err.Push({cap: "error", msg: printf(lang.msg.missingLink, fs_type), src: new_lnk})
			}
			else {
				; create parent folder if not exists
				if (parent_lnk && !path_exist(true, parent_lnk)) {
					apply_control("LAB_LNK", "+cGreen")
					out.err.Push({cap: "info", msg: printf(lang.msg.newPathLink, fs_type), src: new_lnk})
					out.cmd.Push("MKDIR " . parent_lnk)
				}
			}
		}
	}
	else
	{
		;apply_control("LAB_LNK", "+cRed")
		out.err.Push({cap: "error", msg: printf(lang.msg.emptyLink, fs_type), src: new_lnk})
	}
	
	;===========================
	; TARGET checks...
	if (new_src != "")
	{
		if (!path_exist(is_dir, new_src)) {
			apply_control("LAB_SRC", "+cRed")
			out.err.Push({cap: "warning", msg: printf(lang.msg.missingTarget, fs_type), src: new_src})
		}
	}
	else
	{
		;apply_control("LAB_LNK", "+cRed")
		out.err.Push({cap: "error", msg: printf(lang.msg.emptyTarget, fs_type), src: new_src})
	}
	
	;===========================
	; MKLINK
	switch := !RAD_FILE   ? switch : ""
	switch := !RAD_DIR    ? switch : "/D"
	switch := !RAD_FILE_H ? switch : "/H"
	switch := !RAD_DIR_H  ? switch : "/J"
	out.cmd.Push("MKLINK " . switch . " """ . new_lnk . """ """ . new_src . """")

	return out
}
