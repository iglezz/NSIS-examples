!ifndef FILEFUNC_INCLUDED

!define FILEFUNC_INCLUDED

!include Util.nsh





!define GetCommandLine `!insertmacro GetCommandLine_macro`

!macro GetCommandLine_macro RESULT
    ${CallArtificialFunction} GetCommandLine_
    Pop ${RESULT}
!macroend

!macro GetCommandLine_
    Push $0
    Push $1
    Push $2
    
    StrLen $1 $EXEPATH
    IntOp $1 $1 + 1
    
    System::Call "kernel32::GetCommandLine() t.r0"

    StrCpy $2 $0 1
    StrCmp $2 '"' 0 +3
        IntOp $1 $1 + 2
    
    StrCpy $0 $0 "" $1
    
    Pop $2
    Pop $1
    Exch $0
!macroend



!endif