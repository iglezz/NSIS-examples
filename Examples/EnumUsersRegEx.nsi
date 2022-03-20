!include EnumUsersRegEx.nsh

ShowInstDetails show


Function ProcUserProfiles

    Pop $0 ; SubKey
    Pop $1 ; SID
    
    ${EnumUsersRegEx_GetProfilePath} $3 $1
    
    ${If} $3 != ""
        DetailPrint "SID: $1"
        DetailPrint "profilepath = $3"
        
        DetailPrint ""
    ${EndIf}
    
FunctionEnd


Function SIDFilter_UsersOnly

    System::Store L
    Pop $0 ; SID
    
    StrCpy $1 $0 8
    StrCmp $1 "S-1-5-21" +3 0
        StrCpy $1 ""
        Goto Fin

    StrCpy $1 $0 "" -8
    StrCmp $1 "_Classes" 0 +3
        StrCpy $1 ""
        Goto Fin
    
    Fin:
    
    System::Store S
    Push $1
    
FunctionEnd


Function ProcUsers

    System::Store L
    Pop $0 ; SubKey
    Pop $1 ; SID
    
    DetailPrint "SID: $1"
    
    StrCpy $2 $0 7 ; == "offline" if user is not logged on
    
    ${If} $2 == "offline"
        DetailPrint "<offline>"
    ${Else}
        DetailPrint "<logged on>"
    ${EndIf}
    
    ${EnumUsersRegEx_GetProfilePath} $3 $1
    
    ${If} $3 != ""
        DetailPrint "Profile path = $3"
        
        ReadRegStr $4 HKU "$0\${REGPATH_UserShellFolders}" "AppData"
        ${WordReplace} "$4" "%USERPROFILE%" "$3" "+*" $4
        DetailPrint "AppData = $4"
        
        ReadRegStr $5 HKU "$0\${REGPATH_UserShellFolders}" "Local AppData"
        ${WordReplace} "$5" "%USERPROFILE%" "$3" "+*" $5
        DetailPrint "LocalAppData = $5"
        
        DetailPrint ""
    ${EndIf}
    
    System::Store S
    
FunctionEnd


!macro EnumClassesTest CLASSESPATH
    
    Push ${CLASSESPATH}
    Exch $0 ; path
    Push $1 ; counter
    Push $2
    Push $3
    
    StrCpy $1 0
    
    ${Do}
    
        EnumRegKey $2 HKU $0 $1
        
        ${If} $2 != ""
            ReadRegStr $3 HKU "$0\$2" ""
            
            DetailPrint "'$2' = '$3'"
            
            IntOp $1 $1 + 1
            
            ${If} $1 = 15
                ${ExitDo}
            ${EndIf}
        ${EndIf}
        
    ${LoopUntil} $2 == ""
    
    Pop $3
    Pop $2
    Pop $1
    Pop $0
    
!macroend


Function ProcUserClasses

    System::Store L
    Pop $0 ; SubKey
    Pop $1 ; SID
    ; $R9 - offline reg subkey
    
    StrCpy $2 $0 7 ; == "offline" if user is not logged on
    StrCpy $3 "" ; Classes regpath
    
    ${If} $2 == "offline"
        ${EnumUsersRegEx_LoadClasses} $R9 $0 $1
        ${If} $R9 != ""
            StrCpy $3 $R9
        ${EndIf}
    ${Else}
        StrCpy $3 "$0_Classes"
    ${EndIf}
    
    ${If} $3 != ""
        DetailPrint "SID: $1"
        DetailPrint "First # registered extensions"
        !insertmacro EnumClassesTest $3
        DetailPrint ""
    
        ${If} $2 == "offline"
        ${AndIf} $R9 != ""
            ${EnumUsersRegEx_UnloadClasses} $R9
        ${EndIf}
    ${EndIf}
    
    System::Store S
    
FunctionEnd


Section

    DetailPrint "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    DetailPrint "Example 1: Accounts with profilepath"
    DetailPrint "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    ${EnumUsersRegEx} ProcUserProfiles ""

    DetailPrint "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    DetailPrint "Example 2: User profile folders"
    DetailPrint "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    ${EnumUsersRegEx} ProcUsers SIDFilter_UsersOnly

    DetailPrint "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    DetailPrint "Example 3: User extensions"
    DetailPrint "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    ${EnumUsersRegEx} ProcUserClasses SIDFilter_UsersOnly

SectionEnd