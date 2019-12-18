#NoTrayIcon
#SingleInstance
#Include ..\lib\GuiButtonIcon.inc.ahk

Gui, Add, Text, x12 y15 w40 h20 , Link:
Gui, Add, Text, x12 y45 w40 h20 , Source:
Gui, Add, Text, x12 y72 w40 h20 , CMD:
Gui, Add, Edit, x52 y13 w490 h20 vED_LNK , D:\Orkan\Code\Exe\AutoHotkey\Symlink\src\symlink.ahk
Gui, Add, Edit, x52 y43 w490 h20 vED_SRC , C:\Users\Orkan\Desktop\Andrzej
Gui, Add, Edit, x52 y73 w520 h80 vED_CMD
Gui, Add, Button, x552 y13 w20 h20 vBTN_LNK gonClick_Browse hwndBTN_LNK,
Gui, Add, Button, x552 y43 w20 h20 vBTN_SRC gonClick_Browse hwndBTN_SRC,
GuiButtonIcon(BTN_LNK, "imageres.dll", 4)
GuiButtonIcon(BTN_SRC, "imageres.dll", 4)
Gui, Add, Radio, x52 y163 w40 h20 gRadioFile vRadioFile, File
Gui, Add, Radio, x102 y163 w60 h20 gRadioDir vRadioDir Checked, Dir (/D)
Gui, Add, Radio, x172 y163 w80 h20 gRadioFile vRadioFileH, Hard File (/H)
Gui, Add, Radio, x272 y163 w90 h20 gRadioDir vRadioDirH, Hard Dir (/J)
Gui, Add, Button, x362 y163 w100 h30 vBTN_OK Disabled, &OK
Gui, Add, Button, Default x472 y163 w100 h30 , &Cancel
Gui, Show, w584 h206, Symlink Creator
return

RadioDir:
GuiButtonIcon(BTN_LNK, "imageres.dll", 4)
GuiButtonIcon(BTN_SRC, "imageres.dll", 4)
build_mklink_cmd()
return

RadioFile:
GuiButtonIcon(BTN_LNK, "imageres.dll", 3)
GuiButtonIcon(BTN_SRC, "imageres.dll", 3)
build_mklink_cmd()
return

;===========================
; handle Drop & Down of explorer files onto editboxes
GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
	if (A_GuiControl = "ED_LNK" or A_GuiControl = "ED_SRC")
		GuiControl,, %A_GuiControl%, % FileArray[1]
}

;===========================
; Browse for a file or folder
onClick_Browse:
Gui, Submit, NoHide
Gui, +OwnDialogs

dir := "C:\"
ed_id := StrReplace(A_GuiControl, "BTN", "ED")
GuiControlGet, ed_txt,, %ed_id%

Loop { ; find the nearest valid path (going UPward)
	if (!ed_txt) ; empty edit, go with defaults
		break

	path_info := FileExist(ed_txt) ; path is found !!!
	if(path_info) {
		dir := ed_txt

		if (InStr(path_info, "D")) { ; find root dir for a File/FolderSelect() modal
			root_dir :=  dir
		}
		else {
			SplitPath, dir,, root_dir
		}
		
		break
	}
	
	ed_txt := RTrim(ed_txt, "\")
	ed_txt := RegExReplace(ed_txt, "[^\\]+$")
}

if(RadioFile || RadioFileH) {
	FileSelectFile, dir, 3, %root_dir%
}
else {
	FileSelectFolder, dir, % "*" . root_dir, 3
}

; save new path - if not empty
if (dir) { 
	GuiControl,, %ed_id% , %dir%
}

build_mklink_cmd()
return

;===========================
; build MKLINK
build_mklink_cmd() {
	global RadioFile, RadioDir, RadioFileH, RadioDirH, ED_LNK, ED_SRC
	Gui, Submit, NoHide
;	GuiControlGet, lnk,, ED_LNK
;	GuiControlGet, src,, ED_SRC
	
	switch := !RadioFile  ? switch : " "
	switch := !RadioDir   ? switch : " /D"
	switch := !RadioFileH ? switch : " /H"
	switch := !RadioDirH  ? switch : " /J"
	GuiControl,, ED_CMD , % "MKLINK" . switch . " """ . ED_LNK . """ """ . ED_SRC . """"
	
	enable_button_ok()
}

;===========================
; Enable / Disable button OK
enable_button_ok() {
	global RadioFile, RadioDir, RadioFileH, RadioDirH, ED_LNK, ED_SRC
	
	Gui, Submit, NoHide
	is_dir := RadioDir || RadioDirH

	if (test_path(is_dir, ED_LNK) && test_path(is_dir, ED_SRC))
		GuiControl, Enable, BTN_OK
	else 
		GuiControl, Disable, BTN_OK
}

;===========================
; test if file/dir path
test_path(is_dir, s) {
	exists := FileExist(s)
	isdir := InStr(exists, "D")
	return is_dir ? isdir : exists && !isdir
}

;===========================
; CALL mklink
ButtonOK:
MsgBox % ED_CMD
return

GuiEscape:
ButtonCancel:
GuiClose:
ExitApp

;MsgBox RadioFile: %RadioFile% RadioDir: %RadioDir% RadioFileH: %RadioFileH% RadioDirH: %RadioDirH% switch %switch%




