; cmdlinedev_editGui.ahk
; part of cmdlinedev


;-------------------------------- editGuiCreate --------------------------------
editGuiCreate(){
  global directoriesFile, directoriesArr, forcedCancel, fontsize, emptyFieldSubstituteChar
  global paramMaxCount, currentSelected
  global editRow1, editRow2, editRow3, editRow4, editRow5, editRow6, editRow7
  
  directoryEntryArr := StrSplit(directoriesArr[currentSelected], ",")
  ; entries: 1 Name, 2 Current, 3 path, 4 - 7 commands
  
  Gui, editGui:new, +owner +0x80000000, Edit entry
  Gui, editGui:Font, s%fontsize%
  Gui, editGui:Add, Text, x2 y2 w100, Name
  Gui, editGui:Add, Edit, x+m section yp+0 w400 VeditRow1, % directoryEntryArr[1]
  Gui, editGui:Add, Text, x2, Current
  Gui, editGui:Add, Edit, xs yp+0 w400 VeditRow2, % directoryEntryArr[2]
  Gui, editGui:Add, Text, x2, Path
  Gui, editGui:Add, Edit, xs yp+0 w400 VeditRow3, % (directoryEntryArr[3] = emptyFieldSubstituteChar) ? "" : directoryEntryArr[3]
  Gui, editGui:Add, Text, x2, Cmd1
  Gui, editGui:Add, Edit, xs yp+0 w400 VeditRow4, % (directoryEntryArr[4] = emptyFieldSubstituteChar) ? "" : directoryEntryArr[4]
  Gui, editGui:Add, Text, x2, Cmd2
  Gui, editGui:Add, Edit, xs yp+0 w400 VeditRow5, % (directoryEntryArr[5] = emptyFieldSubstituteChar) ? "" : directoryEntryArr[5]
  Gui, editGui:Add, Text, x2, Cmd3
  Gui, editGui:Add, Edit, xs yp+0 w400 VeditRow6, % (directoryEntryArr[6] = emptyFieldSubstituteChar) ? "" : directoryEntryArr[6]
  Gui, editGui:Add, Text, x2, Cmd4
  Gui, editGui:Add, Edit, xs yp+0 w400 VeditRow7, % (directoryEntryArr[7] = emptyFieldSubstituteChar) ? "" : directoryEntryArr[7]
  Gui, editGui:Add, Button, GeditGuiButtonSave Default w80, Save
  Gui, editGui:Add, Button, GeditGuiButtonCancel w80 x+m yp+0, Cancel
  Gui, editGui:Show, center
}
;------------------------------ editGuiButtonSave ------------------------------
editGuiButtonSave(){
  global paramMaxCount, emptyFieldSubstituteChar, directoriesArr, currentSelected, directoriesFile
  global editRow1, editRow2, editRow3, editRow4, editRow5, editRow6, editRow7
  
  gui, editGui:submit
  
  directoryEntryArr := StrSplit(directoriesArr[currentSelected], ",")
  
  loop, %paramMaxCount% {
    if (editRow%A_Index% = ""){
      if (A_Index > 2){
        directoryEntryArr[A_Index] := emptyFieldSubstituteChar
      }
    } else {
      directoryEntryArr[A_Index] := editRow%A_Index%
    }
  }
  
  inp := ""
  for k,v in directoryEntryArr
    inp .= v . ","
  
  inp := SubStr(inp, 1, -1)  ; remove last colon
  ;save new command
  directoriesArr[currentSelected] := inp
  
  content := ""
  
  Loop, % directoriesArr.length() {
    content := content . directoriesArr[A_Index] . "`n"
  }
  
  FileDelete, %directoriesFile%
  FileAppend, %content%, %directoriesFile%, UTF-8
  
  Gui, editGui:Destroy
  editGui := ""
  
  showWindowRefreshed()
}
;------------------------------ editGuiGuiClose ------------------------------
editGuiGuiClose(){
  editGuiButtonSave()
}
;---------------------------- editGuiButtonCancel ----------------------------
editGuiButtonCancel(){

  Gui, editGui:Destroy
  editGui := ""
  showWindowRefreshed()
}

;----------------------------------------------------------------------------





















