#NoTrayIcon
#SingleInstance,force
#Include ..\..\_ahk\lib\orkan.lib.ahk
#Include symlink.inc.ahk
#Include symlink.def.inc.ahk
#Include symlink.lang.inc.ahk

base_name := "symlink"
version := "v0.3"

; user settings - overwrites symlink.def.inc.ahk
name_ini := base_name . ".ini"
ini  := merge_from_ini(ini,  name_ini)
; user lang - overwrites symlink.lang.inc.ahk
lang_ini := base_name . ".lang." . ini.wnd.lang . ".ini"
lang := merge_from_ini(lang, lang_ini)

Gui -MaximizeBox
Gui, Margin , 10, 10

Gui, Add, Text, w40     vLAB_LNK, % lang.window.link . ":"
Gui, Add, Text,         vLAB_SRC, % lang.window.target . ":"
Gui, Add, Edit, ys w480 gonChange_EDIT vEDIT_LNK ;, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\link3.txt
Gui, Add, Edit,    w480 gonChange_EDIT vEDIT_SRC ;, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\target.txt
; get command line args (Menu > View > Parameters (Shift+F8))
if (A_Args[1])
    GuiControl,, EDIT_LNK, % A_Args[1]
if (A_Args[2])
    GuiControl,, EDIT_SRC, % A_Args[2]

Gui, Add, Button, ys w20 h20 vBTN_LNK gonClick_BROWSE hwndBTN_LNK,
Gui, Add, Button,    w20 h20 vBTN_SRC gonClick_BROWSE hwndBTN_SRC,
GuiButtonIcon(BTN_LNK, "imageres.dll", 4)
GuiButtonIcon(BTN_SRC, "imageres.dll", 4)

Gui, Add, Text, xs w40, % lang.window.cmd . ":"
Gui, Add, Edit, xp x+m R6 w510 vEDIT_CMD ReadOnly 

; select last radio button
for key, val in ini.rad {
    ch%key% := val ; Checked1 - selected, Checked0 - unselected
    chSum += val
}
if (!chSum)
    chRAD_DIR := 1 ; go with default
Gui, Add, Radio, xp y+m gonClick_RAD vRAD_FILE   Checked%chRAD_FILE%  , % lang.window.mkFile
Gui, Add, Radio, xp x+m gonClick_RAD vRAD_DIR    Checked%chRAD_DIR%   , % lang.window.mkDir
Gui, Add, Radio, xp x+m gonClick_RAD vRAD_FILE_H Checked%chRAD_FILE_H%, % lang.window.mkFileH
Gui, Add, Radio, xp x+m gonClick_RAD vRAD_DIR_H  Checked%chRAD_DIR_H% , % lang.window.mkDirH

Gui, Add, Button, xp x+m w100 h30 vBTN_OK gonClick_BTN_OK, % lang.window.btnok
Gui, Add, Button, xp x+m w100 h30 Default gonClick_BTN_CLOSE, % lang.window.btnclose

;Gui, Add, Picture, x10 y121 w32 h32, ..\res\shell32.dll,16769.ico ; only linked!

Menu, menu_popup, Add, % lang.menu.alwaysOnTop, onClickMenu_alwaysOnTop
Menu, menu_popup, Add, % lang.menu.swapLinkTarget, onClickMenu_swapLinkTarget
Menu, menu_popup, Add
Menu, menu_popup, Add, % lang.menu.about, onClickMenu_about
Menu, menu_popup, % ini.wnd.top ? "Check" : "UnCheck", % lang.menu.alwaysontop
show_cmd()

Gui, +HwndhWndGui
Gui, Show,, % "Symlink Creator " version " (" lang.window.adminmode ": " (A_IsAdmin ? lang.window.yes : lang.window.no) ")"
; WinMove instead of Gui, Show size params because of incosistency of size values (borders, etc...)
; Gui > Show, w: -16px
; Gui > Show, h: -35px
WinMove, A,, ini.pos.x, ini.pos.y
WinSet, AlwaysOnTop, % ini.wnd.top, A

hWndGui := Format("{:u}", hWndGui) ; convert from 0x (hex) to UInt (dec)

; register even hook callback: on_activate_gui (EVENT_SYSTEM_FOREGROUND = 3)
DllCall("SetWinEventHook", "UInt", 3, "UInt", 3, "Ptr", 0, "Ptr", RegisterCallback(Func("on_activate_gui")), "Int", 0, "Int", 0, "UInt", 0, "Ptr")

return


GuiClose:
GuiEscape:
onClick_BTN_CLOSE:
save_pos_gui()
save_rad()
WriteINI(ini, name_ini)
ExitApp

;===========================
; onContextMenu:
GuiContextMenu:
Menu, menu_popup, Show
return

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

onClickMenu_about:
Gui, +OwnDialogs
_msg("Made by Orkan® <orkans@gmail.com> © 2019", "info")
return

;===========================
; Drag & Drop explorer files onto editboxes (doesn't work in admin mode due to UAC)
; https://superuser.com/questions/59051/drag-and-drop-file-into-application-under-run-as-administrator
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
onClick_BTN_OK: ; validate and run
global EDIT_LNK, EDIT_SRC, EDIT_CMD
Gui, +OwnDialogs
Gui, Submit, NoHide

arr := build_cmd()

; show errors first
for k, v in arr.err
    _msg(v.msg . (v.src ? ":`n" . v.src : ""), v.cap)

if (!arr.err.Length())
{
    ; show additional info before execution - if any
    for k, v in arr.inf
        _msg(v.msg . (v.src ? ":`n" . v.src : ""), v.cap)
    
    if (FileExist(EDIT_LNK)) {
        MsgBox, 305, Confirm Delete, Replace %EDIT_LNK%?
        IfMsgBox Cancel
            return
    }
    
    output := RunWaitMany(implode(arr.cmd, "`n"))
    
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
    out := []
    arr := build_cmd()

    for k, v in array_merge(arr.inf, arr.err)
        out.Push(A_Index . ". " . v.msg)

    cColor := arr.err.Length() ? "+cRed" : (arr.inf.Length() ? "+cGreen" : "+cDefault")
    apply_control("EDIT_CMD", cColor)
    
    out := array_merge(out, arr.cmd)
    GuiControl,, EDIT_CMD , % implode(out, "`n")
}
;===========================
; validate user input to output array:
; arr := []
; arr.err
; := [{cap: "error",   msg: "An error message", src: "D:\path\to\file1.txt"}
;    ,{cap: "error",   msg: "An error message"}]
; arr.inf
; := [{cap: "warning", msg: "A warning message"}
;    ,{cap: "info",    msg: "A info message", src: "D:\path\to\file3.txt"}]
; arr.cmd
; := ["cmd1", "cmd2", "cmd3"]
build_cmd() {
    global RAD_FILE, RAD_DIR, RAD_FILE_H, RAD_DIR_H, EDIT_LNK, EDIT_SRC, EDIT_CMD, lang
    Gui, Submit, NoHide
    
    out := {err: [], inf: [], cmd: []}
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
                    out.inf.Push({cap: "info", msg: printf(lang.msg.newPathLink, fs_type), src: new_lnk})
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

;===========================
; Foreground window change callback
on_activate_gui(_hWinEventHook, _event, _hWnd, _idObject, _idChild, _dwEventThread, _dwmsEventTime) {
    global hWndGui
    if (hWndGui = _hWnd)
        show_cmd()
}
