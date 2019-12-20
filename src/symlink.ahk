#NoTrayIcon
#SingleInstance,force
#Include ..\lib\GuiButtonIcon.inc.ahk

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
check_status()
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
check_status()
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
	FileSelectFile, dir, 3, %root_dir%
else
	FileSelectFolder, dir, % "*" . root_dir, 3

; save new path - if not empty
if (dir) { 
	GuiControl,, %edit_id% , %dir%
}

build_cmd()
return

;###################################################################################################
; OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK
;###################################################################################################
ButtonOK:
global EDIT_LNK, EDIT_SRC, EDIT_CMD
Gui, +OwnDialogs
Gui, Submit, NoHide

is_dir := RAD_DIR || RAD_DIR_H
fs_type := is_dir ? "directory" : "file"

edit_lnk := path_validate(EDIT_LNK)
edit_src := path_validate(EDIT_SRC)

;===============================================
; EDITOR checks...
if (edit_lnk = "") {
	MsgBox, 16, Error, The <link> path is empty
	return
}
if (edit_src = "") {
	MsgBox, 16, Error, The <target> path is empty
	return
}
if (edit_lnk = edit_src) {
	MsgBox, 16, Error, Both paths are the same!
	return
}

;===============================================
; TARGET checks...
if (!path_exist(is_dir, edit_src)) {
	MsgBox, 48, Warning, % "The <target:" . fs_type . "> path doesn't exist:`n" . edit_src
	return
}

;===============================================
; LINK checks...
if (path_exist(is_dir, edit_lnk) && !path_issymlink(edit_lnk))
{
	if (is_dir) {
		if (!dir_isempty(edit_lnk)) {
			MsgBox, 16, Error, % "The <link:" . fs_type . "> is not empty:`n" . edit_lnk
			return
		}
	}
	else {
		if (!file_isempty(edit_lnk)) {
			MsgBox, 16, Error, % "The <link:" . fs_type . "> is not empty:`n" . edit_lnk
			return
		}
		if (file_isreadonly(edit_lnk)) {
			MsgBox, 16, Error, % "The <link:" . fs_type . "> is read-only:`n" . edit_lnk
			return
		}
	}
}
	
MsgBox, 305, Confirm Delete, Replace %edit_lnk%?
IfMsgBox Cancel
	return

output := RunWait_output(EDIT_CMD)
MsgBox output: %output%
return

;###################################################################################################
; FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS 
;###################################################################################################

;===========================
; build command line
build_cmd() {
	global RAD_FILE, RAD_DIR, RAD_FILE_H, RAD_DIR_H, EDIT_LNK, EDIT_SRC
	Gui, Submit, NoHide
	
	cmd_out := ""
	check_status()
	
	switch := !RAD_FILE  ?  switch : " "
	switch := !RAD_DIR   ?  switch : " /D"
	switch := !RAD_FILE_H ? switch : " /H"
	switch := !RAD_DIR_H  ? switch : " /J"
	
	edit_lnk := path_validate(EDIT_LNK)
	edit_src := path_validate(EDIT_SRC)

	; check <link> existence, and remove if necessary
	if (RAD_FILE || RAD_FILE_H) { ; file, do not remove read-only files!!!
		if (path_exist(0, edit_lnk) && file_isempty(edit_lnk))
			cmd_out .=  "DEL " . edit_lnk . "`n" ; /F Force deleting of read-only files
	}
	else { ; folder, do not remove non empty folders!!!
		if (path_exist(1, edit_lnk) && dir_isempty(edit_lnk))
			cmd_out .= "RD " . edit_lnk . "`n" ; /S remove a directory tree, /Q quite
	}
	
	; check parent dir, and create it if not present
	parent_lnk := path_get_parent(edit_lnk)
	if (!path_exist(true, parent_lnk))
		cmd_out .= "MKDIR " . parent_lnk . "`n"

	; final cmd
	cmd_out .= "MKLINK" . switch . " """ . edit_lnk . """ """ . edit_src . """"
	
	GuiControl,, EDIT_CMD , % cmd_out
}

;===========================
; Visualize future errors
check_status() {
	global RAD_FILE, RAD_DIR, RAD_FILE_H, RAD_DIR_H, EDIT_LNK, EDIT_SRC
	Gui, Submit, NoHide
	
	is_dir := RAD_DIR || RAD_DIR_H
	ok_lnk := !path_exist(is_dir, EDIT_LNK) && EDIT_LNK != EDIT_SRC ; must not exist
	ok_src :=  path_exist(is_dir, EDIT_SRC) && EDIT_LNK != EDIT_SRC ; must exist

	apply_control("LAB_LNK", ok_lnk ? "+cDefault" : "+cRed")
	apply_control("LAB_SRC", ok_src ? "+cDefault" : "+cRed")
	;apply_control("BTN_OK", ok_lnk && ok_src ? "Enable" : "Disable")
}

;===========================
; test if file/dir path exists
path_exist(is_dir, s) {
	exists := FileExist(s)
	isdir := InStr(exists, "D")
	return is_dir ? isdir : exists && !isdir
}

;===========================
; find root dir of this path string
path_get_parent(path) {
	SplitPath, path,, parent
	return parent
}

;===========================
; Functionize GuiControl command
; So, it can be parametrized eg. with ternary conditional operators
apply_control(el, set) {
	GuiControl %set% +Redraw, %el%
}

;===========================
; Check if empty...
check_isempty(is_dir, path) {
	return is_dir ? dir_isempty(path) : file_isempty(path)
}

;===========================
; Dir is empty?
dir_isempty(path) {
	path := path_validate(path)
	Loop %path%\*.*, 0, 1
		return false
	return true
}

;===========================
; File is empty?
file_isempty(path) {
	FileGetSize, isempty, % path
	return isempty = 0 ? true : false
}

;===========================
; File is readonly?
file_isreadonly(path) {
	attr := FileExist(path)
	return InStr(attr, "R")
}

;===========================
; Make path valid
path_validate(path) {
	return RTrim(path, "\")
}

;===========================
; Check if given resource is a symlink
path_issymlink(path) {
;https://docs.microsoft.com/pl-pl/windows/win32/api/fileapi/nf-fileapi-getfileattributesa
;https://docs.microsoft.com/pl-pl/windows/win32/fileio/file-attribute-constants
;FILE_ATTRIBUTE_REPARSE_POINT : 1024 (0x400) -A file or directory that has an associated reparse point, or a file that is a symbolic link.
	attr := DllCall("GetFileAttributes", "Str", path)
	return attr & 1024 > 0
}

;===========================
; RunWait Examples
; return output string
RunWait_output(command) {
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99¬
    shell := ComObjCreate("WScript.Shell")
    ; Execute a single command via cmd.exe
    exec := shell.Exec(ComSpec " /C " command)
    ; Read and return the command's output
    return exec.StdOut.ReadAll()
}



