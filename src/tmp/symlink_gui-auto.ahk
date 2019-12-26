#NoTrayIcon
#SingleInstance, Force

;Gui -MaximizeBox +Resize +MinSize 
Gui -MaximizeBox
Gui, Margin , 10, 10

Gui, Add, Text  , w40			, Link:
Gui, Add, Text  ,    			, Source:
Gui, Add, Edit  , ys w480		, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\link.txt
Gui, Add, Edit  ,    w480		, D:\Orkan\Code\Exe\AutoHotkey\Symlink\test\target.txt
Gui, Add, Button, ys w20 h20	, B
Gui, Add, Button,    w20 h20	, B
Gui, Add, Text  , xs w40		, CMD:
Gui, Add, Edit  , xp x+m R6 w510 
Gui, Add, Radio , xp y+m 		, File
Gui, Add, Radio , xp x+m 		, Dir (/D)
Gui, Add, Radio , xp x+m 		, Hard File (/H)
Gui, Add, Radio , xp x+m 		, Hard Dir (/J)
Gui, Add, Button, xp x+m w100 h30, &OK
Gui, Add, Button, xp x+m w100 h30, Close

Gui, Show


return


GuiEscape:
ButtonClose:
GuiClose:

ExitApp
