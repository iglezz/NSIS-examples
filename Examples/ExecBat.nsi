; ExecBat - silently runs batch (bat|cmd) files with the same name as the executable file

Name "ExecBat"
Unicode true

RequestExecutionLevel user
SetOverwrite on
SetCompressor  LZMA
Icon "ExecBat.ico"
OutFile "ExecBat.exe"

!include "FileFunc.nsh"

Function .onInit
	StrCpy $0 "$EXEFILE" -3
    
	StrCpy $1 "$0bat"	
	IfFileExists "$EXEDIR\$1" +3 0
	
	StrCpy $1 "$0cmd"	
	IfFileExists "$EXEDIR\$1" 0 QuitApp
	
	${GetParameters} $2
	nsExec::Exec '"$1" $2'
	
	QuitApp:
	Quit
FunctionEnd

Section ""
SectionEnd
