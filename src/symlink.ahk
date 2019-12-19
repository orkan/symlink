#NoTrayIcon
#SingleInstance,force
#Include ..\lib\GuiButtonIcon.inc.ahk

Gui, Add, Text, x12 y15 w40 h20 vLAB_LNK, Link:
Gui, Add, Text, x12 y45 w40 h20 vLAB_SRC, Source:
Gui, Add, Text, x12 y72 w40 h20 , CMD:
Gui, Add, Edit, x52 y13 w490 h20 vEDIT_LNK gonChange_EDIT_LNK, D:\Orkan\Code\Exe\AutoHotkey\Symlink\etc\test lnk
Gui, Add, Edit, x52 y43 w490 h20 vEDIT_SRC gonChange_EDIT_SRC, D:\Orkan\Code\Exe\AutoHotkey\Symlink\etc\test src
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
Gui, Add, Button, Default x472 y163 w100 h30 , &Cancel
enable_btn_ok()
build_mklink_cmd()
Gui, Show, w584 h206, Symlink Creator
return

onClick_RAD_FILE:
onClick_RAD_DIR:
onClick_RAD_FILE_H:
onClick_RAD_DIR_H:
is_filelink := A_GuiControl = "RAD_FILE" || A_GuiControl = "RAD_FILE_H"
icon_browse := is_filelink ? 3 : 4
GuiButtonIcon(BTN_LNK, "imageres.dll", icon_browse)
GuiButtonIcon(BTN_SRC, "imageres.dll", icon_browse)
build_mklink_cmd()
return

onChange_EDIT_LNK: ; gonChange_ED_LNK
onChange_EDIT_SRC: ; gonChange_ED_SRC
enable_btn_ok()
return

;===========================
; handle Drop & Down of explorer files onto editboxes
GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
	if (A_GuiControl = "EDIT_LNK" or A_GuiControl = "EDIT_SRC")
		GuiControl,, %A_GuiControl%, % FileArray[1]
}

;===========================
; Browse for a file or folder
onClick_BTN_LNK:
onClick_BTN_SRC:
Gui, Submit, NoHide
Gui, +OwnDialogs

dir := "C:\"
edit_id := StrReplace(A_GuiControl, "BTN", "EDIT")
edit_txt := %edit_id% ; extract variable reference
;GuiControlGet, edit_txt,, %edit_id%
;MsgBox % "edit_id: " . edit_id . " `n %edit_id%: " . %edit_id% . " `n edit_txt: " . edit_txt
;MsgBox % "EDIT_LNK: " . EDIT_LNK . " `n edit_txt: " . edit_txt


Loop { ; find the nearest valid path (going UPward)
	if (!edit_txt) ; empty edit, go with defaults
		break

	path_info := FileExist(edit_txt) ; path is found !!!
	if (path_info) {
		dir := edit_txt

		if (InStr(path_info, "D")) { ; find root dir for a File/FolderSelect() modal
			root_dir :=  dir
		}
		else {
			SplitPath, dir,, root_dir
		}
		
		break
	}
	
	;edit_txt := RTrim(edit_txt, "\")
	edit_txt := RegExReplace(edit_txt, "[^\\]+\\?$")
}

if (RAD_FILE || RAD_FILE_H) {
	FileSelectFile, dir, 3, %root_dir%
}
else {
	FileSelectFolder, dir, % "*" . root_dir, 3
}

; save new path - if not empty
if (dir) { 
	GuiControl,, %edit_id% , %dir%
}

build_mklink_cmd()
return

;===========================
; build MKLINK
build_mklink_cmd() {
	global RAD_FILE, RAD_DIR, RAD_FILE_H, RAD_DIR_H, EDIT_LNK, EDIT_SRC
	Gui, Submit, NoHide
	
	switch := !RAD_FILE  ? switch : " "
	switch := !RAD_DIR   ? switch : " /D"
	switch := !RAD_FILE_H ? switch : " /H"
	switch := !RAD_DIR_H  ? switch : " /J"
	GuiControl,, EDIT_CMD , % "MKLINK" . switch . " """ . EDIT_LNK . """ """ . EDIT_SRC . """"
	
	enable_btn_ok()
}

;===========================
; Enable / Disable button OK
enable_btn_ok() {
	global RAD_FILE, RAD_DIR, RAD_FILE_H, RAD_DIR_H, EDIT_LNK, EDIT_SRC
	Gui, Submit, NoHide
	
	is_dir := RAD_DIR || RAD_DIR_H
	ok_lnk := test_path(is_dir, EDIT_LNK) && EDIT_LNK != EDIT_SRC
	ok_src := test_path(is_dir, EDIT_SRC) && EDIT_LNK != EDIT_SRC

	apply_control("LAB_LNK", ok_lnk ? "+cDefault" : "+cRed")
	apply_control("LAB_SRC", ok_src ? "+cDefault" : "+cRed")
	apply_control("BTN_OK", ok_lnk && ok_src ? "Enable" : "Disable")
}

;===========================
; test if file/dir path exists
test_path(is_dir, s) {
	exists := FileExist(s)
	isdir := InStr(exists, "D")
	return is_dir ? isdir : exists && !isdir
}

;===========================
; Functionize GuiControl command
; So, it can be parametrized eg. with ternary conditional operators
apply_control(el, set) {
	GuiControl %set% +Redraw, %el%
}

;===========================
; RunWait Examples
RunWaitOne(command) {
	global My_LastError
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99¬
    shell := ComObjCreate("WScript.Shell")
    ; Execute a single command via cmd.exe
    exec := shell.Exec(ComSpec " /C " command)
	My_LastError = %A_LastError%
    ; Read and return the command's output
    return exec.StdOut.ReadAll()
}

;===========================
; CALL mklink
ButtonOK:
global EDIT_LNK, EDIT_CMD, My_LastError
Gui, Submit, NoHide

MsgBox, 8500, Confirm Delete, Replace %EDIT_LNK%?
IfMsgBox No
	return

output := RunWaitOne(EDIT_CMD)

;MsgBox ComSpec: %ComSpec%
MsgBox My_LastError: %My_LastError%
MsgBox output: %output%
MsgBox ErrorLevel: %ErrorLevel%
MsgBox A_LastError: %A_LastError%

;RunWait, mklink.exe /?, , UseErrorLevel
;~ if (ErrorLevel = "ERROR")
    ;~ MsgBox A_LastError: %A_LastError%

;MsgBox % EDIT_CMD
	
return

GuiEscape:
ButtonCancel:
GuiClose:
ExitApp

;MsgBox RAD_FILE: %RAD_FILE% RAD_DIR: %RAD_DIR% RAD_FILE_H: %RAD_FILE_H% RAD_DIR_H: %RAD_DIR_H% switch %switch%




