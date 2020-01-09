; This file is partial copy of: _ahk\lib\orkan.lib.ahk
; Moved here to simplify code sharing in git repo and reduce codebase of final EXE
; Not perfect idea, though

;###################################################################################################
; ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN 
;###################################################################################################

;===========================
; Load user settings from ini file and merge it with given array
merge_from_ini(obj, name) {
    if (FileExist(name)) {
        obj := object_merge(obj, ReadINI(name)) ; overwrites symlink.def.inc.ahk
    }
    return obj
}

;===========================
; Merge 2 objects recursively
; same numeric and string keys gets overwriten
object_merge(o1, o2) {
    for, key, val in o2
        o1[key] := IsObject(val) ? object_merge(o1[key], val) : val
    return o1
}

;===========================
; Merge 2 arrays
; same numeric keys gets added at the end
array_merge(a1, a2) {
    a1.Push(a2*)
    return a1
}

;===========================
; Join array elements with a string
implode(arr, str) {
    len := arr.Length()
    if !len
        return ""
    
    Loop % len - 1
        s .= arr[A_Index] . str
    
    return s . arr[len]
}

;===========================
; pseudo sprintf
; @TODO: Use Format() instead
; Tip: DllCall( "msvcrt\sprintf", Str,HexClr, Str,"%06X", UInt,RGB )
printf(msg, args*) {
    for each, s in args
        msg := StrReplace(msg, "%s", s,, 1)
    
    msg := StrReplace(msg, "\n", "`n")
    return msg
}

;===========================
; Shorten git tag version string to only: major.minor(-RC...)
get_version(str) {
    return RegExReplace(str, "(v[0-9]+)(\.[0-9]+)(\.[0-9]+)(-.+)?", "$1$2$4") ; 
}

;###################################################################################################
; EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT
;###################################################################################################

;===========================
; INI-file object maker
; https://www.autohotkey.com/boards/viewtopic.php?t=60756&p=268738
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

;===========================
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
    NumPut( normal_il := DllCall( "ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1 ), button_il, 0, Ptr ) ; Width & Height
    NumPut( L, button_il, 0 + Psz, DW )  ; Left Margin
    NumPut( T, button_il, 4 + Psz, DW )  ; Top Margin
    NumPut( R, button_il, 8 + Psz, DW )  ; Right Margin
    NumPut( B, button_il, 12 + Psz, DW ) ; Bottom Margin    
    NumPut( A, button_il, 16 + Psz, DW ) ; Alignment
    SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %Handle%
    return IL_Add( normal_il, File, Index )
}

;===========================
; RunWait Examples (AutoHotkey HELP)
; https://www.autohotkey.com/boards/viewtopic.php?t=60756&p=268738
RunWaitMany(commands) {
    shell := ComObjCreate("WScript.Shell")
    ; Open cmd.exe with echoing of commands disabled
    exec := shell.Exec(ComSpec " /Q /K echo off")
    ; Send the commands to execute, separated by newline
    exec.StdIn.WriteLine(commands "`nexit")  ; Always exit at the end!
    ; Read and return the output of all commands
    return exec.StdOut.ReadAll()
}
