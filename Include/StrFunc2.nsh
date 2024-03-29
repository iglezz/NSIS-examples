;StrFunc2.nsh
;Some new string manupulation macro/functions
;by iglezz iglezz@gmail.com
;ver 0.2.unstable

; ${Asc}         "Return" "Char"
; ${AscW}        "Return" "WChar"
; ${Chr}         "Return" "Integer"
; ${ChrW}        "Return" "Integer"
; ${StrEscape}   "Return" "InputString" "EscapeChar" "CharsToEscape"
; ${StrUnEscape} "Return" "InputString" "EscapeChar"

!ifndef __StrFunc2__
!define __StrFunc2__ "__StrFunc2__nsh__"

!include "Util.nsh"

!define IfIsHex "!insertmacro IfIsHex"

!macro IfIsHex _STRING _GOTO_YES _GOTO_NO
	Push $0
	Push $1

	Messagebox mb_ok "0$\nin=[${_STRING}] 0=[$0] 1=[$1]"
	StrCpy $0 "${_STRING} ++" ;2 0
;	Messagebox mb_ok "1$\nin=[${_STRING}] 0=[$0] 1=[$1]"
	StrCmp $0 "0x" 0 +3
		StrCpy $0 "${_STRING}"
		Goto +2
		StrCpy $0 "0x${_STRING}"
;	Messagebox mb_ok "2$\nin=[${_STRING}] 0=[$0] 1=[$1]"
	IntFmt $1 "%X" "$0"
;	Messagebox mb_ok "3$\nin=[${_STRING}] 0=[$0] 1=[$1]"
	StrCmp "$0" "0x$1" 0 +4
		Pop $1
		Pop $0
		Goto ${_GOTO_YES}
		!ifdef ${_GOTO_NO}
			Pop $1
			Pop $0
			Goto ${_GOTO_NO}
		!endif

!macroend




/***** Asc *********************************************************************
Returns an 1-byte Integer representing the character code corresponding to the first letter in a string.
Based on Asc function by nechai (https://nsis.sourceforge.io/Asc)

Syntax:
${Asc} "Return" "Char"

"Return" ; Variable where the ASCII code is returned.
"Char"   ; string argument

Example:
${Asc} $0 "a"   ; $0 = 97
*/
!define Asc "!insertmacro Asc"

!macro Asc RETURN CHAR
	Push $0
	Push $1

	System::Call "*(&t1 '${CHAR}')i.r1"
	System::Call "*$1(&i1 .r0)"
	System::Free $1

	Pop $1
	Exch $0
	Pop ${RETURN}
!macroend


/***** AscW ********************************************************************
Returns an 2-byte Integer representing character code corresponding to the WChar

Syntax:
${AscW} "Return" "WChar"

"Return"   ; Variable where the Integer code is returned.
"WChar"    ; string argument

Example:
${AscW} $0 "№"   ; $0 = 8470 (0x2116)
*/
!define AscW "!insertmacro AscW"

!macro AscW RETURN CHAR
	Push $0
	Push $1

	System::Call "*(&t2 '${CHAR}')i.r1"
	System::Call "*$1(&i2 .r0)"
	System::Free $1

	Pop $1
	Exch $0
	Pop ${RETURN}
!macroend


/***** Chr *********************************************************************
Returns a char corresponding to the integer (1-byte) number

Syntax:
${Chr} "Return" "Integer"

"Return"   ; Variable where the Char is returned.
"Integer"  ; Integer argument

Example:
${Chr} $0 97   ; $0 = "a"
*/
!define Chr "!insertmacro Chr"

!macro Chr RETURN INTEGER
	Push $0
	Push $1

	System::Call "*(&i1 '${INTEGER}')i.r1"
	System::Call "*$1(&t1 .r0)"
	System::Free $1

	Pop $1
	Exch $0
	Pop ${RETURN}
!macroend


/***** ChrW ********************************************************************
Returns a WChar corresponding to the integer (2-byte) number

Syntax:
${ChrW} "Integer" "Return"

"Return"   ; Variable where the WChar is returned.
"Integer"  ; Integer argument

Example:
${ChrW} $0 0x2116   ; $0 = "№"
*/
!define ChrW "!insertmacro ChrW"

!macro ChrW RETURN INTEGER
	Push $0
	Push $1

	System::Call "*(&i2 '${INTEGER}')i.r1"
	System::Call "*$1(&t2 .r0)"
	System::Free $1

	Pop $1
	Exch $0
	Pop ${RETURN}
!macroend


/***** StrEscape ***************************************************************

Syntax:
${StrEscape}   "Return" "InputString" "EscapeChar" "CharsToEscape"

"Return"        ; Output string
"InputString"   ; Input string
"EscapeChar"    ; Escape char
"CharsToEscape" ; String with characters to escape

Example:
${StrEscape} $0 "C:\Program Files\" "\" ":\ "  ; $0 = "C\:\\Program\ Files\\"
*/
!define StrEscape '!insertmacro StrEscape_macro'

!macro StrEscape_macro RETURN INPUT ESCCHAR CHARSTOESC
	Push "${CHARSTOESC}"
	Push "${ESCCHAR}"
	Push "${INPUT}"

    ${CallArtificialFunction} StrEscape_func

	Pop ${RETURN}
!macroend

!macro StrEscape_func
    Exch $0  ; INPUT string
    Exch 2
    Exch $1  ; CHARSTOESC string
    Exch
    Exch $2  ; ESC char
    Push $3  ; temp char to read from INPUT string
    Push $4  ; temp char to read from CHARSTOESC string
    Push $5  ; OUTPUT string
    Push $R0 ; length of INPUT string
    Push $R1 ; length of CHARSTOESC string
    Push $R3 ; counter for INPUT string
    Push $R4 ; counter for CHARSTOESC string

    StrCmp $0 "" StrEscape_exit
    StrCmp $1 "" StrEscape_exit
    StrCmp $2 "" StrEscape_exit

    StrCpy $2 $2 1 ; limit escape char to first char in string
    StrLen $R0 $0  ; length(INPUT)
    StrLen $R1 $1  ; length(CHARSTOESC)
    StrCpy $R3 0   ; reset INPUT counter
    StrCpy $5 ""   ; reset OUTPUT string

    loop_str:
        StrCpy $3 $0 1 $R3               ; read INPUT char

        StrCpy $R4 0                     ; reset CHARSTOESC counter
        loop_esc:                        ; DO
            StrCpy $4 $1 1 $R4           ; get CHARSTOESC char
            StrCmp $3 $4 0 +3            ; if (INPUT char) == (CHARSTOESC char)
                StrCpy $5 "$5$2"         ; then: output += ESC char
                Goto exitloop_esc        ;       & exitloop ; endif
            IntOp $R4 $R4 + 1            ; CHARSTOESC counter += 1
            IntCmp $R4 $R1 0 loop_esc 0  ; WHILE (counter < length)
        exitloop_esc:

        StrCpy $5 "$5$3"                 ; OUTPUT += INPUT char
        IntOp $R3 $R3 + 1                ; INPUT counter += 1
        IntCmp $R3 $R0 0 loop_str 0
    ; exitloop_str:

    StrCpy $0 $5 ; $0 is output now

    StrEscape_exit:

    Pop $R4
    Pop $R3
    Pop $R1
    Pop $R0
    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Exch $0
!macroend


/***** StrUnEscape *************************************************************
Syntax:
${StrUnEscape}   "Return" "InputString" "EscapeChar"

"Return"        ; Output string
"InputString"   ; Input string
"EscapeChar"    ; Escape char

Example:
${StrUnEscape} $0 "C:\\Program Files\\" "\"   ; $0 = "C:\Program Files\"
*/
!macro StrUnEscape_macro RETURN _INPUT _ESCAPE
	Push "${_ESCAPE}"
	Push "${_INPUT}"

    ${CallArtificialFunction} StrUnEscape_func

	Pop ${RETURN}
!macroend

!define StrUnEscape '!insertmacro StrUnEscape_macro'


!macro StrUnEscape_func
    Exch $0 ; INPUT string
    Exch
    Exch $1 ; ESC char
    Push $2 ; temp char to read from INPUT string
    Push $3 ; output string
    Push $R0 ; length(INPUT)
    Push $R2 ; counter for INPUT string

    StrCmp $0 "" StrUnEscape_exit
    StrCmp $1 "" StrUnEscape_exit

    StrLen $R0 $0  ; length(INPUT)
    StrCpy $1 $1 1 ; limit escape char to first char in string
    StrCpy $R2 0   ; reset INPUT counter
    StrCpy $3 ""   ; reset OUTPUT string

    loop:
        StrCpy $2 $0 1 $R2      ; read INPUT char

        StrCmp $2 $1 0 +3       ; if (INPUT char) == (ESC char)
            IntOp $R2 $R2 + 1   ; then: INPUT counter += 1
            StrCpy $2 $0 1 $R2  ;       & read (next) INPUT char ; endif

        StrCpy $3 "$3$2"        ; OUTPUT += INPUT char
        IntOp $R2 $R2 + 1       ; INPUT counter += 1
        IntCmp $R2 $R0 0 loop 0
    ; exitloop:

    StrCpy $0 $3 ; $0 is output now

    StrUnEscape_exit:

    Pop $R2
    Pop $R0
    Pop $3
    Pop $2
    Pop $1
    Exch $0
!macroend


/***** StrUnEscapeUnicode ******************************************************
Return string where Unicode escape sequences (\u0000..\uFFFF) are converted to Unicode characters

Syntax:
${StrUnEscape}   "Return" "InputString"

"Return"        ; Output string
"InputString"   ; Input string

Example:
${StrUnEscapeUnicode} $0 "\u0430\u0431\u0432\u0433\u0434\u0435"   ; $0 = "абвгде"
*/
!macro StrUnEscapeUnicode RETURN INPUT
	Push "${INPUT}"

    ${CallArtificialFunction} StrUnEscapeUnicode_func

	Pop ${RETURN}
!macroend

!define StrUnEscapeUnicode '!insertmacro StrUnEscapeUnicode'

!macro StrUnEscapeUnicode_func un
;		Exch $0 ; input
;		Push $1 ; length of input
;		Push $2 ; counter of input
;		Push $3 ; read char 1
;		Push $4 ; read char 2
;		Push $5 ; output string

;		StrCpy $OUTSTRING ""
;		StrLen $1 $0
;		StrCpy $2 0

;		StrUnEscapeUnicode_beginloop:
;			StrCpy $3 $0 1 $2              ; get in_char

;			StrCmp $3 "\" 0 ++++++++++            ; if (in_char == "\")
;				IntOp $2 $2 + 1    ; then: counter += 1
;				StrCpy $4 $0 1 $2  ;     & get in_char ; endif
;				StrCmp $4 "u" 0 ++++++++++++    ; if (2nd char == "u")
;					IntOp $2 $2 + 1
;					StrCpy $4 $0 4 $2       ; read 4char string (possible Unicode code) //rewrite $4
;					IntFmt $3 "%X" "0x$4"   ; filter out non [0-9A-B] chars, so '12AB' remains '12AB' and 'EFGH' becomes 'EF'


;			StrCpy $5 "$5$4"       ; output += in_char
;			IntOp $3 $3 + 1        ; counter += 1
;			IntCmp $3 $2 StrUnEscape_exitloop StrUnEscape_beginloop StrUnEscape_exitloop
;		StrUnEscape_exitloop:

;		Exch $5
;		Exch 5
;		Pop $0
;		Pop $4
;		Pop $3
;		Pop $2
;		Pop $1
!macroend


/***** StrStripBS **************************************************************
Returns a string without trailing backslash

Syntax:
${StrStripBS} "Return" "String"

"Return"   ; Variable where the WChar is returned.
"String"  ; String argument

Example:
${StrStripBS} $0 "x:\path\"   ; $0 = "x:\path"
*/
!define StrStripBS '!insertmacro StrStripBS_macro'

!macro StrStripBS_macro RETURN INPUT
	Push $0

	StrCpy $0 "${INPUT}" "" -1
	StrCmp $0 "\" 0 +3
	StrCpy $0 "${INPUT}" -1
    Goto +2
	StrCpy $0 "${INPUT}"

	Exch $0
    Pop ${RETURN}
!macroend


/***** StrAddBS **************************************************************
Returns a string with trailing backslash

Syntax:
${StrAddBS} "Return" "String"

"Return"   ; Variable where the WChar is returned.
"String"  ; String argument

Example:
${StrAddBS} $0 "x:\path"   ; $0 = "x:\path\"
*/
!define StrAddBS '!insertmacro StrAddBS_macro'

!macro StrAddBS_macro RETURN INPUT
	Push $0

	StrCpy $0 "${INPUT}" "" -1
	StrCmp $0 "\" 0 +3
	StrCpy $0 "${INPUT}"
    Goto +2
	StrCpy $0 "${INPUT}\"

	Exch $0
    Pop ${RETURN}
!macroend



; !define LBToStr `!insertmacro LBToStr`

; !macro LBToStr RETURN HANDLE
    ; Push ${HANDLE}
    ; Call LBToStr
    ; Pop ${RETURN}
; !macroend

; Function LBToStr
    ; Exch $0 ; output string
    ; Push $1 ; number of records
    ; Push $2 ; counter
    ; Push $3 ; temp string (gettext)
    ; Push $4 ; listbox handle

    ; StrCpy $4 $0
    ; StrCpy $0 ""
    ; ${NSD_LB_GetCount} $4 $1
    ; IntOp $2 0 + 0

    ; loop:
        ; System::Call 'user32::SendMessage(p $4, i ${LB_GETTEXT}, h $2, t.r3)'
        ; StrCpy $0 "$0$3$\n"
        ; IntOp $2 $2 + 1
        ; IntCmp $2 $1 0 loop

    ; Pop $4
    ; Pop $3
    ; Pop $2
    ; Pop $1
    ; Exch $0
; FunctionEnd



!define StrToLB `!insertmacro StrToLB`

!macro StrToLB HANDLE STRING
    Push ${HANDLE}
    Push "${STRING}"
    Call StrToLB
!macroend

Function StrToLB
    Exch $0 ; source string
    Exch
    Exch $1 ; ListBox handle
    Push $2 ; counter 1
    Push $3 ; counter 2
    Push $4 ; temp char
    Push $5 ; temp

    StrCpy $2 0
    StrCpy $3 0

    loop:
        StrCpy $4 $0 1 $3

        StrCmp $4 "" 0 +4 ;; use empty char to detect end of line instead of string length
        IntCmp $3 $2 +2 0 0
            Call :addstring
            Goto exitloop

        ; if char == "\r" or "\n"
        StrCmp $4 "$\r" +2
        StrCmp $4 "$\n" 0 nextloop

        ; then ...
        IntOp $5 $3 - $2
        IntCmp $5 0 +3 +3 0
            ; addstring
            Call :addstring
            Goto +2
            ; checkfornewline
            Call :checkfornewline
        IntOp $2 $3 + 1

    nextloop:
        IntOp $3 $3 + 1
        Goto loop

    checkfornewline:
    ; if char == "\r"
    StrCmp $4 "$\r" 0 +6
        IntOp $5 $3 + 1
        StrCpy $5 $0 1 $5
        ; if next char == "\n"
        StrCmp $5 "$\n" +2 0
            Call :addemptystring
        Return

    ; CHAR == \n:

    ; if first char == "\n"
    IntCmp $3 0 0 0 +3
        Call :addemptystring
        Return

    ; get previous char
    IntOp $5 $3 - 1
    StrCpy $5 $0 1 $5

    ; previous char == "\n" ??
    StrCmp $5 "$\n" 0 +3
        Call :addemptystring
        Return

    ; if previous char != "\r"
    StrCmp $5 "$\r" +2 0
        Return

    ; PREV.CHAR = \r:

    ; if first two chars == "\r\n"
    IntCmp $3 1 0 0 +3
        Call :addemptystring
        Return

    ; get pre-prev. char
    IntOp $5 $3 - 2
    StrCpy $5 $0 1 $5

    ; if pre-previous char == "\r" or "\n"
    StrCmp $5 "$\r" +2
    StrCmp $5 "$\n" 0 +2
        Call :addemptystring

    Return ; return from checkfornewline

    addstring:
    IntOp $5 $3 - $2
    StrCpy $5 $0 $5 $2
    SendMessage $1 ${LB_ADDSTRING} 0 `STR:$5`
    Return

    addemptystring:
    SendMessage $1 ${LB_ADDSTRING} 0 `STR:`
    Return

    exitloop:

    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
FunctionEnd


!define StrAdd `!insertmacro StrAdd `
!macro StrAdd OUTPUT STRING
    StrCpy ${OUTPUT} "${OUTPUT}${STRING}"
!macroend

!define StrAddLine `!insertmacro StrAddLine `
!macro StrAddLine OUTPUT STRING
    StrCpy ${OUTPUT} "${OUTPUT}${STRING}$\n"
!macroend

!define CodeBlockLine "______________________________________________________________________________"

!define StrAddCodeBlock `!insertmacro StrAddCodeBlock `
!macro StrAddCodeBlock OUTPUT STRING TITLE
    Push "${TITLE}"
    Push "${STRING}"
    Push "${OUTPUT}"

    Exch $0 ; output
    Exch 2
    Exch $1 ; title
    Exch
    Exch $2 ; string
    Push $3 ; tmp
    Push $4 ; tmp

    ; trim trailing \n
    StrCpy $4 $2 "" -1
    StrCmp $4 "$\n" 0 +2
        StrCpy $2 $2 -1

    StrLen $3 $1
    IntCmp $3 0 0 +3 +3
        ; empty title
        StrCpy $4 "${CodeBlockLine}"
        Goto +5
        ; not empty title
        IntOp $3 78 - $3 ; substract title length
        IntOp $3 $3 - 7  ; substract title brackets and first three "___"
        StrCpy $3 ${CodeBlockLine} $3
        StrCpy $4 "___[ $1 ]$3"

    StrCpy $0 "$0$4$\n$2$\n${CodeBlockLine}$\n$\n"

    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Exch $0

    Pop ${OUTPUT}
!macroend

!define StrAddCodeQuote `!insertmacro StrAddCodeQuote `
!macro StrAddCodeQuote OUTPUT STRING QUOTEPREFIX
    Push "${QUOTEPREFIX}"
    Push "${STRING}"
    Push "${OUTPUT}"

    Exch $0 ; output
    Exch 2
    Exch $1 ; quoteprefix
    Exch
    Exch $2 ; string
    Push $3 ; strlen(string)
    Push $4 ; counter
    Push $5 ; counter2
    Push $6 ; tmp
    Push $7 ; tmp

    ; trim trailing "\r\n"
    StrCpy $6 $2 2 -2
    StrCmp $6 "$\r$\n" 0 +2
        StrCpy $2 $2 -2
        
    ; trim trailing "\n"
    StrCpy $6 $2 1 -1
    StrCmp $6 "$\n" 0 +2
        StrCpy $2 $2 -1
    ; trim trailing "\r"
    StrCmp $6 "$\r" 0 +2
        StrCpy $2 $2 -1
    
    ; set initial values
    ; StrCpy $0 "$0$\n"
    StrLen $3 $2
    IntOp  $4 0 - 1
    IntOp  $5 0 + 0

    ; beginloop:
    IntOp $4 $4 + 1 ; counter++

    IntCmp $4 $3 +3 0 ; check bounds

    StrCpy $6 $2 1 $4 ; getchar

    StrCmp $6 "$\n" 0 -3 ; if char == \n

    IntOp  $6 $4 - $5
    IntOp  $6 $6 + 1
    StrCpy $7 $2 $6 $5
    ; StrCpy $0 "$0[$5 $4 $6]>>$7" ;;DEBUG
    StrCpy $0 "$0$1$7"
    IntCmp $4 $3 +3 0 ; if it was the last chunk
    IntOp $5 $4 + 1
    Goto -10 ; continue loop
    
    StrCpy $0 "$0$\n"
    
    Pop $7
    Pop $6
    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Exch $0

    Pop ${OUTPUT}
!macroend



!endif