#NoTrayIcon
#SingleInstance

Gui, Add, Text, x12 y15 w40 h20 , Link:
Gui, Add, Text, x12 y45 w40 h20 , Source:
Gui, Add, Text, x12 y72 w40 h20 , CMD:
Gui, Add, Edit, x52 y13 w490 h20 vED_LNK
Gui, Add, Edit, x52 y43 w490 h20 vED_SRC
Gui, Add, Edit, x52 y73 w520 h80 vED_CMD
Gui, Add, Button, x552 y13 w20 h20 vBTN_LNK gButtonBTN_LNK,
Gui, Add, Button, x552 y43 w20 h20 vBTN_SRC gButtonBTN_SRC,
Gui, Add, Radio, x52 y163 w40 h20 , File
Gui, Add, Radio, x102 y163 w60 h20 Checked, Dir (/D)
Gui, Add, Radio, x172 y163 w80 h20 , Hard File (/H)
Gui, Add, Radio, x272 y163 w90 h20 , Hard Dir (/J)
Gui, Add, Button, x362 y163 w100 h30 , &OK
Gui, Add, Button, Default x472 y163 w100 h30 , &Cancel
Gui, +OwnDialogs ;+AlwaysOnTop
Gui, Show, w584 h206, Symlink Creator
return


; handle Drop & Down explorer files onto editboxes
GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
	if (A_GuiControl = "ED_LNK" or A_GuiControl = "ED_SRC")
		GuiControl,, %A_GuiControl%, % FileArray[1]
}


; Browse for a file
ButtonBTN_LNK:
ButtonBTN_SRC:
dir := "C:\"
ed_id := StrReplace(A_GuiControl, "BTN", "ED")
GuiControlGet, ed_txt,, %ed_id%
path_info := FileExist(ed_txt)

if (path_info) {
	; is directory
	if(InStr(path_info, "D")) { 
		dir := ed_txt
	}
	; is file
	else {
		SplitPath, path_info,, dir
	}
}

FileSelectFolder, dir, % "*" . dir, 3
; save new path if not empty
if (dir) { 
	GuiControl,, %ed_id% , %dir%
}
return


ButtonBTN_SRC_:
MsgBox "A_GuiControl: " . %A_GuiControl%
;Gui, Submit, NoHide
GuiControlGet, ED_SRC
FileSelectFolder, dir_link, *%ED_SRC%, 3, Select Source folder
return

ButtonOK:
;MsgBox Wykonaj
return

GuiEscape:
ButtonCancel:
GuiClose:
ExitApp