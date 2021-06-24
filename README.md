# sbt_console_select
Download from github:  
[sbt_console_select.exe](https://github.com/jvr-ks/sbt_console_select/raw/master/sbt_console_select.exe)   
[sbt_console_select.ini](https://github.com/jvr-ks/sbt_console_select/raw/master/sbt_console_select.ini)   
[sbt_console_select.txt](https://github.com/jvr-ks/sbt_console_select/raw/master/sbt_console_select.txt)   
[sbt_console_select_jhome.txt](https://github.com/jvr-ks/sbt_console_select/raw/master/sbt_console_select_jhome.txt)   
[sbt_console_select_shortcuts.txt](https://github.com/jvr-ks/sbt_console_select/raw/master/sbt_console_select_shortcuts.txt)   
~~[repl.txt](https://github.com/jvr-ks/sbt_console_select/raw/master/repl.txt)~~   
  
Virus check see below.  

App changes the Clipboard-content!  
  
Simple app (Windows only \*1)) to start "sbt console" (the [Scala](https://www.scala-lang.org/) REPL) [sbt](https://www.scala-sbt.org/) is a Scala build tool in different directories. 
  
Can be used to start any programm/app in a selectable directory.  
("sbt console" needs a ["build.sbt" file](https://www.scala-sbt.org/1.x/docs/Basic-Def.html) in the running directory!).  


* Start sbt_console_select by a doubleclick onto the file "sbt_console_select.exe".  
or  
* drag the "sbt_console_select.exe" to the taskbar.  
or  
* create a shortcut of "sbt_console_select.exe" in the windows-autostart folder ("shell:startup")  
and add "hidewindow" as a parameter.  
-> "sbt_console_select - Shortcut.lnk" -> rightclick -> properties -> target -> add "hidewindow" as a parameter,  
(and optional the Command-file and Config-file path),  
then start with the hotkey.  

##### Hotkey operations supplied by the app   
(default -> \[Config-file]):  

* menuhotkey: **\[ALT] + \[t]** -> open menu,    
* exitHotkey: **\[SHIFT] + \[ALT] + \[t]** -> sends \[CTRL] + \[d] and "exit",   

* replLoadHotkey: **\[ALT] + \[e]** or **\[CTRL] + \[e]**  ->
The replcommand1 ... replcommandN commands defined in the "[replcommands]"-section of the \[Config-file]  
are executed one by one.  
If the --load the code-- replcommandN (a dummy) is reached,   
the **whole** code or the **selected** code-part  
of the current file is executed in the REPL.  
 
The code is copied to the clipboard, written to temporary file "repl.tmp" \*3)  
(in the sbt-console-select directory, with an additional newline appended)   
and then loaded into the SBT-REPL and "executed" by executing "replcommandN=:load path-to-repl.tmp" instead of the "replcommandN=--load the code--" command \*2)  
   
* replLoadExecHotkey: **\[SHIFT] + \[ALT] + \[e]**  ->  
The currently **selected** code-part is saved to the temporary file "replExec.tmp"  
This code is executed by the REPL everytime the dummy replcommandN = --load the codeExec--   
is reached, i.e. when on of the replLoadHotkeys is pressed.  
The \[Config-file] must contain "replcommandN = --load the codeExec--"  
preferable as the last command!   
  
Example code:  
  
// scala3   
  
// mark this part1 and press the replLoadExecHotkey (once only!) (**\[SHIFT] + \[ALT] + \[e]** is default).  
listMagician(List(Magician("Copperfield", 64), Magician("Merlin", 920)))  
\/* 1)
  
// mark this part2 and press the replLoadHotkey (**\[CTRL] + \[e]** is default).   
case class Magician(name: String, age: Int)  
  
given magicianOrdering: Ordering[Magician] = new Ordering[Magician] {  
	override def compare(x: Magician, y: Magician): Int = {  
		x.age.compareTo(y.age)  
	}  
}  
  
def listMagician(magicians: Seq[Magician]) = {  
	println("List of Magicians:")  
	for p <- magicians.sorted do  
		println(s"Name: $p.name, Age: p.age")  
}  
  
Code is interpreted as two parts (like :paste-mode).  
  
/* 1) to inactivate contents mark "//" and press the replLoadExecHotkey!  
   
* replResethotkey: **\[CTRL] + \[r]** -> Reset SBT-REPL  
To reset SBT-REPL via hotkey.   
The SBT-console is identified by its title with an id created from actual time.    
Can be used while Notepad\++ is in the forground, switches to Repl-window and back. 

Remember: SBT-Console depends on "build.sbt" and the files in the "project"-subfolder!     

\*1) Can be used with the WSL, but cannot set the Java-runtime-version in WSL.  
\*2) Drawback: Code is inserted as a block, you cannot navigate thru each line,  
\*3) Sends Ctrl + C keys or Ctrl + A, Ctrl + C keys to your editor
 
##### Setting Java and Scala versions  
Using SBT:  
Java-version: SBT reads the JAVA_HOME environment variable  
Scala-version: SBT uses the definition in the file "build.sbt"  
  
Using plain Scala:
Java-version: First Windows-path environment variable is used (can bet set by [Selja](https://github.com/jvr-ks/selja))  
JAVA_HOME environment variable is ignored.  
Scala-version:  First Windows-path environment variable is used ~~(can bet set by a powershell command, would be better to have something like Selja)~~ (can bet set by [Selsca](https://github.com/jvr-ks/selsca) I've created today :-) ).  
SCALA_HOME environment variable is ignored.  
SCALA_HOME can be set by appending the path to the Java-path with a "#"-separator (in the file)   "sbt_console_select_jhome.txt", but it is ignored by Scala.
  
##### App status  
* Usable, but work in progress!  
* Executable is **64bit** now

##### Remarks
* Do not change the Console-Window if the last command has not started!  
* Last opened (by sbt_console_select) Console-Window is peferred but any other opened Console-Window is used. 
* Can be used not only to start sbt but many other tools, starts a %comspec% shell if command-field is emtpy.
* REPL Past mode:  
* * Just prepend code with :paste, mark the code and press a replLoadHotkey.   
* * No Ctrl+D is needed, past-mode ends when the file-end is reached.  

##### Latest changes  

* Moved GraalVM to "C:\shared\*" (file "sbt_console_select_jhome.txt")
* replLoadHotkey mechanism changed!
* JAVA_OPTS and JAVA_TOOL_OPTIONS   
can be set (global setting valid for all entries):  
* * as "JAVA_OPTS= ..." / "JAVA_OPTS= ..." in the the \[Config-file]  
or (valid for the specific entry only): 
* * as the two last columns in the  \[Command-file]
* * any valid not empty value overrides the global setting
* * a value of "-" disables the global setting also
  
* Last opened (by sbt_console_select) Console-Window is used, otherwise any other last opened Console-Window.  
* [replcommands] containing "//" are not send 
* Use \[Capslock] to start WSL promt instead Windows-shell prompt, example:  
Activate \[Capslock] and select "amm", starts Ammonite REPL on WSL.  
(Ammonite REPL must be installed in your Linux Distribution on WSL [64 bit only])  
Ammonite REPL on Windows ignores JAVA_HOME settings and has some other drawbacks,  
but is usable inside a [Jupyter Notebook](https://jupyter.org/) on Windows 10 [Almond Jupyter Scala Kernel](https://almond.sh/)
* Menu entry to edit the \[Config-file] 
* New mechanism to send commands to the REPL prior to the code, usefull example: ":silent"  
Up to 10 variables replcommand1, replcommand2, ... ,replcommand10 can be defined in the [replcommands] section of the \[Config-file]   
* \[SHIFT] + Click, additional opens "build.sbt" with the default Windows program assigned to *.sbt suffixes.  
* \[CTRL] + Click, additional opens the filemanager -> \[Config-file]  
* Command-number as a startparameter (autostart this command),  
Example: sbt_console_select.exe 3 sbt_console_select.txt  
Pathes can also be absolut, i.e. c:\\...\\sbt_console_select.txt
* notepadpath removed, relies on Windows mechanism now, to open a text-editor
* Special  keyword "+close+" to close SBT-console  
* More the one parameter allowed  
* Problem starting with hidewindow parameter solved
* Additional parameter can be send to sbt console, delimiter character is "#"
* Config-file is UTF-8 coded
* Gui redesign  
* **hidemenu** changed to **hidewindow**  
Batch-file "create_sbt_console_select_exe_link_hidewindow_in_autostartfolder.bat" creates a link with "hidewindow" parameter  
* New Edit menu-entries  
* **"sbt_console_select_java.txt"** renamed to **"sbt_console_select_jhome.txt"**  
* New \[Shortcuts-file] **"sbt_console_select_shortcuts.txt"** to define path-shortcuts to be used in the \[Command-file]  
* The "exitHotkey" \[SHIFT] + \[ALT] + \[t] now sends \[CTRL] + \[d] and "exit".   
* The \[Command-file] now contains three entries separated by a comma,  
The working directory,the command with parameter,the JAVA_HOME directory.  
The command can be any program (accessible via Windows path), not only sbt.  
* Holding down \[CTRL] while clicking an menu entry additionaly first starts the filemanager in the working directory.  
* Example of an \[Command-file] entry:   c:\tmp,java -version,jdk8   
* Section \[sbt] removed from \[Config-file]  

### Example (Windows 10):  

##### Download and configure "sbt_console_select":  
  
* [Download sbt_console_select as ZIP](https://github.com/jvr-ks/sbt_console_select/archive/master.zip)  
* Extract folder "sbt_console_select-master" from the downloaded file "sbt_console_select-master.zip"  
* DoubleClick "sbt_console_select.exe" in the just created "sbt_console_select-master" folder  
* Click on \\[Edit] -> \[Edit JavaHome-file], configure your Java,save,close editor  
* Click on \[Edit] -> \[Edit Command-file], edit the last line ", sbt -sbt-version 1.4.6 consoleQuick,graalvm11_203", replace "graalvm11_203" with your just configured Java name, save, close editor  
(-sbt-version 1.4.6 is added because there is not "project/build.properties"-file yet (is created then),  
the path is not set, so using the actual path of the "sbt_console_select.exe")    
  
##### Start REPL
(SBT must be installed!) 
* Using included files "build.sbt" and "scalafxTest2.sc" which is [based on https://github.com/scalafx/scalafx/blob/master/scalafx-demos/src/main/scala/scalafx/ColorfulCircles.scala](https://github.com/scalafx/scalafx/blob/master/scalafx-demos/src/main/scala/scalafx/ColorfulCircles.scala)
* Type \[Alt] + \[t] to reopen sbt_console_select
* Click on the last entry, sbt consoleQuick is started  
* It takes a moment to start the REPL, (using included file "built.sbt") 
* Type ":load scalafxTest2.sc"  
* After closing th demo, type \[Shift] + \[Alt] + \[t] to close the REPL (sends \[Ctrl] + \[D] and "exit")
* For ScalaFX us \[Ctrl] + \[D] then \[Arrow Up] then ":load scalafxTest2.sc" to restart

##### Executable
* "sbt_console_select.exe"  
* "sbt_console_select.exe" \[Command-file] \[Config-file] \[hidewindow] \[remove]   
 
\[Command-file], \[Config-file] see below
\[hidewindow] = the word "hidewindow" 
\[remove] = the word "remove" , remove app from memory (to compile a new one)  

##### Configuration
* \[Command-file], default is "sbt_console_select.txt",  
contains on each line, separated by a tab or a comma:  
  
Entry 1 | Entry 2 | Entry 3
------------ | ------------- | -------------
Working directory, | Command, | JAVA_HOME setting \[optional] *)  
 
*) Selecting the JAVA-version via JAVA_HOME operates only with programms/apps that evaluate the JAVA_HOME environment-variable.   
Elsewhere you can use [selja](https://github.com/jvr-ks/selja) , to select the JAVA-version.  
 

* \[Config-file], default is "sbt_console_select.ini",  
contains name=value pairs,  
divided by different \[sections].
Currently:  
- Hotkey definitions  
- Path to Notepad\++, emailapp and filemanager. 
   
The Config-file **must** have the extension *.ini  
  
Only simple Hotkey modifications are reflected in the menu.  
(Parsing is limited to \[CTRL], \[ALT], \[WIN], \[SHIFT]).  
~~If the Config-file contains special characters, it must be ANSI encoded! (not UTF-8 but UCS-2 LE-BOM is also allowed)~~  
  
* \[Java-file] "sbt_console_select_java.txt" (name not changable),  
contains on each line, separated by a tab or a comma:  
   
Entry 1 | Entry 2
------------ | ------------- 
A name, | The JAVA_HOME setting (path to Java) 
    
Use [Notepad\++](https://notepad-plus-plus.org/) to edit the config-files.  
  
  
##### Startparameter / Autostart
Startparameter |  action
------------ | ------------- 
hidewindow | start app in the background  
Command-number: 1 or 2 ... N | autostart this command (app stays in the background afterwards)
Config-file | must have extension ".ini"
Command-file | must have extension ".txt"
remove | removes app from memory
  
##### Sourcecode: [Autohotkey format](https://www.autohotkey.com)
* "sbt_console_select.ahk".  
  
##### Requirements
* Windows 10 or later only.  
* Installed [SBT](https://www.scala-sbt.org/)  
* Portable app, nothing to install. 
  
##### Sourcecode
Github URL [github](https://github.com/jvr-ks/sbt_console_select).  

##### Hotkeys
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/cmdlinedev/blob/master/hotkeys.md)
  
  
##### License: MIT
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sub-license, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT-ABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
  
Copyright (c) 2020 J. v. Roos  


##### Virus check at Virustotal 
[Check here](https://www.virustotal.com/gui/url/ff99979467dfc66771a6fc4ea2525f0071804ae60257147bee1b05f626c48eb8/detection/u-ff99979467dfc66771a6fc4ea2525f0071804ae60257147bee1b05f626c48eb8-1624546012
)  
Use [CTRL] + Click to open in a new window! 
