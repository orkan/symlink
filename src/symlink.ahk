#NoTrayIcon
#SingleInstance force
#Include ..\..\_ahk\lib\orkan.lib.ahk
#Include symlink.inc.ahk
#Include symlink.ver.ahk
#Include symlink.def.inc.ahk
#Include symlink.lang.inc.ahk

base_name := "symlink"
version := RegExReplace(git_version, "(v[0-9]+)(\.[0-9]+)(\.[0-9]+)(-.+)?", "$1$2$4") ; only: major.minor(-RC...)

; user settings - overwrites symlink.def.inc.ahk
name_ini := base_name . ".ini"
ini  := merge_from_ini(ini,  name_ini)
; user lang - overwrites symlink.lang.inc.ahk
lang_ini := base_name . ".lang." . ini.wnd.lang . ".ini"
lang := merge_from_ini(lang, lang_ini)

edW := 478 ; initial edit width
ecW := 510 ; initial cmd width
lbW :=  40 ; labels width

Gui, Add, Text, w%lbW%    vLAB_LNK, % lang.window.link . ":"
Gui, Add, Text,           vLAB_SRC, % lang.window.target . ":"
Gui, Add, Edit, ys w%edW% gonChange_EDIT vEDIT_LNK ;, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\link3.txt
Gui, Add, Edit,    w%edW% gonChange_EDIT vEDIT_SRC ;, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\target.txt
; get command line args (Menu > View > Parameters (Shift+F8))
if (A_Args[1])
    GuiControl,, EDIT_LNK, % A_Args[1]
if (A_Args[2])
    GuiControl,, EDIT_SRC, % A_Args[2]

Gui, Add, Button, ys w22 h22 vBTN_LNK hwndhWndBtnLnk gonClick_BROWSE ; vBTN_LNK - for GuiControl, and hWnd for ControlGetPos - ROTFL!
Gui, Add, Button,    w22 h22 vBTN_SRC hwndhWndBtnSrc gonClick_BROWSE ; vBTN_SRC

Gui, Add, Text, xs w%lbW%, % lang.window.cmd . ":"
Gui, Add, Edit, xp x+m R6 w%ecW% vEDIT_CMD ReadOnly 

; select last radio button
for key, val in ini.rad {
    %key% := val
    radCurrent := val ? key : radCurrent
}
Gui, Add, Radio, xp y+m gonClick_RAD vRAD_FILE   Checked%RAD_FILE%  , % lang.window.mkFile ; Checked1 - selected, Checked0 - unselected
Gui, Add, Radio, xp x+m gonClick_RAD vRAD_DIR    Checked%RAD_DIR%   , % lang.window.mkDir
Gui, Add, Radio, xp x+m gonClick_RAD vRAD_FILE_H Checked%RAD_FILE_H%, % lang.window.mkFileH
Gui, Add, Radio, xp x+m gonClick_RAD vRAD_DIR_H  Checked%RAD_DIR_H% , % lang.window.mkDirH

Gui, Add, Button, xp x+m w100 h30 vBTN_OK hwndhWndBtnOk gonClick_BTN_OK        , % lang.window.btnok
Gui, Add, Button, xp x+m w100 h30 vBTN_CL hwndhWndBtnCl gonClick_BTN_CL Default, % lang.window.btnclose

Menu, menu_popup, Add, % lang.menu.alwaysOnTop, onClickMenu_alwaysOnTop
Menu, menu_popup, Add, % lang.menu.swapLinkTarget, onClickMenu_swapLinkTarget
Menu, menu_popup, Add
Menu, menu_popup, Add, % lang.menu.about, onClickMenu_about
Menu, menu_popup, % ini.wnd.top ? "Check" : "UnCheck", % lang.menu.alwaysontop
show_cmd()

; GUI Show!
Gui, % "+Resize +MinSize +HwndhWndGui " (ini.wnd.top ? "+AlwaysOnTop" : "")
Gui, Show,, % "Symlink Creator " version " (" lang.window.adminmode ": " (A_IsAdmin ? lang.window.yes : lang.window.no) ")"

; convert from 0x (hex) to UInt (dec)
hWndGuiDec := Format("{:u}", hWndGui)

; register even hook callback: on_activate_gui (EVENT_SYSTEM_FOREGROUND = 3)
DllCall("SetWinEventHook", "UInt", 3, "UInt", 3, "Ptr", 0, "Ptr", RegisterCallback(Func("on_activate_gui")), "Int", 0, "Int", 0, "UInt", 0, "Ptr")
update_icon_browse(radCurrent)
return

; Restore last GUI size & pos
GuiSize:
guiW := A_GuiWidth ; remember last resize to save in INI on exit

if (!initGuiW) {
	initGuiW := A_GuiWidth ; 581
    guiW := ini.pos.w ? ini.pos.w : A_GuiWidth

    ; get initial button positions
    ControlGetPos, btnOkX,,,,, ahk_id %hWndBtnOk%
    ControlGetPos, btnClX,,,,, ahk_id %hWndBtnCl%
    ControlGetPos, BtnLnkX,,,,, ahk_id %hWndBtnLnk% 
    ControlGetPos, BtnSrcX,,,,, ahk_id %hWndBtnSrc%
    btnOkX -= 8
    btnClX -= 8
    BtnLnkX -= 8
    BtnSrcX -= 8

    ; set initial gui size here - not in Gui, Show because of remembering +MinSize
    WinMove, ahk_id %hWndGui%,, ini.pos.x, ini.pos.y, guiW + 16
	Gui, % "+MaxSizex" A_GuiHeight ; block Gui height
    
    ; is Maximized?
    if (ini.wnd.max = -1) {
        WinMinimize, ahk_id %hWndGui%
        initMinMax := 0
    }
    ;~ else if (ini.wnd.max = 1) {
        ;~ WinMaximize, ahk_id %hWndGui% ; Doesn't update controls. Needs redraw !!!
        ;~ WinSet, Redraw,, ahk_id %hWndGui% ; Doesn't work either
    ;~ }
}
    
offset := guiW - initGuiW
GuiControl, movedraw, EDIT_LNK, % "w" offset + edW
GuiControl, movedraw, EDIT_SRC, % "w" offset + edW ; 478 ; initial edit width
GuiControl, movedraw, EDIT_CMD, % "w" offset + ecW ; 510 ; initial cmd width
GuiControl, movedraw, BTN_OK  , % "x" offset + btnOkX ; movedraw - auto redraw otherwise afterfacts
GuiControl, movedraw, BTN_CL  , % "x" offset + btnClX
GuiControl, movedraw, BTN_LNK , % "x" offset + BtnLnkX
GuiControl, movedraw, BTN_SRC , % "x" offset + BtnSrcX
return

GuiClose:
GuiEscape:
onClick_BTN_CL:
save_pos()
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
MsgBox, 64, % Format("{:T} {:s} (rev. {:s})", base_name, git_version, git_revision), % "AutoHotkey GUI for MKLINK command line tool`n2019 © Orkan <orkans@gmail.com> "
return

;===========================
; Drag & Drop explorer files onto editboxes (doesn't work in admin mode due to UAC)
; https://superuser.com/questions/59051/drag-and-drop-file-into-application-under-run-as-administrator
GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
    if (A_GuiControl = "EDIT_LNK" or A_GuiControl = "EDIT_SRC")
        GuiControl,, %A_GuiControl%, % FileArray[1]
}

update_icon_browse(rad) {
    global hWndBtnLnk, hWndBtnSrc
    is_filelink := rad = "RAD_FILE" || rad = "RAD_FILE_H"
    icon_browse := is_filelink ? 3 : 4
    GuiButtonIcon(hWndBtnLnk, "imageres.dll", icon_browse)
    GuiButtonIcon(hWndBtnSrc, "imageres.dll", icon_browse)
}

onClick_RAD:
update_icon_browse(A_GuiControl)
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
    global hWndGuiDec
    if (_hWnd = hWndGuiDec)
        show_cmd()
}
