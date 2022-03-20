!ifndef nsDialogs_IPaddress_Ex_INCLUDED
!define nsDialogs_IPaddress_Ex_INCLUDED


!define /ifndef       IPN_FIRST        0xFFFFFCA4
!define /ifndef /math IPN_FIELDCHANGED ${IPN_FIRST} - 0

!define IPADDRESS_FIELDS '(b,b,b,b)i'

!define /redef NSD_CreateIPAddress `!insertmacro NSD_CreateIPAddressFixed`

!macro NSD_CreateIPAddressFixed x y w h label

Push $0
Push $1

nsDialogs::CreateControl ${__NSD_IPAddress_CLASS} ${__NSD_IPAddress_STYLE} ${__NSD_IPAddress_EXSTYLE} ${x} ${y} ${w} ${h} ""
Pop $0

CreateFont $1 "$(^Font)" "$(^FontSize)"
SendMessage $0 ${WM_SETFONT} $1 1
${NSD_SetText} $0 "${label}"

Pop $1
Exch $0

!macroend


!define NSD_IPAddress_GetUnpackedIPv4 `!insertmacro __NSD_IPAddress_GetUnpackedIPv4 `

!macro __NSD_IPAddress_GetUnpackedIPv4 CONTROL VAR1 VAR2 VAR3 VAR4

Push $1
Push $2
Push $3
Push $4

System::Call '*${IPADDRESS_FIELDS}(0, 0, 0, 0) .r1'
System::Call 'USER32::SendMessage(p${CONTROL},i${IPM_GETADDRESS},p0,i r1)'
System::Call '*$1${IPADDRESS_FIELDS}(.r4,.r3,.r2,.r1)'

Push $1
Push $2
Push $3
Push $4

Exch 7
Pop $1
Exch 5
Pop $2
Exch 3
Pop $3
Exch 
Pop $4

Pop ${VAR1}
Pop ${VAR2}
Pop ${VAR3}
Pop ${VAR4}

!macroend


!endif