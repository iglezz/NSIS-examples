; Sections2E.nsh
;
; Defines and macros for section control
;
; Include in your script using:
; !include "Sections2E.nsh"

;--------------------------------

!ifndef SECTIONS2E_INCLUDED
!define SECTIONS2E_INCLUDED

!include "Sections.nsh"

!define SF_SELF_SHIFT 10
!define /math SF_SELF 1 << ${SF_SELF_SHIFT} ; 1024 ; selected flag (internal use)
!define SF_RADIO   2048 ; radio (internal use)
!define SF_RACTIVE 4096 ; active radio (internal use)
!define SF_RSUB    8192 ; radio subsection (internal use)

!macro SaveSelectedFlag SECTION ;; 15
	Push $R0
	Push $R1
	Push $R2
	
	StrCpy $R0 ${SECTION}
	SectionGetFlags $R0 $R1
	IntOp $R2 $R1 & ${SF_SELECTED}
	IntCmp $R2 ${SF_SELECTED} 0 +3 +3
		IntOp $R1 $R1 & ${SF_SELF}
		Goto +3
		IntOp $R2 ${SF_SELF} ~
		IntOp $R1 $R1 & $R2
	SectionSetFlags $R0 $R1
	
	Pop $R2
	Pop $R1
	Pop $R0
!macroend

!macro RestoreSelectedFlag SECTION ;; 15
	Push $R0
	Push $R1
	Push $R2
	
	StrCpy $R0 ${SECTION}
	SectionGetFlags $R0 $R1
	IntOp $R2 $R1 & ${SF_SELF}
	IntCmp $R2 ${SF_SELF} 0 +3 +3
		IntOp $R1 $R1 & ${SF_SELECTED}
		Goto +3
		IntOp $R2 ${SF_SELECTED} ~
		IntOp $R1 $R1 & $R2
	SectionSetFlags $R0 $R1
	
	Pop $R2
	Pop $R1
	Pop $R0
!macroend


!macro DefineActiveRadio SECTION
	!insertmacro SetSectionFlag ${SECTION} ${SF_RACTIVE}
!macroend

!macro DefineRadio SECTION
	!insertmacro SetSectionFlag ${SECTION} ${SF_RADIO}

	!insertmacro SectionFlagIsSet ${SECTION} ${SF_RACTIVE} +10 ""
		!insertmacro UnselectSection ${SECTION} ;; 8 ops
		Goto +17
		!insertmacro SelectSection ${SECTION} ;; 8 ops
		!insertmacro SetSectionFlag ${SECTION} ${SF_SELF} ;; 8 ops
!macroend

!macro DefineRadioSub SECTION SUBSECTION
	!insertmacro SetSectionFlag ${SUBSECTION} ${SF_RADIO} ;; ??? really need??
	!insertmacro SetSectionFlag ${SUBSECTION} ${SF_RSUB}
	!insertmacro SaveSelectedFlag ${SUBSECTION}
	
	!insertmacro SectionFlagIsSet ${SECTION} ${SF_RACTIVE} +18 ""
		!insertmacro UnselectSection ${SUBSECTION} ;; 8 ops
		!insertmacro SetSectionFlag ${SUBSECTION} ${SF_RO} ;; 8 ops
		Goto +12
		!insertmacro ClearSectionFlag ${SUBSECTION} ${SF_RO} ;; 11 ops
!macroend


!macro BeginRadioButtonsBlock
	Push $R0 ; changed/clicked section id
	Push $R1 ; prev radio id
	Push $R2 ; clicked radio id 
	Push $R3 ; radio sections counter
	Push $R4 ; tmp: section id
	Push $R5 ; tmp: section flags
	
	StrCpy $R0 $0 ; .onSelChange sets $0 to changed/clicked section id
	StrCpy $R2 -1
	StrCpy $R3 0
!macroend

!macro CheckRadioButton SECTION
	Push ${SECTION}
	
	; if this SECTION is changed then $R2 (selected) = SECTION
	StrCmp ${SECTION} $R0 0 +2 
		StrCpy $R2 ${SECTION}
	
	; if this SECTION have SF_RACTIVE flag then $R1 (prev selected) = SECTION
	SectionGetFlags ${SECTION} $R5
	IntOp $R5 $R5 & ${SF_RACTIVE}
	IntCmp $R5 ${SF_RACTIVE} 0 +2 +2
		StrCpy $R1 ${SECTION}
	
	IntOp $R3 $R3 + 1
!macroend

!macro CheckRadioSub SECTION SUBSECTION
	IntCmp $R1 $R2 CheckRadioSub${SECTION}_${SUBSECTION}Skip 0  ; $R2 == $R1 if this radio was clicked last time
	IntCmp -1 $R2 CheckRadioSub${SECTION}_${SUBSECTION}Skip 0  ; $R2 == -1 if no radio is pressed in this block
		
		SectionGetFlags ${SUBSECTION} $R5
		
		; IF (SECTION is checked)
		IntCmp $R2 ${SECTION} 0 CheckRadioSub${SECTION}_${SUBSECTION}Else CheckRadioSub${SECTION}_${SUBSECTION}Else
			; THEN
			; restore SF_SELF -> SF_SELECTED
			IntOp $R4 $R5 & ${SF_SELF}
			IntCmp $R4 ${SF_SELF} 0 +3 +3
				IntOp $R5 $R5 | ${SF_SELECTED}
				Goto +3
				IntOp $R4 ${SF_SELECTED} ~
				IntOp $R5 $R5 & $R4
			; remove SF_RO
			IntOp $R4 ${SF_RO} ~
			IntOp $R5 $R5 & $R4		
			Goto CheckRadioSub${SECTION}_${SUBSECTION}EndIf
			
			CheckRadioSub${SECTION}_${SUBSECTION}Else:
			; ELSE
			; save SF_SELECTED -> SF_SELF
			IntOp $R4 $R5 & ${SF_SELECTED}
			IntCmp $R4 ${SF_SELECTED} 0 +3 +3
				IntOp $R5 $R5 | ${SF_SELF}
				Goto +3
				IntOp $R4 ${SF_SELF} ~
				IntOp $R5 $R5 & $R4
			; remove SF_SELECTED
			IntOp $R4 ${SF_SELECTED} ~
			IntOp $R5 $R5 & $R4
			; set SF_RO
			IntOp $R5 $R5 | ${SF_RO}
		CheckRadioSub${SECTION}_${SUBSECTION}EndIf:
		
		SectionSetFlags ${SUBSECTION} $R5
	
	CheckRadioSub${SECTION}_${SUBSECTION}Skip:
!macroend

!macro EndRadioButtonsBlock
	
	; if changed section is GROUP then redefine $R0 = $R1 (prevoius radio)
	SectionGetFlags $R0 $R5
	IntOp $R5 $R5 & ${SF_SECGRP}
	IntCmp $R5 ${SF_SECGRP} 0 +3
		StrCpy $R0 $R1
		Goto +5
	
	; $R2 = -1 if no radio in this radio block was clicked
	IntCmp -1 $R2 0 +3 +3
		StrCpy $R0 $R1 ; not clicked, $R0 = $R1 (prevoius radio) 
		Goto +2
		StrCpy $R0 $R2 ; clicked, $R0 = $R2 (selected radio)
	
	; $R0 is used as active/current radio now
	; $R1 & $R2 are free now to use for other purposes
	
	; begin loop
	
	; Pop section id from stack and get it's flags
	Pop $R4
	SectionGetFlags $R4 $R5
	
	IntCmp $R4 $R0 0 +4 +4
		IntOp $R5 $R5 | ${SF_SELECTED}
		IntOp $R5 $R5 | ${SF_RACTIVE}
		Goto +4
		IntOp $R5 $R5 & ${SECTION_OFF}
		IntOp $R1 ${SF_RACTIVE} ~
		IntOp $R5 $R5 & $R1
	
	SectionSetFlags $R4 $R5
	
	IntOp $R3 $R3 - 1
	IntCmp $R3 0 +2 0 0
	Goto -12
	
	Pop $R5
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
!macroend


!endif