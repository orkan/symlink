#NoTrayIcon
#SingleInstance, Force
#Include D:\Orkan\Code\Exe\AutoHotkey\Symlink\lib\wolf_II - CustomBoxes.2018\TreeBox.ahk

array_merge(a1, a2) {
	a1.Push(a2*)
	return a1
}

object_merge(o1, o2) {
	for, k, v in o2
		o1[k] := isobject(v) ? object_merge(o1[k], v) : v
	return o1
}

a1 := {a: "1", b: "2", c: ["3a", "3b", "3c", "3d"]}
a2 := {a: "4", e: "5", c: ["6a", "3b", "6c"]}
a3 := {g: "7", h: "8", i: "9"}

TreeBox(object_merge(a1, a2), "object from begin")
MsgBox, object from begin

;MsgBox % "isobject: " . isobject(a3.g)


;~ for, k, v in a1
	;~ MsgBox % "k: " . k "`n v: " . v

ExitApp
