#NoTrayIcon
#SingleInstance, Force
#Include D:\Orkan\Code\Exe\AutoHotkey\Symlink\lib\wolf_II - CustomBoxes.2018\TreeBox.ahk
#Include ..\symlink.lang.inc.ahk

_msg(type, str) {
	global lang
	arr := {error: 16, warning: 48, info: 64}
	MsgBox, % arr[type], % lang.msg[type], % str
}

implode(arr, str) {
	len := arr.Length()
	Loop % len - 1
		s .= arr[A_Index] . str
	return s . arr[len]
}

;~ arr := []
;~ arr.err
;~ := [ {cap: "error",   msg: "A message", src: "D:\path\to\file1.txt"}
	;~ ,{cap: "warning", msg: "A message"}
	;~ ,{cap: "info",    msg: "A message", src: "D:\path\to\file3.txt"}]
	
;~ arr.cmd
;~ := ["cmd1", "cmd2", "cmd3", "cmd4"]


arr := {err: [], cmd: []}
arr.err.Push({cap: "error",   msg: "A message 1", src: "D:\path\to\file1.txt"})
arr.err.Push({cap: "warning", msg: "A message 2"})
arr.err.Push({cap: "info",    msg: "A message 3", src: "D:\path\to\file3.txt"})




TreeBox(arr, "object from begin")

for k, v in arr.err {
	_msg(v.cap, v.msg . (v.src ? ":`n" . v.src : ""))
}

for k, v in arr.cmd {
	cmd .= v . "`n"
}

MsgBox % implode(arr.cmd, "`n")

ExitApp
