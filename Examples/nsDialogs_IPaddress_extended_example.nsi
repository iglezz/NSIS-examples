!include LogicLib.nsh
!include nsDialogs.nsh
!include nsDialogs_IPaddress_Ex.nsh

RequestExecutionLevel user
ShowInstDetails show

Page custom nsD_IPAddress_create nsD_IPAddress_leave
Page components
Page instfiles

Var h_ipaddress1
Var h_ipaddress2
Var h_edit
Var h_log
Var ipaddress1
Var ipaddress2


Function nsD_IPAddress_create
    nsDialogs::Create 1018
    Pop $0

    StrCmp $0 "error" 0 +2
        Abort
    
    ; Init IPAddress
    ${NSD_InitCommonControl_IPAddress}
    
    ; 1st row
    ${NSD_CreateLabel} 5u 2u 64u 12u "Text field:"
    
    ${NSD_CreateText} 70u 0u 80u 12u "234.1.1.355"
    Pop $h_edit

    ${NSD_CreateButton} 155u 0u 110u 12u "NSD_SetText(IP address 1)"
    Pop $0
    ${NSD_OnClick} $0 onClick_SetIP1
    
    ; 2nd row
    ${NSD_CreateLabel} 5u 17u 64u 12u "IP address 1:"

    ${NSD_CreateIPAddress} 70u 15u 80u 14u ""
    Pop $h_ipaddress1
    ${NSD_OnNotify} $h_ipaddress1 onNotify_IPAddress
    
    ${NSD_CreateButton} 155u 16u 25u 12u "127"
    Pop $0
    ${NSD_OnClick} $0 onClick_SetIP11

    ${NSD_CreateButton} 183u 16u 25u 12u "0"
    Pop $0
    ${NSD_OnClick} $0 onClick_SetIP12

    ${NSD_CreateButton} 211u 16u 25u 12u "0"
    Pop $0
    ${NSD_OnClick} $0 onClick_SetIP13

    ${NSD_CreateButton} 239u 16u 25u 12u "1"
    Pop $0
    ${NSD_OnClick} $0 onClick_SetIP14

    ; 3rd row
    ${NSD_CreateLabel} 5u 32u 64u 12u "IP address 2:"

    ${NSD_CreateIPAddress} 70u 30u 80u 14u "255.1.34.100"
    Pop $h_ipaddress2
    ${NSD_OnNotify} $h_ipaddress2 onNotify_IPAddress
    
    ${NSD_CreateButton} 155u 31u 110u 12u "Get IP2"
    Pop $0
    ${NSD_OnClick} $0 onClick_GetIP2


    ; log window
    ${NSD_CreateListBox} 0u 44u 100% 70u ""
    Pop $h_log
    
    ; memo
    ${NSD_CreateLabel} -150u -12u 150u 12u "Set IP address 1 == $\"127.0.0.1$\" to continue"
    
    ; lock next/install button
    GetDlgItem $0 $HWNDPARENT 1
    EnableWindow $0 0
    
    nsDialogs::Show
FunctionEnd

!define GetFieldValue `!insertmacro GetFieldValue`
!macro GetFieldValue FIELD RESULT
    ${NSD_GetText} ${FIELD} ${RESULT} 
    StrCmp ${RESULT} "" 0 +2
    StrCpy ${RESULT} 0
!macroend

Function onClick_GetIP2
    ${NSD_IPAddress_GetUnpackedIPv4} $h_ipaddress2 $1 $2 $3 $4
    ${NSD_LB_AddString} $h_log "IP2: $1.$2.$3.$4"
FunctionEnd

Function onNotify_IPAddress
    Pop $R7 ; HWND
    Pop $R8 ; Code
    Pop $R9 ; NMHDR*

    ${If} $R8 <> ${IPN_FIELDCHANGED}
        ${NSD_Return} 0
    ${EndIf}

    ; Set $R5 to the index of the field that was previously focused
    ; Set $5 to the value of the field $R5
    System::Call '*$R9(p,p,p, i.R5,i.r5)'   ; extract from NMIPADDRESS*
    IntOp $R5 $R5 + 1 ; change field index from 0-based to 1-based

    System::Call "user32::GetFocus(v) i.R6" ; handle of the focused control/IP field

    FindWindow $R4 "" "" $R7       ; handle of the 4th field
    FindWindow $R3 "" "" $R7 $R4   ; handle of the 3rd field
    FindWindow $R2 "" "" $R7 $R3   ; handle of the 2nd field
    FindWindow $R1 "" "" $R7 $R2   ; handle of the 1st field

    ; Set $R0 to the index of the focused field or zero
    ; $R0 = 0 if the IP control loses focus
    ${Select} $R6
        ${Case} $R1
            StrCpy $R0 1
        ${Case} $R2
            StrCpy $R0 2
        ${Case} $R3
            StrCpy $R0 3
        ${Case} $R4
            StrCpy $R0 4
        ${Default}
            StrCpy $R0 0
    ${EndSelect}

    ; Equal field indexes are similar to the 'leave field' event before focusing to another field
    ${If} $R0 = $R5
        ${NSD_Return} 0
    ${EndIf}

    ; Begin your checks and validations here:
    
    ; -------------
    ; Example start
    ; -------------
    
    ; Get the value of the exact field:
    ${GetFieldValue} $R1 $1 ; $1 is the value of the 1st field
    ${GetFieldValue} $R2 $2 ; $2 is the value of the 2nd field
    ${GetFieldValue} $R3 $3 ; $3 is the value of the 3rd field
    ${GetFieldValue} $R4 $4 ; $4 is the value of the 4th field
    
    ; Get the values of all fields:
    ${NSD_IPAddress_GetUnpackedIPv4} $h_ipaddress2 $1 $2 $3 $4 ; field values: $1.$2.$3.$4
    
    
    ; Construct and write log details on the IPN_FIELDCHANGED event
    ${If} $R0 = 0 
        StrCpy $9 "outer space..."
    ${Else}
        ${NSD_GetText} $R6 $0           ; $0 is the value of focused field
        StrCpy $9 "field$R0='$0'"
    ${EndIf}
    
    ${If} $R7 = $h_ipaddress1
        ${NSD_GetText} $R7 $ipaddress1
        ${NSD_LB_AddString} $h_log "1: field$R5='$5'  -->  $9,   S:$ipaddress1, F:$1.$2.$3.$4"
    ${ElseIf} $R7 = $h_ipaddress2
        ${NSD_GetText} $R7 $ipaddress2
        ${NSD_LB_AddString} $h_log "2: field$R5='$5'  -->  $9,   S:$ipaddress2, F:$1.$2.$3.$4"
    ${EndIf}
    
    
    ;(un)locking next/install button part of example
    GetDlgItem $0 $HWNDPARENT 1
    
    ${If} $R7 = $h_ipaddress1
        ${If} $ipaddress1 == "127.0.0.1"
            EnableWindow $0 1
        ${Else}
            EnableWindow $0 0
        ${EndIf}
    ${EndIf}
    
    ; -----------
    ; Example end
    ; -----------
    
    /* Other functions defined in the nDialogs.nsh
    
    !define NSD_IPAddress_Clear         `${__NSD_MkCtlCmd} IPM_CLEARADDRESS 0 0 `
    !define NSD_IPAddress_IsBlank       `${__NSD_MkCtlCmd_RV} IPM_ISBLANK 0 0 `
    !define NSD_IPAddress_SetPackedIPv4 `${__NSD_MkCtlCmd_LP} IPM_SETADDRESS 0 `
    !define NSD_IPAddress_GetPackedIPv4 `!insertmacro __NSD_IPAddress_GetPackedIPv4 `
    
    Information about IP Address Control on the Microsoft Docs site: https://docs.microsoft.com/en-us/windows/win32/controls/ip-address-control-reference

    */
    
FunctionEnd


Function onClick_SetIP1
    ${NSD_GetText} $h_edit $0
    ${NSD_SetText} $h_ipaddress1 $0
FunctionEnd


Function onClick_SetIP11
    FindWindow $R4 "" "" $h_ipaddress1
    FindWindow $R3 "" "" $h_ipaddress1 $R4
    FindWindow $R2 "" "" $h_ipaddress1 $R3
    FindWindow $R1 "" "" $h_ipaddress1 $R2
    ${NSD_SetText} $R1 127
FunctionEnd


Function onClick_SetIP12
    FindWindow $R4 "" "" $h_ipaddress1
    FindWindow $R3 "" "" $h_ipaddress1 $R4
    FindWindow $R2 "" "" $h_ipaddress1 $R3
    ${NSD_SetText} $R2 0
FunctionEnd


Function onClick_SetIP13
    FindWindow $R4 "" "" $h_ipaddress1
    FindWindow $R3 "" "" $h_ipaddress1 $R4
    ${NSD_SetText} $R3 0
FunctionEnd


Function onClick_SetIP14
    FindWindow $R4 "" "" $h_ipaddress1
    ${NSD_SetText} $R4 1
FunctionEnd


Function nsD_IPAddress_leave
    ${NSD_GetText} $h_ipaddress1 $ipaddress1
    ${NSD_GetText} $h_ipaddress2 $ipaddress2

    StrCmp $ipaddress1 "127.0.0.1" +2 0
        Abort
FunctionEnd


Section ""
    DetailPrint "IP address 1: $ipaddress1"
    DetailPrint "IP address 2: $ipaddress2"
SectionEnd