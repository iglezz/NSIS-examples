!include LogicLib.nsh
!include nsDialogs.nsh

RequestExecutionLevel user
ShowInstDetails show

Page custom NSDIP_create NSDIP_leave
Page instfiles
    
Var h_ipaddress
Var ipaddress


Function NSDIP_create
    nsDialogs::Create 1018
    Pop $0
    
    ; Init IPAddress control
    ${NSD_InitCommonControl_IPAddress}
    
    ; Create control
    ${NSD_CreateIPAddress} 33% 15u 34% 14u ""
    Pop $h_ipaddress
    
    ; Workaround for ugly fonts
    CreateFont $0 "$(^Font)" "$(^FontSize)"
    SendMessage $h_ipaddress ${WM_SETFONT} $0 1
    
    ; Set IP address with NSD_SetText
    ${NSD_SetText} $h_ipaddress "192.168.1.1"
    
    nsDialogs::Show
FunctionEnd


Function NSDIP_leave
    ; Get IP address with NSD_GetText
    ${NSD_GetText} $h_ipaddress $ipaddress
FunctionEnd


Section ""
    DetailPrint "IP address: $ipaddress"
SectionEnd