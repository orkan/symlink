Gui, +hwndGui1
Gui, +resize
gui, font, s15 ; try to change the font size 
Gui, add, button, w100 hwndBut1 vBut1 section, Ok 
Gui, add, button, w100 hwndBut2 vBut2 ys, Cancel
Gui, show, w300 h100
return

GuiSize:
	gosub doTheJob
return

doTheJob:	
	rightMargin := 20, bottomMargin := 50
	WinGetPos, x,y,w,h, ahk_id %Gui1%
	ControlGetPos,,,w2,h2,,ahk_id %But2%
	ControlGetPos,,,w1,h1,,ahk_id %But1%
	GuiControl, movedraw, But1, % "x" w-(w1+w2+rightMargin) " y" h-(h1+bottomMargin)
	GuiControl, movedraw, But2, % "x" w-(w2+rightMargin)    " y" h-(h2+bottomMargin)
return

GuiClose:
GuiEscape:
    ExitApp