Name "SetSectionFromCommandlineExample"
OutFile "SetSectionFromCommandlineExample.exe"

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


Section "Section 1" sec1
	DetailPrint "Section 1: Doing some stuff..."
SectionEnd

Section  "Section 2" sec2
	DetailPrint "Section 2: Doing some stuff..."
SectionEnd

Section  /o "Section 3" sec3
	DetailPrint "Section 3: Doing some stuff..."
SectionEnd


Function .onInit
	Push $R0
	Push $R1
	
	${GetParameters} $R0
	${GetOptions} "$R0" "/1" $R1
	${IfNot} ${Errors}
		${If} $R1 == '+'
			${SelectSection} ${sec1}
		${ElseIf} $R1 == '-'
			${UnselectSection} ${sec1}
		${Else}
			${SelectSection} ${sec1}
			${UnselectSection} ${sec2}
			${UnselectSection} ${sec3}
		${EndIf}
	${EndIf}
	
	${GetOptions} "$R0" "/2" $R1
	${IfNot} ${Errors}
		${If} $R1 == '+'
			${SelectSection} ${sec2}
		${ElseIf} $R1 == '-'
			${UnselectSection} ${sec2}
		${Else}
			${UnselectSection} ${sec1}
			${SelectSection} ${sec2}
			${UnselectSection} ${sec3}
		${EndIf}
	${EndIf}
	
	${GetOptions} "$R0" "/3" $R1
	${IfNot} ${Errors}
		${If} $R1 == '+'
			${SelectSection} ${sec3}
		${ElseIf} $R1 == '-'
			${UnselectSection} ${sec3}
		${Else}
			${UnselectSection} ${sec1}
			${UnselectSection} ${sec2}
			${SelectSection} ${sec3}
		${EndIf}
	${EndIf}
	
	Pop $R1
	Pop $R0

FunctionEnd
