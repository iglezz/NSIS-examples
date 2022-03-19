Name "Sections2E example"
OutFile "Sections2E example.exe"

ShowInstDetails show
AutoCloseWindow false
RequestExecutionLevel user

Page components
Page instfiles

!include "Sections2E.nsh"

Section "!Install" RInstall
SectionEnd

Section "   All users"  RIAll
SectionEnd

Section /o "   Current User" RICurrent
SectionEnd

Section "shortcut to Start Menu" RISStartmenu
SectionEnd

Section /o "shortcut to Desktop" RISDesktop
SectionEnd

Section "Add to %PATH%" RISENVpath
SectionEnd 

Section /o "!Unpack Portable" RPortable
SectionEnd

Section /o "    shortcut to Desktop" RPSDesktop
SectionEnd

Section  /o "!     " 
SectionIn RO
SectionEnd

Section  /o "32-bit" Rx86
SectionEnd

Section /o "64-bit"  Rx64
SectionEnd


Function .onInit
	!insertmacro DefineActiveRadio ${RInstall}
	!insertmacro DefineRadio ${RInstall}
	!insertmacro DefineRadio ${RPortable}
	!insertmacro DefineRadioSub ${RInstall} ${RISStartmenu}
	!insertmacro DefineRadioSub ${RInstall} ${RISDesktop}
	!insertmacro DefineRadioSub ${RInstall} ${RISENVpath}
	!insertmacro DefineRadioSub ${RPortable} ${RPSDesktop}

	!insertmacro DefineActiveRadio ${RIAll}
	!insertmacro DefineRadio ${RIAll}
	!insertmacro DefineRadio ${RICurrent}

	!insertmacro DefineActiveRadio ${Rx86}
	!insertmacro DefineRadio ${Rx86}
	!insertmacro DefineRadio ${Rx64}
FunctionEnd

Function .onSelChange
	!insertmacro BeginRadioButtonsBlock
		!insertmacro CheckRadioButton ${RInstall}
		!insertmacro CheckRadioButton ${RPortable}
		!insertmacro CheckRadioSub ${RInstall} ${RISStartmenu}
		!insertmacro CheckRadioSub ${RInstall} ${RISDesktop}
		!insertmacro CheckRadioSub ${RInstall} ${RISENVpath}
		!insertmacro CheckRadioSub ${RInstall} ${RIAll}
		!insertmacro CheckRadioSub ${RInstall} ${RICurrent}
		!insertmacro CheckRadioSub ${RPortable} ${RPSDesktop}
	!insertmacro EndRadioButtonsBlock
	
	!insertmacro BeginRadioButtonsBlock
		!insertmacro CheckRadioButton ${RIAll}
		!insertmacro CheckRadioButton ${RICurrent}
	!insertmacro EndRadioButtonsBlock
	
	!insertmacro BeginRadioButtonsBlock
		!insertmacro CheckRadioButton ${Rx86}
		!insertmacro CheckRadioButton ${Rx64}
	!insertmacro EndRadioButtonsBlock
FunctionEnd 