/*  EnumUsersRegEx.nsh:

This script will enumerate all local users and load their registry hives (HKCU) one by one. You can use it to delete settings of logged off users. 
Based on EnumUsersReg.nsh (https://nsis.sourceforge.io/EnumUsersReg) by kichik (https://nsis.sourceforge.io/User:Kichik)

Version: 0.9
Author: iglezz

*/
!ifndef ___EnumUsersRegEx___
!define ___EnumUsersRegEx___


!include Util.nsh
!include LogicLib.nsh
!include WordFunc.nsh


;defined if "Win\WinNT.nsh"
!define /ifndef TOKEN_QUERY             0x0008
!define /ifndef TOKEN_ADJUST_PRIVILEGES 0x0020
!define /ifndef SE_RESTORE_NAME         SeRestorePrivilege
!define /ifndef SE_PRIVILEGE_ENABLED    0x00000002
;defined in WinCore.nsh
!define /ifndef HKEY_USERS              0x80000003

/*; alt define using !include:
!define __WIN_NOINC_WINBASE
!define __WIN_NOINC_WINGDI
!define __WIN_NOINC_WINDOWSX
!define __WIN_NOINC_SHLOBJ
!define __WIN_NOINC_SHOBJIDL
!define __WIN_NOINC_SHLGUID
!define __WIN_NOINC_WINDEF
!define __WIN_NOINC_WINERROR
!define WIN32_NO_STATUS
!define __WIN_NOINC_WINUSER
!include "WinCore.nsh"
*/
!define REGPATH_ProfileList "SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
!define REGPATH_UserShellFolders "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"


!define EnumUsersRegEx_LoadClasses '!insertmacro EnumUsersRegEx_LoadClasses'

!macro EnumUsersRegEx_LoadClasses RETURN SUBKEY SID

Push "${SUBKEY}"
Push "${SID}"

Exch $0 ; SID
Exch
Exch $1 ; subkey
Push $2
Push $3

${EnumUsersRegEx_GetProfilePath} $2 $0
ReadRegStr $3 HKU "$1\${REGPATH_UserShellFolders}" "Local AppData"
${WordReplace} "$3\Microsoft\Windows\UsrClass.dat" "%USERPROFILE%" "$2" "+*" $3

${If} ${FileExists} $3
    GetFullPathName /SHORT $3 $3
    StrCpy $0 "$1_Classes"
    System::Call "advapi32::RegLoadKey(i ${HKEY_USERS}, t r0, t r3) i .r3"
    
    ${If} $3 <> 0
        StrCpy $0 ""
    ${EndIf}
${Else}
    StrCpy $0 ""
${EndIf}

Pop $3
Pop $2
Pop $1
Exch $0

Pop ${RETURN}

!macroend


!define EnumUsersRegEx_UnloadClasses '!insertmacro EnumUsersRegEx_UnloadClasses'

!macro EnumUsersRegEx_UnloadClasses SUBKEY 

System::Call "advapi32::RegUnLoadKey(i ${HKEY_USERS}, t '${SUBKEY}')"

!macroend


!define EnumUsersRegEx_GetProfilePath '!insertmacro EnumUsersRegEx_GetProfilePath'

!macro EnumUsersRegEx_GetProfilePath RETURN SID

ReadRegStr ${RETURN} HKLM "${REGPATH_ProfileList}\${SID}" "ProfileImagePath"
ExpandEnvStrings ${RETURN} ${RETURN}

!macroend


!macro _EnumUsersRegEx_AdjustTokens

Push $R1

StrCpy $R1 0

System::Call "kernel32::GetCurrentProcess() i .R0"
System::Call "advapi32::OpenProcessToken(i R0, i ${TOKEN_QUERY}|${TOKEN_ADJUST_PRIVILEGES}, *i R1R1) i .R0"

${If} $R0 != 0
    System::Call "advapi32::LookupPrivilegeValue(t n, t '${SE_RESTORE_NAME}', *l .R2) i .R0"
    
    ${If} $R0 != 0
        System::Call "*(i 1, l R2, i ${SE_PRIVILEGE_ENABLED}) i .R0"
        System::Call "advapi32::AdjustTokenPrivileges(i R1, i 0, i R0, i 0, i 0, i 0)"
        System::Free $R0
    ${EndIf}
    
    System::Call "kernel32::CloseHandle(i R1)"
${EndIf}

Pop $R1

!macroend


!macro _EnumUsersRegEx_InvokeCallback CALLBACK SUBKEY SID

Push $0
Push $1
Push $R0
Push $R1
Push $R2

Push "${SID}"
Push "${SUBKEY}"

Call "${CALLBACK}"

Pop $R2
Pop $R1
Pop $R0
Pop $1
Pop $0

!macroend


!macro _EnumUsersRegEx_Load FILE CALLBACK SUBKEY SID

GetFullPathName /SHORT $R2 ${FILE}
System::Call "advapi32::RegLoadKey(i ${HKEY_USERS}, t '${SUBKEY}', t R2) i .R2"

${If} $R2 == 0
    !insertmacro _EnumUsersRegEx_InvokeCallback "${CALLBACK}" "${SUBKEY}" "${SID}"
    System::Call "advapi32::RegUnLoadKey(i ${HKEY_USERS}, t '${SUBKEY}')"
${EndIf}

!macroend


!macro _EnumUsersRegEx_FilterSID RETURN FUNC SID

${If} ${FUNC} = 0
    StrCpy ${RETURN} 1
${Else}
    Push $0
    Push $1
    Push $R0
    Push $R1
    Push $R2
    
    Push ${SID}
    
    Call ${FUNC}
    
    Exch 5
    Pop $0
    Pop $R2
    Pop $R1
    Pop $R0
    Pop $1
    
    Pop ${RETURN}
${EndIf}

!macroend


!define EnumUsersRegEx '!insertmacro EnumUsersRegEx'

!macro EnumUsersRegEx CALLBACKFUNC FILTERFUNC

!if "${FILTERFUNC}" == ""
!insertmacro _EnumUsersRegEx_NoFilter ${CALLBACKFUNC}
!else
!insertmacro _EnumUsersRegEx_WithFilter ${CALLBACKFUNC} ${FILTERFUNC}
!endif

!macroend


!macro _EnumUsersRegEx_NoFilter CALLBACKFUNC

Push 0
Push $0

GetFunctionAddress $0 "${CALLBACKFUNC}"

Exch $0

${CallArtificialFunction} _EnumUsersRegEx

!macroend


!macro _EnumUsersRegEx_WithFilter CALLBACKFUNC FILTERFUNC

Push $0
Push $1

GetFunctionAddress $0 "${CALLBACKFUNC}"
GetFunctionAddress $1 "${FILTERFUNC}"

Exch $1
Exch 
Exch $0

${CallArtificialFunction} _EnumUsersRegEx

!macroend


!macro _EnumUsersRegEx
Exch $0 ; callback func address
Exch
Exch $1 ; filter func address
Push $R0 ; counter
Push $R1 ; SID
Push $R2 ; tmp

; enumerate logged on users
StrCpy $R0 0

loop:
    EnumRegKey $R1 HKU "" $R0
    StrCmp $R1 "" done
    
    !insertmacro _EnumUsersRegEx_FilterSID $R2 $1 $R1
    StrCmp $R2 "" skip_InvokeCallback
    
    !insertmacro _EnumUsersRegEx_InvokeCallback $0 $R1 $R1
    
    skip_InvokeCallback:
    
    IntOp $R0 $R0 + 1
    Goto loop
    
done:

; enumerate logged off users
!insertmacro _EnumUsersRegEx_AdjustTokens

StrCpy $R0 0

loop2:
    EnumRegKey $R1 HKLM "${REGPATH_ProfileList}" $R0
    StrCmp $R1 "" done2
    
    ; skip already logged on users
    EnumRegKey $R2 HKU "$R1" $R0
    StrCmp $R2 "" 0 skipinvoke2
    
    !insertmacro _EnumUsersRegEx_FilterSID $R2 $1 $R1
    StrCmp $R2 "" skip_InvokeCallback
    
    ${EnumUsersRegEx_GetProfilePath} $R2 $R1

    !insertmacro _EnumUsersRegEx_Load "$R2\NTUSER.DAT" $0 "offline$R1" $R1
    
    skipinvoke2:
    
    IntOp $R0 $R0 + 1
    Goto loop2
done2:

Pop $R2
Pop $R1
Pop $R0
Pop $1
Pop $0

!macroend


!endif