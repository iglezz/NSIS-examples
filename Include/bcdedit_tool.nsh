!ifndef __bcdedit_tool.nsh__
!define __bcdedit_tool.nsh__

!include x64.nsh

/*
bcdedit  | findstr -i testsigning

bcdedit /set testsigning on

OK exitcode:
    0
OK stdout:
    The operation completed successfully.


bcdedit /set testsigning off
bcdedit /deletevalue testsigning

OK exitcode:
    0
OK stdout:
    The operation completed successfully.

ERR exitcode:
    1
ERR stdout:
    An error occurred while attempting to delete the specified data element.
    Element not found.

*/

/*  BCDEDIT_FullName
    https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/bcdedit-command-line-options

Return Success:
    Full path to bcdedit.exe or "" (empty string)
    
*/
!define BCDEDIT_FullName '!insertmacro BCDEDIT_FullName'

!macro BCDEDIT_FullName RETURN
    Call BCDEDIT_FullName
    Pop ${RETURN}
!macroend

Function BCDEDIT_FullName
    Push $0
    
    StrCpy $0 "$WINDIR\Sysnative\bcdedit.exe"
    ${IfNot} ${RunningX64}
        StrCpy $0 "$SYSDIR\bcdedit.exe"
    ${EndIf}
    
    IfFileExists "$0" +2
    StrCpy $0 ""
    
    Exch $0
FunctionEnd


/*  BCDEDIT_TestModeGetState

Return: 
    0 - TestMode disabled
    1 - TestMode enabled
    2 - BCDEDIT call error

*/
!define BCDEDIT_TestModeGetState '!insertmacro BCDEDIT_TestModeGetState'

!macro BCDEDIT_TestModeGetState RETURN
    Call BCDEDIT_TestModeGetState
    Pop ${RETURN}
!macroend

Function BCDEDIT_TestModeGetState
    Push $0
    Push $1
    Push $2
    
    StrCpy $2 ""
    
    ${BCDEDIT_FullName} $0
    nsExec::ExecToStack /OEM '"$0" /enum {current}'
    Pop $0 ; exitcode ('error' on nsExec error)
    
    StrCmp $0 0 0 capturefinished
    
    Pop $0 ; captured output
    
    IntOp $1 0 - 1 ; counter
    
    loop_first:
        IntOp $1 $1 + 1
        StrCpy $2 $0 1 $1
        
        StrCmp $2 "" capturefinished
        StrCmp $2 "$\n" 0 loop_first
        
        StrCpy $2 $0 12 $1
        StrCmp $2 "$\ntestsigning" 0 loop_first
    
    IntOp $1 $1 + 12
    
    loop_second:
        IntOp $1 $1 + 1
        StrCpy $2 $0 1 $1
        
        StrCmp $2 "" capturefinished
        StrCmp $2 "$\n" 0 loop_second
        
    IntOp $1 $1 - 4
    StrCpy $2 $0 3 $1
    
    DetailPrint "captured::[$2]"
    
    capturefinished:
    StrCmp $2 "" +2 0
    StrCmp $2 " No" 0 +2
        StrCpy $0 0
    StrCmp $2 "Yes" 0 +2
        StrCpy $0 1
        
    Pop $2
    Pop $1
    Exch $0
FunctionEnd


/*  BCDEDIT_TestModeEnable

Return: 
    0 - TestMode disabled
    1 - TestMode enabled
    2 - BCDEDIT call error

*/
!define BCDEDIT_TestModeEnable '!insertmacro BCDEDIT_TestModeEnable'

!macro BCDEDIT_TestModeEnable RETURN
    Call BCDEDIT_TestModeEnable
    Pop ${RETURN}
!macroend

Function BCDEDIT_TestModeEnable
    Push $0
    
    ${BCDEDIT_FullName} $0
    nsExec::Exec '"$0" /set testsigning on'
    Pop $0 ; exitcode ('error' on nsExec error)
    
    StrCmp $0 0 0 +3
        StrCpy $0 1
        Goto +2
    StrCpy $0 0

    Exch $0
FunctionEnd


!endif
