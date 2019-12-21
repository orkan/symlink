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
	
	new_lnk := path_validate(EDIT_LNK)
	new_src := path_validate(EDIT_SRC)
	
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
				if (!path_exist(true, parent_lnk)) {
					apply_control("LAB_LNK", "+cGreen")
					_msg(out_msg, "Info", "The parent <link> path will be created:`n" . parent_lnk)
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

;===========================
; remove dir
cmd_remove(is_dir, path) {
	return (is_dir ? "RD " : "DEL ") . path
}

;===========================
; collect commands in a given buffor
_cmd(append, ByRef buff, cmd) {
	if (append) {
		buff .= cmd . "`n"
	}
}

;===========================
; Visualize future errors
_msg(show, key, msg) {
	if (show) {
		arr := {Error: 16, Warning: 48, Info: 64}
		MsgBox, % arr[key], % key, % msg
	}
}

;===========================
; Check if empty...
check_isempty(is_dir, path) {
	return is_dir ? dir_isempty(path) : file_isempty(path)
}

;===========================
; Dir is empty?
; Return true only if dir is empty or is symlink
dir_isempty(path) {
	path := path_validate(path)
	Loop %path%\*.*, 0, 1
		return path_issymlink(path)
	return true
}

;===========================
; File is empty?
; Return true only if file is empty or is symlink
file_isempty(path) {
	FileGetSize, isempty, % path
	return isempty = 0 ? true : path_issymlink(path)
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
; File is readonly?
file_isreadonly(path) {
	attr := FileExist(path)
	return InStr(attr, "R")
}

;===========================
; test if file/dir path exists
path_exist(is_dir, s) {
	exists := FileExist(s)
	return exists
	
	; no point for distinguish file - directory
	isdir := InStr(exists, "D")
	return is_dir ? isdir : exists && !isdir
}

;===========================
; Make path valid
path_validate(path) {
	;return RTrim(path, "\")
	return path
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


;###################################################################################################
; EXTERNAL EXTERNAL EXTERNAL EXTERNAL EXTERNAL EXTERNAL EXTERNAL EXTERNAL EXTERNAL EXTERNAL EXTERNAL 
;###################################################################################################

; GuiButtonIcon
; This function allows an icon to be assigned to a Gui Button using the button's hwnd to identify the button.
; https://www.autohotkey.com/boards/viewtopic.php?t=1985
GuiButtonIcon(Handle, File, Index := 1, Options := "")
{
	RegExMatch(Options, "i)w\K\d+", W), (W="") ? W := 16 :
	RegExMatch(Options, "i)h\K\d+", H), (H="") ? H := 16 :
	RegExMatch(Options, "i)s\K\d+", S), S ? W := H := S :
	RegExMatch(Options, "i)l\K\d+", L), (L="") ? L := 0 :
	RegExMatch(Options, "i)t\K\d+", T), (T="") ? T := 0 :
	RegExMatch(Options, "i)r\K\d+", R), (R="") ? R := 0 :
	RegExMatch(Options, "i)b\K\d+", B), (B="") ? B := 0 :
	RegExMatch(Options, "i)a\K\d+", A), (A="") ? A := 4 :
	Psz := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"
	VarSetCapacity( button_il, 20 + Psz, 0 )
	NumPut( normal_il := DllCall( "ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1 ), button_il, 0, Ptr )	; Width & Height
	NumPut( L, button_il, 0 + Psz, DW )		; Left Margin
	NumPut( T, button_il, 4 + Psz, DW )		; Top Margin
	NumPut( R, button_il, 8 + Psz, DW )		; Right Margin
	NumPut( B, button_il, 12 + Psz, DW )	; Bottom Margin	
	NumPut( A, button_il, 16 + Psz, DW )	; Alignment
	SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %Handle%
	return IL_Add( normal_il, File, Index )
}

;===========================
; RunWait Examples
; return output string
RunWait_output(command) {
    return "Debuging..."
	
	; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99�
    shell := ComObjCreate("WScript.Shell")
    ; Execute a single command via cmd.exe
    exec := shell.Exec(ComSpec " /C " command)
    ; Read and return the command's output
    return exec.StdOut.ReadAll()
}
