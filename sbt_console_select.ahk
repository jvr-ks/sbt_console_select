#NoEnv
#Warn
#SingleInstance force
#InstallKeybdHook

; https://github.com/zhamlin/AHKhttp
#include, Lib\AHKhttp.ahk

; http://www.autohotkey.com/forum/viewtopic.php?p=355775
#include, Lib\AHKsock.ahk

license := "
(
/*
 --------------------------------------------------------------------------------*
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
 --------------------------------------------------------------------------------*
*/

/*
 --------------------------------------------------------------------------------*
 *
 * MIT License
 *
 *
 * Copyright (c) 2020 jvr.de. All rights reserved.

 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the ""Software""), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sub-license, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT-ABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
 * UTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
  --------------------------------------------------------------------------------*
*/

)"

/*
 --------------------------------------------------------------------------------*
 * Main view element is the ListView LV1.
 * Upon a click guiMainListViewClick() is called.
  --------------------------------------------------------------------------------*
*/

;SetWinDelay, -1

DetectHiddenWindows, On
DetectHiddenText, On

SendMode Input
FileEncoding, UTF-8-RAW

SetWorkingDir, %A_ScriptDir%
; SetKeyDelay, 10, 10
CoordMode, Mouse, Screen

;----------------------------- global variables -----------------------------
global variables

appName := "Sbt_console_select"
appnameLower := "sbt_console_select"
appVersion := "0.237"
app := appName . " " . appVersion
extension := ".exe"

bit := (A_PtrSize=8 ? "64" : "32")
if (!A_IsUnicode)
  bit := "A" . bit

bitName := (bit="64" ? "" : bit)

wrkDir := A_ScriptDir . "\"
replFilePart1 := wrkDir . "replPart1.hs"
replFilePart2 := wrkDir . "replPart2.hs"
lastPid := 0
editTextFileFilename := ""
editTextFileContent := ""

usingWSL := false
msgDefault := "Hold key down while clicking: [CTRL] -> open filemanager"

posXsave := 0
posYsave := 0

nomenu := false

lastOpenedTitle := ""

fontDefault := "Segoe UI"
font := fontDefault
fontsizeDefault := 9
fontsize := fontsizeDefault

listWidthDefault := 700

cmdFile := "sbt_console_select.txt"
configFile := "sbt_console_select.ini"
shortcutsFile  := "sbt_console_select_shortcuts.txt"

filemanagerPathDefault := "%SystemRoot%\explorer.exe"
filemanagerpath := filemanagerPathDefault

importFileName := ""
wslStart := ""

menuhotkeyDefault := "!t"
menuhotkey := menuhotkeyDefault

replLoadHotkeyDefault := "!e"
replLoadHotkey := replLoadHotkeyDefault

replSelectLoadHotkeyDefault := "^e"
replSelectLoadHotkey := replSelectLoadHotkeyDefault

replSelectLoadPart2HotkeyDefault := "+!e"
replSelectLoadPart2Hotkey := replSelectLoadPart2HotkeyDefault

replResetHotkeyDefault := "^r"
replResetHotkey := replResetHotkeyDefault

exitHotkeyDefault := "+!t"
exitHotkey := exitHotkeyDefault

scsRestPortDefault := 65505
scsRestPort := scsRestPortDefault

localVersionFileDefault := "version.txt"
serverURLDefault := "https://github.com/jvr-ks/"
serverURLExtensionDefault := "/raw/main/"

;------------------------------- Gui parameter -------------------------------
clientWidthDefault := 800
clientHeightDefault := 600
windowPosXDefault := 0
windowPosYDefault := 0

windowPosX := windowPosXDefault
windowPosY := windowPosYDefault
clientWidth := clientWidthDefault
clientHeight := clientHeightDefault

;---------------------------------- objects ----------------------------------
entryNameArr := {}
entryIndexArr := []
directoriesArr := []
startcmdArr := []
shortcutsArr := {}
replcommandsArr := []
;---------------------------------- Params ----------------------------------
hideOnStartup := false
autoselect := false
autoselectName := ""
restapi := true
;------------------------------ Default values ------------------------------
localVersionFile := localVersionFileDefault
serverURL := serverURLDefault
serverURLExtension := serverURLExtensionDefault

updateServer := serverURL . appnameLower . serverURLExtension

replcommandsDefault := ":reset,--load imports--,--load the code part 1--,--load the code part 2--"
replcommands := replcommandsDefault

wsltitlecmd := "echo -ne '\033]0;§§THE TITLE§§\a'"

MouseGetPos, posXsave, posYsave

allArgs := ""

Loop % A_Args.Length()
{
  if(eq(A_Args[A_index],"remove"))
    ExitApp

  if(eq(SubStr(A_Args[A_index],-3,4),".ini"))
    configFile := A_Args[A_index]

  if(eq(SubStr(A_Args[A_index],-3,4),".txt"))
    cmdFile := A_Args[A_index]

  if(eq(A_Args[A_index],"restapioff")){
    restapioff := 1
  }

  if(eq(A_Args[A_index],"hidewindow")){
    hideOnStartup := 1
  }
  
  if(eq(A_Args[A_index],"showwindow")){
    hideOnStartup := 0
  }
  

  FoundPos := RegExMatch(A_Args[A_index],"\([\s\w]+?\)", found)

  If (FoundPos > 0){
    autoSelectName := found
    autoselect := true
    showMessageRed(app . " selected entry: " . autoSelectName, 5000)
    ; old instance must be closed, takes time ...
    sleep,3000
  }
  
  allArgs .= A_Args[A_index] . " "
}

additionalCommand := ""
replcommand1 := ""
replcommand2 := ""
replcommand3 := ""
replcommand4 := ""
replcommand5 := ""
replcommand6 := ""
replcommand7 := ""
replcommand8 := ""
replcommand9 := ""
replcommand10 := ""

restapioff := 0

; start global
if (FileExist(appnameLower . ".ini")){
  readConfig()
  readGuiData()
} else {
  saveConfig()
}

readCmd()
readShortcuts()


;  serverHttp
if (!restapioff){
; Servermode
  paths := {}
  paths["/scs"] := Func("scsRest")

  serverHttp := new HttpServer()
  if (!serverHttp)
    msgbox, Could not start HttpServer!

  serverHttp.LoadMimes(A_ScriptDir . "/mime.types")
  serverHttp.SetPaths(paths)
  if (scsRestPort != "" && scsRestPort > 1000){
    serverHttp.Serve(0 + scsRestPort)
  } else {
    serverHttp.Serve(65505)
  }
} else {
  showMessageRed(app . " Rest API disabled", 3000)
}

if (hideOnStartup){
  msg1 := app . " started`n`nCommand-file: " . cmdFile . "`nConfig-file: " . configFile . "`nMenu-hotkey is: " . hotkeyToText(menuhotkey)
  showHint(msg1, 6000, 1)
}

mainWindow()

OnMessage(0x03,"WM_MOVE")

return

;---------------------------------- WM_MOVE ----------------------------------
WM_MOVE(wParam, lParam){
  global hMain, windowPosX, windowPosY
  
  WinGetPos, windowPosX, windowPosY,,, ahk_id %hMain%
  
  return
}
;---------------------------------- scsRest ----------------------------------
scsRest(ByRef req, ByRef res) {
  global autoSelectName, app, entryNameArr

; request example -> curl http://localhost:65505/scs?open=(testareaQuick)
; request example -> curl http://localhost:65505/scs?close=(testareaQuick)
  autoSelectName := req.queries["open"]
  closeName := req.queries["close"]

  if (autoSelectName != ""){
    sel := entryNameArr[autoselectName]
    if(sel > 0){
      res.SetBodyText("Starting / opening: " . autoSelectName)
      showMessageGreen(app . " selected entry (" . sel . "): " . autoSelectName, 4000)
      res.status := 200
      runInDir(sel)
    } else {
      res.SetBodyText("Selected entry: " . autoSelectName . " not found!")
      showHint(app . " selected entry: " . autoSelectName . " not found!", 4000)
      res.status := 200
    }
  }

  if (closeName != ""){
    res.SetBodyText("Closing: " . closeName)
    res.status := 200
    toClose := StrReplace(closeName,"(","")
    toClose := StrReplace(toClose,")","")
    if WinExist(toClose){
      Winclose
    } else {
      msgbox, Window to close (%toClose%) not found!
    }
  }

  return
}
;-------------------------------- mainWindow --------------------------------
mainWindow() {
  global hMain, windowPosX, windowPosY, clientWidth, clientHeight
  global hideOnStartup
  global font, fontsize, wrkDir

  global cmdFile, configFile, shortcutsFile, entryNameArr
  global entryIndexArr, directoriesArr, startcmdArr, app
  global appName, posXsave, posYsave, appVersion, menuhotkey, exitHotkey

  global LV1, listWidthDefault, msgDefault, autoselectName, restapioff
  global scsRestPort, autoselect
  global messagetextRed, messagetextGreen

  Menu, Tray, UseErrorLevel   ; This affects all menus, not just the tray.

  Menu, MainMenu, DeleteAll
  Menu, MainMenuEdit, DeleteAll

  Menu, MainMenuEdit,Add,Edit Command-file: "%cmdFile%", editTextFileCmdFile
  Menu, MainMenuEdit,Add,Edit Command-file: "%cmdFile%" with system default editor,editCommandFileExternal
  Menu, MainMenuEdit,Add,
  
  Menu, MainMenuEdit,Add,Edit Shortcuts-file: "%shortcutsFile%", editTextFileShortcutsFile
  Menu, MainMenuEdit,Add,Edit Shortcuts-file: "%shortcutsFile%" with system default editor,editShortcutsFileExternal
  Menu, MainMenuEdit,Add,
  
  Menu, MainMenuEdit,Add,Edit Config-file: "%configFile%", editTextFileConfigFile
  Menu, MainMenuEdit,Add,Edit Config-file: "%configFile%" with system default editor,editConfigFileExternal
  Menu, MainMenuEdit,Add,
  
  Menu, MainMenuUpdate, Add,Check if new version is available, checkUpdate
  Menu, MainMenuUpdate, Add,Start updater, startUpdate

  Menu, MainMenu, NoDefault
  Menu, MainMenu, Add,Edit,:MainMenuEdit

  Menu, MainMenu, Add,Update,:MainMenuUpdate

  Menu, MainMenu, Add,Github,openGithubPage
  Menu, MainMenu, Add,Kill %appname%,exit

  if (restapioff)
    Gui,guiMain:New,+OwnDialogs +LastFound MaximizeBox HwndhMain +Resize, %app% (RestAPI: offline)
  Else
    Gui,guiMain:New,+OwnDialogs +LastFound MaximizeBox HwndhMain +Resize, %app% (RestAPI-port: %scsRestPort%)

  Gui, guiMain:Font, s%fontsize%, %font%

  xStart := 2
  yStart := 2
  xStartLV1 := xStart
  yStartLV1 := yStart + 20

  Gui, guiMain:Add, Text, VmessagetextRed w400 r1 cRed x%xStart% y%yStart%
  Gui, guiMain:Add, Text, VmessagetextGreen w400 r1 cGreen x%xStart% y%yStart%
  
  linesInList := directoriesArr.length()
  Gui, guiMain:Add, ListView, x%xStartLV1% y%yStartLV1% r%linesInList% w%listWidthDefault% GguiMainListViewClick vLV1 Grid AltSubmit -Multi NoSortHdr -LV0x10, |Name|Directory|Command

  Loop % directoriesArr.length()
  {
    LV_Add("",A_index,entryIndexArr[A_index],directoriesArr[A_index], startcmdArr[A_index])
  }

  LV_ModifyCol(1,"Auto Integer")
  LV_ModifyCol(2,"Auto")
  LV_ModifyCol(3,"Auto")
  LV_ModifyCol(4,"Auto")
  LV_ModifyCol(5,"Auto")
  LV_ModifyCol(6,"Auto")
  LV_ModifyCol(7,"Auto")

  Gui, guiMain:Add, StatusBar, hwndMainStatusBarHwnd -Theme +BackgroundSilver 0x800

  showMessage("", msgDefault)

  Gui, guiMain:Menu, MainMenu

  if (!hideOnStartup){
    setTimer,checkFocus,3000
    Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%clientWidth% h%clientHeight%
  } else {
    Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%clientWidth% h%clientHeight%
    hideWindow()
  }

  if (autoselectName != ""){
    n := entryNameArr[autoselectName]
    if(n > 0){
      hideWindow()
      runInDir(n)
    } else {
      msgbox, Entry not found: %autoselectName%
    }
  }

  return
}
;------------------------------ guiMainGuiSize ------------------------------
guiMainGuiSize(){
  global clientWidthDefault, clientHeightDefault, clientWidth, clientHeight

   if (A_EventInfo != 1) {
    ; not minimized
    clientWidth := A_GuiWidth
    clientHeight := A_GuiHeight

    borderX := 10
    borderY := 50 ; reserve some space for statusbar and scrollbar

    GuiControl, Move, LV1, % "W" . (clientWidth - borderX) . " H" . (clientHeight - borderY)
  }

  return
}
;-------------------------------- iniReadSave --------------------------------
iniReadSave(name, section, defaultValue){
  global configFile
  
  r := ""
  IniRead, r, %configFile%, %section%, %name%, %defaultValue%
  if (r == "" || r == "ERROR")
    r := defaultValue
    
  if (r == "#empty!")
    r := ""
    
  return r
}
;----------------------------------- readIni ------------------------------
readConfig(){
  global msgDefault, configFile, menuhotkeyDefault, menuhotkey
  global replLoadHotkeyDefault, replLoadHotkey, replSelectLoadHotkeyDefault, replSelectLoadHotkey
  global replSelectLoadPart2HotkeyDefault, replSelectLoadPart2Hotkey, replResetHotkeyDefault, replResetHotkey
  global exitHotkeyDefault, exitHotkey
  global filemanagerpath, filemanagerpathDefault
  global fontDefault, font, fontsizeDefault, fontsize
  global listWidthDefault, replcommands, replcommandsDefault, replcommandsArr
  global additionalCommand, wslStart
  global scsRestPortDefault, scsRestPort, restapioff
  global wsltitlecmd, lastOpenedTitle


; read Hotkey definition
  font := iniReadSave("font", "config", fontDefault)
  
  menuhotkey := iniReadSave("menuhotkey", "config", menuhotkeyDefault)
  Hotkey, %menuhotkey%, showWindowRefreshed

  replLoadHotkey := iniReadSave("replLoadHotkey", "hotkeys", replLoadHotkeyDefault)
  Hotkey, %replLoadHotkey%, replLoad

  replSelectLoadHotkey := iniReadSave("replSelectLoadHotkey", "hotkeys", replSelectLoadHotkeyDefault)
  Hotkey, %replSelectLoadHotkey%, replSelectLoad

  replSelectLoadPart2Hotkey := iniReadSave("replSelectLoadPart2Hotkey", "hotkeys", replSelectLoadPart2HotkeyDefault)
  Hotkey, %replSelectLoadPart2Hotkey%, replSelectLoadExec

  replResetHotkey := iniReadSave("replResetHotkey", "hotkeys", replResetHotkeyDefault)
  Hotkey, %replResetHotkey%, replReset

  exitHotkey := iniReadSave("exitHotkey", "hotkeys", exitHotkey)
  Hotkey, %exitHotkey%, sendExit

  filemanagerpath := iniReadSave("filemanagerpath", "external", filemanagerpathDefault)

  font := iniReadSave("font", "config", fontDefault)
  fontsize := iniReadSave("fontsize", "config", fontsizeDefault)

  additionalCommand := iniReadSave("additionalCommand", "config", "")

  wslStart := iniReadSave("wslStart", "config", "C:\Windows\System32\wsl.exe")

  scsRestPort := iniReadSave("scsRestPort", "config", scsRestPortDefault)
  restapioff := iniReadSave("restapioff", "config", 0)
  
  replcommandsArr := StrSplit(iniReadSave("replcommands", "config", replcommandsDefault),",")
  
  wsltitlecmd := iniReadSave("wsltitlecmd", "config", "echo -ne '\033]0;§§THE TITLE§§\a'")
  
  lastOpenedTitle := iniReadSave("lastOpenedTitle", "config", "")
  
  runCmd := iniReadSave("runCmd", "config", "cmd.exe /k")

  return
}
;-------------------------------- saveConfig --------------------------------
saveConfig(){
  global configFile
  global menuhotkey, replLoadHotkey, replSelectLoadHotkey, replSelectLoadPart2Hotkey
  global replResetHotkey, exitHotkey, filemanagerpath
  global font, fontsize, additionalCommand, wslStart, scsRestPort, restapioff
  global replcommands, replcommandsArr

  ; config section:
  IniWrite, "%menuhotkey%", %configFile%, config, menuhotkey
  IniWrite, "%replLoadHotkey%", %configFile%, config, replLoadHotkey
  IniWrite, "%replSelectLoadHotkey%", %configFile%, config, replSelectLoadHotkey
  IniWrite, "%replSelectLoadPart2Hotkey%", %configFile%, config, replSelectLoadPart2Hotkey
  IniWrite, "%replResetHotkey%", %configFile%, config, replResetHotkey
  IniWrite, "%exitHotkey%", %configFile%, config, exitHotkey
  IniWrite, "%filemanagerpath%", %configFile%, config, filemanagerpath
  IniWrite, "%font%", %configFile%, config, font
  IniWrite, "%fontsize%", %configFile%, config, fontsize
  IniWrite, "%additionalCommand%", %configFile%, config, additionalCommand
  IniWrite, "%wslStart%", %configFile%, config, wslStart
  IniWrite, "%scsRestPort%", %configFile%, config, scsRestPort
  IniWrite, "%restapioff%", %configFile%, config, restapioff
  IniWrite, "%replcommands%", %configFile%, config, replcommands

  return
}
;-------------------------------- readConfig --------------------------------
readGuiData(){
  global configFile, windowPosX, windowPosY, clientWidth, clientHeight
  global windowPosXDefault, windowPosYDefault, clientWidthDefault, clientHeightDefault

  windowPosX := iniReadSave("windowPosX","gui", windowPosXDefault)
  windowPosY := iniReadSave("windowPosY","gui", windowPosYDefault)
  clientWidth := iniReadSave("clientWidth","gui", clientWidthDefault)
  clientHeight := iniReadSave("clientHeight","gui", clientHeightDefault)
  
  windowPosX := max(windowPosX,-100)
  windowPosY := max(windowPosY,-100)

  return
}
;-------------------------------- saveGuiData --------------------------------
saveGuiData(){
  global hMain, configFile, windowPosX, windowPosY, clientWidth, clientHeight, windowPosXSave

  IniWrite, %windowPosX%, %configFile%, gui, windowPosX
  IniWrite, %windowPosY%, %configFile%, gui, windowPosY

  IniWrite, %clientWidth%, %configFile%, gui, clientWidth
  IniWrite, %clientHeight%, %configFile%, gui, clientHeight

  return
}
;----------------------------- showMessageGreen -----------------------------
showMessageGreen(s, t := 0){
  global messagetextRed, messagetextGreen
  
  GuiControl,guiMain:, messagetextGreen,%s%
  if (t > 0){
    tvalue := -1 * t
    SetTimer,showMessageRemove,%tvalue%
  }
  
  return
}
;------------------------------ showMessageRed ------------------------------
showMessageRed(s, t := 0){
  global messagetextRed, messagetextGreen
  
  GuiControl,guiMain:, messagetextRed,%s%
  if (t > 0){
    tvalue := -1 * t
    SetTimer,showMessageRemove,%tvalue%
  }
  
  return
}
;----------------------------- showMessageRemove -----------------------------
showMessageRemove(){
  global messagetextRed, messagetextGreen
  
  GuiControl,guiMain:, messagetextRed,
  GuiControl,guiMain:, messagetextGreen,
  
  return
}
;----------------------------- checkUpdate -----------------------------
checkUpdate(){
  global appname, appnameLower, localVersionFile, updateServer

  localVersion := getLocalVersion(localVersionFile)

  remoteVersion := getVersionFromGithubServer(updateServer . localVersionFile)

  if (remoteVersion != "unknown!" && remoteVersion != "error!"){
    if (remoteVersion > localVersion){
      checkUpdateMsg1 := "New version available: (" . localVersion . " -> " . remoteVersion . ")`, please use the Updater (updater.exe) to update " . appname . "!"
      showMessageRed(checkUpdateMsg1, 5000)

    } else {
      checkUpdateMsg2 := "No new version available (" . localVersion . " -> " . remoteVersion . ")"
      showMessageGreen(checkUpdateMsg2, 5000)
    }
  } else {
    checkUpdateMsg := "Update-check failed: (" . localVersion . " -> " . remoteVersion . ")"
    showMessageRed(checkUpdateMsg, 5000)
  }

  return
}
;------------------------------ getLocalVersion ------------------------------
getLocalVersion(file){

  versionLocal := 0.000
  if (FileExist(file) != ""){
    file := FileOpen(file,"r")
    versionLocal := file.Read()
    file.Close()
  }

  return versionLocal
}
;------------------------ getVersionFromGithubServer ------------------------
getVersionFromGithubServer(url){

  ret := "unknown!"

  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  Try
  {
    whr.Open("GET", url)
    whr.Send()
    status := whr.Status
    if (status == 200){
     ret := whr.ResponseText
    } else {
      msgArr := {}
      msgArr.push("Error while reading actual app version!")
      msgArr.push("Connection to:")
      msgArr.push(url)
      msgArr.push("failed!")
      msgArr.push("URL -> clipboard")
      msgArr.push("Closing Updater due to an error!")

      errorExit(msgArr, url)
    }
  }
  catch e
  {
    ret := "error!"
  }

  return ret
}
;--------------------------- GetProcessMemoryUsage ---------------------------
GetProcessMemoryUsage() {
    PID := DllCall("GetCurrentProcessId")
    size := 440
    VarSetCapacity(pmcex,size,0)
    ret := ""
    
    hProcess := DllCall( "OpenProcess", UInt,0x400|0x0010,Int,0,Ptr,PID, Ptr )
    if (hProcess)
    {
        if (DllCall("psapi.dll\GetProcessMemoryInfo", Ptr, hProcess, Ptr, &pmcex, UInt,size))
            ret := Round(NumGet(pmcex, (A_PtrSize=8 ? "16" : "12"), "UInt") / 1024**2, 2)
        DllCall("CloseHandle", Ptr, hProcess)
    }
    return % ret
}
;------------------------------ resetStatusBar ------------------------------
resetStatusBar(){
  global msgDefault

  showMessage("", msgDefault)

  return
}
;-------------------------------- showMessage --------------------------------
showMessage(hk1 := "", hk2 := "", part1 := 200, part2 := 500){
  global menuHotkey, exitHotkey

  SB_SetParts(part1,part2)
  if (hk1 != ""){
    SB_SetText(" " . hk1 , 1, 0)
  } else {
    SB_SetText(" " . "Hotkey: " . hotkeyToText(menuHotkey) , 1, 0)
  }

  if (hk2 != ""){
    SB_SetText(" " . hk2 , 2, 0)
  } else {
    SB_SetText(" " . "Exit-hotkey: " . hotkeyToText(exitHotkey) , 2, 0)
  }

  memory := "[" . GetProcessMemoryUsage() . " MB]      "
  SB_SetText("`t`t" . memory , 3, 0)

  return
}
;-------------------------------- startUpdate --------------------------------
startUpdate(){
  global appname, bitName, extension

  updaterExeVersion := "updater" . bitName . extension

  if(FileExist(updaterExeVersion)){
    msgbox,Starting "Updater" now, please restart "%appname%" afterwards!
    run, %updaterExeVersion% runMode
    exit()
  } else {
    msgbox, Updater not found!
  }

  showWindow()

  return
}
;-------------------------------- checkFocus --------------------------------
checkFocus(){
  global hMain

  if (hMain != WinActive("A")){
    hideWindow()
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

;--------------------------------- isComment ---------------------------------
isComment(s){
  ret := RegExMatch(s, "(?<!\w)\/\/")

  return ret
}
;------------------------------ replLoadAction ------------------------------
replLoadAction(selectAll := false){
  global replcommandsArr, lastOpenedTitle, replFilePart1, replFilePart2
  global usingWSL, wslStart, importFileName
  global replSelectLastDirUsed, lastPid

  clipSaved := ClipboardAll

  resetStatusBar()

  toSend := ""

  isWin := WinActive("A")

  if (selectAll){
    Send {Ctrl down}a{Ctrl up}
  }

  Send {Ctrl down}c{Ctrl up}

  sleep, 1000

  if (clipboard != ""){
    code := clipboard

    if (code != ""){
      isLoad := RegExMatch(code,"iO)\/\*\* code part 2 section((.|`n|`r)+?)\*\/",m)
      if (isLoad > 0){
        s := m.Value(1)
        FileDelete, %replFilePart2%
        FileAppend, %s%, %replFilePart2%
        showHint("Loaded code part 2: " . s, 15000)
        FileAppend ,`n, %replFilePart2%
      }

      FileDelete, %replFilePart1%
      FileAppend, %code%, %replFilePart1%
      FileAppend,`n, %replFilePart1%
      
      if (winExist(lastOpenedTitle)){
        winActivate,%lastOpenedTitle%

        ;--------------------------- replcommands overload ---------------------------
        replcommandsFile := replSelectLastDirUsed . "\replcommands.txt"
        
        if (replSelectLastDirUsed != ""){
          if (FileExist(replcommandsFile)){
            FileRead, replComm, %replcommandsFile%
            if (replComm != ""){
              replcommandsArr := {}
              replcommandsArr := StrSplit(replComm,",")
            }
          }
        }
        ;---------------------------- command parse loop ----------------------------
        l := replcommandsArr.length()

        Loop, %l%
        {
          toSend := replcommandsArr[A_Index]

          specialCommand := false

          comment := isComment(toSend)

          isLoad := RegExMatch(toSend, "i)--load the code part 1--")

          if (isLoad && !comment){
            if (FileExist(replFilePart1)){
              if (!usingWSL){
                ; not reliable sending multible underscores!
                ; sendTextViaControl(":load " . replFilePart1, lastPid)
                sendTextClipBoard(":load " . replFilePart1, lastPid)
                sleep,200
              } else {
                sendLinuxClipBoard(":load " . cvtToLinux(replFilePart1), lastPid)
                sleep,200
              }
            } else {
              msgbox,48,ERROR, File %replFilePart1% not found!
            }
            specialCommand := true
          }

          isLoadExec := RegExMatch(toSend, "i)--load the code part 2--")

          if (isLoadExec && !comment){
            if (FileExist(replFilePart2)){
              FileGetSize, fSize, %replFilePart2%
              if (0 + fSize > 6){
                if (!usingWSL){
                  ; not reliable sending multible underscores!
                  ; sendTextViaControl(":load " . replFilePart2, lastPid)
                  sendTextClipBoard(":load " . replFilePart2, lastPid)
                  sleep,200
                } else {
                  sendLinuxClipBoard(":load " . cvtToLinux(replFilePart2), lastPid)
                  sleep,200
                }
              }
            }
            specialCommand := true
          }
          
          isLoadExec := RegExMatch(toSend, "i)--load imports--")

          if (isLoadExec){
            useImportFile := RegExMatch(code,"iO)\/\*\* useImports=([\w\.]*)",m)
            
            if (useImportFile > 0){
              importFileName := m.Value(1)
              if (importFileName != ""){
                if (!usingWSL){
                  sendTextViaControl(":load " . importFileName, lastPid)
                  sleep,200
                } else {
                  sendLinuxClipBoard(":load " . cvtToLinux(importFileName), lastPid)
                  sleep,200
                }
              }
            }
            specialCommand := true
          }

          ;---------------------------- other REPL-commands ----------------------------
          if (!specialCommand && !comment){
            SendInput,{text}%toSend%
            SendInput,{Enter}
          }
        }
        showHint("Press [CTRL]-key to return to the previously open window!", 0)

        endlessloop:
        loop
        {
          KeyWait,Ctrl,D
          sleep,900
          if (getkeystate("Ctrl","P") == 0)
            break endlessloop
        }

        showHintDestroy()

        if !ErrorLevel
        {
          winActivate,ahk_id %isWin%
        }

      } else {
        if (lastOpenedTitle == ""){
          msgbox,48,ERROR, Console-Window to open, title is empty!
        } else {
          msgbox,48,ERROR, Console-Window %lastOpenedTitle% not found!
        }
      }
    } else {
      msgbox, No code to run in REPL selected!
    }
  } else {
    msgbox, Clipboard is empty or contains wrong data-type!
  }

  clipBoard := clipSaved

  return
}
;-------------------------------- cvtToLinux --------------------------------
cvtToLinux(d){
  pathLinux := RegExReplace(d,"\\","/")
  pathLinux := RegExReplace(pathLinux,"i)c:","/mnt/c")
  pathLinux := RegExReplace(pathLinux,"i)d:","/mnt/d")
  pathLinux := RegExReplace(pathLinux,"i)e:","/mnt/e")
  pathLinux := RegExReplace(pathLinux,"i)~","$HOME")

  return pathLinux
}
;---------------------------- replSelectLoadExec ----------------------------
replSelectLoadExec(){
  ; save part 2-code to file "replPart2.tmp" or delete it, if clipBoard is empty

  global replFilePart2

  clipSaved := clipBoardAll

  Send {Ctrl down}c{Ctrl up}
  sleep,1000

  clp := Trim(clipBoard)
  clipBoard :=
  if (clp != ""){
    if (FileExist(replFilePart2))
      FileDelete, %replFilePart2%

    FileAppend , %clp%, %replFilePart2%
    FileAppend ,`n, %replFilePart2%

    showHint("Saved as code part 2: `n" . clp, 5000)
  } else {
    if (FileExist(replFilePart2)){
      FileDelete, %replFilePart2%
      showHint("Code part 2 removed!", 5000)
    }
  }

  clipBoard := clipSaved

  return
}
;----------------------------- SetTextAndResize -----------------------------
SetTextAndResize(controlHwnd, newText) {

  dc := DllCall("GetDC", "Ptr", controlHwnd)

; 0x31 = WM_GETFONT
  SendMessage 0x31,,,, ahk_id %controlHwnd%
  hFont := ErrorLevel
  oldFont := 0
  if (hFont != "FAIL")
    oldFont := DllCall("SelectObject", "Ptr", dc, "Ptr", hFont)

  VarSetCapacity(rect, 16, 0)
  ; 0x440 = DT_CALCRECT | DT_EXPANDTABS
  h := DllCall("DrawText", "Ptr", dc, "Ptr", &newText, "Int", -1, "Ptr", &rect, "UInt", 0x440)
  ; width = rect.right - rect.left
  w := NumGet(rect, 8, "Int") - NumGet(rect, 0, "Int")

  if oldFont
    DllCall("SelectObject", "Ptr", dc, "Ptr", oldFont)
  DllCall("ReleaseDC", "Ptr", controlHwnd, "Ptr", dc)

  GuiControl,, %controlHwnd%, %newText%

  GuiControl Move, %controlHwnd%, % "w" w

  return w
}
;------------------------------ replReset ------------------------------
replReset(){
  global lastOpenedTitle, replFilePart1, replFilePart2

  isWin := WinActive("A")

  if WinExist(lastOpenedTitle){
    winActivate,%lastOpenedTitle%

    toSend := ":reset`n"
    SendInput,{text}%toSend%

    if (FileExist(replFilePart1))
      FileDelete, %replFilePart1%

    if (FileExist(replFilePart2))
      FileDelete, %replFilePart2%

    sleep,500
    winActivate,ahk_id %isWin%
  } else {
    showMessageRed("No approbiate console-window found!",3000)
  }

  return
}
;----------------------------------- readCmd ------------------------------
readCmd(){
  global wrkDir, cmdFile

  global entryNameArr, entryIndexArr, directoriesArr, startcmdArr

; read path and sbtstarttype
  entryNameArr := {}
  entryIndexArr := []
  entryIndexArr := []
  directoriesArr := []
  startcmdArr := []

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
            if (s == "(-auto-)")
              s := "(entry" . LineNumber . ")"

            entryNameArr[s] := LineNumber
            entryIndexArr[LineNumber] := s
          }

          if (A_Index = 2)
            directoriesArr[LineNumber] := A_LoopField

          if (A_Index = 3)
            startcmdArr[LineNumber] := A_LoopField
        }
    }
  }
  a := entryNameArr.count()
  b := startcmdArr.count()

  return
}

; ----------------------------------- readShortcuts ------------------------------
readShortcuts(){
  global wrkDir, shortcutsArr, shortcutsFile

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
  global appName, entryNameArr, entryIndexArr, directoriesArr
  global startcmdArr

  LV_Delete()
  a := directoriesArr.length()
  Loop %a%
  {
    LV_Add(A_index,A_index,entryIndexArr[A_index],directoriesArr[A_index], startcmdArr[A_index])
  }

  resetStatusBar()

  return
}
; ----------------------------------- showWindow ------------------------------
showWindow(){
  global windowPosX, windowPosY, clientWidth, clientHeight

  setTimer,checkFocus,3000
  Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%clientWidth% h%clientHeight%

  return
}
;--------------------------------* hideWindow --------------------------------*
hideWindow(){
  setTimer,checkFocus,delete
  Gui,guiMain:Hide

  return
}
;---------------------------- showWindowRefreshed ----------------------------
showWindowRefreshed(){
  global appName, menuhotkey, msgDefault

  setTimer,checkFocus,3000
  Gui, guiMain:Show
  
  return
}
;--------------------------- guiMainListViewClick ---------------------------
guiMainListViewClick(){
  if (A_GuiEvent = "Normal"){
    LV_GetText(rowSelected, A_EventInfo)
    runInDir(rowSelected)
  }

  return
}
;---------------------------- sendTextViaControl ----------------------------
sendTextViaControl(toSend := "", lastPid := 0){

  if (lastPid){
    ControlSend, ahk_parent, {Text}%toSend%, ahk_pid %lastPid%
    ControlSend, ahk_parent, {ENTER}, ahk_pid %lastPid%
  }

  return
}
;---------------------------- sendTextViaClipboard ----------------------------
sendTextViaClipboard(toSend := "", lastPid := 0){
; using clipboard to send is more reliable (but switches the windows)!

  if (lastPid){
    clipSave := clipboardAll
    clipboard := toSend
    ControlSend, ahk_parent, ^v, ahk_pid %lastPid%
    ControlSend, ahk_parent, {ENTER}, ahk_pid %lastPid%
    
    clipboard := clipSave
  }

  return
}
;-------------------------------- pSendChars --------------------------------
; pSendChars(string := "", pid := "") {

  ; for k, char in StrSplit(string)
    ; postmessage, WM_CHAR := 0x102, Asc(char),,, ahk_pid %pid%

  ; ControlSend, ahk_parent, {ENTER}, ahk_pid %pid%

  ; return
; }
;--------------------------------- sendText ---------------------------------
sendText(toSend := "", lastPid := 0){

  if (lastPid){
    SendInput,{Text}%toSend%
    SendInput,{ENTER}
  } else {
    msgbox, Error`, Window not found!
  }

  return
}
;----------------------------- sendTextClipBoard -----------------------------
sendTextClipBoard(toSend := "", lastPid := 0){

  if (!lastPid){
    clipboard := toSend
    SendInput,{Shift down}{RBUTTON}{Shift up}
    SendInput,{Enter}
  } else {
    WinWaitActive, ahk_pid %lastPid%
    clipboard := toSend
    SendInput,{Shift down}{RBUTTON}{Shift up}
    SendInput,{Enter}
  }

  return
}
;---------------------------- sendLinuxClipBoard ----------------------------
sendLinuxClipBoard(toSend := "", lastPid := 0){

  if (!lastPid){
    clipboard := toSend
    SendInput,{Shift down}{RBUTTON}{Shift up}
    SendInput,{Enter}
  } else {
    WinWaitActive,ahk_pid %lastPid%
    clipboard := toSend
    SendInput,{Shift down}{RBUTTON}{Shift up}
    SendInput,{Enter}
  }
  
  return
}
;----------------------------------- runInDir ------------------------------
runInDir(lineNumber){
  global sbtstarttype, lastOpenedTitle, filemanagerpath
  global configFile
  global entryNameArr, entryIndexArr, directoriesArr, startcmdArr
  global replSelectLastDirUsed, autoselectName, additionalCommand
  global app, lastPid, wslStart, usingWSL, wsltitlecmd

  usingWSL := false
  usingWT := false

  id := ""

  if (entryIndexArr[lineNumber] != "")
    id := entryIndexArr[lineNumber]

  id := StrReplace(id,"(","")
  id := StrReplace(id,")","")

  lastOpenedTitle := id
  
  replSelectLastDirUsed := cvtPath(directoriesArr[lineNumber])

  sw := 0
  startApp := ""
  qMark := """"
  bl := " "

  if (GetKeyState("Ctrl", "P"))
    sw := 1

  if (GetKeyState("Shift", "P"))
    sw := 2

  terminalType="CMD"
  
  ; switch to WSL
  if (InStr(id, "$WSL$")){
    terminalType := "WSL"
  }
  
  ; switch to WT
  if (InStr(id, "$WT$")){
    terminalType := "WT"
  }

  if (sw == 0){
    ; normal

    h := WinExist(lastOpenedTitle)
    if (h){
      MsgBox, 4,,An already open cmd-window found (%lastOpenedTitle%), close it?
      IfMsgBox Yes
        {
        Winclose
        }
      else
        {
        showMessageRed("Operation failed due to an already open window!", 3000)

        return
        }
    }

    lineArr := StrSplit(startcmdArr[lineNumber],"#")
    startCmd := lineArr[1]
    param := lineArr[2]
    usePath := cvtPath(directoriesArr[lineNumber])

    switch terminalType
    {
      case "CMD":
        cs := cvtPath("%comspec%")
        startEnv := cs . " /k"
        ; remove "JAVA_HOME"
        setEnv := setSystemEnvCmd("", "JAVA_HOME")
        Run, %setEnv%,,min
        
        Run, %startEnv%,%usePath%,max,lastPid
          
      case "WSL":
        cs := "wsl.exe"
        SetTitleMatchMode, 2
        Run, %wslStart%,,max, lastPid
        sleep, 3000

      case "WT":
        SetTitleMatchMode, 2
        run, wt.exe -w 0 nt --title Name: -d %usePath%,%usePath%,max,lastPid
        cs := "Sbt_console"
    }
  
    WinWaitActive, %cs%,,10
    if ErrorLevel
    {
        MsgBox, Cannot open window %cs%!
        return
    }
    
    SetTitleMatchMode, 1
    StringCaseSense, Off
    
    switch terminalType
    {
      case "CMD", "%comspec%":
        sleep, 500
        ;pSendChars("title " . lastOpenedTitle, lastPid)
        sendTextViaControl("title " . lastOpenedTitle, lastPid)
        sleep, 500
            
      case "WSL":
        sendLinuxClipBoard(StrReplace(wsltitlecmd,"§§THE TITLE§§", lastOpenedTitle))
        sleep, 3000
        pathLinux := cvtToLinux(replSelectLastDirUsed)
        sendLinuxClipBoard("cd " . pathLinux)

      case "WT":
        sleep, 500
        ;pSendChars("title " . lastOpenedTitle, lastPid)
        sendTextViaControl("title " . lastOpenedTitle, lastPid)
        sleep, 500
    }
    
    if (additionalCommand != ""){
      switch terminalType
      {
        case "CMD", "%comspec%":
          sendTextViaClipboard(additionalCommand, lastPid)
        
        case "WSL":
          sendTextViaClipboard(additionalCommand)
        
        case "WT":
          sendTextViaClipboard(additionalCommand)
      }
    }

    if (startCmd != ""){
      switch terminalType
      {
        case "CMD", "%comspec%":
          sendTextViaControl(startCmd, lastPid)
        
        case "WSL":
          sendLinuxClipBoard(startCmd)
        
        case "WT":
          sendLinuxClipBoard(startCmd)
      }
    }
    
    if (param != ""){
      lineArrLength := lineArr.Length() - 1
      Loop, % lineArrLength
      {
        index := A_index + 1
        param := lineArr[index]

        MsgBox,4,Command has an additional parameter!,`nPlease wait until the command has finished!`n`nIf the command has finished you can send the additional parameter:`n`n%param%`n`nSend it now?
        IfMsgBox Yes
        {
          if (InStr(param,"+close+")){
            msgbox, closing`, using [CTRL + D] and exit
            sendExit()
            break
          } else {
            switch terminalType
            {
              case "CMD", "%comspec%":
                sendLinuxClipBoard(param)
                  
              case "WSL":
                sendLinuxClipBoard(param)

              case "WT":
                sendLinuxClipBoard(param)
            }
          }
        }
      }
    }
    IniWrite, "%lastOpenedTitle%", %configFile%, config, lastOpenedTitle
  }
  
  if (sw == 1){
  ; + Ctrl = Filemanager
    startApp := cvtPath(filemanagerpath) . bl . qMark . replSelectLastDirUsed . qMark
    Run, %startApp%,%replSelectLastDirUsed%,max
    sleep, 3000
  }
  
  return
}
;--------------------------------* unselect --------------------------------*
unselect(){
  sendinput {left}
}
;--------------------------------* sendExit --------------------------------*
sendExit(){
  sendInput,{Ctrl Down}d{Ctrl Up}{ENTER}
  sleep, 1000
  sendInput,exit
  sendInput,{ENTER}

  return
}
;------------------------------ openGithubPage ------------------------------
openGithubPage(){
  global appnameLower

  Run https://github.com/jvr-ks/%appnameLower%

  return
}
;----------------------------------- ret ------------------------------
ret() {
  return
}

; ----------------------------------- cvtPath ------------------------------
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
;-------------------------------- resolvePath --------------------------------
resolvePath(p){
  global wrkdir

  r := p
  if (!InStr(p, ":"))
    r := wrkdir . p

  return r
}
;----------------------------------- envVariConvert ------------------------------
envVariConvert(s){
  r := s
  if (InStr(s,"%")){
    s := StrReplace(s,"`%","")
    EnvGet, v, %s%
    Transform, r, Deref, %v%
  }

  return r
}

; ----------------------------------- shortcut ------------------------------
shortcut(s){
  global shortcutsArr

  r := s

  sc := shortcutsArr[r]
  if (sc != "")
    r := sc

  return r
}
;------------------------------------ eq ------------------------------------
eq(a, b) {
  if (InStr(a, b) && InStr(b, a))
    return 1
  return 0
}
;--------------------------------- showHint ---------------------------------
showHint(s, t := 0, positionTop := 0){
  global font, fontsize

  Gui, hint:Destroy
  Gui, hint:Font, %fontsize%, %font%
  Gui, hint:Add, Text,, %s%
  Gui, hint:-Caption
  Gui, hint:+ToolWindow
  Gui, hint:+AlwaysOnTop
  if (positionTop)
    Gui, hint:Show,xcenter y2
  else
    Gui, hint:Show
  
  if (t > 0){
    t := -1 * t
    setTimer, showHintDestroy, %t%
  }
  
  return
}
;------------------------------ showHintDestroy ------------------------------
showHintDestroy(){
  global hinttimer

  setTimer,showHintDestroy, delete
  Gui, hint:Destroy
  return
}
;---------------------------- ConsoleWindowClass ----------------------------
; *enter::
; if (WinActive("ahk_class ConsoleWindowClass")) {
  ; sendInput, ^j
; } else {
  ; sendInput,{enter}
; }

;----------------------------------- hkToDescription ------------------------------
; in Lib
;----------------------------------- hotkeyToText ------------------------------
; in Lib
;----------------------------------- shutdown ------------------------------
;------------------------------- exitAndReload -------------------------------
exitAndReload(){
  global appname

  saveConfig()
  saveGuiData()
  
  restart(0)
}
;--------------------------------- errorExit ---------------------------------
errorExit(theMsgArr, clp := "") {
  global app, posXsave, posYsave

  msgComplete := ""
  for index, element in theMsgArr
  {
    msgComplete .= element . "`n"
  }
  msgbox,48,ERROR,%msgComplete%

  saveConfig()
  saveGuiData()
  showHint("""" . app . """ removed from memory!", 1500)
  MouseMove, posXsave, posYsave, 0

  exit()
}
;---------------------------- editTextFileCmdFile ----------------------------
editTextFileCmdFile(){
  global editTextFileFilename, cmdFile
  
  editTextFileFilename:= cmdFile
  editTextFile()
  
  return
}
;-------------------------- editCommandFileExternal --------------------------
editCommandFileExternal(){
  global cmdFile
  
  run, %cmdFile%
  msgbox, If content was changed via an external editor`,`nplease press the "OK"-button to reload!
  restart(1)
  
  return
}
;-------------------------- editTextFileConfigFile --------------------------
editTextFileConfigFile(){
  global editTextFileFilename, configFile
  
  editTextFileFilename:= configFile
  editTextFile()
  
  return
}
;-------------------------- editConfigFileExternal --------------------------
editConfigFileExternal(){
  global configFile
  
  run, %configFile%
  msgbox, If content was changed via an external editor`,`nplease press the "OK"-button to reload!
  restart(1)
  
  return
}
;------------------------- editTextFileShortcutsFile -------------------------
editTextFileShortcutsFile(){
  global editTextFileFilename, shortcutsFile
  
  editTextFileFilename:= shortcutsFile
  editTextFile()
  
  return
}
;------------------------- editShortcutsFileExternal -------------------------
editShortcutsFileExternal(){
  global shortcutsFile
  
  run, %shortcutsFile%
  msgbox, If content was changed via an external editor`,`nplease press the "OK"-button to reload!
  restart(1)
  
  return
}
;------------------------------- editTextFile -------------------------------
; non SCI version
editTextFile(){
  global editTextFileFilename, editTextFileContent, clientWidth, clientHeight
  
  saveConfig()
  
  hideWindow()

  if (FileExist(editTextFileFilename)){
    theFile := FileOpen(editTextFileFilename,"r")
    
    if !IsObject(theFile) {
        msgbox, Error, can't open "%editTextFileFilename%" for reading, exiting to prevent a data loss!
        exitApp
    } else {
      data := theFile.Read()
      theFile.Close()
      
      editTextFileContent := data
      
      borderX := 10
      borderY := 50
      
      h := clientHeight - borderY
      w := clientWidth - borderX
      
      gui, editTextFile:new, +resize +AlwaysOnTop,Edit (autosave on close): %theFile%
      gui, editTextFile:Font, s9, Segoe UI
      gui, editTextFile:Add, edit, x0 y0 w0 h0
      gui, editTextFile:add,edit, h%h% w%w% VeditTextFileContent,%data%
      
      gui, editTextFile:show,center autosize
    } 
  } else {
    msgbox, Error, file not found: %theFile% !
  }

  return
}
;--------------------------- editTextFileGuiClose ---------------------------
editTextFileGuiClose(){
  global appname, editTextFileFilename, editTextFileContent
  
  gui,editTextFile:submit,nohide
  
  theFile := FileOpen(editTextFileFilename,"w")
  
  if !IsObject(theFile) {
      msgbox, Error, can't open "%editTextFileFilename%" for writing!
  } else {
    theFile.Write(editTextFileContent)
    theFile.Close()

    gui,editTextFile:destroy

    restart(1,1)
  }
  
  return
}
;---------------------------- editTextFileGuiSize ----------------------------
editTextFileGuiSize(){

   if (A_EventInfo != 1) {
    editTextFileWidth := A_GuiWidth
    editTextFileHeight := A_GuiHeight

    borderX := 10
    borderY := 50
    
    w := editTextFileWidth - borderX
    h := editTextFileHeight - borderY

    GuiControl, Move, editTextFileContent, h%h% w%w%
  }

  return
}
;------------------------------ setSystemEnvCmd ------------------------------
setSystemEnvCmd(s := "", p := "PATH"){

  theEnv := ""
  if(s != ""){
    theEnv := cvtPath("%SystemRoot%\System32\windowspowershell\v1.0\powershell.exe")
    theEnv := theEnv . " -NoProfile -ExecutionPolicy Bypass -Command """
    theEnv := theEnv . "$newEnvVari = '" . s . "'`n"
    theEnv := theEnv . "[Environment]::SetEnvironmentVariable('" . p . "', ""$newEnvVari"",'Machine');""`n"
  }
  
  ;msgbox, % theEnv

  return theEnv
}
;---------------------------------- restart ----------------------------------
restart(forceShow := 0, noSave := 0){
  global app, posXsave, posYsave
  global allArgs

  if (!noSave)
    saveConfig()
    
  saveGuiData()
  showHint("""" . app . """ restart!", 1500)

  if (forceShow){
    allArgs := StrReplace(allArgs,"showwindow","")
    allArgs := StrReplace(allArgs,"hidewindow","")
    allArgs .= " " . "showwindow"
  }
  
  if A_IsCompiled
      Run "%A_ScriptFullPath%" /force /restart %allArgs%
  else
      Run "%A_AhkPath%" /force /restart "%A_ScriptFullPath%" %allArgs%


  ExitApp
}
;----------------------------------- Exit -----------------------------------
exit(){
  global app, posXsave, posYsave

  saveConfig()
  saveGuiData()
  showHint("""" . app . """ removed from memory!", 1500)
  MouseMove, posXsave, posYsave, 0

  ExitApp
}
;----------------------------------- ExitFunc ------------------------------
ExitFunc(ExitReason, ExitCode)
{
  msgbox, Should not reach this point point! ExitReason: %ExitReason%, ExitCode: %ExitCode%
  
  return
}
