;DEBUG
;~ ListVars
;~ Pause

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
	path := RTrim(path, "\")
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
	return InStr(FileExist(path), "R")
}

;===========================
; test if file/dir path exists
path_exist(is_dir, path) {
	attr := FileExist(path)
	isdir := InStr(attr, "D")
	return is_dir ? isdir : attr && !isdir
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

;###################################################################################################
; AutoHotkey HELP: RunWait Examples
; https://www.autohotkey.com/boards/viewtopic.php?t=60756&p=268738
;###################################################################################################
RunWait_output(command) {
    return "Debuging..."
	
	; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99¬
    shell := ComObjCreate("WScript.Shell")
    ; Execute a single command via cmd.exe
    exec := shell.Exec(ComSpec " /C " command)
    ; Read and return the command's output
    return exec.StdOut.ReadAll()
}
RunWaitMany(commands) {
    shell := ComObjCreate("WScript.Shell")
    ; Open cmd.exe with echoing of commands disabled
    exec := shell.Exec(ComSpec " /Q /K echo off")
    ; Send the commands to execute, separated by newline
    exec.StdIn.WriteLine(commands "`nexit")  ; Always exit at the end!
    ; Read and return the output of all commands
    return exec.StdOut.ReadAll()
}

;###################################################################################################
; Just another INI-file object maker
; https://www.autohotkey.com/boards/viewtopic.php?t=60756&p=268738
;###################################################################################################
WriteINI(ByRef Array2D, INI_File) { ; write 2D-array to INI-file
    for SectionName, Entry in Array2D {
        Pairs := ""
        for Key, Value in Entry
            Pairs .= Key "=" Value "`n"
        IniWrite, %Pairs%, %INI_File%, %SectionName%
    }
}
ReadINI(INI_File) { ; return 2D-array from INI-file
    Result := []
    IniRead, SectionNames, %INI_File%
    for each, Section in StrSplit(SectionNames, "`n") {
        IniRead, OutputVar_Section, %INI_File%, %Section%
        for each, Haystack in StrSplit(OutputVar_Section, "`n")
            RegExMatch(Haystack, "(.*?)=(.*)", $)
            , Result[Section, $1] := $2
    }
    return Result
}
