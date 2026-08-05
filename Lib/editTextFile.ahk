; editTextFile.ahk


content := ""


editTextFile(fileName){

  if (FileExist(fileName)){
  
    FileRead, data, % configFile
    
    setTextToSCI(data)
  
  
  
  
  
  
  }




  return
}