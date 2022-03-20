Name "SetSectionFromCommandlineExample2.1"
OutFile "SetSectionFromCommandlineExample2.1.exe"

ShowInstDetails show
AutoCloseWindow false
RequestExecutionLevel user

Page components
Page instfiles

!include "FileFunc.nsh"
!include "LogicLib.nsh"
!include "Sections.nsh"
!define SelectSection "!insertmacro SelectSection"
!define UnselectSection "!insertmacro UnselectSection"


Section /o "Section 1" g1o1
	DetailPrint "Section 1: Doing some stuff..."
SectionEnd

Section  /o "Section 2" g1o2
	DetailPrint "Section 2: Doing some stuff..."
SectionEnd

Section  /o "Section 3" g1o3
	DetailPrint "Section 3: Doing some stuff..."
SectionEnd

Section  /o "Section 4" g1o4
	DetailPrint "Section 4: Doing some stuff..."
SectionEnd


Function .onInit
	Push $R0
	Push $R1
	Push $R2
	
	StrCpy $1 ${g1o1}
	
	${GetParameters} $R0
	${GetOptions} "$R0" "/O" $R1
	${IfNot} ${Errors}
		IntFmt $R2 "%u" $R1
		
		${If} $R2 > 0
		${AndIf} $R2 < 5
			IntOp $1 $R2 - 1
		${EndIf}
	${EndIf}
	
	${SelectSection} $1
	
	Pop $R2
	Pop $R1
	Pop $R0

FunctionEnd

Function .onSelChange
	!insertmacro StartRadioButtons $1
		!insertmacro RadioButton ${g1o1}
		!insertmacro RadioButton ${g1o2}
		!insertmacro RadioButton ${g1o3}
		!insertmacro RadioButton ${g1o4}
	!insertmacro EndRadioButtons
FunctionEnd 