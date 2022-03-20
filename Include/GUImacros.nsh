!ifndef __GUImacros.nsh__
!define __GUImacros.nsh__

/* 
${SetButtonState} button state
    button = next | cancel | back
    state = hide | show | disable | enable

${SetButtonText} button text
    button = next | cancel | back
    text = user defined text
*/


!macro _SetButtonNameToID BUTTON_ID BUTTON_NAME 
    !if ${BUTTON_NAME} == next
    
        StrCpy ${BUTTON_ID} 1
        
    !else if ${BUTTON_NAME} == cancel
    
        StrCpy ${BUTTON_ID} 2
        
    !else if ${BUTTON_NAME} == back
    
        StrCpy ${BUTTON_ID} 3
        
    !else
    
        StrCpy ${BUTTON_ID} ${BUTTON_NAME}
        
    !endif
!macroend


!define SetButtonState '!insertmacro SetButtonState'

!macro SetButtonState BUTTON_ID BUTTON_FUNC
    Push $0
    
    ${_SetButtonNameToID} $0 ${BUTTON_ID}
    GetDlgItem $0 $HWNDPARENT $0
    
    !if ${BUTTON_FUNC} == hide
    
        ShowWindow $0 ${SW_HIDE}
        
    !else if ${BUTTON_FUNC} == show
    
        ShowWindow $0 ${SW_SHOW}
        
    !else if ${BUTTON_FUNC} == disable
    
        EnableWindow $0 0
        
    !else if ${BUTTON_FUNC} == enable
    
        EnableWindow $0 1
        
    !endif
    
    Pop $0
!macroend


!define SetButtonText '!insertmacro SetButtonText'

!macro SetButtonText BUTTON_ID BUTTON_TEXT
    Push $0
    
    ${_SetButtonNameToID} $0 ${BUTTON_ID}
    GetDlgItem $0 $HWNDPARENT $0
    
    SendMessage $0 ${WM_SETTEXT} 0 "STR:${BUTTON_TEXT}"
    
    Pop $0
!macroend



!endif