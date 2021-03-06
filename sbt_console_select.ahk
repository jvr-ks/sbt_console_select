/*
 *********************************************************************************
 * 
 * sbt_console_select.ahk
 * 
 * use UTF-8 BOM codec
 * 
 * Version -> appVersion
 * 
 * Copyright (c) 2020 jvr.de. All rights reserved.
 *
 *
 *********************************************************************************
*/

/*
 *********************************************************************************
 * 
 * MIT License
 * 
 * 
 * Copyright (c) 2020 jvr.de. All rights reserved.
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sub-license, and/or sell copies 
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all 
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT-ABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE 
 * UTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
  *********************************************************************************
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance force
#Persistent

#Include, Lib\ahk_common.ahk
#Include, Lib\WinGetPosEx.ahk

OwnPID := DllCall("GetCurrentProcessId")

msgDefault := ""

;---------------------------------- appName ----------------------------------
appName := "sbt_console_select"
appVersion := "0.160"
app := appName . " " . appVersion

SetWorkingDir, %A_ScriptDir%

wrkDir := A_ScriptDir . "\"
replExecFile := wrkDir . "replExec.tmp"
replFile := wrkDir . "repl.tmp"

FileEncoding, UTF-8-RAW

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

posXsave := 0
posYsave := 0

CoordMode, Mouse, Screen

nomenu := false

lastOpendTitle := "???"

holdtimeDefault := 3000 ; milliseconds
holdtime := holdtimeDefault

fontDefault := "Calibri"
font := fontDefault

fontsizeDefault := 10
fontsize := fontsizeDefault

listWidthDefault := 700

cmdFile := "sbt_console_select.txt"
configFile := "sbt_console_select.ini"
jhomeFile := "sbt_console_select_jhome.txt"
shortcutsFile  := "sbt_console_select_shortcuts.txt"

emailPathDefault := "C:\Program Files (x86)\Mozilla Thunderbird\thunderbird.exe"
filemanagerPathDefault := "%SystemRoot%\explorer.exe"

; overwritten by ini-file
emailpath := emailPathDefault
filemanagerpath := filemanagerPathDefault

;------------------------------------ WSL ------------------------------------
WSL := "C:\Windows\System32\wsl.exe"

menuhotkeyDefault := "!t"
menuhotkey := menuhotkeyDefault

replLoadHotkeyDefault := "!e"
replLoadHotkey := replLoadHotkeyDefault

replSelectLoadhotkeyDefault := "^e"
replSelectLoadhotkey := replSelectLoadhotkeyDefault

replSelectLoadExecHotkeyDefault := "+!e"
replSelectLoadExecHotkey := replSelectLoadExecHotkeyDefault

replResethotkeyDefault := "^r"
replResethotkey := replResethotkeyDefault

exitHotkeyDefault := "+!t"
exitHotkey := exitHotkeyDefault

javaTool := ""
javaOpts := ""

;------------------------------- Gui parameter -------------------------------
activeWin := 0

windowPosX := 0
windowPosY := 0
windowWidth := 0
windowHeight := 0

windowPosFixed := false

windowWidthDefault := Round(A_ScreenWidth/2)
windowHeightDefault := Round(A_ScreenHeight/2)
;----------------------------------------------------------------------------
entryNameArr := {}
entryIndexArr := []
directoriesArr := []
startcmdArr := []
javaHomeArr := {}
javaIndexArr := []
javaOptsArr := []
javaToolArr := []
shortcutsArr := {}
replcommandsArr := []
;---------------------------------- Params ----------------------------------
hideOnStartup := false
autoselectName := ""

MouseGetPos, posXsave, posYsave

Loop % A_Args.Length()
{
	if(eq(A_Args[A_index],"remove"))
		exit()
	
	if(eq(SubStr(A_Args[A_index],-3,4),".ini"))
		configFile := A_Args[A_index]
		
	if(eq(SubStr(A_Args[A_index],-3,4),".txt"))
		cmdFile := A_Args[A_index]
		
	if(eq(A_Args[A_index],"hidewindow")){
		hideOnStartup := true
	}
	
	FoundPos := RegExMatch(A_Args[A_index], "^[0-9]+$" , argsParam)
	if(FoundPos > 0){
		msgbox, Entry selection by number is not supported anymore, please use an entry-name instead!
		exit()
	}
	
	FoundPos := RegExMatch(A_Args[A_index], "\[.+?]" , argsParam)
	if(FoundPos > 0){
		autoSelectName := argsParam
		;msgbox, % autoselectName
	}
}

cmdFile := resolvepath(wrkDir,cmdFile)
configFile := resolvepath(wrkDir,configFile)
jhomeFile := resolvepath(wrkDir,jhomeFile)
shortcutsFile := resolvepath(wrkDir,shortcutsFile)

readIni()
readCmd()
readShortcuts()
readGuiParam()

if (!hideOnStartup){
	mainWindow()
} else {
	msg1 := "Command-file: " . cmdFile . "`,Config-file: " . configFile . "`,Menu-hotkey is: " . hotkeyToText(menuhotkey)
	tipTopTime(msg1, 4000)
	mainWindow(hideOnStartup)
}
	
return
;-------------------------------- mainWindow --------------------------------
mainWindow(hide := false) {
	global hMain
	global windowPosX
	global windowPosY
	global windowWidth
	global windowHeight
	global font
	global fontsize
	global wrkDir
	
	global cmdFile
	global configFile
	global shortcutsFile
	global jhomeFile
	
	global entryNameArr
	global entryIndexArr
	global directoriesArr
	global startcmdArr
	global javaHomeArr
	global javaIndexArr
	global javaToolArr
	global javaOptsArr
	

	global app
	global appName
	global posXsave
	global posYsave
	global appVersion
	global menuhotkey
	global exitHotkey

	global LV1
	global OwnPID
	global listWidthDefault
	global msgDefault
	global autoselectName
	
	Menu, Tray, UseErrorLevel   ; This affects all menus, not just the tray.
	
	Menu, MainMenu, DeleteAll
	Menu, MainMenuEdit, DeleteAll
	
	Menu, MainMenuEdit,Add,Edit Command-file: "%cmdFile%",editCmdFile
	Menu, MainMenuEdit,Add,Edit Config-file: "%configFile%",editConfigFile
	Menu, MainMenuEdit,Add,Edit Shortcuts-file: "%shortcutsFile%",editShortcutsFile
	Menu, MainMenuEdit,Add,Edit JavaHome-file: "%jhomeFile%",editJHomeFile

	Menu, MainMenu, NoDefault
	Menu, MainMenu, Add,Edit,:MainMenuEdit
	Menu, MainMenu, Add,Github,openGithubPage
	exitText := "Close app and remove it from memory!" 
	Menu, MainMenu, Add,%exitText%,exit
	
	Gui,guiMain:New,+E0x08000000 +OwnDialogs +LastFound MaximizeBox HwndhMain +Resize, %app%
	
	Gui, guiMain:Font, s%fontsize%, %font%

	xStart := 5
	yStart := 5
	linesInList := directoriesArr.length()
	Gui, Add, ListView, x%xStart% y%yStart% r%linesInList% w%listWidthDefault% gLVCommands vLV1 Grid AltSubmit -Multi, |Name|Directory|Command|JDK|JAVA_OPTS|JAVA_TOOL_OPTIONS

	Loop % directoriesArr.length()	
	{
		LV_Add("",A_index,entryIndexArr[A_index],directoriesArr[A_index], startcmdArr[A_index], javaIndexArr[A_index], javaOptsArr[A_index], javaToolArr[A_index])
	}

	LV_ModifyCol(1,"Auto Integer")
	LV_ModifyCol(2,"Auto")
	LV_ModifyCol(3,"Auto")
	LV_ModifyCol(4,"Auto")
	LV_ModifyCol(5,"Auto")
	LV_ModifyCol(6,"Auto")
	LV_ModifyCol(7,"Auto")
	
	Gui, guiMain:Add, StatusBar,,
	
	showMessage("", msgDefault)
	
	Gui, guiMain:Menu, MainMenu
		
	if (!hide){
		checkVersionFromGithub()
		
		setTimer,checkFocus,3000
		setTimer,registerWindow,-500
		Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%windowWidth% h%windowHeight%
	}
	
	if (autoselectName != ""){
		hideWindow()
		runInDir(entryNameArr[autoselectName])
		autoselectName := ""
	}
	OnMessage(0x200, "WM_MOUSEMOVE")
	OnMessage(0x2a3, "WM_MOUSELEAVE")

	return
}
;------------------------------ registerWindow ------------------------------
registerWindow(){
	global activeWin
	
	activeWin := WinActive("A")
		
	return
}
;******************************** checkFocus ********************************
checkFocus(){
	global hMain
	global activeWin
	global windowPosX
	global windowPosY
	global windowWidth
	global windowHeight

	global configFile

	h := WinActive("A")
	if (activeWin != h){
		hideWindow()
	} else {
		static xOld := 0
		static yOld := 0
		static wOld := 0
		static hOld := 0

		WinGetPosEx(hMain,xn1,yn1,wn1,hn1,Offset_X1,Offset_Y1)
		hn1 := hn1 - 129
		xn1 := xn1 + Offset_X1
		
		hn1 := Min(Round(A_ScreenHeight * 0.9),hn1)
		wn1 := Min(Round(A_ScreenWidth * 0.9),wn1)
		
		yn1 := Min(Round(A_ScreenHeight - hn1),yn1)
		xn1 := Min(Round(A_ScreenWidth - wn1),xn1)

		if (xOld != xn1 || yOld != yn1 || wOld != wn1 || hOld != hn1){
		;Tiptop(hn1 . "/" . hOld . "/" . Offset_X1)
			
			xOld := xn1
			yOld := yn1
			wOld := wn1
			hOld := hn1
			
			IniWrite, %xn1% , %configFile%, config, windowPosX
			IniWrite, %yn1%, %configFile%, config, windowPosY
			
			IniWrite, %wn1% , %configFile%, config, windowWidth
			IniWrite, %hn1%, %configFile%, config, windowHeight
		}
	}
	
	return
}
;*********************************** readIni ******************************
readIni(){
	global msgDefault
	global configFile
	global menuhotkeyDefault
	global menuhotkey
	global replLoadHotkeyDefault
	global replLoadHotkey
	global replSelectLoadHotkeyDefault
	global replSelectLoadHotkey
	global replSelectLoadExecHotkeyDefault
	global replSelectLoadExecHotkey
	global replResetHotkeyDefault
	global replResetHotkey
	global exitHotkeyDefault
	global exitHotkey

	global filemanagerpath
	global filemanagerpathDefault
	
	global emailpath
	global emailPathDefault
	
	global fontDefault
	global font
	global fontsizeDefault
	global fontsize

	global listWidthDefault
	global replcommandsArr
	global javaTool
	global javaOpts
	

; read Hotkey definition
	IniRead, menuhotkey, %configFile%, hotkeys, menuHotkey , %menuhotkeyDefault%
	Hotkey, %menuhotkey%, showWindowRefreshed
	
	IniRead, replLoadHotkey, %configFile%, hotkeys, replLoadHotkey , %replLoadHotkeyDefault%
	Hotkey, %replLoadHotkey%, replLoad
	
	IniRead, replSelectLoadhotkey, %configFile%, hotkeys, replSelectloadhot , %replSelectLoadhotkeyDefault%
	Hotkey, %replSelectLoadhotkey%, replSelectLoad
	
	IniRead, replSelectLoadExecHotkey, %configFile%, hotkeys, replSelectloadhot , %replSelectLoadExecHotkeyDefault%
	Hotkey, %replSelectLoadExecHotkey%, replSelectLoadExec
	
	IniRead, replResethotkey, %configFile%, hotkeys, replResethot , %replResethotkeyDefault%
	Hotkey, %replResethotkey%, replReset
	
	IniRead, exitHotkey, %configFile%, hotkeys, exitHotkey , %exitHotkeyDefault%
	Hotkey, %exitHotkey%, sendExit
	
	IniRead, filemanagerpath, %configFile%, external, filemanagerpath , %filemanagerpathDefault%
	IniRead, emailpath, %configFile%, external, emailpath, %emailPathDefault%
	
	IniRead, font, %configFile%, config, font, %fontDefault%
	IniRead, fontsize, %configFile%, config, fontsize, %fontsizeDefault%
	
	IniRead, javaOpts,%configFile%,config,JAVA_OPTS,%A_Space%
	IniRead, javaTool,%configFile%,config,JAVA_TOOL_OPTIONS,%A_Space%
	
	blank := "-"
	replcommandsArr := []
	Loop, 10
	{
		replcommand%A_Index% := blank
		IniRead, replcommand%A_Index%, %configFile%, replcommands, replcommand%A_Index%,%blank%
		if (replcommand%A_Index% != blank)
			replcommandsArr.push(replcommand%A_Index%)
	}
	
	msgDefault := "Click + [CTRL] -> filemanager, Click + [SHIFT] -> build.sbt, Click +  [Capslock] -> use WSL"
	
	return
}
;--------------------------------- replLoad ---------------------------------
replLoad_dpre(){
	global replcommandsArr
	global lastOpendTitle

	winActivate,ahk_exe notepad++.exe
	Send {Ctrl down}s{Ctrl up}

	SetTitleMatchMode, 2
	winFound := false
	
	if WinExist(lastOpendTitle){
		winActivate,%lastOpendTitle%
		winFound := true
	} else {
		if WinExist("ahk_class ConsoleWindowClass"){
			winActivate,ahk_class ConsoleWindowClass
			winFound := true
		}
	}
	
	if (winFound){
		tipWindow("Press [CTRL]-key to return to Notepad2!")
		
		l := replcommandsArr.length()
		Loop, %l%
		{
			toSend := replcommandsArr[A_Index]
			if (toSend != "" && !InStr(toSend,"//")){
				SendInput,{text}%toSend%
				SendInput,{Enter}
			}
		}

		KeyWait,Control,D
		tipWindowClose()
		winActivate,ahk_exe notepad++.exe
	} else {
		msgbox, No suitable Console-Window found!
	}
	
	return
}

;--------------------------------- replLoad ---------------------------------
replLoad(){
	replLoadAction(true)
	return
}
;------------------------------ replSelectLoad ------------------------------
replSelectLoad(){
	replLoadAction(false)
	return
}
;------------------------------ replLoadAction ------------------------------
replLoadAction(selectAll := false){
	global replcommandsArr
	global lastOpendTitle
	global replFile
	global replExecFile
	
	if (selectAll){
		Send {Ctrl down}a{Ctrl up}
		sleep,200
	}

	Send {Ctrl down}c{Ctrl up}
	
	if (clipboard != ""){
		code := clipboard
		
		if (code != ""){
			FileDelete, %replFile%
			FileAppend , %code%, %replFile%
			FileAppend ,`n, %replFile%
			
			SetTitleMatchMode, 2
			winFound := false
			
			if WinExist(lastOpendTitle){
				winActivate,%lastOpendTitle%
				winFound := true
			} else {
				if WinExist("ahk_class ConsoleWindowClass"){
					winActivate,ahk_class ConsoleWindowClass
					winFound := true
				}
			}
			
			if (winFound){
				l := replcommandsArr.length()
				Loop, %l%
				{
					toSend := replcommandsArr[A_Index]
					
					isLoad := RegExMatch(toSend, "i)--load the code--")
					
					if (isLoad)
						if (FileExist(replFile))
							toSend := ":load " . replFile
					
					if (toSend != "" && !InStr(toSend,"//") && !InStr(toSend,"--load the code")){
						SendInput,{text}%toSend%
						SendInput,{Enter}
					}
					
					isLoadExec := RegExMatch(toSend, "i)--load the codeExec--")
					
					if (isLoadExec)
						if (FileExist(replExecFile))
							toSend := ":load " . replExecFile
					
					if (toSend != "" && !InStr(toSend,"//") && !InStr(toSend,"--load the code")){
						SendInput,{text}%toSend%
						SendInput,{Enter}
					}
					
				}
				tipWindow("Press [CTRL]-key to return to Notepad2!")
				
				KeyWait,Control,D
				tipWindowClose()
				winActivate,ahk_exe notepad++.exe
			
			} else {		
				msgbox, No suitable Console-Window found!
			}		
		} else {
			msgbox, No code to run in REPL selected!
		}
	} else {
		msgbox, Clipboard is empty or contains wrong data-type!
	}

	return
}
;---------------------------- replSelectLoadExec ----------------------------
replSelectLoadExec(){
	; save exec-code to file "replExec.tmp"
	
	global replExecFile
	
	Send {Ctrl down}c{Ctrl up}
	
	if (clipboard != ""){
		code := clipboard
		
		if (code != ""){
			FileDelete, %replExecFile%
			FileAppend , %code%, %replExecFile%
			FileAppend ,`n, %replExecFile%
			
			tipTopTime("Saved EXEC-part: `n" . code, 5000)
		}
	}
	
	return
}
;------------------------------ replReset ------------------------------
replReset(){
	global lastOpendTitle
	global replExecFile
	
	SetTitleMatchMode, 2
	winFound := false
	
	isWin := WinActive("A")
	
	if WinExist(lastOpendTitle){
		winActivate,%lastOpendTitle%
		winFound := true
	} else {
		if WinExist("ahk_class ConsoleWindowClass"){
			winActivate,ahk_class ConsoleWindowClass
			winFound := true
		}
	}
	
	if (winFound){
		toSend := ":reset`n"
		SendInput,{text}%toSend%
		
		if (FileExist(replExecFile))
			FileDelete, %replExecFile%
			
		tipWindow("Press [CTRL]-key to return to previous window!")
		KeyWait,Control,D
		tipWindowClose()
		winActivate,ahk_id %isWin%
	} else {
		tipWindow("No approbiate console-window found!")
	}
	
	return
}
;*********************************** readCmd ******************************
readCmd(){
	global wrkDir
	global cmdFile
	global configFile
	global shortcutsFile
	global jhomeFile
	
	global entryNameArr
	global entryIndexArr
	global directoriesArr
	global startcmdArr
	global javaHomeArr
	global javaIndexArr
	global javaToolArr
	global javaOptsArr
	
	
; read path and sbtstarttype
	entryNameArr := {}
	entryIndexArr := []
	entryIndexArr := []
	directoriesArr := []
	startcmdArr := []
	javaHomeArr := {}
	javaIndexArr := []
	javaOptsArr := []
	javaToolArr := []

	Loop, read, %cmdFile%
	{
		LineNumber := A_Index
		
		if (A_LoopReadLine != "") {
			directoriesArr.Push("")
			startcmdArr.Push("")
		
			Loop, parse, A_LoopReadLine, %A_Tab%`,
				{
					if (A_Index = 1){
						s := A_LoopField
						if (s == "-auto-")
							s := "[entry" . LineNumber . "]"
							
						entryNameArr[s] := LineNumber
						entryIndexArr[LineNumber] := s
					}
						
					if (A_Index = 2)
						directoriesArr[LineNumber] := A_LoopField
						
					if (A_Index = 3)
						startcmdArr[LineNumber] := A_LoopField
						
					if (A_Index = 4){
						javaHomeArr[A_LoopField] := LineNumber
						javaIndexArr[LineNumber] := A_LoopField
					}
						
					if (A_Index = 5)
						javaOptsArr[LineNumber] := A_LoopField
						
					if (A_Index = 6)
						javaToolArr[LineNumber] := A_LoopField
				}
		}
	}

	readJhome()

	return
}
;********************************* readJhome *********************************
readJhome(){
	global wrkDir
	global jhomeFile
	global javaHomeArr
	
	javaHomeArr := {}

	Loop, read, %jhomeFile%
	{
		LineNumber := A_Index
		
		if (A_LoopReadLine != "") {
		
			Loop, parse, A_LoopReadLine, %A_Tab%`,
			{
				if (A_Index = 1)
					key:= A_LoopField

				if (A_Index = 2)
					value := A_LoopField
			}
				
			javaHomeArr[key] := value
		}
	}

	return
}
; *********************************** readShortcuts ******************************
readShortcuts(){
	global wrkDir
	global shortcutsArr
	global shortcutsFile
	
	shortcutsArr := {}

	Loop, read, %shortcutsFile%
	{
		LineNumber := A_Index
		shortcutName := ""
		shortcutReplace := ""
		
		if (A_LoopReadLine != "") {
			Loop, parse, A_LoopReadLine, %A_Tab%`,
			{	
				if(A_Index == 1)
					shortcutName := A_LoopField
					
				if(A_Index == 2)
					shortcutReplace := A_LoopField
			}
			shortcutsArr[shortcutName] := shortcutReplace
		}
	}
	
	return
}

;-------------------------------- refreshGui --------------------------------
refreshGui(){
	global appName
	global entryNameArr
	global entryIndexArr
	global directoriesArr
	global startcmdArr
	global javaHomeArr
	global javaIndexArr
	global javaOptsArr
	global javaToolArr

	LV_Delete()
	
	Loop % directoriesArr.length()	
	{
		LV_Add("",A_index,entryIndexArr[A_index],directoriesArr[A_index], startcmdArr[A_index], javaIndexArr[A_index], javaOptsArr[A_index], javaToolArr[A_index])
	}
	
	return
}
;****************************** guiMainGuiSize ******************************
guiMainGuiSize:
; Expand or shrink the ListView in response to the user's resizing of the window.

SetTimer %A_ThisLabel%,Off
	
if (A_EventInfo = 1)  ; The window has been minimized. No action needed.
		return

borderX := 10
borderY := 50 ; reserve some space for statusbar and scrollbar

GuiControl, Move, LV1, % "W" . (A_GuiWidth - borderX) . " H" . (A_GuiHeight - borderY)

return
; *********************************** showWindow ******************************
showWindow(){
	global windowPosX
	global windowPosY
	global windowWidth
	global windowHeight
	
	setTimer,checkFocus,3000
	setTimer,registerWindow,-500
	Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%windowWidth% h%windowHeight%
	
	return
}
;********************************* hideWindow *********************************
hideWindow(){
	setTimer,checkFocus,delete
	Gui,guiMain:Hide

	return
}
;---------------------------- showWindowRefreshed ----------------------------
showWindowRefreshed(){
	global appName
	global menuhotkey
	global msgDefault
	global OwnPID

	readIni()
	readCmd()
	readShortcuts()
	readGuiParam()
	showWindow()
	refreshGui()
	
	showMessage("", msgDefault)
	
	return
}
;******************************** LVCommands ********************************
LVCommands(){
	if (A_GuiEvent = "Normal"){
		runInDir(A_EventInfo) 
	}

	return
}
;*********************************** runInDir ******************************
runInDir(lineNumber){
	global holdtime
	global sbtstarttype
	global lastOpendTitle
	global filemanagerpath
	global WSL
	
	global entryNameArr
	global entryIndexArr
	global directoriesArr
	global startcmdArr
	global javaHomeArr
	global javaIndexArr
	global javaToolArr
	global javaOptsArr
	
	global replSelectLastDirUsed
	global javaTool
	global javaOpts


	lastOpendTitle := "Console: " . javaIndexArr[lineNumber] . " (id: " . A_Now . ")"
	
	d := cvtPath(directoriesArr[lineNumber])
	replSelectLastDirUsed := d
	
	sw := 0
	startApp := ""
	qMark := """"
	bl := " "
	
	if (GetKeyState("Ctrl", "P") == 1)
		sw := 1
	
	if (GetKeyState("Shift", "P") == 1)
		sw := 2
		
	if (GetKeyState("Capslock", "T") == 1)
		sw := 4
		
	switch sw
	{
		case 0,1:
			; normal or  Ctrl = + Filemanager
			
			if (sw == 1){
				SetWorkingDir,%d%
				startApp := cvtPath(filemanagerpath) . bl . qMark . d . qMark
				Run, %startApp%,%d%,max
				sleep, 3000
			}
			
			jHArr := javaHomeArr[javaIndexArr[lineNumber]]
			jSplit := StrSplit(jHArr,"#") ; JDK,SDK
			jH := jSplit[1]
			sH := jSplit[2]

			jOpts := javaOptsArr[lineNumber]
			jTool := javaToolArr[lineNumber]

			startEnv := cvtPath("%comspec%") . " /k" 
			lineArr := StrSplit(startcmdArr[lineNumber],"#")
			startCmd := lineArr[1]
			param := lineArr[2]
			
			SetTitleMatchMode, 2
			
			Run, %startEnv%,%d%,max
			sleep, 3000
			
			title := "cmd.exe"
			if WinExist(title){
				winActivate,%title%
				toSend := "title " . lastOpendTitle
				SendInput,{text}%toSend%
				SendInput,{ENTER}
				sleep, 500
			} else {
				msgbox, Command could not finish because window was switched to early (or closed)!
				return
			}
				
			if WinExist(lastOpendTitle){
				if (jH != ""){
					winActivate,%lastOpendTitle%
					toSend := "set ""JAVA_HOME=" . jH . """"
					SendInput,{text}%toSend%
					SendInput,{ENTER}
				}
			} else {
				msgbox, Command could not finish because window was switched to early (or closed)!
				return
			}
			
			if WinExist(lastOpendTitle){
				if (sH != ""){
					winActivate,%lastOpendTitle%
					toSend := "set ""SCALA_HOME=" . sH . """"
					SendInput,{text}%toSend%
					SendInput,{ENTER}
				}
			} else {
				msgbox, Command could not finish because window was switched to early (or closed)!
				return
			}
			
			if WinExist(lastOpendTitle){
				if (StrLen(javaOpts) > 0 && javaOpts != "ERROR" && StrLen(jOpts) < 2 && jOpts != "-"){
					winActivate,%lastOpendTitle%
					toSend := "set ""JAVA_OPTS=" . javaOpts . """"
					SendInput,{text}%toSend%
					SendInput,{ENTER}
				}
			} else {
				msgbox, Command could not finish because window was switched to early (or closed)!
				return
			}
				
			if WinExist(lastOpendTitle){
				if (StrLen(javaTool) > 0 && javaTool != "ERROR" && StrLen(jTool) < 2 && jTool != "-"){
					winActivate,%lastOpendTitle%
					toSend := "set ""JAVA_TOOL_OPTIONS=" . javaTool . """"
					SendInput,{text}%toSend%
					SendInput,{ENTER}
				}
			} else {
				msgbox, Command could not finish because window was switched to early (or closed)!
				return
			}
				
			if WinExist(lastOpendTitle){
				if (StrLen(jOpts) > 0 && jOpts != "-"){
					winActivate,%lastOpendTitle%
					toSend := "set ""JAVA_OPTS=" . jOpts . """"
					SendInput,{text}%toSend%
					SendInput,{ENTER}
				}
			} else {
				msgbox, Command could not finish because window was switched to early (or closed)!
				return
			}
				
			if WinExist(lastOpendTitle){
				if (StrLen(jTool) > 0 && jTool != "-"){
					winActivate,%lastOpendTitle%
					toSend := "set ""JAVA_TOOL_OPTIONS=" . jTool . """"
					SendInput,{text}%toSend%
					SendInput,{ENTER}
				}
			} else {
				msgbox, Command could not finish because window was switched to early (or closed)!
				return
			}
				
			if WinExist(lastOpendTitle){
				winActivate,%lastOpendTitle%
				SendInput,{text}%startCmd%
				SendInput,{ENTER}
			} else {
				msgbox, Command could not finish because window was switched to early (or closed)!
				return
			}
			
			if WinExist(lastOpendTitle){
				if (param != ""){
					winActivate,%lastOpendTitle%
					lineArrLength := lineArr.Length() - 1
					Loop, % lineArrLength
					{
						index := A_index + 1
						param := lineArr[index]
							
						MsgBox,4,Command has an additional parameter!,`nPlease wait until the command has finished!`n`nIf the command has finished you can send the additional parameter:`n`n%param%`n`nSend it now?
						IfMsgBox Yes
						{
							;clipboard := param
							if (InStr(param,"+close+")){
								sendExit()
							} else {
								clipboard := param
								Send {Ctrl down}v{Ctrl up}
								SendInput,{Enter}
							}
						}
					}
				}
			} else {
				msgbox, *** ERROR! *** SBT-Console with titel %lastOpendTitle% is not open!
				return
			}
		
		case 2:
			;*** Shift = edit built.sbt ***
			
			f := d . "\build.sbt"
			runWait,%f%,%d%,max
	
			showWindowRefreshed()

		case 4:
			; Capslock
			SetWorkingDir,%d%
			startApp := cvtPath(filemanagerpath) . bl . qMark . d . qMark
			Run, %startApp%,%d%,max
			sleep, 3000
			
			startApp := WSL
			clipboard := startApp
			Run, %startApp%,%d%,max
			SetTitleMatchMode, 2
			sleep, 3000
			WinActivate,,"wsl"
			send,amm{Enter}
			SetCapsLockState, Off
	}
	
	return
}
;********************************* unselect *********************************
unselect(){
	sendinput {left}
}
;********************************* sendExit *********************************
sendExit(){
	sendInput,{Ctrl Down}d{Ctrl Up}{ENTER}
	sleep, 1000
	sendInput,exit
	sendInput,{ENTER}
	
	return
}
; *********************************** openGithubPage ******************************
openGithubPage(){
	global appName
	
	StringLower, name, appName
	Run https://github.com/jvr-ks/%name%
	
	return
}
;*********************************** editCmdFile ******************************
editCmdFile() {
	global cmdFile

	runWait,%cmdFile%,,max
	
	showWindowRefreshed()
	
	return
}
;------------------------------ editConfigFile ------------------------------
editConfigFile() {
	global configFile

	runWait,%configFile%,,max
	
	showWindowRefreshed()
	
	return
}

;*********************************** editCmdFile ******************************
editJHomeFile() {
	global jhomeFile
	
	runWait,%jhomeFile%,,max
	
	showWindowRefreshed()
	
	return
}
;*********************************** editShortcutsFile ******************************
editShortcutsFile() {
	global shortcutsFile

	runWait,%shortcutsFile%,,max
	
	showWindowRefreshed()
	
	return
}
;*********************************** ret ******************************
ret() {
	return
}
; *********************************** cvtPath ******************************
cvtPath(s){
	r := s
	pos := 0
	
	While pos := RegExMatch(r,"O)(\[.*?\])", match, pos+1){
		r := RegExReplace(r, "\" . match.1, shortcut(match.1), , 1, pos)
	}

	While pos := RegExMatch(r,"O)(%.+?%)", match, pos+1){
		r := RegExReplace(r, match.1, envVariConvert(match.1), , 1, pos)
	}
	return r
}
;*********************************** envVariConvert ******************************
envVariConvert(s){
	r := s
	if (InStr(s,"%")){
		s := StrReplace(s,"`%","")
		EnvGet, v, %s%
		Transform, r, Deref, %v%
	}

	return r
}
; *********************************** shortcut ******************************
shortcut(s){
	global shortcutsArr
	
	r := s

	sc := shortcutsArr[r]
	if (sc != "")
		r := sc

	return r
}
;------------------------------- readGuiParam -------------------------------
readGuiParam(){
	global configFile
	global fontDefault
	global font
	global fontsizeDefault
	global fontsize
	global windowPosX
	global windowPosY
	global windowWidthDefault
	global windowWidth
	global windowHeightDefault
	global windowHeight
	global windowPosFixed
	
	
	IniRead, windowPosFixed, %configFile%, config, windowPosFixed, 0
	
	IniRead, windowPosX, %configFile%, config, windowPosX, 0
		
	IniRead, windowPosY, %configFile%, config, windowPosY, 0
		
	IniRead, windowWidth, %configFile%, config, windowWidth, %windowWidthDefault%
	if (windowWidth == 0)
		windowWidth := windowWidthDefault
	
	IniRead, windowHeight, %configFile%, config, windowHeight, %windowHeightDefault%
	if (windowHeight < 0)
		windowHeight := windowHeightDefault
	
	IniRead, font, %configFile%, config, font, %fontDefault%
	IniRead, fontsize, %configFile%, config, fontsize, %fontsizeDefault%
	
	;DPIScale correction:
	windowWidth := Round(windowWidth * 96/A_ScreenDPI)
	windowHeight := Round(windowHeight * 96/A_ScreenDPI)

	return
}
;******************************* fixWindowPos *******************************
fixWindowPos(){
	global windowPosFixed
	global configFile
	
	windowPosFixed := true
	IniWrite, %windowPosFixed% , %configFile%, config, windowPosFixed
}
;***************************** releaseWindowPos *****************************
releaseWindowPos(){
	global windowPosFixed
	global configFile

	windowPosFixed := false
	IniWrite, %windowPosFixed% , %configFile%, config, windowPosFixed
}
;*************************** guiMainGuiContextMenu ***************************
guiMainGuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y){
	isr := IsRightClick ? "yes" : "no"
	msgBox, 
	(
	A contextmenu is not defined at the moment!
	Parameters are
	GuiHwnd: %GuiHwnd%
	CtrlHwnd: %CtrlHwnd%
	EventInfo: %EventInfo%
	IsRightClick: %isr%
	X: %X%
	Y: %Y%
	)

	return
}
;*********************************** hkToDescription ******************************
; in Lib
;*********************************** hotkeyToText ******************************
; in Lib
;*********************************** shutdown ******************************
exit() {
	global app
	global posXsave
	global posYsave
	
	showHint("""" . app . """ removed from memory!", 1500)
	MouseMove, posXsave, posYsave, 0
	ExitApp
}

;*********************************** ExitFunc ******************************
ExitFunc(ExitReason, ExitCode)
{
	;Gui, Destroy
	return
}


