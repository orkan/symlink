#NoTrayIcon
#SingleInstance,force
#Include ..\symlink.inc.ahk
#Include ..\symlink.def.inc.ahk
#Include ..\symlink.lang.inc.ahk

ini  := merge_from_ini(ini,  "..\symlink.ini")
lang := merge_from_ini(lang, "..\symlink.lang.pl.ini")


_msg(printf(lang.msg.mkNoOutput), "error")