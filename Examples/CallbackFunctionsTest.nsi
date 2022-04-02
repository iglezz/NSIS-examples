Name "CallbackFunctions"
Unicode true

RequestExecutionLevel user

Page components
Page instfiles

!include "sections.nsh"


Section "Normal -> .onInstSuccess -> .onGUIEnd" SEC_N
    DetailPrint "doing something..."
SectionEnd

Section /o "Abort -> .onInstFailed -> .onGUIEnd" SEC_A
    DetailPrint "Abort!"
    Abort
SectionEnd

Section /o "Quit -> .onGUIEnd" SEC_Q
    Quit
SectionEnd


Function .onInit
	MessageBox MB_OK ".onInit"
    
    StrCpy $1 ${SEC_N}
FunctionEnd


Function .onGUIInit
	MessageBox MB_OK ".onGUIInit"
FunctionEnd


Function .onUserAbort
	MessageBox MB_OK ".onUserAbort"
FunctionEnd


Function .onGUIEnd
	MessageBox MB_OK ".onGUIEnd"
FunctionEnd


Function .onInstFailed
	MessageBox MB_OK ".onInstFailed"
FunctionEnd


Function .onInstSuccess
	MessageBox MB_OK ".onInstSuccess"
FunctionEnd


Function .onSelChange
  !insertmacro StartRadioButtons $1
    !insertmacro RadioButton ${SEC_N}
    !insertmacro RadioButton ${SEC_A}
    !insertmacro RadioButton ${SEC_Q}
  !insertmacro EndRadioButtons
FunctionEnd


