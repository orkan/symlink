;WinGetTitle, guiTitle, A
;WinSetTitle, ahk_id %hWndGui%,, % "hWndBtnOk: " hWndBtnOk ", guiW: " guiW ", addW: " addW

;===========================
; save window position to ini
save_pos() {
    global ini
    WinGetPos tmpX, tmpY,,, A
    ini.pos := { x: tmpX, y: tmpY}
}

;===========================
; save radiobutons state to ini
save_rad() {
    global RAD_FILE, RAD_DIR, RAD_FILE_H, RAD_DIR_H, ini
    Gui, Submit, NoHide

    for key, val in ini.rad
        ini.rad[key] := %key%
}
;===========================
; remove dir
cmd_remove(is_dir, path) {
    return (is_dir ? "RD " : "DEL ") . """" . path . """"
}

;===========================
; Visualize future errors
_msg(str, type:=64) {
    global lang
    arr := {error: 16, warning: 48, info: 64}
    MsgBox, % arr[type], % lang.msg[type], % str
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
