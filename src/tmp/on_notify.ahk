#SingleInstance Force

Gui +AlwaysOnTop +HwndhWnd
Gui Add, Text,, Automatic sound profile change
Gui Add, Radio, gHookRadioHandler Checked, On
Gui Add, Radio, gHookRadioHandler X+, Off
Gui Font,, Consolas
Gui Add, Edit, HwndhLog xm w800 r30 ReadOnly -Wrap -WantReturn

Gui, Add, Button, , jakis button

ftspsActive := !false

; Get the dynamic identifier for shell messages and assign our callback to handle these messages
SHELL_MSG := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
OnMessage(SHELL_MSG, Func("ShellCallback"))

if (!SetHook(true)) {
    GuiControl,, Off, 1
}

Gui Show


GuiClose() {
    ExitApp
}

; Dummy implementation that logs the changes to an edit control for demonstration purposes
Run_Peace_Profile(profile) {
    Println("Switched to " profile)
}

; Sets whether the shell hook is registered
SetHook(state) {
    global hWnd
    static shellHookInstalled := false
    if (!shellHookInstalled and state) {
        if (!DllCall("RegisterShellHookWindow", "Ptr", hWnd)) {
            Println("Failed to register shell hook")
            return false
        }
        Println("Registered shell hook")
        shellHookInstalled := true
    }
    else if (shellHookInstalled and !state) {
        if (!DllCall("DeregisterShellHookWindow", "Ptr", hWnd)) {
            Println("Failed to deregister shell hook")
            return false
        }
        Println("Deregistered shell hook")
        shellHookInstalled := false
    }

    return true
}

; Radio button handler that controls registration of the sound profile hook
HookRadioHandler() {
    state := A_GuiControl == "On"
    if (!SetHook(state)) {
        GuiControl,, % (state ? "Off" : "On"), 1
    }
}

; Shell messages callback
ShellCallback(wParam, lParam) {
    ; HSHELL_WINDOWACTIVATED = 4, HSHELL_RUDEAPPACTIVATED = 0x8004
    if (wParam & 4) {
        ; lParam = hWnd of activated window
        global ftspsActive
        WinGet fnHWnd, ID, Fortnite

        WinGetTitle t, ahk_id %lParam%
        Println("active window: " t)

        if (!ftspsActive and fnHWnd = lParam) {
            Run_Peace_Profile("Ftsps")
            ftspsActive := true
        }
        else if (ftspsActive and fnHWnd != lParam) {
            Run_Peace_Profile("Graphic EQ")
            ftspsActive := false
        }
    }
}

; Prints a line to the logging edit box
Println(s) {
    global hLog
    static MAX_LINES := 1000, LINE_ADJUST := 200, nLines := 0
    ; EM_SETSEL = 0xB1, EM_REPLACESEL = 0xC2, EM_LINEINDEX = 0xBB
    if (nLines = MAX_LINES) {
        ; Delete the oldest LINE_ADJUST lines
        SendMessage 0xBB, LINE_ADJUST,,, ahk_id %hLog%
        SendMessage 0xB1, 0, ErrorLevel,, ahk_id %hLog%
        SendMessage 0xC2, 0, 0,, ahk_id %hLog%
        nLines -= LINE_ADJUST
    }
    ++nLines
    ; Move to the end by selecting all and deselecting
    SendMessage 0xB1, 0, -1,, ahk_id %hLog%
    SendMessage 0xB1, -1, -1,, ahk_id %hLog%
    ; Add the line
    str := "[" A_Hour ":" A_Min "] " s "`r`n"
    SendMessage 0xC2, 0, &str,, ahk_id %hLog%
}