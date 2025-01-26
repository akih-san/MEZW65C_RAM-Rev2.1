                PW      132
                PL      0

	        CHIP    W65C02S ;ENABLE WDC 65C02 INSTRUCTIONS
                GLOBALS ON
                CASE    OFF
                INCLIST ON
;
; 2025.01.24: Rebuilt by Akihito Honda for MEZW65C_RAM.
; It has been modified so that it can be assembled using WDC tools
;  (Western Design Center, Inc.).
;   https://wdc65xx.com/WDCTools

;Microsoft 9 Digit Basic
;version 2.02
;released:	13 november 1983
;last revision:	28 december 1983
;			added check of ctcflg
;		7 July 2017 (2.02)
;			added pzstrt = 5 (not used)
;			added comment semicolons
;			changed EXIT to use PEM warm boot
;			moved TRAP variables out of page 0
;			moved RNDWRK array out of page 0
;			added closing ' where needed in #' '
;	.opt	nol
;absolute DOS/65 or environment external references
pzstrt	equ	5		;first free page 0 loc
BOOT	equ	$100		;warm boot entry
PEM	equ	$103		;PEM entry
TEA	equ	$200		;load address
;FIXED PARAMETER DEFINITIONS
BELL	equ	7		;bell code
CTLI	equ	9		;tab
LF	equ	$A		;linefeed
CR	equ	$D		;return
CTLO	equ	$F		;toggle output enable
CTLP	equ	$10		;toggle printer enable
CTLX	equ	$18		;line cancel
EOF	equ	$1A		;eof char
DELETE	equ	$7F		;delete
TRUE	equ	$FF
FALSE	equ	0

;PAGE ZERO VARIABLE DEFINITIONS
	page0
	org	pzstrt
TKNPNT	equ	pzstrt		;token table pointer
L000A	equ	$A
SRCCHR	equ	$B
L000C	equ	$C		;number of subscripts
L000D	equ	$D
VRTYFL	equ	$E		;variable type flag - 0equnumber ffequstring
NVTYFL	equ	$F		;number type flag - 0equreal 80equinteger
L0010	equ	$10
L0011	equ	$11
L0012	equ	$12
L0013	equ	$13
OUTENB	equ	$14		;output enabled if < 128
NULCNT	equ	$15		;null count
LINPSN	equ	$16		;current line position
MAXPSN	equ	$17		;maximum line position
LSTTAB	equ	$18		;last tab field position
INLNNM	equ	$19		;input line number
INPBUF	equ	$1B		;input line buffer
L0063	equ	$63
L0064	equ	$64
L0065	equ	$65

	org	$66
STRSTK	equ	$		;string stack
ME	equ	$6F		;load/save accum pointer
MEMPNT	equ	$0071
QM	equ	$0073
L0077	equ	$0077
BSCSTR	equ	$78		;start of BASIC source
VARSTR	equ	$7A		;start of variable storage
ARYSTR	equ	$7C		;start of array storage
EMPSTR	equ	$7E

STRSTR	equ	$80
L0082	equ	$82
MEMLMT	equ	$84		;memory limit
CURLNM	equ	$86		;current line number
PRVLNM	equ	$88		;previous line number
PRVLNA	equ	$8A		;previous line address
CURDNM	equ	$8C		;current DATA line number
CURDAD	equ	$8E		;current DATA address
INPTAD	equ	$90		;input address
CURVNM	equ	$92		;current variable name
CURVAD	equ	$94		;current variable address
FNXPNT	equ	$96		;FOR/NEXT variable pointer
SVECPT	equ	$98		;save current pointer
L009A	equ	$9A
L009B	equ	$9B
L009C	equ	$9C
L009D	equ	$9D
L009E	equ	$9E
L00A0	equ	$A0
FUNJMP	equ	$A1		;entry for function jump
TEMPN1	equ	$A4
L00A5	equ	$00A5
L00A6	equ	$00A6
L00A7	equ	$00A7
L00A8	equ	$00A8
TEMPN2	equ	$00A9
DPOFF	equ	$00AA
NE	equ	$00AB
DPFLG	equ	$00AC
;primary accumulator
PE	equ	$AE
PM	equ	$AF
PS	equ	$B3
NS	equ	$B4
PC	equ	$B5
;secondary accumulator
SE	equ	$B6
SM	equ	$B7
SS	equ	$BB
SGNCMP	equ	$BC
PR	equ	$BD
CNVIND	equ	$BE

;the character scanner follows
	org	$C0
GETCHR	ds	6		;normal entry
GTCWOI	ds	1		;entry w/o bump
CHRPNT	ds	20		;pointer
;disk I/O variables
RECADD	ds	2		;record address
FILADR	ds	2		;FCB address
BUFFER	ds	2		;buffer address

;table of token hex equivalents
TKEND	equ	$80
TKFOR	equ	TKEND+1
TKNEXT	equ	TKFOR+1
TKDATA	equ	TKNEXT+1
TKINPX	equ	TKDATA+1
TKINPU	equ	TKINPX+1
TKDIM	equ	TKINPU+1
TKREAD	equ	TKDIM+1
TKLET	equ	TKREAD+1
TKGOTO	equ	TKLET+1
TKRUN	equ	TKGOTO+1
TKIFEN	equ	TKRUN+1
TKIF	equ	TKIFEN+1
TKREST	equ	TKIF+1
TKGOSU	equ	TKREST+1
TKRETU	equ	TKGOSU+1
TKREM	equ	TKRETU+1
TKSTOP	equ	TKREM+1
TKON	equ	TKSTOP+1
TKWAIT	equ	TKON+1
TKOPEN	equ	TKWAIT+1
TKCLOS	equ	TKOPEN+1
TKTRAP	equ	TKCLOS+1
TKLOAD	equ	TKTRAP+1
TKSAVE	equ	TKLOAD+1
TKEXIT	equ	TKSAVE+1
TKDEF	equ	TKEXIT+1
TKPOKE	equ	TKDEF+1
TKPRIX	equ	TKPOKE+1
TKPRIN	equ	TKPRIX+1
TKCONT	equ	TKPRIN+1
TKLISX	equ	TKCONT+1
TKLIST	equ	TKLISX+1
TKCLEA	equ	TKLIST+1
TKNEW	equ	TKCLEA+1
;following are not statements
TKTAB	equ	TKNEW+1
TKTO	equ	TKTAB+1
TKFN	equ	TKTO+1
TKSPC	equ	TKFN+1
TKTHEN	equ	TKSPC+1
TKNOT	equ	TKTHEN+1
TKSTEP	equ	TKNOT+1
TKPLUS	equ	TKSTEP+1
TKMINU	equ	TKPLUS+1
TKMULT	equ	TKMINU+1
TKDIVI	equ	TKMULT+1
TKPOWE	equ	TKDIVI+1
TKAND	equ	TKPOWE+1
TKOR	equ	TKAND+1
TKGT	equ	TKOR+1
TKEQ	equ	TKGT+1
TKLT	equ	TKEQ+1
;following are functions
TKSGN	equ	TKLT+1
TKINT	equ	TKSGN+1
TKABS	equ	TKINT+1
TKUSR	equ	TKABS+1
TKFRE	equ	TKUSR+1
TKPOS	equ	TKFRE+1
TKSQR	equ	TKPOS+1
TKRND	equ	TKSQR+1
TKLOG	equ	TKRND+1
TKEXP	equ	TKLOG+1
TKCOS	equ	TKEXP+1
TKSIN	equ	TKCOS+1
TKTAN	equ	TKSIN+1
TKATN	equ	TKTAN+1
TKPEEK	equ	TKATN+1
TKLEN	equ	TKPEEK+1
TKSTR	equ	TKLEN+1
TKVAL	equ	TKSTR+1
TKASC	equ	TKVAL+1
TKCHR	equ	TKASC+1
;multi parameter functions
TKLEFT	equ	TKCHR+1
TKRIGH	equ	TKLEFT+1
TKMID	equ	TKRIGH+1
;following are token related definitions
;FUNOFS	equ	(TKSGN-128)*2	;offset in function table
FUNOFS	equ	(TKSGN&$7f)*2	;offset in function table
;program code starts here
	code
	org	TEA
;The entry address and the following address are
;set by the initialization code at COLD.
SIMJMP	JMP	COLD		;go to cold entry point
PEMJMP	JMP	0		;go to PEM
CPMJMP	JMP	0		;execute call(pem)
CSMJMP	JMP	0		;execute call(sim+x)
RA	.byte	0		;A for call(pem) or call(sim+x)
RY	.byte	0		;Y
RX	.byte	0		;X
LSTFLG	.byte	0		;enable LIST if < 128
CTCFLG	.byte	0		;enable CTL-C if < 128
NEWFLG	.byte	0		;enable NEW if < 128
;Jumps to user defined I/O devices
;input
USERI4	JMP	0
USERI5	JMP	0
USERIA	JMP	0
USERIB	JMP	0
;output
USERO4	JMP	0
USERO5	JMP	0
USEROA	JMP	0
USEROB	JMP	0
;The following code provides the ability to have
;an auto-execute input line at initial
;execution of the interpreter.  If the first
;byte is less than 128, it and all characters
;up to the CR ($0D) are read as a console
;input line.
AUTOBF	.byte	$FF
	BLKB	31,0
;The following three lines provide the ability to
;reserve space either at the start or end of the
;BASIC storage area.
ENDCDE	.word	COLD		;first usable location
STRBAS	.word	COLD		;actual start of BASIC
HSVLNG	.word	0		;length to save below PEM
;BASIC dispatch table
DSPTBL	.word	XEND-1
	.word	XFOR-1
	.word	XNEXT-1
	.word	XDATA-1
	.word	XINPUX-1
	.word	XINPUT-1
	.word	XDIM-1
	.word	XREAD-1
	.word	XLET-1
	.word	XGOTO-1
	.word	XRUN-1
	.word	XIFEND-1
	.word	XIF-1
	.word	XRESTR-1
	.word	XGOSUB-1
	.word	XRETRN-1
	.word	XREM-1
	.word	XSTOP-1
	.word	XON-1
	.word	XWAIT-1
	.word	XOPEN-1
	.word	XCLOSE-1
	.word	XTRAP-1
	.word	XLOAD-1
	.word	XSAVE-1
	.word	XEXIT-1
	.word	XDEF-1
	.word	XPOKE-1
	.word	XPRINX-1
	.word	XPRINT-1
	.word	XCONT-1
	.word	XLISTX-1
	.word	XLIST-1
	.word	XCLEAR-1
	.word	XNEW-1
;entry points for functions
FUNTBL	.word	XSGN
	.word	XINT
	.word	XABS
	.word	XUSR
	.word	XFRE
	.word	XPOS
	.word	XSQR
	.word	XRND
	.word	XLOG
	.word	XEXP
	.word	XCOS
	.word	XSIN
	.word	XTAN
	.word	XATN
	.word	XPEEK
	.word	XLEN
	.word	XSTR
	.word	XVAL
	.word	XASC
	.word	XCHR
	.word	XLEFT
	.word	XRIGHT
	.word	XMID
;The following table is the operator dispatch table
;for expressions.  The first entry is the precedence
;and the following word is the entry-1.
OPRTBL	.byte	$79
	.word	L16D9-1
	.byte	$79
	.word	L16C2-1
	.byte	$7B
	.word	L18F4-1
	.byte	$7B
	.word	L1A0D-1
	.byte	$7F
	.word	L1E4F-1
	.byte	$50
	.word	L0E8C-1
	.byte	$46
	.word	L0E89-1
	.byte	$7D
	.word	L1E88-1
	.byte	$5A
	.word	L0DEA-1
	.byte	$64
	.word	L0EB9-1
;following table is the table of KEY WORDS
TKNTBL	.byte	'EN',('D'+128)
	.byte	'FO',('R'+128)
	.byte	'NEX',('T'+128)
	.byte	'DAT',('A'+128)
	.byte	'INPUT',('#'+128)
	.byte	'INPU',('T'+128)
	.byte	'DI',('M'+128)
	.byte	'REA',('D'+128)
	.byte	'LE',('T'+128)
	.byte	'GOT',('O'+128)
	.byte	'RU',('N'+128)
	.byte	'IFEND',('#'+128)
	.byte	'I',('F'+128)
	.byte	'RESTOR',('E'+128)
	.byte	'GOSU',('B'+128)
	.byte	'RETUR',('N'+128)
	.byte	'RE',('M'+128)
	.byte	'STO',('P'+128)
	.byte	'O',('N'+128)
	.byte	'WAI',('T'+128)
	.byte	'OPE',('N'+128)
	.byte	'CLOS',('E'+128)
	.byte	'TRA',('P'+128)
	.byte	'LOA',('D'+128)
	.byte	'SAV',('E'+128)
	.byte	'EXI',('T'+128)
	.byte	'DE',('F'+128)
	.byte	'POK',('E'+128)
	.byte	'PRINT',('#'+128)
	.byte	'PRIN',('T'+128)
	.byte	'CON',('T'+128)
	.byte	'LIST',('#'+128)
	.byte	'LIS',('T'+128)
	.byte	'CLEA',('R'+128)
	.byte	'NE',('W'+128)
	.byte	'TAB',('('+128)
	.byte	'T',('O'+128)
	.byte	'F',('N'+128)
	.byte	'SPC',('('+128)
	.byte	'THE',('N'+128)
	.byte	'NO',('T'+128)
	.byte	'STE',('P'+128)
	.byte	('+'+128)
	.byte	('-'+128)
	.byte	('*'+128)
	.byte	('/'+128)
	.byte	('^'+128)
	.byte	'AN',('D'+128)
	.byte	'O',('R'+128)
	.byte	('>'+128)
	.byte	('='+128)
	.byte	('<'+128)
	.byte	'SG',('N'+128)
	.byte	'IN',('T'+128)
	.byte	'AB',('S'+128)
	.byte	'US',('R'+128)
	.byte	'FR',('E'+128)
	.byte	'PO',('S'+128)
	.byte	'SQ',('R'+128)
	.byte	'RN',('D'+128)
	.byte	'LO',('G'+128)
	.byte	'EX',('P'+128)
	.byte	'CO',('S'+128)
	.byte	'SI',('N'+128)
	.byte	'TA',('N'+128)
	.byte	'AT',('N'+128)
	.byte	'PEE',('K'+128)
	.byte	'LE',('N'+128)
	.byte	'STR',('$'+128)
	.byte	'VA',('L'+128)
	.byte	'AS',('C'+128)
	.byte	'CHR',('$'+128)
	.byte	'LEFT',('$'+128)
	.byte	'RIGHT',('$'+128)
	.byte	'MID',('$'+128)
	.byte	0
;error messages
ERMS00	.byte	'NEXT without FOR',0
ERMS02	.byte	'Syntax',0
ERMS04	.byte	'RETURN without GOSUB',0
ERMS06	.byte	'Out of DATA',0
ERMS08	.byte	'Function Call',0
ERMS0A	.byte	'Overflow',0
ERMS0C	.byte	'Out of Memory',0
ERMS0E	.byte	'Undefined Statememt',0
ERMS10	.byte	'Bad Subscript',0
ERMS12	.byte	'Double DIMension',0
ERMS14	.byte	'Divide by Zero',0
ERMS16	.byte	'Illegal Direct',0
ERMS18	.byte	'Type Mismatch',0
ERMS1A	.byte	'Long String',0
ERMS1C	.byte	'String too Complex',0
ERMS1E	.byte	'CONTinue',0
ERMS20	.byte	'Undefined Function',0
ERMS22	.byte	'Duplicate OPEN',0
ERMS24	.byte	'File not OPEN',0
ERMS26	.byte	'Illegal Name',0
ERMS28	.byte	'Disk Read',0
ERMS2A	.byte	'Disk Open',0
ERMS2C	.byte	'Disk Close',0
ERMS2E	.byte	'Disk Write',0
ERMS30	.byte	'File Exists',0
ERMS32	.byte	'Record Too Long',0
ERMS34	.byte	'EOF',0
ERMS36	.byte	'Invalid File Number',0
ERMS38	.byte	'Disk Create',0
ERMS3A	.byte	'TRAP Destination',0
ERMS3C	.byte	'Unblocked File',0
ERMS3E	.byte	'Invalid Record Number',0
ERMS40	.byte	'Invalid Record Length in OPEN',0
;error message vectors
ERRTBL	.word	ERMS00,ERMS02,ERMS04,ERMS06,ERMS08
	.word	ERMS0A,ERMS0C,ERMS0E,ERMS10,ERMS12
	.word	ERMS14,ERMS16,ERMS18,ERMS1A,ERMS1C
	.word	ERMS1E,ERMS20,ERMS22,ERMS24,ERMS26
	.word	ERMS28,ERMS2A,ERMS2C,ERMS2E,ERMS30
	.word	ERMS32,ERMS34,ERMS36,ERMS38,ERMS3A
	.word	ERMS3C,ERMS3E,ERMS40
ERRMSG	.byte	' ERROR',0
INMSG	.byte	' IN ',0
OKMSG	.byte	CR,LF,'OK',CR,LF,0
BRKMSG	.byte	CR,LF,'BREAK',0
L03A1	TSX
	INX
	INX
	INX
	INX
L03A6	LDA	$101,X
	CMP	#TKFOR		;see if FOR token
	BNE	L03CE
	LDA	FNXPNT+1
	BNE	L03BB
	LDA	$102,X
	STA	FNXPNT
	LDA	$103,X
	STA	FNXPNT+1
L03BB	CMP	$103,X
	BNE	L03C7
	LDA	FNXPNT
	CMP	$102,X
	BEQ	L03CE
L03C7	TXA
	CLC
	ADC	#18
	TAX
	BNE	L03A6
L03CE	RTS
L03CF	JSR	L041F
	STA	EMPSTR
	STY	EMPSTR+1
L03D6	SEC
	LDA	L00A7
	SBC	DPFLG
	STA	ME
	TAY
	LDA	L00A8
	SBC	DPFLG+1
	TAX
	INX
	TYA
	BEQ	L040A
	LDA	L00A7
	SEC
	SBC	ME
	STA	L00A7
	BCS	L03F3
	DEC	L00A8
	SEC
L03F3	LDA	L00A5
	SBC	ME
	STA	L00A5
	BCS	L0403
	DEC	L00A6
	BCC	L0403
L03FF	LDA	(L00A7),Y
	STA	(L00A5),Y
L0403	DEY
	BNE	L03FF
	LDA	(L00A7),Y
	STA	(L00A5),Y
L040A	DEC	L00A8
	DEC	L00A6
	DEX
	BNE	L0403
	RTS
;check stack depth
L0412	ASL	A
	ADC	#$36
	BCS	OMERR
	STA	ME
	TSX
	CPX	ME
	BCC	OMERR
	RTS
;check memory space
L041F	CPY	STRSTR+1
	BCC	L044B
	BNE	L0429
	CMP	STRSTR
	BCC	L044B
L0429	PHA
	LDX	#9
	TYA
L042D	PHA
	LDA	TEMPN1,X
	DEX
	BPL	L042D
	JSR	L13A4
	LDX	#$F7
L0438	PLA
	STA	PE,X
	INX
	BMI	L0438
	PLA
	TAY
	PLA
	CPY	STRSTR+1
	BCC	L044B
	BNE	OMERR
	CMP	STRSTR
	BCS	OMERR
L044B	RTS
;out of memory error
OMERR	LDX	#$0C
;general error output routine
XERR	LSR	OUTENB
	JSR	STIOCN		;set I/O to console
	JSR	CRLF
	JSR	OUTQMR
	JSR	OUTSPC		;send space
	LDA	ERRTBL,X
	LDY	ERRTBL+1,X	;get vector
	JSR	STROUT		;and send it
L0462	JSR	L0695		;restore stack
	LDA	#<ERRMSG	;point to error message
	LDY	#>ERRMSG
L0469	JSR	STIOCN		;set I/O to console
	JSR	STROUT		;and send message
	LDY	CURLNM+1
	INY
	BEQ	L0474		;jump if direct
	LDA	TRPFLG		;get TRAP flag
	BEQ	NOTRAP		;if clear send message
	JSR	CRLF		;else do CR and LF
	LDA	TRPLIN		;get line number
	LDY	TRPLIN+1
	STA	INLNNM		;and set
	STY	INLNNM+1
	LDA	#$FF		;set direct mode
	STA	CURLNM+1
	JSR	L0633		;search for line
	BCC	L0469A		;not found
	BEQ	L0469B		;found
L0469A	LDA	#0		;else clear trap flag
	STA	TRPFLG
	STA	TRPLIN		;and line
	STA	TRPLIN+1
	LDX	#$3A		;and do error
	BNE	XERR		;again
L0469B	JSR	L08AC		;do a GOTO
	JMP	L07B4		;and execute
NOTRAP	JSR	PRIMLN		;send line message


;
; warm boot?
; Print OK
;
L0474	LSR	OUTENB
	LDA	#<OKMSG		;point to OK message
	LDY	#>OKMSG
	JSR	STROUT		;send message
L047D	JSR	INPLIN
	STX	CHRPNT
	STY	CHRPNT+1
	JSR	GETCHR
	TAX
	BEQ	L047D
	LDX	#$FF
	STX	CURLNM+1
	BCC	L0496
	JSR	L05A7		;convert to tokenized
	JMP	L07E0
L0496	JSR	L096C		;convert number to binary
	JSR	L05A7		;then tokenize line
	STY	L000C
	JSR	L0633
	BCC	L04E7
	LDY	#1
	LDA	(DPFLG),Y
	STA	ME+1
	LDA	VARSTR
	STA	ME
	LDA	DPFLG+1
	STA	MEMPNT+1
	LDA	DPFLG
	DEY
	SBC	(DPFLG),Y
	CLC
	ADC	VARSTR
	STA	VARSTR
	STA	MEMPNT
	LDA	VARSTR+1
	ADC	#$FF
	STA	VARSTR+1
	SBC	DPFLG+1
	TAX
	SEC
	LDA	DPFLG
	SBC	VARSTR
	TAY
	BCS	L04D1
	INX
	DEC	MEMPNT+1
L04D1	CLC
	ADC	ME
	BCC	L04D9
	DEC	ME+1
	CLC
L04D9	LDA	(ME),Y
	STA	(MEMPNT),Y
	INY
	BNE	L04D9
	INC	ME+1
	INC	MEMPNT+1
	DEX
	BNE	L04D9
L04E7	LDA	INPBUF
	BEQ	L051A
	LDA	MEMLMT
	LDY	MEMLMT+1
	STA	STRSTR
	STY	STRSTR+1
	LDA	VARSTR
	STA	L00A7
	ADC	L000C
	STA	L00A5
	LDY	VARSTR+1
	STY	L00A8
	BCC	L0502
	INY
L0502	STY	L00A6
	JSR	L03CF
	LDA	EMPSTR
	LDY	EMPSTR+1
	STA	VARSTR
	STY	VARSTR+1
	LDY	L000C
	DEY
L0512	LDA	MAXPSN,Y
	STA	(DPFLG),Y
	DEY
	BPL	L0512
L051A	JSR	L0678
	JSR	RECHAN		;rechain memory
	JMP	L047D		;and loop to direct
;rechain program in memory
RECHAN	LDA	BSCSTR
	LDY	BSCSTR+1
	STA	ME
	STY	ME+1
	CLC
L0526	LDY	#1
	LDA	(ME),Y
	BNE	L052F
	RTS			;done
L052F	LDY	#4
L0531	INY
	LDA	(ME),Y
	BNE	L0531
	INY
	TYA
	ADC	ME
	TAX
	LDY	#0
	STA	(ME),Y
	LDA	ME+1
	ADC	#0
	INY
	STA	(ME),Y
	STX	ME
	STA	ME+1
	BCC	L0526
;convert input line to tokenized form
L05A7	LDX	CHRPNT
	LDY	#4
	STY	L0010
L05AD	LDA	0,X
	CMP	#' '
	BEQ	L05ED
	STA	SRCCHR
	CMP	#'"'
	BEQ	L0611
	BIT	L0010
	BVS	L05ED
	CMP	#'?'		;see if question mark
	BNE	L05C5		;it isn't
L05C1	LDA	#TKPRIN		;get PRINT token
L05C3	BNE	L05ED
L05C5	CMP	#'0'
	BCC	L05CD
	CMP	#';'+1
	BCC	L05ED
L05CD	STY	CNVIND
	LDA	#<TKNTBL	;set pointer
	LDY	#>TKNTBL
	STA	TKNPNT
	STY	TKNPNT+1
	LDY	#0
	STY	L000C		;clear token counter
	DEY
	STX	CHRPNT
	DEX
L05D7	INY
L05D8	INX
L05D9	LDA	0,X		;get char
	JSR	LWRUPR		;convert to upper case
	CMP	#' '		;see if blank
	BEQ	L05D8
	SEC
	SBC	(TKNPNT),Y	;subtract char in token
	BEQ	L05D7
	CMP	#$80
	BNE	L0618
	ORA	L000C
L05EB	LDY	CNVIND
L05ED	INX
	INY
	STA	INPBUF-5,Y
	LDA	INPBUF-5,Y
	BEQ	L062B
	SEC
	SBC	#'9'+1
	BEQ	L0600
	CMP	#TKDATA-'9'-1	;see if remainder from DATA
	BNE	L0602
L0600	STA	L0010
L0602	SEC
	SBC	#TKREM-'9'-1	;see if from REM
	BNE	L05AD
	STA	SRCCHR
L0609	LDA	0,X
	BEQ	L05ED
	CMP	SRCCHR
	BEQ	L05ED
L0611	INY
	STA	INPBUF-5,Y
	INX
	BNE	L0609
;skip to next TKNTBL entry
L0618	LDX	CHRPNT
	INC	L000C
	LDY	#$FF		;set y to -1
L061C	INY
	LDA	(TKNPNT),Y	;get char
	BPL	L061C		;loop if pos
	INY			;point past token
	CLC			;now add Y to old pointer
	TYA
	ADC	TKNPNT
	STA	TKNPNT
	BCC	*+4
	INC	TKNPNT+1
	LDY	#0		;clear Y
	LDA	(TKNPNT),Y	;get first char of next
	BNE	L05D9		;loop if not end
	LDA	0,X
	BPL	L05EB
;end of conversion
L062B	STA	INPBUF-3,Y
	LDA	#INPBUF-1
	STA	CHRPNT
	RTS
;search for line number in program
;if found c=1 else c=0
L0633	LDA	BSCSTR
	LDX	BSCSTR+1
L0637	LDY	#1
	STA	DPFLG
	STX	DPFLG+1
	LDA	(DPFLG),Y
	BEQ	L0660
	INY
	INY
	LDA	INLNNM+1
	CMP	(DPFLG),Y
	BCC	L0661
	BEQ	L064E
	DEY
	BNE	L0657
L064E	LDA	INLNNM
	DEY
	CMP	(DPFLG),Y
	BCC	L0661
	BEQ	L0661
L0657	DEY
	LDA	(DPFLG),Y
	TAX
	DEY
	LDA	(DPFLG),Y
	BCS	L0637
L0660	CLC
L0661	RTS
;execute NEW to reset program pointers.
;note that if anything other than : or eol follows NEW
;then nothing happens.
XNEW	BNE	L0661
	BIT	NEWFLG		;test NEW disable flag
	BMI	L0661		;exit is NEW is disabled
L0664	LDA	#0
	TAY
	STA	(BSCSTR),Y
	INY
	STA	(BSCSTR),Y
	LDA	BSCSTR
	ADC	#2
	STA	VARSTR
	LDA	BSCSTR+1
	ADC	#0
	STA	VARSTR+1
L0678	JSR	L06AB
XCLEAR	TYA
L067E	LDA	MEMLMT
	LDY	MEMLMT+1
	STA	STRSTR
	STY	STRSTR+1
	LDA	VARSTR
	LDY	VARSTR+1
	STA	ARYSTR
	STY	ARYSTR+1
	STA	EMPSTR
	STY	EMPSTR+1
	JSR	XRESTR
L0695	LDX	#STRSTK
	STX	L0063
	PLA
	TAY
	PLA
	LDX	#$FE
	TXS
	PHA
	TYA
	PHA
	LDA	#0
	STA	PRVLNA+1
	STA	L0011
L06AA	RTS
L06AB	CLC
	LDA	BSCSTR
	ADC	#$FF
	STA	CHRPNT
	LDA	BSCSTR+1
	ADC	#$FF
	STA	CHRPNT+1
	RTS
;execute directed LIST
;syntax is LIST#n | LIST#n l-m | LIST#n l- | LIST#n -m | LIST#n l
;note that device n must have been opened if a disk file!
XLISTX	JSR	GETDEV		;get device number
	BEQ	LCA91		;if eol jump ahead
	JSR	CHKCM		;else must be comma
LCA91	PHP			;save eol status
	PHA			;and next char
	STX	CURDEV		;set device
	JSR	VEROPN		;make sure is open
	JSR	VDSKX		;see if a disk device
	BCC	*+5		;not so skip setup
	JSR	SUDSIO		;initialize disk I/O
	PLA			;get char back
	PLP			;get eol status back
	JSR	XLIST		;do list
	JMP	STIOCN		;set i/o to console
;execute LIST
XLIST	BEQ	L06C1		;do all if eol
	BCC	L06C1		;or may be number
XLST1	CMP	#TKMINU		;see if - token
	BNE	L06AA
L06C1	BIT	LSTFLG		;test list flag
	BMI	L06AA		;exit if list disabled
	JSR	L096C		;convert ASCII line number to binary
	JSR	L0633		;search  for line
	JSR	GTCWOI
	BEQ	L06D8
	CMP	#TKMINU		;see if - token
	BNE	L06AA		;not so do all to end
	JSR	GETCHR
	JSR	L096C
	BNE	L06AA
L06D8	LDA	INLNNM
	ORA	INLNNM+1
	BNE	L06E6
	LDA	#$FF
	STA	INLNNM
	STA	INLNNM+1
L06E6	LDY	#1
	LDA	(DPFLG),Y
	BEQ	L0725
	JSR	L0819
	JSR	CRLF
	INY
	LDA	(DPFLG),Y
	TAX
	INY
	LDA	(DPFLG),Y
	CMP	INLNNM+1
	BNE	L0701
	CPX	INLNNM
	BEQ	L0703
L0701	BCS	L0725
L0703	STY	FNXPNT
	JSR	PRAX
	LDA	#' '
L070A	LDY	FNXPNT
	AND	#$7F
L070E	JSR	OUTCHR
	INY
	BEQ	L0725
	LDA	(DPFLG),Y
	BNE	L0728
	TAY
	LDA	(DPFLG),Y
	TAX
	INY
	LDA	(DPFLG),Y
	STX	DPFLG
	STA	DPFLG+1
	BNE	L06E6
L0725	JMP	CRLF		;end with cr and lf
L0728	BPL	L070E
	SEC
	SBC	#$7F
	TAX
	STY	FNXPNT
	LDA	#<TKNTBL	;set pointer to page before table
	LDY	#(TKNTBL>>8)-1
	STA	TKNPNT
	STY	TKNPNT+1
	LDY	#$FF
L0732	DEX
	BEQ	L073D
L0735	JSR	INCTPT		;bump pointer and get char
	BPL	L0735
	BMI	L0732
L073D	JSR	INCTPT		;bump pointer and get char
	BMI	L070A
	JSR	OUTCHR
	BNE	L073D
;increment token table pointer and get char
INCTPT	INY			;bump Y
	BNE	*+4		;ok if not zero
	INC	TKNPNT+1	;else bump page
	LDA	(TKNPNT),Y	;get char
	RTS
;execute FOR statement
XFOR	LDA	#$80
	STA	L0011
	JSR	XLET
	JSR	L03A1
	BNE	L0759
	TXA
	ADC	#15
	TAX
	TXS
L0759	PLA
	PLA
	LDA	#9
	JSR	L0412
	JSR	L0907
	CLC
	TYA
	ADC	CHRPNT
	PHA
	LDA	CHRPNT+1
	ADC	#0
	PHA
	LDA	CURLNM+1
	PHA
	LDA	CURLNM
	PHA
	LDA	#TKTO		;check for TO token
	JSR	CHKA
	JSR	L0CBC
	JSR	L0CB9
	LDA	PS
	ORA	#$7F
	AND	PM
	STA	PM
	LDA	#<L0791		;set ay to address
	LDY	#>L0791
	STA	ME
	STY	ME+1
	JMP	L0D72
L0791	LDA	#<ONE		;point to floating one
	LDY	#>ONE
	JSR	LPA
	JSR	GTCWOI
	CMP	#TKSTEP		;see if STEP token
	BNE	L07A5
	JSR	GETCHR
	JSR	L0CB9
L07A5	JSR	ESP
	JSR	L0D67
	LDA	FNXPNT+1
	PHA
	LDA	FNXPNT
	PHA
	LDA	#TKFOR		;put FOR token on stack
	PHA
L07B4	JSR	L0819
	LDA	CHRPNT
	LDY	CHRPNT+1
	BEQ	L07C3
	STA	PRVLNA
	STY	PRVLNA+1
	LDY	#0
L07C3	LDA	(CHRPNT),Y
	BNE	L0803
	LDY	#2
	LDA	(CHRPNT),Y
	BEQ	L0842
	INY
	LDA	(CHRPNT),Y
	STA	CURLNM
	INY
	LDA	(CHRPNT),Y
	STA	CURLNM+1
	TYA
	JSR	L08FD
	CLC
	BCC	L07E0
	INC	CHRPNT+1
L07E0	JSR	GETCHR
	JSR	L07E9
	JMP	L07B4
L07E9	BEQ	L0818
L07EB	SBC	#$80
	BCC	L0800
	CMP	#TKTAB-$80
	BCS	L0807
	ASL	A
	TAY
	LDA	DSPTBL+1,Y
	PHA
	LDA	DSPTBL,Y
	PHA
	JMP	GETCHR
L0800	JMP	XLET
L0803	CMP	#':'		;see if colon
	BEQ	L07E0
L0807	JMP	ERSN
XRESTR	SEC
	LDA	BSCSTR
	SBC	#1
	LDY	BSCSTR+1
	BCS	L0814
	DEY
L0814	STA	CURDAD
	STY	CURDAD+1
L0818	RTS
;do check for control-c
L0819	BIT	CTCFLG		;test control c difable flag
	BMI	L0818		;exit if disabled
	JSR	SYSBRK		;see if input
	BEQ	L0818		;done if no input
	JSR	CNSRDE		;read keyboard
	CMP	#3
XSTOP	BCS	L082B
XEND	CLC
L082B	BNE	L086C
	LDA	CHRPNT
	LDY	CHRPNT+1
	BEQ	L083F
	STA	PRVLNA
	STY	PRVLNA+1
	LDA	CURLNM
	LDY	CURLNM+1
	STA	PRVLNM
	STY	PRVLNM+1
L083F	PLA
	PLA
	.byte	$24
L0842	CLC
	LDA	#<BRKMSG	;point to BREAK message
	LDY	#>BRKMSG
	LDX	#0
	STX	OUTENB
	BCC	L0850
	JMP	L0469
L0850	JMP	L0474
;execute CONT
XCONT	BNE	L086C
;preset for CONTINUE error
	LDX	#$1E
	LDY	PRVLNA+1
	BNE	L085E
	JMP	XERR
L085E	LDA	PRVLNA
	STA	CHRPNT
	STY	CHRPNT+1
	LDA	PRVLNM
	LDY	PRVLNM+1
	STA	CURLNM
	STY	CURLNM+1
L086C	RTS
;execute RUN
XRUN	BNE	L0883		;continue if not eol
	JMP	L0678
L0883	JSR	L067E
	JMP	L089D
;execute GOSUB
XGOSUB	LDA	#3
	JSR	L0412
	LDA	CHRPNT+1
	PHA
	LDA	CHRPNT
	PHA
	LDA	CURLNM+1
	PHA
	LDA	CURLNM
	PHA
	LDA	#TKGOSU		;put GOSUB token on stack
	PHA
L089D	JSR	GTCWOI
	JSR	XGOTO
	JMP	L07B4
;execute GOTO
XGOTO	JSR	L096C
	JSR	L090A
L08AC	LDA	CURLNM+1
	CMP	INLNNM+1
	BCS	L08BD
	TYA
	SEC
	ADC	CHRPNT
	LDX	CHRPNT+1
	BCC	L08C1
	INX
	BCS	L08C1
L08BD	LDA	BSCSTR
	LDX	BSCSTR+1
L08C1	JSR	L0637		;search for line
	BCC	L08E4		;error if not found
	LDA	DPFLG
	SBC	#1
	STA	CHRPNT
	LDA	DPFLG+1
	SBC	#0
	STA	CHRPNT+1
L08D2	RTS
XRETRN	BNE	L08D2
	LDA	#$FF
	STA	FNXPNT
	JSR	L03A1
	TXS
	CMP	#TKGOSU		;see if GOSUB on stack
	BEQ	L08EC
;RETURN without GOSUB error
	LDX	#$04
	.byte	$2C
;undefined statement error - line number does not exist
L08E4	LDX	#$0E
	JMP	XERR
L08E9	JMP	ERSN
L08EC	PLA
	PLA
	STA	CURLNM
	PLA
	STA	CURLNM+1
	PLA
	STA	CHRPNT
	PLA
	STA	CHRPNT+1
XDATA	JSR	L0907		;scan until eol or colon
L08FC	TYA
L08FD	CLC
	ADC	CHRPNT
	STA	CHRPNT
	BCC	L0906
	INC	CHRPNT+1
L0906	RTS
;scan until colon or eol
L0907	LDX	#':'		;get a colon
	.byte	$2C
;scan until eol
L090A	LDX	#0
	STX	L000A
	LDY	#0
	STY	SRCCHR
L0912	LDA	SRCCHR
	LDX	L000A
	STA	L000A
	STX	SRCCHR
L091A	LDA	(CHRPNT),Y
	BEQ	L0906
	CMP	SRCCHR
	BEQ	L0906
	INY
	CMP	#'"'		;see if quote
	BNE	L091A
	BEQ	L0912
;execute IF statement
XIF	JSR	L0CCD		;evaluate expression
	JSR	GTCWOI
	CMP	#TKGOTO		;see if GOTO token
	BEQ	L0938
	LDA	#TKTHEN		;must be THEN token
	JSR	CHKA
L0938	LDA	PE
	BNE	L0941
;execute REM by scanning to eol
XREM	JSR	L090A
	BEQ	L08FC
L0941	JSR	GTCWOI
	BCS	L0949
	JMP	XGOTO
L0949	JMP	L07E9
XON	JSR	GTBYTW
	PHA
	CMP	#TKGOSU		;see if GOSUB
	BEQ	L0958
L0954	CMP	#TKGOTO		;see if GOTO
	BNE	L08E9
L0958	DEC	PM+3
	BNE	L0960
	PLA
	JMP	L07EB
L0960	JSR	GETCHR
	JSR	L096C
	CMP	#','		;see if comma
	BEQ	L0958
	PLA
L096B	RTS
;convert ascii line number to binary
L096C	LDX	#0
	STX	INLNNM
	STX	INLNNM+1
L0972	BCS	L096B
	SBC	#$2F
	STA	L000A
	LDA	INLNNM+1
	STA	ME
	CMP	#$19
	BCS	L0954
	LDA	INLNNM
	ASL	A
	ROL	ME
	ASL	A
	ROL	ME
	ADC	INLNNM
	STA	INLNNM
	LDA	ME
	ADC	INLNNM+1
	STA	INLNNM+1
	ASL	INLNNM
	ROL	INLNNM+1
	LDA	INLNNM
	ADC	L000A
	STA	INLNNM
	BCC	L09A0
	INC	INLNNM+1
L09A0	JSR	GETCHR
	JMP	L0972
XLET	JSR	L0F2E
	STA	FNXPNT
	STY	FNXPNT+1
	LDA	#TKEQ		;check for = token
	JSR	CHKA
	LDA	NVTYFL
	PHA
	LDA	VRTYFL
	PHA
	JSR	L0CCD
	PLA
	ROL	A
	JSR	L0CBF
	BNE	L09DA
	PLA
L09C3	BPL	L09D7
	JSR	RNP
	JSR	L1047
	LDY	#0
	LDA	PM+2
	STA	(FNXPNT),Y
	INY
	LDA	PM+3
	STA	(FNXPNT),Y
	RTS
L09D7	JMP	L1ACB
L09DA	PLA
L09DB	LDY	#2
	LDA	(PM+2),Y
	CMP	STRSTR+1
	BCC	L09FA
	BNE	L09EC
	DEY
	LDA	(PM+2),Y
	CMP	STRSTR
	BCC	L09FA
L09EC	LDY	PM+3
	CPY	VARSTR+1
	BCC	L09FA
	BNE	L0A01
	LDA	PM+2
	CMP	VARSTR
	BCS	L0A01
L09FA	LDA	PM+2
	LDY	PM+3
	JMP	L0A17
L0A01	LDY	#0
	LDA	(PM+2),Y
	JSR	L12F9
	LDA	L009D
	LDY	L009E
	STA	SGNCMP
	STY	PR
	JSR	L14F4
	LDA	#PE		;point to primary
	LDY	#0
L0A17	STA	L009D
	STY	L009E
	JSR	L1555
	LDY	#0
	LDA	(L009D),Y
	STA	(FNXPNT),Y
	INY
	LDA	(L009D),Y
	STA	(FNXPNT),Y
	INY
	LDA	(L009D),Y
	STA	(FNXPNT),Y
	RTS
;execute directed print
XPRINX	JSR	GETDEV		;get device number
	PHP			;save eol status
	STX	CURDEV		;set device number
	JSR	VEROPN		;make sure is open
	JSR	VDSKX		;see if disk I/O
	BCS	XPRDSK		;it is
;not disk
	PLP			;restore eol status
	BEQ	LCA90		;skip if eol
	JSR	CHKSC		;else must be semicolon
LCA90	JSR	XPRINT		;do regular print
	JMP	STIOCN		;and set io to console
;disk
XPRDSK	JSR	SUDSIO		;set up pointers
	PLP			;get eol status
	BEQ	LCA90A		;must be seq
	JSR	GTCWOI		;get char
	CMP	#';'		;see if semicolon
	BEQ	LCA90B		;if so is seq
	JSR	CHKCM		;else must be comma
	JSR	L0CB9		;evaluate expression
	JSR	L1672		;must be 0 to 65535
	JSR	RANSTU		;set up for random
	JSR	GTCWOI		;get char without bump
	BEQ	LCA90A		;skip if eol else
LCA90B	JSR	CHKSC		;now must be semicolon
LCA90A	JSR	XPRINT		;do output
	JSR	EX63		;do end of record
	JMP	STIOCN		;and go back to console
;part of XPRINT
L0A2F	JSR	L0ACF
L0A32	JSR	GTCWOI
;normal print entry
XPRINT	BEQ	NDCRLF		;do cr and lf if first char
L0A35	BEQ	L0A91		;else just exit
	CMP	#TKTAB		;see if TAB token
L0A3B	BEQ	L0AA9
	CMP	#','		;see if comma
	BEQ	L0A92
	CMP	#TKSPC		;see if SPC token
	CLC			;but clear carry
	BEQ	L0AA9		;branch if SPC
	CMP	#';'		;see if semicolon
	BEQ	L0AC1
	JSR	L0CCD		;evaluate expression
L0A4D	BIT	VRTYFL
	BMI	L0A2F
	JSR	FLTOUT		;output floating number
	JSR	L130B
	LDY	#0
	LDA	(PM+2),Y
	CLC
	ADC	LINPSN
	CMP	MAXPSN
	BCC	L0A65
	JSR	NDCRLF
L0A65	JSR	L0ACF
	JSR	OUTSPC
	BNE	L0A32
;after line input insert zero then do cr and lf
L0A6D	LDY	#0
	STY	INPBUF,X
	LDX	#INPBUF-1
;send CR and LF to current device unless disk - then do nothing
NDCRLF	TXA			;save x in a
	JSR	VDSKX		;see if disk I/O
	TAX			;restore x
	BCS	L0A91		;is so done
;send cr and lf to current device
;clear linpsn
CRLF	LDA	#CR		;get a cr
	STA	LINPSN
	JSR	OUTCHR
	LDA	#LF		;and a linefeed
	JSR	OUTCHR
L0A7F	TXA
	LDX	#0		;CLEAR LINE POSITION
	STX	LINPSN
	TAX
L0A91	RTS
;do , in PRINT
L0A92	LDA	LINPSN
	CMP	LSTTAB
	BCC	L0A9E
	JSR	NDCRLF
	JMP	L0AC1
L0A9E	SEC
L0A9F	SBC	#17
	BCS	L0A9F
	EOR	#$FF
	ADC	#1
	BNE	L0ABC
;do TAB (c=1) and SPC (c=0)
L0AA9	PHP
	JSR	GTBYT
	CMP	#')'		;see if close paren
	BEQ	L0AB4
	JMP	ERSN
L0AB4	PLP
	BCC	L0ABD
	TXA
	SBC	LINPSN
	BCC	L0AC1
L0ABC	TAX
L0ABD	INX
L0ABE	DEX
	BNE	L0AC7
;do ; in PRINT
L0AC1	JSR	GETCHR
	JMP	L0A35		;then loop
L0AC7	JSR	OUTSPC
	BNE	L0ABE
STROUT	JSR	L130B
L0ACF	JSR	L1520
	TAX
	LDY	#0
	INX
L0AD6	DEX
	BEQ	L0A91
	LDA	(ME),Y
	JSR	OUTCHR
	INY
	CMP	#CR		;see if return
	BNE	L0AD6
	JSR	L0A7F
	JMP	L0AD6
;send a space to curdev
OUTSPC	LDA	#' '
	BNE	OUTCHR		;go send it
;send a question mark to curdev
OUTQMR	LDA	#'?'
;send char in a to curdev
;if console check end of line and do crlf if eol reached
OUTCHR	BIT	OUTENB
	BMI	L0B0A
	PHA
	CMP	#' '
	BCC	L0B02
	LDA	CURDEV		;get current device
	CMP	#1		;see if console
	BNE	L0B02		;if not skip line position check
	LDA	LINPSN
	CMP	MAXPSN
	BNE	L0B00
	JSR	NDCRLF
L0B00	INC	LINPSN
L0B02	PLA
	JSR	SYSOUT
L0B0A	AND	#$FF
	RTS
L0B0D	LDA	L0012
	BEQ	L0B1C
	LDA	CURDNM
	LDY	CURDNM+1
	STA	CURLNM
	STY	CURLNM+1
	JMP	ERSN
;do redo from start message
L0B1C	LDA	#<RDOMSG	;point to REDO message
	LDY	#>RDOMSG
	JSR	STROUT
	LDA	PRVLNA
	LDY	PRVLNA+1
	STA	CHRPNT
	STY	CHRPNT+1
	RTS
;directed input syntax error
XINPSR	JMP	ERSN		;do error
;do directed input
XINPUX	JSR	GETDEV		;get device number
	BEQ	XINPSR		;error if eol
	STX	CURDEV		;set device number
	SEC			;turn off output
	ROR	OUTENB
	JSR	VEROPN		;make sure is open
	JSR	VDSKX		;see if disk
	BCS	XINDSK		;it is
;not disk
	JSR	CHKSC		;must be semicolon
	JSR	L0B3D		;do actual input
	LSR	OUTENB		;turn on output
	JMP	STIOCN		;set io to console
;disk
XINDSK	JSR	SUDSIO		;set up pointers
	JSR	GTCWOI		;get char
	CMP	#';'		;see if semicolon
	BEQ	LX0B4F		;branch if is
	JSR	CHKCM		;else must be comma
	JSR	L0CB9		;evaluate expression
	JSR	L1672		;must be 0 to 65535
	JSR	RANSTU		;set up random
	JSR	GTCWOI		;get char
	BEQ	XINPSR		;error if eol
LX0B4F	JSR	CHKSC		;must be semicolon
	JSR	L0B3D		;do input
	JSR	VARBSZ
	BEQ	EX62B		;if not var$block$size then
EX62A	JSR	GTDSCH		;get char
	CMP	#LF		;see if linefeed
	BNE	EX62A		;loop if not
EX62B	JSR	STRRPT		;store$rec$ptr
	LSR	OUTENB		;turn on output
	JMP	STIOCN		;set io to console
;do normal console input
XINPUT	LSR	OUTENB		;enable output
	CMP	#'"'		;see if quote for prompt
	BNE	L0B3D
	JSR	L0DD3
	LDA	#';'		;make sure is a semicolon
	JSR	CHKA
	JSR	L0ACF
;this would be entry after front of INPUT#
L0B3D	JSR	CHILDR
	LDA	#','		;insert a comma
	STA	INPBUF-1
	JSR	L0B4F		;do the input
	LDA	INPBUF
	BNE	L0B5D
	CLC
	JMP	L0B1C
;send ? and space then get line
L0B4F	JSR	OUTQMR
	JSR	OUTSPC
	JMP	INPLIN
;execute READ statement
XREAD	LDX	CURDAD
	LDY	CURDAD+1
	.byte	$A9		;load opcode
L0B5D	TYA
	STA	L0012		;set type ($98=READ,0=INPUT)
;VIC uses $40 for GET so BIT L0012 sets overflow
	STX	INPTAD
	STY	INPTAD+1
L0B64	JSR	L0F2E
	STA	FNXPNT
	STY	FNXPNT+1
	LDA	CHRPNT
	LDY	CHRPNT+1
	STA	SVECPT
	STY	SVECPT+1
	LDX	INPTAD
	LDY	INPTAD+1
	STX	CHRPNT
	STY	CHRPNT+1
	JSR	GTCWOI
	BNE	L0B8E
	BIT	L0012
	BMI	L0BE8
	JSR	OUTQMR
	JSR	L0B4F
	STX	CHRPNT
	STY	CHRPNT+1
L0B8E	JSR	GETCHR
	BIT	VRTYFL
	BPL	L0BB9
	STA	L000A
	CMP	#'"'		;see if quote
	BEQ	L0BA2
	LDA	#':'		;get colon
	STA	L000A
	LDA	#','		;then a comma
	CLC
L0BA2	STA	SRCCHR
	LDA	CHRPNT
	LDY	CHRPNT+1
	ADC	#0
	BCC	L0BAD
	INY
L0BAD	JSR	L1311
	JSR	L165D
	JSR	L09DB
	JMP	L0BC1
L0BB9	JSR	FLTASC
	LDA	NVTYFL
	JSR	L09C3
L0BC1	JSR	GTCWOI
	BEQ	L0BCD
	CMP	#','		;see if comma
	BEQ	L0BCD
	JMP	L0B0D
L0BCD	LDA	CHRPNT
	LDY	CHRPNT+1
	STA	INPTAD
	STY	INPTAD+1
	LDA	SVECPT
	LDY	SVECPT+1
	STA	CHRPNT
	STY	CHRPNT+1
	JSR	GTCWOI
	BEQ	L0C0E
	JSR	CHKCM
	JMP	L0B64
L0BE8	JSR	L0907
	INY
	TAX
	BNE	L0C01
	LDX	#6
	INY
	LDA	(CHRPNT),Y
	BEQ	L0C5F
	INY
	LDA	(CHRPNT),Y
	STA	CURDNM
	INY
	LDA	(CHRPNT),Y
	INY
	STA	CURDNM+1
L0C01	LDA	(CHRPNT),Y
	TAX
	JSR	L08FC
	CPX	#TKDATA		;see if DATA
	BNE	L0BE8
	JMP	L0B8E
L0C0E	LDA	INPTAD
	LDY	INPTAD+1
	LDX	L0012
	BPL	L0C19
	JMP	L0814
L0C19	LDY	#0
	LDA	(INPTAD),Y	;get next char
	BEQ	L0C26
	LDA	#<XTRMSG	;point to EXTRA message
	LDY	#>XTRMSG
	JMP	STROUT
L0C26	RTS
XTRMSG	.byte	'?EXTRA IGNORED',CR,LF,0
RDOMSG	.byte	'?REDO FROM START',CR,LF,0
;execute NEXT
XNEXT	BNE	L0C51
	LDY	#0
	BEQ	L0C54
L0C51	JSR	L0F2E
L0C54	STA	FNXPNT
	STY	FNXPNT+1
	JSR	L03A1
	BEQ	L0C61
	LDX	#0
L0C5F	BEQ	L0CCA
L0C61	TXS
	INX
	INX
	INX
	INX
	TXA
	INX
	INX
	INX
	INX
	INX
	INX
	STX	MEMPNT
	LDY	#1
	JSR	LPA
	TSX
	LDA	$109,X
	STA	PS
	LDA	FNXPNT
	LDY	FNXPNT+1
	JSR	APA
	JSR	L1ACB
	LDY	#1
	JSR	L1B58
	TSX
	SEC
	SBC	$109,X
	BEQ	L0CA7
	LDA	$10F,X
	STA	CURLNM
	LDA	$110,X
	STA	CURLNM+1
	LDA	$112,X
	STA	CHRPNT
	LDA	$111,X
	STA	CHRPNT+1
L0CA4	JMP	L07B4
L0CA7	TXA
	ADC	#17
	TAX
	TXS
	JSR	GTCWOI
	CMP	#','		;see if comma
	BNE	L0CA4
	JSR	GETCHR
	JSR	L0C51
;evaluate expression and confirm numerical
L0CB9	JSR	L0CCD
L0CBC	CLC
	.byte	$24
L0CBE	SEC
L0CBF	BIT	VRTYFL
	BMI	L0CC6
	BCS	L0CC8
L0CC5	RTS
L0CC6	BCS	L0CC5
;type mismatch error - string and numerical paired
L0CC8	LDX	#$18
L0CCA	JMP	XERR
;evaluate expression
L0CCD	LDX	CHRPNT
	BNE	L0CD3
	DEC	CHRPNT+1
L0CD3	DEC	CHRPNT
	LDX	#0
	.byte	$24		; dummy $24 xx : Direct Page
				; skip L0CD8 PHA
L0CD8	PHA
	TXA
	PHA
	LDA	#1
	JSR	L0412
	JSR	L0DB2
	LDA	#0
	STA	L009A
L0CE7	JSR	GTCWOI
L0CEA	SEC
	SBC	#TKGT		;subtract > token
	BCC	L0D06
	CMP	#3
	BCS	L0D06
	CMP	#1
	ROL	A
	EOR	#1
	EOR	L009A
	CMP	L009A
	BCC	L0D5F
	STA	L009A
	JSR	GETCHR
	JMP	L0CEA
L0D06	LDX	L009A
	BNE	L0D36
	BCS	L0D87
	ADC	#7
	BCC	L0D87
	ADC	VRTYFL
	BNE	L0D17
	JMP	L14B7
L0D17	ADC	#$FF
	STA	ME
	ASL	A
	ADC	ME
	TAY
L0D1F	PLA
	CMP	OPRTBL,Y
	BCS	L0D8C
	JSR	L0CBC
L0D28	PHA
L0D29	JSR	L0D4F
	PLA
	LDY	SVECPT
	BPL	L0D48
	TAX
	BEQ	L0D8A
	BNE	L0D95
L0D36	LSR	VRTYFL
	TXA
	ROL	A
	LDX	CHRPNT
	BNE	L0D40
	DEC	CHRPNT+1
L0D40	DEC	CHRPNT
	LDY	#INPBUF
	STA	L009A
	BNE	L0D1F
L0D48	CMP	OPRTBL,Y
	BCS	L0D95
	BCC	L0D28
L0D4F	LDA	OPRTBL+2,Y
	PHA
	LDA	OPRTBL+1,Y
	PHA
	JSR	L0D62
	LDA	L009A
	JMP	L0CD8
L0D5F	JMP	ERSN
L0D62	LDA	PS
	LDX	OPRTBL,Y
L0D67	TAY
	PLA
	STA	ME
	INC	ME
	PLA
	STA	ME+1
	TYA
	PHA
L0D72	JSR	RNP
	LDA	PM+3
	PHA
	LDA	PM+2
	PHA
	LDA	PM+1
	PHA
	LDA	PM
	PHA
	LDA	PE
	PHA
	JMP	($0+ME)
L0D87	LDY	#$FF
	PLA
L0D8A	BEQ	L0DAF
L0D8C	CMP	#$64
	BEQ	L0D93
	JSR	L0CBC
L0D93	STY	SVECPT
L0D95	PLA
	LSR	A
	STA	L0013
	PLA
	STA	SE
	PLA
	STA	SM
	PLA
	STA	SM+1
	PLA
	STA	SM+2
	PLA
	STA	SM+3
	PLA
	STA	SS
	EOR	PS
	STA	SGNCMP
L0DAF	LDA	PE
	RTS
L0DB2	LDA	#0
	STA	VRTYFL
L0DB6	JSR	GETCHR
	BCS	L0DBE
L0DBB	JMP	FLTASC
L0DBE	JSR	TSALPH
	BCS	L0E2A
	CMP	#'.'
	BEQ	L0DBB
	CMP	#TKMINU		;see if minus token
	BEQ	L0E23
	CMP	#TKPLUS		;see if plus token
	BEQ	L0DB6
	CMP	#'"'		;see if quote
	BNE	L0DE2
L0DD3	LDA	CHRPNT
	LDY	CHRPNT+1
	ADC	#0
	BCC	L0DDC
	INY
L0DDC	JSR	L130B
	JMP	L165D
L0DE2	CMP	#TKNOT		;see if NOT token
	BNE	L0DF9
	LDY	#$18
	BNE	L0E25
;entry for = in expression
L0DEA	JSR	L1047
	LDA	PM+3
	EOR	#$FF
	TAY
	LDA	PM+2
	EOR	#$FF
	JMP	FXTOFL
L0DF9	CMP	#TKFN		;see if FN token
	BNE	L0E00
	JMP	L1276
L0E00	CMP	#TKSGN		;see if SGN token
	BCC	L0E07
	JMP	L0E4A
L0E07	JSR	CHKOP
	JSR	L0CCD
;series of entries to verify that syntax required chars are used
;if char is not as specified a syntax error message is generated
CHKCP	LDA	#')'		;check for close
	BNE	CHKA
CHKOP	LDA	#'('		;check for open
	BNE	CHKA
CHKCM	LDA	#','		;check for comma
	BNE	CHKA
CHKSC	LDA	#';'		;check for semicolon
CHKA	LDY	#0
	CMP	(CHRPNT),Y
	BNE	ERSN
	JMP	GETCHR
;syntax error
ERSN	LDX	#$02
	JMP	XERR
L0E23	LDY	#$15
L0E25	PLA
	PLA
	JMP	L0D29
L0E2A	JSR	L0F2E
	STA	PM+2
	STY	PM+3
	LDX	VRTYFL
	BEQ	L0E36
	RTS
L0E36	LDX	NVTYFL
	BPL	L0E47
	LDY	#0
	LDA	(PM+2),Y
	TAX
	INY
	LDA	(PM+2),Y
	TAY
	TXA
	JMP	FXTOFL
L0E47	JMP	LPA
;handle function
L0E4A	ASL	A
	PHA
	TAX
	JSR	GETCHR
;	CPX	#TKLEFT*2*256/256-1	;see if one param only
	CPX	#((TKLEFT<<9)>>8)-1	;see if one param only
	BCC	L0E74
	JSR	CHKOP
	JSR	L0CCD
	JSR	CHKCM
	JSR	L0CBE
	PLA
	TAX
	LDA	PM+3
	PHA
	LDA	PM+2
	PHA
	TXA
	PHA
	JSR	GTBYTW
	PLA
	TAY
	TXA
	PHA
	JMP	L0E79
L0E74	JSR	L0E07
	PLA
	TAY
L0E79	LDA	FUNTBL-FUNOFS,Y
	STA	FUNJMP+1
	LDA	FUNTBL-FUNOFS+1,Y
	STA	FUNJMP+2
	JSR	FUNJMP
	JMP	L0CBC
;entry for OR in expression
L0E89	LDY	#$FF
	.byte	$2C
;entry for AND operand in expression
L0E8C	LDY	#0
	STY	L000C
	JSR	L1047
	LDA	PM+2
	EOR	L000C
	STA	L000A
	LDA	PM+3
	EOR	L000C
	STA	SRCCHR
	JSR	TSP
	JSR	L1047
	LDA	PM+3
	EOR	L000C
	AND	SRCCHR
	EOR	L000C
	TAY
	LDA	PM+2
	EOR	L000C
	AND	L000A
	EOR	L000C
	JMP	FXTOFL
;entry for < in expression
L0EB9	JSR	L0CBF
	BCS	L0ED1
	LDA	SS
	ORA	#$7F
	AND	SM
	STA	SM
	LDA	#<SE		;point to secondary accum
	LDY	#>SE
	JSR	CPA
	TAX
	JMP	L0F04
L0ED1	LDA	#0
	STA	VRTYFL
	DEC	L009A
	JSR	L1520
	STA	PE
	STX	PM
	STY	PM+1
	LDA	SM+2
	LDY	SM+3
	JSR	L1524
	STX	SM+2
	STY	SM+3
	TAX
	SEC
	SBC	PE
	BEQ	L0EF9
	LDA	#1
	BCC	L0EF9
	LDX	PE
	LDA	#$FF
L0EF9	STA	PS
	LDY	#$FF
	INX
L0EFE	INY
	DEX
	BNE	L0F09
	LDX	PS
L0F04	BMI	L0F15
	CLC
	BCC	L0F15
L0F09	LDA	(PM),Y
	JSR	LWRUPR		;convert to upper
	STA	L17D5+1		;save it
	LDA	(SM+2),Y
	JSR	LWRUPR
L17D5	CMP	#0		;compare chars
	BEQ	L0EFE
	LDX	#$FF
	BCS	L0F15
	LDX	#1
L0F15	INX
	TXA
	ROL	A
	AND	L0013
	BEQ	L0F1E
	LDA	#$FF
L0F1E	JMP	L1B37
L0F21	JSR	CHKCM
XDIM	TAX
	JSR	L0F33
	JSR	GTCWOI
	BNE	L0F21
	RTS
;locate variable
L0F2E	LDX	#0
	JSR	GTCWOI
L0F33	STX	L000D
L0F35	STA	CURVNM
	JSR	GTCWOI
	JSR	TSALPH
	BCS	L0F42
L0F3F	JMP	ERSN
L0F42	LDX	#0
	STX	VRTYFL
	STX	NVTYFL
	JSR	GETCHR
	BCC	L0F52
	JSR	TSALPH
	BCC	L0F5D
L0F52	TAX
L0F53	JSR	GETCHR
	BCC	L0F53
	JSR	TSALPH
	BCS	L0F53
L0F5D	CMP	#'$'		;see if dollar for string
	BNE	L0F67
	LDA	#$FF
	STA	VRTYFL
	BNE	L0F77
L0F67	CMP	#'%'		;see if percent for integer
	BNE	L0F7E
	LDA	L0011
	BNE	L0F3F
	LDA	#$80
	STA	NVTYFL
	ORA	CURVNM
	STA	CURVNM
L0F77	TXA
	ORA	#$80
	TAX
	JSR	GETCHR
L0F7E	STX	CURVNM+1
	SEC
	ORA	L0011
	SBC	#'('		;see if array
	BNE	L0F8A
	JMP	L1059
L0F8A	LDA	#0
	STA	L0011
	LDA	VARSTR
	LDX	VARSTR+1
	LDY	#0
L0F94	STX	DPFLG+1
L0F96	STA	DPFLG
	CPX	ARYSTR+1
	BNE	L0FA0
	CMP	ARYSTR
	BEQ	L0FC2
L0FA0	LDA	CURVNM
	CMP	(DPFLG),Y
	BNE	L0FAE
	LDA	CURVNM+1
	INY
	CMP	(DPFLG),Y
	BEQ	L1019
	DEY
L0FAE	CLC
	LDA	DPFLG
	ADC	#7
	BCC	L0F96
	INX
	BNE	L0F94
TSALPH	CMP	#'A'		;compare to A
	BCC	L0FC1
	SBC	#'Z'+1		;subtract Z+1
	SEC
	SBC	#$A5
L0FC1	RTS
L0FC2	PLA
	PHA
	CMP	#','		;see if comma
	BNE	L0FD7
	TSX
	LDA	$102,X
	CMP	#$0E
	BNE	L0FD7
	LDA	#<L0FD5		;point to zero word
	LDY	#>L0FD5
	RTS
L0FD5	.word	0
L0FD7	LDA	ARYSTR
	LDY	ARYSTR+1
	STA	DPFLG
	STY	DPFLG+1
	LDA	EMPSTR
	LDY	EMPSTR+1
	STA	L00A7
	STY	L00A8
	CLC
	ADC	#7
	BCC	L0FED
	INY
L0FED	STA	L00A5
	STY	L00A6
	JSR	L03CF
	LDA	L00A5
	LDY	L00A6
	INY
	STA	ARYSTR
	STY	ARYSTR+1
	LDY	#0
	LDA	CURVNM
	STA	(DPFLG),Y
	INY
	LDA	CURVNM+1
	STA	(DPFLG),Y
	LDA	#0
	INY
	STA	(DPFLG),Y
	INY
	STA	(DPFLG),Y
	INY
	STA	(DPFLG),Y
	INY
	STA	(DPFLG),Y
	INY
	STA	(DPFLG),Y
L1019	LDA	DPFLG
	CLC
	ADC	#2
	LDY	DPFLG+1
	BCC	L1023
	INY
L1023	STA	CURVAD
	STY	CURVAD+1
	RTS
L1028	LDA	L000C
	ASL	A
	ADC	#5
	ADC	DPFLG
	LDY	DPFLG+1
	BCC	L1034
	INY
L1034	STA	L00A5
	STY	L00A6
	RTS
M2TO15	.byte	$90,$80,0,0	;-32768
L103D	JSR	GETCHR
	JSR	L0CB9
L1043	LDA	PS
	BMI	L1054
L1047	LDA	PE
	CMP	#$90
	BCC	L1056
	LDA	#<M2TO15	;point to -32768
	LDY	#>M2TO15
	JSR	CPA
L1054	BNE	L10D0
L1056	JMP	FXU
L1059	LDA	L000D
	ORA	NVTYFL
	PHA
	LDA	VRTYFL
	PHA
	LDY	#0
L1063	TYA
	PHA
	LDA	CURVNM+1
	PHA
	LDA	CURVNM
	PHA
	JSR	L103D
	PLA
	STA	CURVNM
	PLA
	STA	CURVNM+1
	PLA
	TAY
	TSX
	LDA	$0102,X
	PHA
	LDA	$0101,X
	PHA
	LDA	PM+2
	STA	$0102,X
	LDA	PM+3
	STA	$0101,X
	INY
	JSR	GTCWOI
	CMP	#','		;see if comma
	BEQ	L1063
	STY	L000C
	JSR	CHKCP
	PLA
	STA	VRTYFL
	PLA
	STA	NVTYFL
	AND	#$7F
	STA	L000D
;----------------------------------------------
	LDX	ARYSTR
	LDA	ARYSTR+1
L10A4	STX	DPFLG
	STA	DPFLG+1
	CMP	EMPSTR+1
	BNE	L10B0
	CPX	EMPSTR
	BEQ	L10E9		;OK next
L10B0	LDY	#0
	LDA	(DPFLG),Y
	INY
	CMP	CURVNM
	BNE	L10BF
	LDA	CURVNM+1
	CMP	(DPFLG),Y
	BEQ	L10D5		; error check
L10BF	INY
	LDA	(DPFLG),Y
	CLC
	ADC	DPFLG
	TAX
	INY
	LDA	(DPFLG),Y

; 2025.01.24 bug fix  Akihito Honda
;	ADC	DPFLG		; -> ADC	DPFLG+1

	ADC	DPFLG+1
	BCC	L10A4
;----------------------------------------------
;bad subscript error - subscript too big
L10CD	LDX	#$10
	.byte	$2C	;dummy : $2c xx xx : bit Absolute
			; skip ldx #$08
;function call error - parameter out of range
L10D0	LDX	#$08
L10D2	JMP	XERR
;preset for double dimension error
L10D5	LDX	#$12
	LDA	L000D
	BNE	L10D2		;double dimension error
	JSR	L1028
	LDA	L000C
	LDY	#4
	CMP	(DPFLG),Y
	BNE	L10CD		;bad subscript error
	JMP	L1173

L10E9	JSR	L1028
	JSR	L041F
	LDA	#0
	TAY
	STA	CNVIND+1
	LDX	#5
	LDA	CURVNM
	STA	(DPFLG),Y

	BPL	L10FD
	DEX
L10FD	INY

	LDA	CURVNM+1
	STA	(DPFLG),Y

	BPL	L1106
	DEX
	DEX
L1106	STX	CNVIND

	LDA	L000C
	INY
	INY
	INY
	STA	(DPFLG),Y

L110F	LDX	#11
	LDA	#0
	BIT	L000D

	BVC	L111F
	PLA
	CLC
	ADC	#1
	TAX
	PLA
	ADC	#0
L111F	INY

	STA	(DPFLG),Y
	INY
	TXA
	STA	(DPFLG),Y
	JSR	L11D3
	STX	CNVIND
	STA	CNVIND+1
	LDY	ME
	DEC	L000C
	BNE	L110F

	ADC	L00A6
	BCS	L1194
	STA	L00A6
	TAY
	TXA
	ADC	L00A5
	BCC	L1142
	INY
	BEQ	L1194
L1142	JSR	L041F
	STA	EMPSTR
	STY	EMPSTR+1
	LDA	#0
	INC	CNVIND+1
	LDY	CNVIND
	BEQ	L1156
L1151	DEY
	STA	(L00A5),Y
	BNE	L1151
L1156	DEC	L00A6
	DEC	CNVIND+1
	BNE	L1151
	INC	L00A6
	SEC
	LDA	EMPSTR
	SBC	DPFLG
	LDY	#2
	STA	(DPFLG),Y
	LDA	EMPSTR+1
	INY
	SBC	DPFLG+1
	STA	(DPFLG),Y
	LDA	L000D
	BNE	RET00
	INY

L1173	LDA	(DPFLG),Y
	STA	L000C
	LDA	#0
	STA	CNVIND
L117B	STA	CNVIND+1
	INY
	PLA
	TAX
	STA	PM+2
	PLA
	STA	PM+3
	CMP	(DPFLG),Y
	BCC	L1197
	BNE	L1191
	INY
	TXA
	CMP	(DPFLG),Y
	BCC	L1198
L1191	JMP	L10CD
L1194	JMP	OMERR
L1197	INY
L1198	LDA	CNVIND+1
	ORA	CNVIND
	CLC
	BEQ	L11A9
	JSR	L11D3
	TXA
	ADC	PM+2
	TAX
	TYA
	LDY	ME
L11A9	ADC	PM+3
	STX	CNVIND
	DEC	L000C
	BNE	L117B
	STA	CNVIND+1
	LDX	#5
	LDA	CURVNM		;get first char of name
	BPL	L11B8
	DEX
L11B8	LDA	CURVNM+1
	BPL	L11BE
	DEX
	DEX
L11BE	STX	QM+2
	LDA	#0
	JSR	L11DC
	TXA
	ADC	L00A5
	STA	CURVAD
	TYA
	ADC	L00A6
	STA	CURVAD+1
	TAY
	LDA	CURVAD
RET00	RTS
L11D3	STY	ME
	LDA	(DPFLG),Y
	STA	QM+2
	DEY
	LDA	(DPFLG),Y
L11DC	STA	QM+3
	LDA	#$10
	STA	DPOFF
	LDX	#0
	LDY	#0
L11E6	TXA
	ASL	A
	TAX
	TYA
	ROL	A
	TAY
	BCS	L1194
	ASL	CNVIND
	ROL	CNVIND+1
	BCC	L11FF
	CLC
	TXA
	ADC	QM+2
	TAX
	TYA
	ADC	QM+3
	TAY
	BCS	L1194
L11FF	DEC	DPOFF
	BNE	L11E6
	RTS
XFRE	LDA	VRTYFL
	BEQ	L120B
	JSR	L1520
L120B	JSR	L13A4
	SEC
	LDA	STRSTR
	SBC	EMPSTR
	TAY
	LDA	STRSTR+1
	SBC	EMPSTR+1
;convert 16 bit integer to floating
FXTOFL	LDX	#0
	STX	VRTYFL
	STA	PM
	STY	PM+1
	LDX	#$90
	JMP	L1B3F
XPOS	LDY	LINPSN
L1227	LDA	#0
	BEQ	FXTOFL
CHILDR	LDX	CURLNM+1
	INX
	BNE	RET00
;illegal direct - DEF and INPUT not legal direct
	LDX	#$16
L1232	JMP	XERR
XDEF	JSR	L1263
	JSR	CHILDR
	JSR	CHKOP
	LDA	#$80
	STA	L0011
	JSR	L0F2E
	JSR	L0CBC
	JSR	CHKCP
	LDA	#TKEQ		;check for = token
	JSR	CHKA
	PHA
	LDA	CURVAD+1
	PHA
	LDA	CURVAD
	PHA
	LDA	CHRPNT+1
	PHA
	LDA	CHRPNT
	PHA
	JSR	XDATA
	JMP	L12D3
L1263	LDA	#TKFN		;must be FN
	JSR	CHKA
	ORA	#$80
	STA	L0011
	JSR	L0F35
	STA	L009B
	STY	L009C
	JMP	L0CBC
L1276	JSR	L1263
	LDA	L009C
	PHA
	LDA	L009B
	PHA
	JSR	L0E07
	JSR	L0CBC
	PLA
	STA	L009B
	PLA
	STA	L009C
	LDY	#2
	LDX	#$20
	LDA	(L009B),Y
	BEQ	L1232
	STA	CURVAD
	TAX
	INY
	LDA	(L009B),Y
	STA	CURVAD+1
	INY
L129C	LDA	(CURVAD),Y
	PHA
	DEY
	BPL	L129C
	LDY	CURVAD+1
	JSR	L1ACF
	LDA	CHRPNT+1
	PHA
	LDA	CHRPNT
	PHA
	LDA	(L009B),Y
	STA	CHRPNT
	INY
	LDA	(L009B),Y
	STA	CHRPNT+1
	LDA	CURVAD+1
	PHA
	LDA	CURVAD
	PHA
	JSR	L0CB9
	PLA
	STA	L009B
	PLA
	STA	L009C
	JSR	GTCWOI
	BEQ	L12CD
	JMP	ERSN
L12CD	PLA
	STA	CHRPNT
	PLA
	STA	CHRPNT+1
L12D3	LDY	#0
	PLA
	STA	(L009B),Y
	PLA
	INY
	STA	(L009B),Y
	PLA
	INY
	STA	(L009B),Y
	PLA
	INY
	STA	(L009B),Y
	PLA
	INY
	STA	(L009B),Y
	RTS
XSTR	JSR	L0CBC
	LDY	#0
	JSR	L1CEE
	PLA
	PLA
	LDA	#$FF
	LDY	#0
	BEQ	L130B
L12F9	LDX	PM+2
	LDY	PM+3
	STX	L009D
	STY	L009E
L1301	JSR	L1372
	STX	PM
	STY	PM+1
	STA	PE
	RTS
L130B	LDX	#'"'		;get a quote
	STX	L000A
	STX	SRCCHR
L1311	STA	SGNCMP
	STY	PR
	STA	PM
	STY	PM+1
	LDY	#$FF
L131B	INY
	LDA	(SGNCMP),Y
	BEQ	L132C
	CMP	L000A
	BEQ	L1328
	CMP	SRCCHR
	BNE	L131B
L1328	CMP	#'"'		;see if quote
	BEQ	L132D
L132C	CLC
L132D	STY	PE
	TYA
	ADC	SGNCMP
	STA	CNVIND
	LDX	PR
	BCC	L1339
	INX
L1339	STX	CNVIND+1
	LDA	PR
	BNE	L134A
	TYA
	JSR	L12F9
	LDX	SGNCMP
	LDY	PR
	JSR	L1502
L134A	LDX	L0063
	CPX	#STRSTK+9
	BNE	L1355
;string temporary error - expression too complex
	LDX	#$1C
L1352	JMP	XERR
L1355	LDA	PE
	STA	0,X
	LDA	PM
	STA	1,X
	LDA	PM+1
	STA	2,X
	LDY	#0
	STX	PM+2
	STY	PM+3
	DEY
	STY	VRTYFL
	STX	L0064
	INX
	INX
	INX
	STX	L0063
	RTS
L1372	LSR	L0010
L1374	PHA
	EOR	#$FF
	SEC
	ADC	STRSTR
	LDY	STRSTR+1
	BCS	L137F
	DEY
L137F	CPY	EMPSTR+1
	BCC	L1394
	BNE	L1389
	CMP	EMPSTR
	BCC	L1394
L1389	STA	STRSTR
	STY	STRSTR+1
	STA	L0082
	STY	L0082+1
	TAX
	PLA
	RTS
L1394	LDX	#$0C
	LDA	L0010
	BMI	L1352
	JSR	L13A4
	LDA	#$80
	STA	L0010
	PLA
	BNE	L1374
L13A4	LDX	MEMLMT
	LDA	MEMLMT+1
L13A8	STX	STRSTR
	STA	STRSTR+1
	LDY	#0
	STY	L009C
	LDA	EMPSTR
	LDX	EMPSTR+1
	STA	DPFLG
	STX	DPFLG+1
	LDA	#STRSTK
	LDX	#0
	STA	ME
	STX	ME+1
L13C0	CMP	L0063
	BEQ	L13C9
	JSR	L1443
	BEQ	L13C0
L13C9	LDA	#$07
	STA	L00A0
	LDA	VARSTR
	LDX	VARSTR+1
	STA	ME
	STX	ME+1
L13D5	CPX	ARYSTR+1
	BNE	L13DD
	CMP	ARYSTR
	BEQ	L13E2
L13DD	JSR	L1439
	BEQ	L13D5
L13E2	STA	L00A5
	STX	L00A6
	LDA	#3
	STA	L00A0
L13EA	LDA	L00A5
	LDX	L00A6
L13EE	CPX	EMPSTR+1
	BNE	L13F9
	CMP	EMPSTR
	BNE	L13F9
	JMP	L1482
L13F9	STA	ME
	STX	ME+1
	LDY	#0
	LDA	(ME),Y
	TAX
	INY
	LDA	(ME),Y
	PHP
	INY
	LDA	(ME),Y
	ADC	L00A5
	STA	L00A5
	INY
	LDA	(ME),Y
	ADC	L00A6
	STA	L00A6
	PLP
	BPL	L13EA
	TXA
	BMI	L13EA
	INY
	LDA	(ME),Y
	LDY	#0
	ASL	A
	ADC	#5
	ADC	ME
	STA	ME
	BCC	L142A
	INC	ME+1
L142A	LDX	ME+1
L142C	CPX	L00A6
	BNE	L1434
	CMP	L00A5
	BEQ	L13EE
L1434	JSR	L1443
	BEQ	L142C
L1439	LDA	(ME),Y
	BMI	L1472
	INY
	LDA	(ME),Y
	BPL	L1472
	INY
L1443	LDA	(ME),Y
	BEQ	L1472
	INY
	LDA	(ME),Y
	TAX
	INY
	LDA	(ME),Y
	CMP	STRSTR+1
	BCC	L1458
	BNE	L1472
	CPX	STRSTR
	BCS	L1472
L1458	CMP	DPFLG+1
	BCC	L1472
	BNE	L1462
	CPX	DPFLG
	BCC	L1472
L1462	STX	DPFLG
	STA	DPFLG+1
	LDA	ME
	LDX	ME+1
	STA	L009B
	STX	L009C
	LDA	L00A0
	STA	FUNJMP+1
L1472	LDA	L00A0
	CLC
	ADC	ME
	STA	ME
	BCC	L147D
	INC	ME+1
L147D	LDX	ME+1
	LDY	#0
	RTS
L1482	LDX	L009C
	BEQ	L147D
	LDA	FUNJMP+1
	AND	#4
	LSR	A
	TAY
	STA	FUNJMP+1
	LDA	(L009B),Y
	ADC	DPFLG
	STA	L00A7
	LDA	DPFLG+1
	ADC	#0
	STA	L00A8
	LDA	STRSTR
	LDX	STRSTR+1
	STA	L00A5
	STX	L00A6
	JSR	L03D6
	LDY	FUNJMP+1
	INY
	LDA	L00A5
	STA	(L009B),Y
	TAX
	INC	L00A6
	LDA	L00A6
	INY
	STA	(L009B),Y
	JMP	L13A8
L14B7	LDA	PM+3
	PHA
	LDA	PM+2
	PHA
	JSR	L0DB2
	JSR	L0CBE
	PLA
	STA	SGNCMP
	PLA
	STA	PR
	LDY	#0
	LDA	(SGNCMP),Y
	CLC
	ADC	(PM+2),Y
	BCC	L14D7
;long string error - string > 255 characters
	LDX	#$1A
	JMP	XERR
L14D7	JSR	L12F9
	JSR	L14F4
	LDA	L009D
	LDY	L009E
	JSR	L1524
	JSR	L1506
	LDA	SGNCMP
	LDY	PR
	JSR	L1524
	JSR	L134A
	JMP	L0CE7
L14F4	LDY	#0
	LDA	(SGNCMP),Y
	PHA
	INY
	LDA	(SGNCMP),Y
	TAX
	INY
	LDA	(SGNCMP),Y
	TAY
	PLA
L1502	STX	ME
	STY	ME+1
L1506	TAY
	BEQ	L1513
	PHA
L150A	DEY
	LDA	(ME),Y
	STA	(L0082),Y
	TYA
	BNE	L150A
	PLA
L1513	CLC
	ADC	L0082
	STA	L0082
	BCC	L151C
	INC	L0082+1
L151C	RTS
L151D	JSR	L0CBE
L1520	LDA	PM+2
	LDY	PM+3
L1524	STA	ME
	STY	ME+1
	JSR	L1555
	PHP
	LDY	#0
	LDA	(ME),Y
	PHA
	INY
	LDA	(ME),Y
	TAX
	INY
	LDA	(ME),Y
	TAY
	PLA
	PLP
	BNE	L1550
	CPY	STRSTR+1
	BNE	L1550
	CPX	STRSTR
	BNE	L1550
	PHA
	CLC
	ADC	STRSTR
	STA	STRSTR
	BCC	L154F
	INC	STRSTR+1
L154F	PLA
L1550	STX	ME
	STY	ME+1
	RTS
L1555	CPY	L0065
	BNE	L1565
	CMP	L0064
	BNE	L1565
	STA	L0063
	SBC	#3
	STA	L0064
	LDY	#0
L1565	RTS
XCHR	JSR	L161B
	TXA
	PHA
	LDA	#1
	JSR	L1301
	PLA
	LDY	#0
	STA	(PM),Y
	PLA
	PLA
	JMP	L134A
XLEFT	JSR	L15D9
	CMP	(L009D),Y
	TYA
L1580	BCC	L1586
	LDA	(L009D),Y
	TAX
	TYA
L1586	PHA
L1587	TXA
L1588	PHA
	JSR	L1301
	LDA	L009D
	LDY	L009E
	JSR	L1524
	PLA
	TAY
	PLA
	CLC
	ADC	ME
	STA	ME
	BCC	L159F
	INC	ME+1
L159F	TYA
	JSR	L1506
	JMP	L134A
XRIGHT	JSR	L15D9
	CLC
	SBC	(L009D),Y
	EOR	#$FF
	JMP	L1580
XMID	LDA	#$FF
	STA	PM+3
	JSR	GTCWOI
	CMP	#')'		;see if close paren
	BEQ	L15C2
	JSR	CHKCM
	JSR	GTBYTW
L15C2	JSR	L15D9
	DEX
	TXA
	PHA
	CLC
	LDX	#0
	SBC	(L009D),Y
	BCS	L1587
	EOR	#$FF
	CMP	PM+3
	BCC	L1588
	LDA	PM+3
	BCS	L1588
L15D9	JSR	CHKCP
	PLA
	TAY
	PLA
	STA	FUNJMP+1
	PLA
	PLA
	PLA
	TAX
	PLA
	STA	L009D
	PLA
	STA	L009E
	LDA	FUNJMP+1
	PHA
	TYA
	PHA
	LDY	#0
	TXA
	BEQ	L1612
	RTS
XLEN	JSR	L15FC
	JMP	L1227
L15FC	JSR	L151D
	LDX	#0
	STX	VRTYFL
	TAY
	RTS
XASC	JSR	L15FC
	BEQ	L1612
	LDY	#0
	LDA	(ME),Y
	TAY
	JMP	L1227
L1612	JMP	L10D0
;get single byte value
GTBYT	JSR	GETCHR
;get single byte value without bumping pointer
GTBYTW	JSR	L0CB9
L161B	JSR	L1043
	LDX	PM+2
	BNE	L1612
	LDX	PM+3
	JMP	GTCWOI
XVAL	JSR	L15FC
	BNE	L162F
	JMP	L1766
L162F	LDX	CHRPNT
	LDY	CHRPNT+1
	STX	CNVIND
	STY	CNVIND+1
	LDX	ME
	STX	CHRPNT
	CLC
	ADC	ME
	STA	MEMPNT
	LDX	ME+1
	STX	CHRPNT+1
	BCC	L1647
	INX
L1647	STX	MEMPNT+1
	LDY	#0
	LDA	(MEMPNT),Y
	PHA
	LDA	#0
	STA	(MEMPNT),Y
	JSR	GTCWOI
	JSR	FLTASC
	PLA
	LDY	#0
	STA	(MEMPNT),Y
L165D	LDX	CNVIND
	LDY	CNVIND+1
	STX	CHRPNT
	STY	CHRPNT+1
	RTS
L1666	JSR	L0CB9
	JSR	L1672
L166C	JSR	CHKCM
	JMP	GTBYTW
;check for argument in range 0 to 65535
L1672	LDA	PS
	BMI	L1612
	LDA	PE
	CMP	#$91
	BCS	L1612
	JSR	FXU
	LDA	PM+2
	LDY	PM+3
	STY	INLNNM
	STA	INLNNM+1
	RTS
;execute PEEK(x)
XPEEK	JSR	L1672
	LDY	#0
	LDA	(INLNNM),Y
	TAY
	JMP	L1227
;execute POKE x,y
XPOKE	JSR	L1666
	TXA
	LDY	#0
	STA	(INLNNM),Y
	RTS
;execute WAIT x,y,z
XWAIT	JSR	L1666		;get first two args
	STX	FNXPNT		;save byte part
	LDX	#0		;preset for zero
	JSR	GTCWOI		;get without bump
	BEQ	*+5		;use zero if eol
	JSR	L166C		;else get z
	STX	FNXPNT+1	;and save
	LDY	#0		;clear index
XWAITL	LDA	(INLNNM),Y	;get byte at address
	EOR	FNXPNT+1	;exclusive or with z
	AND	FNXPNT		;then and with y
	BEQ	XWAITL		;loop if zero
	RTS
;execute TRAP
XTRAP	JSR	L096C		;convert line number
	JSR	L090A		;scan for eol
	LDA	INLNNM
	BNE	L16A8
	LDA	INLNNM+1
L16A8	STA	TRPFLG		;set flag
	LDA	INLNNM
	STA	TRPLIN		;then line
	LDA	INLNNM+1
	STA	TRPLIN+1
	LDA	#0
L16B7	RTS
;add one half to primary accum
L16B8	LDA	#<HALF		;point to 0.5
	LDY	#>HALF
	JMP	APA
;subtract primary accum from memory
SPA	JSR	LSA
;subtract primary accum from secondary
L16C2	LDA	PS
	EOR	#$FF
	STA	PS
	EOR	SS
	STA	SGNCMP
	LDA	PE
	JMP	L16D9
L16D1	JSR	L183A
	BCC	L1712
APA	JSR	LSA
L16D9	BNE	L16DE
	JMP	TSP
L16DE	LDX	PR
	STX	FUNJMP+2
	LDX	#<SE		;point to secondary
	LDA	SE
L16E6	TAY
	BEQ	L16B7
	SEC
	SBC	PE
	BEQ	L1712
	BCC	L1702
	STY	PE
	LDY	SS
	STY	PS
	EOR	#$FF
	ADC	#0
	LDY	#0
	STY	FUNJMP+2
	LDX	#PE		;point to primary
	BNE	L1706
L1702	LDY	#0
	STY	PR
L1706	CMP	#$F9
	BMI	L16D1
	TAY
	LDA	PR
	LSR	$01,X
	JSR	L1853
L1712	BIT	SGNCMP
	BPL	L176D
	LDY	#<PE
	CPX	#<SE
	BEQ	L171E
	LDY	#<SE
L171E	SEC
	EOR	#$FF
	ADC	FUNJMP+2
	STA	PR
	LDA	4,Y
	SBC	4,X
	STA	PM+3
	LDA	3,Y
	SBC	3,X
	STA	PM+2
	LDA	2,Y
	SBC	2,X
	STA	PM+1
	LDA	1,Y
	SBC	1,X
	STA	PM
L1741	BCS	L1746
	JSR	TWCPRM
L1746	LDY	#0
	TYA
	CLC
L174A	LDX	PM
	BNE	L1798
	LDX	PM+1
	STX	PM
	LDX	PM+2
	STX	PM+1
	LDX	PM+3
	STX	PM+2
	LDX	PR
	STX	PM+3
	STY	PR
	ADC	#8
	CMP	#32		;see if too small
	BNE	L174A
L1766	LDA	#0
L1768	STA	PE
L176A	STA	PS
	RTS
;add two values
L176D	ADC	FUNJMP+2
	STA	PR
	LDA	PM+3
	ADC	SM+3
	STA	PM+3
	LDA	PM+2
	ADC	SM+2
	STA	PM+2
	LDA	PM+1
	ADC	SM+1
	STA	PM+1
	LDA	PM
	ADC	SM
	STA	PM
	JMP	L17A5
L178C	ADC	#1
	ASL	PR
	ROL	PM+3
	ROL	PM+2
	ROL	PM+1
	ROL	PM
L1798	BPL	L178C
	SEC
	SBC	PE
	BCS	L1766
	EOR	#$FF
	ADC	#1
	STA	PE
L17A5	BCC	L17E7
L17A7	INC	PE
	BEQ	OVFERR
	ROR	PM
	ROR	PM+1
	ROR	PM+2
	ROR	PM+3
	ROR	PR
L17E7	RTS
;do two's complement of primary accum
TWCPRM	LDA	PS
	EOR	#$FF
	STA	PS
L17EE	LDA	PM
	EOR	#$FF
	STA	PM
	LDA	PM+1
	EOR	#$FF
	STA	PM+1
	LDA	PM+2
	EOR	#$FF
	STA	PM+2
	LDA	PM+3
	EOR	#$FF
	STA	PM+3
	LDA	PR
	EOR	#$FF
	STA	PR
	INC	PR
	BNE	L181E
L1810	INC	PM+3
	BNE	L181E
	INC	PM+2
	BNE	L181E
	INC	PM+1
	BNE	L181E
	INC	PM
L181E	RTS
;overflow error
OVFERR	LDX	#$0A
	JMP	XERR
SHQR8	LDX	#QM-1		;point to quotient
SHXR8	LDY	4,X
	STY	PR
	LDY	3,X
	STY	4,X
	LDY	2,X
	STY	3,X
	LDY	1,X
	STY	2,X
	LDY	PC
	STY	1,X
L183A	ADC	#8
	BMI	SHXR8
	BEQ	SHXR8
	SBC	#8
	TAY
	LDA	PR
	BCS	L1883
L1847	PHA
	LDA	1,X
	AND	#$80
	LSR	1,X
	ORA	1,X
	STA	1,X
	.byte	$24
L1853	PHA
	ROR	2,X
	ROR	3,X
	ROR	4,X
	PLA
	ROR	A
L1880	INY
	BNE	L1847
L1883	CLC
	RTS
ONE	.byte	$81,0,0,0,0	;one in floating point
LOGCHN	.byte	3
	.byte	$7F,$5E,$56,$CB,$79
	.byte	$80,$13,$9B,$0B,$64
	.byte	$80,$76,$38,$93,$16
	.byte	$82,$38,$AA,$3B,$20
SQR2D2	.byte	$80,$35,$04,$F3,$34
SQR2	.byte	$81,$35,$04,$F3,$34
MHALF	.byte	$80,$80,0,0,0
LN2	.byte	$80,$31,$72,$17,$F8
;execute LOG function
XLOG	JSR	ESP
	BEQ	L18BA
	BPL	L18BD
L18BA	JMP	L10D0
L18BD	LDA	PE
	SBC	#$7F
	PHA
	LDA	#$80
	STA	PE
	LDA	#<SQR2D2	;point to 1/2 square root of 2
	LDY	#>SQR2D2
	JSR	APA
	LDA	#<SQR2		;now point to square root of 2
	LDY	#>SQR2
	JSR	DAP
	LDA	#<ONE		;point to 1
	LDY	#>ONE
	JSR	SPA
	LDA	#<LOGCHN	;point to LOG chain
	LDY	#>LOGCHN
	JSR	SRSAS
	LDA	#<MHALF		;point to -0.5
	LDY	#>MHALF
	JSR	APA
	PLA
	JSR	ADP
	LDA	#<LN2		;point to ln(2)
	LDY	#>LN2
MPA	JSR	LSA
L18F4	BNE	L18F9
	JMP	L1986
L18F9	JSR	SUMPD
	LDA	#0
	STA	QM
	STA	QM+1
	STA	QM+2
	STA	QM+3
	LDA	PR
	JSR	MULNZB
	LDA	PM+3
	JSR	MULNZB
	LDA	PM+2
	JSR	MULNZB
	LDA	PM+1
	JSR	MULNZB
	LDA	PM
	JSR	MULBYT
	JMP	L1A8A
MULNZB	BNE	MULBYT
	JMP	SHQR8
MULBYT	LSR	A
	ORA	#$80
MULLPE	TAY
	BCC	SHONLY
	CLC
	LDA	QM+3
	ADC	SM+3
	STA	QM+3
	LDA	QM+2
	ADC	SM+2
	STA	QM+2
	LDA	QM+1
	ADC	SM+1
	STA	QM+1
	LDA	QM
	ADC	SM
	STA	QM
SHONLY	ROR	QM
	ROR	QM+1
	ROR	QM+2
	ROR	QM+3
	ROR	PR
	TYA
	LSR	A
	BNE	MULLPE
L1986	RTS
;load secondary accum
LSA	STA	ME
	STY	ME+1
LSM	LDY	#4
	LDA	(ME),Y
	STA	SM+3
	DEY
	LDA	(ME),Y
	STA	SM+2
	DEY
	LDA	(ME),Y
	STA	SM+1
	DEY
	LDA	(ME),Y
	STA	SS
	EOR	PS
	STA	SGNCMP
	LDA	SS
	ORA	#$80
	STA	SM
	DEY
	LDA	(ME),Y
	STA	SE
	LDA	PE
	RTS
SUMPD	LDA	SE
L19B4	BEQ	L19D5
	CLC
	ADC	PE
	BCC	L19BF
	BMI	L19DA
	CLC
	.byte	$2C
L19BF	BPL	L19D5
	ADC	#$80
	STA	PE
	BNE	L19CA
	JMP	L176A
L19CA	LDA	SGNCMP
	STA	PS
	RTS
L19CF	LDA	PS
	EOR	#$FF
	BMI	L19DA
L19D5	PLA
	PLA
	JMP	L1766
L19DA	JMP	OVFERR
L19DD	JSR	TPS
	TAX
	BEQ	L19F3
	CLC
	ADC	#2
	BCS	L19DA
	LDX	#0
	STX	SGNCMP
	JSR	L16E6
	INC	PE
	BEQ	L19DA
L19F3	RTS
TEN	.byte	$84,$20,0,0,0	;ten in floating point
L19F9	JSR	TPS
	LDA	#<TEN		;point to 10
	LDY	#>TEN
	LDX	#0
L1A02	STX	SGNCMP
	JSR	LPA
	JMP	L1A0D
DAP	JSR	LSA
L1A0D	BEQ	DV0ERR
	JSR	RNP
	LDA	#0
	SEC
	SBC	PE
	STA	PE
	JSR	SUMPD
	INC	PE
	BEQ	L19DA
	LDX	#$FC
	LDA	#1
L1A24	LDY	SM
	CPY	PM
	BNE	L1A3A
	LDY	SM+1
	CPY	PM+1
	BNE	L1A3A
	LDY	SM+2
	CPY	PM+2
	BNE	L1A3A
	LDY	SM+3
	CPY	PM+3
L1A3A	PHP
	ROL	A
	BCC	L1A47
	INX
	STA	QM+3,X
	BEQ	L1A75
	BPL	L1A79
	LDA	#1
L1A47	PLP
	BCS	L1A58
L1A4A	ASL	SM+3
	ROL	SM+2
	ROL	SM+1
	ROL	SM
	BCS	L1A3A
	BMI	L1A24
	BPL	L1A3A
L1A58	TAY
	LDA	SM+3
	SBC	PM+3
	STA	SM+3
	LDA	SM+2
	SBC	PM+2
	STA	SM+2
	LDA	SM+1
	SBC	PM+1
	STA	SM+1
	LDA	SM
	SBC	PM
	STA	SM
	TYA
	JMP	L1A4A
L1A75	LDA	#$40
	BNE	L1A47
L1A79	ASL	A
	ASL	A
	ASL	A
	ASL	A
	ASL	A
	ASL	A
	STA	PR
	PLP
	JMP	L1A8A
;division by zero error
DV0ERR	LDX	#$14
	JMP	XERR
L1A8A	LDA	QM
	STA	PM
	LDA	QM+1
	STA	PM+1
	LDA	QM+2
	STA	PM+2
	LDA	QM+3
	STA	PM+3
	JMP	L1746
LPA	STA	ME
	STY	ME+1
LPM	LDY	#4
	LDA	(ME),Y
	STA	PM+3
	DEY
	LDA	(ME),Y
	STA	PM+2
	DEY
	LDA	(ME),Y
	STA	PM+1
	DEY
	LDA	(ME),Y
	STA	PS
	ORA	#$80
	STA	PM
	DEY
	LDA	(ME),Y
	STA	PE
	STY	PR
	RTS
L1AC2	LDX	#TEMPN2		;temporary #2
	.byte	$2C
L1AC5	LDX	#TEMPN1		;temporary #1
	LDY	#0
	BEQ	L1ACF
L1ACB	LDX	FNXPNT
	LDY	FNXPNT+1
L1ACF	JSR	RNP
	STX	ME
	STY	ME+1
	LDY	#4
	LDA	PM+3
	STA	(ME),Y
	DEY
	LDA	PM+2
	STA	(ME),Y
	DEY
	LDA	PM+1
	STA	(ME),Y
	DEY
	LDA	PS
	ORA	#$7F
	AND	PM
	STA	(ME),Y
	DEY
	LDA	PE
	STA	(ME),Y
	STY	PR
	RTS
TSP	LDA	SS
L1AF9	STA	PS
	LDX	#5
L1AFD	LDA	PC,X
	STA	DPFLG+1,X
	DEX
	BNE	L1AFD
	STX	PR
	RTS
TPS	JSR	RNP
L1B0A	LDX	#6
L1B0C	LDA	DPFLG+1,X
	STA	PC,X
	DEX
	BNE	L1B0C
	STX	PR
L1B15	RTS
RNP	LDA	PE
	BEQ	L1B15
	ASL	PR
	BCC	L1B15
L1B1E	JSR	L1810
	BNE	L1B15
	JMP	L17A7
ESP	LDA	PE
	BEQ	L1B33
L1B2A	LDA	PS
L1B2C	ROL	A
	LDA	#$FF
	BCS	L1B33
	LDA	#1
L1B33	RTS
XSGN	JSR	ESP
L1B37	STA	PM
	LDA	#0
	STA	PM+1
	LDX	#$88
L1B3F	LDA	PM
	EOR	#$FF
	ROL	A
L1B44	LDA	#0
	STA	PM+3
	STA	PM+2
	STX	PE
	STA	PR
	STA	PS
	JMP	L1741
;execute ABS by setting sign of primary to pos
XABS	LSR	PS
	RTS
CPA	STA	MEMPNT
L1B58	STY	MEMPNT+1
CPM	LDY	#0
	LDA	(MEMPNT),Y
	INY
	TAX
	BEQ	ESP
	LDA	(MEMPNT),Y
	EOR	PS
	BMI	L1B2A
	CPX	PE
	BNE	L1B8D
	LDA	(MEMPNT),Y
	ORA	#$80
	CMP	PM
	BNE	L1B8D
	INY
	LDA	(MEMPNT),Y
	CMP	PM+1
	BNE	L1B8D
	INY
	LDA	(MEMPNT),Y
	CMP	PM+2
	BNE	L1B8D
	INY
	LDA	#$7F
	CMP	PR
	LDA	(MEMPNT),Y
	SBC	PM+3
	BEQ	L1BB5
L1B8D	LDA	PS
	BCC	L1B93
	EOR	#$FF
L1B93	JMP	L1B2C
;convert floating to unsigned fixed point
FXU	LDA	PE
	BEQ	L1BE4
	SEC
	SBC	#$A0
	BIT	PS
	BPL	L1BAA
	TAX
	LDA	#$FF
	STA	PC
	JSR	L17EE
	TXA
L1BAA	LDX	#PE		;point to primary
	CMP	#$F9
	BPL	L1BB6
	JSR	L183A
	STY	PC
L1BB5	RTS
L1BB6	TAY
	LDA	PS
	AND	#$80
	LSR	PM
	ORA	PM
	STA	PM
	JSR	L1853
	STY	PC
	RTS
;execute INT function
XINT	LDA	PE
	CMP	#$A0
	BCS	L1BED
	JSR	FXU
	STY	PR
	LDA	PS
	STY	PS
	EOR	#$80
	ROL	A
	LDA	#$A0
	STA	PE
	LDA	PM+3
	STA	L000A
	JMP	L1741
L1BE4	STA	PM
	STA	PM+1
	STA	PM+2
	STA	PM+3
	TAY
L1BED	RTS
;convert ASCII to floating
FLTASC	LDY	#0
	LDX	#10
L1BF2	STY	DPOFF,X
	DEX
	BPL	L1BF2
	BCC	L1C08
	CMP	#'-'		;see if minus sign
	BNE	L1C01
	STX	NS
	BEQ	L1C05
L1C01	CMP	#'+'		;see if plus sign
	BNE	L1C0A
L1C05	JSR	GETCHR
L1C08	BCC	L1C79
L1C0A	CMP	#'.'		;see if decimal point
	BEQ	L1C46
	CMP	#'E'		;see if E for scientific
	BNE	L1C56
	JSR	GETCHR
	BCC	L1C38
	CMP	#TKMINU		;see if - token
	BEQ	L1C29
	CMP	#'-'		;see if -
	BEQ	L1C29
	CMP	#TKPLUS		;see if + token
	BEQ	L1C35
	CMP	#'+'		;see if +
	BEQ	L1C35
	BNE	L1C3A
L1C29	LDA	#0
	BCC	L1C2F
	LDA	#$80
L1C2F	LSR	DPFLG+1
	ORA	DPFLG+1
	STA	DPFLG+1
L1C35	JSR	GETCHR
L1C38	BCC	L1CA0
L1C3A	BIT	DPFLG+1
	BPL	L1C56
	LDA	#0
	SEC
	SBC	NE
	JMP	L1C58
L1C46	LDA	#0
	BCC	L1C4C
	LDA	#$80
L1C4C	LSR	DPFLG
	ORA	DPFLG
	STA	DPFLG
	BIT	DPFLG
	BVC	L1C05
L1C56	LDA	NE
L1C58	SEC
	SBC	DPOFF
	STA	NE
	BEQ	L1C71
	BPL	L1C6A
L1C61	JSR	L19F9
	INC	NE
	BNE	L1C61
	BEQ	L1C71
L1C6A	JSR	L19DD
	DEC	NE
	BNE	L1C6A
L1C71	LDA	NS
	BMI	L1C76
	RTS
L1C76	JMP	L1E88
L1C79	PHA
	BIT	DPFLG
	BPL	L1C80
	INC	DPOFF
L1C80	JSR	L19DD
	PLA
	SEC
	SBC	#'0'		;make a number
	JSR	ADP
	JMP	L1C05
ADP	PHA
	JSR	TPS
	PLA
	JSR	L1B37
	LDA	SS
	EOR	PS
	STA	SGNCMP
	LDX	PE
	JMP	L16D9
L1CA0	LDA	NE
	CMP	#10
	BCC	L1CAF
	LDA	#100
	BIT	DPFLG+1
	BMI	L1CBD
	JMP	OVFERR
L1CAF	ASL	A
	ASL	A
	CLC
	ADC	NE
	ASL	A
	CLC
	LDY	#0
	ADC	(CHRPNT),Y
	SEC
	SBC	#'0'		;make a number
L1CBD	STA	NE
	JMP	L1C35
L1CC2	.byte	$9B,$3E,$BC,$1F,$FD
L1CC7	.byte	$9E,$6E,$6B,$27,$FD
L1CCC	.byte	$9E,$6E,$6B,$28,0
PRIMLN	LDA	#<INMSG		;point to IN message
	LDY	#>INMSG
	JSR	STROUT		;send message
PRLNNM	LDA	CURLNM+1
	LDX	CURLNM
PRAX	STA	PM
	STX	PM+1
	LDX	#$90
	SEC
	JSR	L1B44
	JSR	FLTOUT
	JMP	STROUT
;convert floating point to string
FLTOUT	LDY	#1
L1CEE	LDA	#' '		;preset for positive
	BIT	PS
	BPL	L1CF6
	LDA	#'-'		;is minus
L1CF6	STA	$FF,Y
	STA	PS
	STY	CNVIND
	INY
	LDA	#'0'		;get a zero
	LDX	PE
	BNE	L1D07
	JMP	L1E0F
L1D07	LDA	#0
	CPX	#$80
	BEQ	L1D0F
	BCS	L1D18
L1D0F	LDA	#<L1CCC		;point to constant
	LDY	#>L1CCC
	JSR	MPA
	LDA	#$F7
L1D18	STA	DPOFF
L1D1A	LDA	#<L1CC7		;next constant
	LDY	#>L1CC7
	JSR	CPA
	BEQ	L1D41
	BPL	L1D37
L1D25	LDA	#<L1CC2		;next constant
	LDY	#>L1CC2
	JSR	CPA
	BEQ	L1D30
	BPL	L1D3E
L1D30	JSR	L19DD
	DEC	DPOFF
	BNE	L1D25
L1D37	JSR	L19F9
	INC	DPOFF
	BNE	L1D1A
L1D3E	JSR	L16B8
L1D41	JSR	FXU
	LDX	#1
	LDA	DPOFF
	CLC
	ADC	#10
	BMI	L1D56
	CMP	#11
	BCS	L1D57
	ADC	#$FF
	TAX
	LDA	#2
L1D56	SEC
L1D57	SBC	#2
	STA	NE
	STX	DPOFF
	TXA
	BEQ	L1D62
	BPL	L1D75
L1D62	LDY	CNVIND
	LDA	#'.'		;get decimal point
	INY
	STA	$FF,Y
	TXA
	BEQ	L1D73
	LDA	#'0'		;get ASCII 0
	INY
	STA	$FF,Y
L1D73	STY	CNVIND
L1D75	LDY	#0
	LDX	#$80
L1D79	LDA	PM+3
	CLC
	ADC	L1E24,Y
	STA	PM+3
	LDA	PM+2
	ADC	L1E23,Y
	STA	PM+2
	LDA	PM+1
	ADC	L1E22,Y
	STA	PM+1
	LDA	PM
	ADC	L1E21,Y
	STA	PM
	INX
	BCS	L1D9D
	BPL	L1D79
	BMI	L1D9F
L1D9D	BMI	L1D79
L1D9F	TXA
	BCC	L1DA6
	EOR	#$FF
	ADC	#10
L1DA6	ADC	#'0'-1
	INY
	INY
	INY
	INY
	STY	CURVAD
	LDY	CNVIND
	INY
	TAX
	AND	#$7F
	STA	$FF,Y
	DEC	DPOFF
	BNE	L1DC1
	LDA	#'.'		;get decimal point
	INY
	STA	$FF,Y
L1DC1	STY	CNVIND
	LDY	CURVAD
	TXA
	EOR	#$FF
	AND	#$80
	TAX
	CPY	#$24
	BNE	L1D79
	LDY	CNVIND
L1DD1	LDA	$FF,Y
	DEY
	CMP	#'0'		;see if 0
	BEQ	L1DD1
	CMP	#'.'		;see if decimal
	BEQ	L1DDE
	INY
L1DDE	LDA	#'+'		;get plus sign
	LDX	NE
	BEQ	L1E12
	BPL	L1DEE
	LDA	#0
	SEC
	SBC	NE
	TAX
	LDA	#'-'		;get minus sign
L1DEE	STA	$101,Y
	LDA	#'E'		;get E for scientific
	STA	$100,Y
	TXA
	LDX	#'0'-1		;get one under 0
	SEC
L1DFA	INX
	SBC	#10
	BCS	L1DFA
	ADC	#'9'+1
	STA	$103,Y
	TXA
	STA	$102,Y
	LDA	#0
	STA	$104,Y
	BEQ	L1E17
L1E0F	STA	$FF,Y
L1E12	LDA	#0
	STA	$100,Y
L1E17	LDA	#0
	LDY	#$01
	RTS
;0.5 in floating point
HALF	.byte	$80,0,0,0,0
L1E21	.byte	$FA
L1E22	.byte	$0A
L1E23	.byte	$1F
L1E24	.byte	$00
	.byte	$00
	.byte	$98
	.byte	$96
	.byte	$80
	.byte	$FF
	.byte	$F0
	.byte	$BD
	.byte	$C0
	.byte	$00
	.byte	$01
	.byte	$86
	.byte	$A0
	.byte	$FF
	.byte	$FF
	.byte	$D8
	.byte	$F0
	.byte	$00
	.byte	$00
	.byte	$03
	.byte	$E8
	.byte	$FF
	.byte	$FF
	.byte	$FF
	.byte	$9C
	.byte	$00
	.byte	$00
	.byte	$00
	.byte	$0A
	.byte	$FF
	.byte	$FF
	.byte	$FF
	.byte	$FF
XSQR	JSR	TPS
	LDA	#<HALF		;point to .5
	LDY	#>HALF
	JSR	LPA
;entry for ^ in expression
L1E4F	BEQ	XEXP
	LDA	SE
	BNE	L1E58
	JMP	L1768
L1E58	LDX	#L009B
	LDY	#0
	JSR	L1ACF
	LDA	SS
	BPL	L1E72
	JSR	XINT
	LDA	#L009B
	LDY	#0
	JSR	CPA
	BNE	L1E72
	TYA
	LDY	L000A
L1E72	JSR	L1AF9
	TYA
	PHA
	JSR	XLOG
	LDA	#L009B
	LDY	#0
	JSR	MPA
	JSR	XEXP
	PLA
	LSR	A
	BCC	L1E92
L1E88	LDA	PE
	BEQ	L1E92
	LDA	PS
	EOR	#$FF
	STA	PS
L1E92	RTS
LN2INV	.byte	$81,$38,$AA,$3B,$29
EXPCHN	.byte	7
	.byte	$71,$34,$58,$3E,$56
	.byte	$74,$16,$7E,$B3,$1B
	.byte	$77,$2F,$EE,$E3,$85
	.byte	$7A,$1D,$84,$1C,$2A
	.byte	$7C,$63,$59,$58,$0A
	.byte	$7E,$75,$FD,$E7,$C6
	.byte	$80,$31,$72,$18,$10
	.byte	$81,0,0,0,0
XEXP	LDA	#<LN2INV	;point to 1/ln(2)
	LDY	#>LN2INV
	JSR	MPA
	LDA	PR
	ADC	#$50
	BCC	L1ED1
	JSR	L1B1E
L1ED1	STA	FUNJMP+2
	JSR	L1B0A
	LDA	PE
	CMP	#$88
	BCC	L1EDF
L1EDC	JSR	L19CF
L1EDF	JSR	XINT
	LDA	L000A
	CLC
	ADC	#$81
	BEQ	L1EDC
	SEC
	SBC	#1
	PHA
	LDX	#5
L1EEF	LDA	SE,X
	LDY	PE,X
	STA	PE,X
	STY	SE,X
	DEX
	BPL	L1EEF
	LDA	FUNJMP+2
	STA	PR
	JSR	L16C2
	JSR	L1E88
	LDA	#<EXPCHN	;point to series
	LDY	#>EXPCHN
	JSR	SRSA
	LDA	#0
	STA	SGNCMP
	PLA
	JSR	L19B4
	RTS
;series evaluation for squared arguments
SRSAS	STA	CNVIND
	STY	CNVIND+1
	JSR	L1AC5
	LDA	#TEMPN1		;point to temp 1
	JSR	MPA
	JSR	L1F2E
	LDA	#TEMPN1		;point to temp 1
	LDY	#0
	JMP	MPA
;series evaluation for unsquared arguments
SRSA	STA	CNVIND
	STY	CNVIND+1
L1F2E	JSR	L1AC2
	LDA	(CNVIND),Y
	STA	NS
	LDY	CNVIND
	INY
	TYA
	BNE	L1F3D
	INC	CNVIND+1
L1F3D	STA	CNVIND
	LDY	CNVIND+1
L1F41	JSR	MPA
	LDA	CNVIND
	LDY	CNVIND+1
	CLC
	ADC	#5
	BCC	L1F4E
	INY
L1F4E	STA	CNVIND
	STY	CNVIND+1
	JSR	APA
	LDA	#TEMPN2		;point to temp 2
	LDY	#0
	DEC	NS
	BNE	L1F41
L1F5D	RTS
L1F5E	.byte	$98,$35,$44,$7A
L1F62	.byte	$68,$28,$B1,$46
;execute RND function
XRND	JSR	ESP
	TAX
	BMI	L1F84
	LDA	#<RNDWRK	;point to work area
	LDY	#>rndwrk
	JSR	LPA
	TXA
	BEQ	L1F5D
	LDA	#<L1F5E		;point to one constant
	LDY	#>L1F5E
	JSR	MPA
	LDA	#<L1F62		;next contstant
	LDY	#>L1F62
	JSR	APA
L1F84	LDX	PM+3
	LDA	PM
	STA	PM+3
	STX	PM
	LDA	#0
	STA	PS
	LDA	PE
	STA	PR
	LDA	#$80
	STA	PE
	JSR	L1746
	LDX	#<RNDWRK	;point to area
	LDY	#>rndwrk
L1F9F	JMP	L1ACF
;execute COS function
XCOS	LDA	#<PI2		;point to pi/2
	LDY	#>PI2
	JSR	APA
;execute SIN function
XSIN	JSR	TPS
	LDA	#<TWOPI		;point to two pi
	LDY	#>TWOPI
	LDX	SS
	JSR	L1A02
	JSR	TPS
	JSR	XINT
	LDA	#0
	STA	SGNCMP
	JSR	L16C2
	LDA	#<QUARTR	;point to .25
	LDY	#>QUARTR
	JSR	SPA
	LDA	PS
	PHA
	BPL	L1FDB
	JSR	L16B8
	LDA	PS
	BMI	L1FDE
	LDA	L0013
	EOR	#$FF
	STA	L0013
L1FDB	JSR	L1E88
L1FDE	LDA	#<QUARTR	;point to .25
	LDY	#>QUARTR
	JSR	APA
	PLA
	BPL	L1FEB
	JSR	L1E88
L1FEB	LDA	#<SINCHN	;point to SIN series
	LDY	#>SINCHN
	JMP	SRSAS
XTAN	JSR	L1AC5
	LDA	#0
	STA	L0013
	JSR	XSIN
	LDX	#L009B		;point to save loc
	LDY	#0
	JSR	L1F9F
	LDA	#TEMPN1		;point to temp 1
	LDY	#0
	JSR	LPA
	LDA	#0
	STA	PS
	LDA	L0013
	JSR	L201A
	LDA	#L009B		;point to save loc
	LDY	#0
	JMP	DAP
L201A	PHA
	JMP	L1FDB
PI2	.byte	$81,$49,$0F,$DA,$A2
TWOPI	.byte	$83,$49,$0F,$DA,$A2
QUARTR	.byte	$7F,0,0,0,0
SINCHN	.byte	5
	.byte	$84,$E6,$1A,$2D,$1B
	.byte	$86,$28,$07,$FB,$F8
	.byte	$87,$99,$68,$89,$01
	.byte	$87,$23,$35,$DF,$E1
	.byte	$86,$A5,$5D,$E7,$28
	.byte	$83,$49,$0F,$DA,$A2
	.byte	$A6
	.byte	$D3
	.byte	$C1
	.byte	$C8
	.byte	$D4
	.byte	$C8
	.byte	$D5
	.byte	$C4
	.byte	$CE
	.byte	$CA
;execute ATN function
XATN	LDA	PS
	PHA
	BPL	LL205E
	JSR	L1E88
LL205E	LDA	PE
	PHA
	CMP	#$81
	BCC	L206C
	LDA	#<ONE		;point to one
	LDY	#>ONE
	JSR	DAP
L206C	LDA	#<ATNCHN	;point to chain
	LDY	#>ATNCHN
	JSR	SRSAS
	PLA
	CMP	#$81
	BCC	L207F
LL2078	LDA	#<PI2		;point to pi/2
	LDY	#>PI2
	JSR	SPA
L207F	PLA
	BPL	L2085
	JMP	L1E88
L2085	RTS
ATNCHN	.byte	$0B
	.byte	$76,$B3,$83,$BD,$D3
	.byte	$79,$1E,$F4,$A6,$F5
	.byte	$7B,$83,$FC,$B0,$10
	.byte	$7C,$0C,$1F,$67,$CA
	.byte	$7C,$DE,$53,$CB,$C1
	.byte	$7D,$14,$64,$70,$4C
	.byte	$7D,$B7,$EA,$51,$7A
	.byte	$7D,$63,$30,$88,$7E
	.byte	$7E,$92,$44,$99,$3A
	.byte	$7E,$4C,$CC,$91,$C7
	.byte	$7F,$AA,$AA,$AA,$13
	.byte	$81,0,0,0,0
;initialize$disk$buffer
INTDBF	LDY	#127
	LDA	#EOF
L030	STA	(BUFFER),Y	;insert eof
	DEY
	BPL	L030
	RTS
;buffer$status$byte
BUFSTB	LDY	#33
	LDA	(FILADR),Y	;return fcb(33)
	RTS
;set$buffer$status$byte(byte)
STBFSB	LDY	#33
	STA	(FILADR),Y	;fcb(33)=status
	RTS
;write$mark
WRTMRK	JSR	BUFSTB
	AND	#1		;set flags
	RTS
;set$write$mark
SWRMRK	JSR	BUFSTB
	ORA	#1
	BNE	STBFSB
;clear$write$mark
CWRMRK	JSR	BUFSTB
	AND	#%11111110
	JMP	STBFSB
;active$buffer
ACTBUF	JSR	BUFSTB
	LSR	A
	AND	#1
	RTS
;set$buffer$inactive
SETBFI	JSR	BUFSTB
	AND	#%11111001
	JMP	STBFSB
;set$buffer$active
SETBFA	JSR	BUFSTB
	ORA	#%00000010
	BNE	STBFSB
;set$random$mode
SETRAN	JSR	BUFSTB
	ORA	#%10000000
	BNE	STBFSB
;random$mode
RANMDE	JSR	BUFSTB
	ROL	A
	ROL	A
	AND	#1
	RTS
;store$rec$ptr
STRRPT	LDY	#36
	LDA	RCRPNT
	STA	(FILADR),Y	;fcb(36)=recordpointer
	RTS
;disk$eof
DSKEOF	LDA	EOFADR
	ORA	EOFADR+1	;if eofaddr <> 0
	BNE	*+7		;then ok
	LDX	#$34		;else eof error
	JMP	XERR
	LDA	RCRPNT		;if record$pointer=0
	BEQ	L031		;then
	JSR	BUFSTB		;else buffer$status$byte or 4
	ORA	#%00000100
	JSR	STBFSB
L031	DEC	RCRPNT		;record$pointer=record$pointer-1
	JSR	STRRPT		;store$rec$ptr
	JSR	STIOCN		;set I/O to console
	JSR	L0695		;restore stack
	LDA	EOFADR		;set line number
	LDY	EOFADR+1
	STA	INLNNM
	STY	INLNNM+1
	LDA	#$FF		;make immediate
	STA	CURLNM+1
	JSR	L08AC		;do GOTO
	JMP	L07B4		;and execute
;fill$file$buffer
FILFBF	JSR	DSKRDE		;if diskread <> 0
	BNE	*+5		;then
	JMP	SETBFA		;else set$buffer$active
	JSR	RANMDE		;if random$mode
	BNE	*+5		;then
	JMP	DSKEOF		;else disk$eof
	JSR	INTDBF		;initialize$disk$buffer
	JSR	SETBFA		;set$buffer$active
	LDY	#32
	LDA	(FILADR),Y
	CLC
	ADC	#1
	STA	(FILADR),Y	;fcb(32):=fcb(32)+1
	RTS
;write$disk$if$req
WDIFRQ	JSR	WRTMRK		;if not write$mark
	BEQ	L032		;then just set recordpointer
	JSR	BUFSTB		;else
	AND	#4
	BEQ	L033		;if not shr(buffer$status$byte,2) then
	LDY	#32
	LDA	(FILADR),Y
	BEQ	L034		;if zero do not subtract
	SEC
	SBC	#1
	STA	(FILADR),Y	;else fcb(32):=fcb(32)-1
L034	JSR	BUFSTB
	AND	#%11111011
	JSR	STBFSB
L033	JSR	DSKWRT
	BEQ	*+7		;if ok then
	LDX	#$2E		;else disk write error
	JMP	XERR
	JSR	CWRMRK		;clear$write$mark
	JSR	RANMDE
	BEQ	*+8		;if not$random$mode then
	JSR	SETBFI		;set$buffer$inactive
	JMP	L032
	JSR	INTDBF		;initialize$disk$buffer
L032	LDA	#0
	STA	RCRPNT		;recordpointer:=0
	RTS
;at$end$disk$buffer
;if at end of disk buffer then N=1 (i.e., minus)
ATENDB	INC	RCRPNT		;recordpointer:=recordpointer+1
	RTS
;var$block$size
VARBSZ	LDA	BLKSZE
	ORA	BLKSZE+1
	BNE	*+5		;if blocksize <> 0 then
	LDA	#FALSE		;else
	RTS
	LDA	#TRUE
	RTS
;write$a$byte(char)
WRABYT	PHA			;save char
	JSR	VARBSZ		;if not var$block$size
	BEQ	L035		;then ok
	INC	BYTSWR
	BNE	*+5
	INC	BYTSWR+1	;byteswritten:=byteswritten+1
	LDA	BLKSZE
	CMP	BYTSWR
	LDA	BLKSZE+1
	SBC	BYTSWR+1	;if blocksize >= byteswritten
	BCS	L035		;then ok
	LDX	#$32		;else record size error
	JMP	XERR
L035	JSR	ATENDB		;if not at$end$disk$buffer
	BPL	*+5		;then
	JSR	WDIFRQ		;else write$disk$if$req
	JSR	ACTBUF		;if active$buffer
	BNE	L036		;then
	JSR	RANMDE		;or if not random$mode
	BEQ	L036		;then
	JSR	FILFBF		;else fill$file$buffer
	LDY	#32
	LDA	(FILADR),Y
	SEC
	SBC	#1
	STA	(FILADR),Y	;fcb(32):=fcb(32)-1
L036	PLA			;get char
	LDY	RCRPNT		;get recordpointer
	STA	(BUFFER),Y	;nextdiskchar:=char
	JMP	SWRMRK		;set$write$mark
;get$disk$char
GTDSCH	JSR	ATENDB		;if not at$end$disk$buffer
	BPL	L041		;then
	JSR	WDIFRQ		;else write$disk$if$req
	JSR	FILFBF		;fill$file$buffer
L041	JSR	ACTBUF		;if active$buffer
	BNE	*+5		;then
	JSR	FILFBF		;else fill$file$buffer
	LDY	RCRPNT		;get index
	LDA	(BUFFER),Y	;if nextdiskchar
	CMP	#EOF		;<> eoffiller
	BNE	L041A		;then
	JMP	DSKEOF		;else disk$eof
L041A	RTS
;fixed point multiply
;multiply PX,PX+1 by AY and retunr result in AY
MXAP	STA	SX
	STY	SX+1		;s:=ay
	LDA	#0		;clear high
	STA	PX+2
	STA	PX+3
	LDY	#16		;do 16 bits
MXAPL	LDA	PX
	LSR	A		;test lsb
	BCC	MXAPNA		;don't add if clear
	CLC
	LDA	PX+2
	ADC	SX
	STA	PX+2
	LDA	PX+3
	ADC	SX+1
	STA	PX+3
MXAPNA	ROR	PX+3		;shift all right
	ROR	PX+2
	ROR	PX+1
	ROR	PX
	DEY
	BNE	MXAPL		;loop if more
	LDA	PX		;get result
	LDY	PX+1
	RTS
;setup$disk$io
SUDSIO	SEC			;calculate number
	LDA	CURDEV
	SBC	#5
;entry for SAVE and LOAD
SUDDIO	JSR	STFLAD		;set$file$addr
	JSR	STFLPT		;set$file$pointer
	LDA	#0
	STA	BYTSWR
	STA	BYTSWR+1	;bytes$written:=0
	RTS
;random$setup
RANSTU	JSR	VARBSZ		;if var$block$size
	BNE	*+7		;then ok
	LDX	#$3C		;else unblocked file error
	JMP	XERR
	LDA	INLNNM
	ORA	INLNNM+1
	BNE	*+7		;ok if not zero
L038	LDX	#$3E		;else invalid record number
	JMP	XERR
	LDA	INLNNM		;drop by one
	BNE	*+4
	DEC	INLNNM+1
	DEC	INLNNM
	JSR	SETRAN		;set$random$mode
	JSR	SETBFI		;set$buffer$inactive
	JSR	WDIFRQ		;write$disk$if$req
	LDA	BLKSZE
	STA	PX
	LDY	#0
	STY	PX+1		;p:=low(blocksize)
	LDA	INLNNM+1	;ay:=high(record)
	JSR	MXAP		;ay:=ay*p
	STA	RUT2
	STY	RUT2+1		;temp2:=low(blocksize)*high(record)
	LDA	BLKSZE+1
	STA	PX
	LDY	#0
	STY	PX+1		;p:=high(blocksize)
	LDA	INLNNM		;ay:=low(record)
	JSR	MXAP		;ay:=ay*p
	CLC
	ADC	RUT2
	STA	RUT2
	TYA
	ADC	RUT2+1
	STA	RUT2+1		;temp2:=temp2+low(record)*high(blocksize)
	LDA	BLKSZE
	LDY	#0
	STA	PX
	STY	PX+1
	LDA	INLNNM
	JSR	MXAP		;ay:=low(blocksize)*low(record)
	STA	RUT1
	STY	RUT1+1		;temp1:=ay
	STA	RUBC
	CLC
	LDA	RUT1+1
	ADC	RUT2
	STA	RUBC+1		;bytecount:=shl(temp2,8)+temp1
	LDA	BLKSZE+1
	LDY	#0
	STA	PX
	STY	PX+1
	LDA	INLNNM+1
	JSR	MXAP		;ay:=high(blocksize)*high(record)
	STA	RUT3
	STY	RUT3+1		;temp3:=ay
	CLC
	LDA	RUT1+1
	ADC	RUT2
	STA	RUT2
	BCC	*+5
	INC	RUT2+1		;temp2:=temp2+high(temp1)
	LDX	#6
L053	LSR	RUT2+1
	ROR	RUT2
	DEX
	BNE	L053		;temp2:=shr(temp2,6)
	LDA	RUT3
	ASL	A
	ASL	A		;a:=shl(low(temp3),2)
	CLC
	ADC	RUT2
	STA	RUEX		;extent:=a+low(temp2)
	LDA	RUBC
	AND	#$7F		;a:=bytecount and $7f
	TAX
	DEX
	STX	RCRPNT		;recordpointer:=a-1
	JSR	STRRPT		;store$rec$ptr
	LDA	RUBC
	LDY	RUBC+1
	STA	RURC
	STY	RURC+1		;record:=bytecount
	LDX	#7
L039	LSR	RURC+1
	ROR	RURC
	DEX
	BNE	L039		;record:=shr( ,7)
	LDY	#12
	LDA	(FILADR),Y	;a:=fcb(12)
	CMP	RUEX
	BEQ	L040		;if extent = () then
	JSR	CLOSE		;else close
	BPL	*+7		;if ok
	LDX	#$2C		;else file close error
	JMP	XERR
	LDY	#12
	LDA	RUEX
	STA	(FILADR),Y	;fcb(12):=extent
	JSR	SUFLEX		;setup$file$extent
L040	LDA	RURC
	AND	#127
	LDY	#32
	STA	(FILADR),Y	;fcb(32):=low(record) and $7f
	RTS
;verify that I/O is for disk
;will return c=1 if curdev is a disk device (0,6,7,8,9)
VDSKCU	LDX	CURDEV		;get device
	BEQ	ISDSIO		;if zero is disk
VDSKX	CPX	#6
	BCC	E151
	CPX	#9+1
	BCS	NTVDSK
ISDSIO	SEC
	RTS
NTVDSK	CLC
E151	RTS
;end of record for write
EX63	JSR	VARBSZ
	BEQ	EX63B		;if not var$block$size then
	SEC
	LDA	BLKSZE
	LDY	BLKSZE+1
	SBC	#2
	STA	EX63BS
	BCS	*+3
	DEY
	STY	EX63BS+1	;calculate blocksize-2
EX63A	LDA	BYTSWR
	CMP	EX63BS
	LDA	BYTSWR+1
	SBC	EX63BS+1	;if bytes$written >= blocksize-2 then
	BCS	EX63B
	LDA	#' '
	JSR	WRABYT		;else write$a$byte(blank)
	JMP	EX63A
EX63B	LDA	#CR
	JSR	WRABYT
	LDA	#LF
	JSR	WRABYT
	JMP	STRRPT		;store$rec$ptr
;disk$open
DSKOPN	LDA	#8		;set type index
	STA	DOIT
	LDA	NXTFLE		;get file
	ASL	A		;make index
	TAX
	LDA	FILES,X		;set filadr
	LDY	FILES+1,X
	STA	FILADR
	STY	FILADR+1
	CLC
	ADC	#37
	STA	BUFFER
	BCC	*+3
	INY
	STY	BUFFER+1	;buffer:=fileaddr+37
	JSR	SETDMA
	LDY	#11
	LDA	#' '
L023	STA	(FILADR),Y	;fill filename with blanks
	DEY
	BNE	L023
	TYA			;clear A
	STA	(FILADR),Y	;and drive select
	LDY	#12		;clear extent
	STA	(FILADR),Y
	LDY	#32		;and next record
	STA	(FILADR),Y
	INY
	STA	(FILADR),Y	;and buffer status byte
	JSR	L0CCD		;evaluate expression
	JSR	L151D		;set pointers
	TAX			;test length
	BNE	*+5		;ok if not zero
	JMP	DOINER		;else error
	CPX	#2		;if under 2
	BCC	L024		;then skip ahead
	LDY	#1
	LDA	(ME),Y		;get second
	CMP	#':'		;if not colon
	BNE	L024		;then skip ahead
	DEY
	LDA	(ME),Y
	JSR	LWRUPR		;make upper case
	AND	#$F
	STA	(FILADR),Y	;fcb(0)=char(0) and $f
	DEX
	DEX
	STX	DOI		;i:=length
	CLC
	LDA	ME
	ADC	#2
	STA	ME
	BCC	*+4
	INC	ME+1		;address:=address+2
	JMP	L026
L024	STX	DOI
L026	LDA	DOI		;if too long is error
	CMP	#12+1
	BCS	DOINER
	LDA	#255
	STA	DOJ		;j:=-1
L028	INC	DOJ
	LDY	DOJ
	CPY	DOI
	BCS	L037		;if j >= i then
	CPY	#8		;if j >= 8 then
	BCS	L029A
	LDA	(ME),Y		;if char
	JSR	LWRUPR		;make upper case
	JSR	TSTLGL		;make sure legal
	CMP	#'.'		;is .
	BEQ	L029		;then
	INY
	STA	(FILADR),Y
	JMP	L028
L029A	LDA	(ME),Y		;get char
	CMP	#'.'		;must be .
	BNE	DOINER		;error if not
L029	INC	DOJ
	INC	DOIT
	LDY	DOJ
	CPY	DOI		;if j >= i
	BCS	L037		;then done
	LDA	(ME),Y
	JSR	LWRUPR		;convert
	JSR	TSTLGL		;make sure legal
	LDY	DOIT
	STA	(FILADR),Y
	JMP	L029
L037	JSR	SUFLEX		;setup$file$extent
	JSR	INTDBF		;initialize$disk$buffer
	LDA	#128
	LDY	#36
	STA	(FILADR),Y	;set recordpointer
	LDY	#17*2		;word addeessing
	LDA	BLKSZE
	STA	(FILADR),Y
	INY
	LDA	BLKSZE+1
	STA	(FILADR),Y	;save blocksize
	RTS
DOINER	JMP	NMEERR		;name error
;verify that device/file in X is OPEN and if not do error
VEROPN	PHP			;save flags
	PHA			;and accum
	LDA	DEVSTS,X	;get status
	BEQ	*+5		;it isn't OPEN
	PLA			;get accum
	PLP			;and flags
	RTS
	LDX	#$24		;file not OPEN error
	JMP	XERR
;execute IF END #
XIFEND	BEQ	XXSNER		;syntax error if eol
	JSR	GTBYTW		;get byte value
	BEQ	XXSNER		;error if now eol
	CPX	#6		;if under 6 is illegal
	BCC	ILLDEV
	CPX	#9+1		;same if over 9
	BCS	ILLDEV
	LDA	#TKTHEN		;must be THEN
	JSR	CHKA
	STX	TKNPNT		;save device number
	JSR	L096C		;convert to line number
	SEC			;make device an index
	LDA	TKNPNT
	SBC	#5
	ASL	A		;then mult by two
	TAX			;make an index
	LDA	INLNNM		;get low
	STA	EOFBRN,X
	LDA	INLNNM+1
	STA	EOFBRN+1,X
	RTS
XXSNER	JMP	ERSN		;syntax error
;get device number and check for illegal
GETDEV	JSR	GTBYTW		;get value w/o bumping
	PHP			;save eol status
	CPX	#0		;see if zero
	BEQ	ILLDEV		;error if is
	CPX	#12		;if over 11
	BCS	ILLDEV		;is error
	PLP			;restore eol status
	RTS
ILLDEV	LDX	#$36		;illegal device error
	JMP	XERR
;OPEN device/file in X
XOPEN	JSR	GETDEV		;get number
	PHP			;save eol status
	LDA	DEVSTS,X	;get status
	AND	#1		;see if OPEN
	BNE	DUOPEN		;error if already is
	LDA	DEVSTS,X	;get again
	ORA	#1		;set lsb
	BMI	OPNEND		;done if not file structured
	PLP			;get eol status
	BEQ	XOSNER		;error if eol
	STA	DEVSTS,X	;and set
	TXA			;else make
	SEC			;6 to 9 into 1 to 4
	SBC	#5
	STA	NXTFLE		;save for later use
	JSR	GTCWOI		;get current char
	CMP	#';'		;see if semicolon
	BNE	L050		;it isn't
	LDX	#0		;so is sequential
	STX	BLKSZE
	STX	BLKSZE+1	;set blocksize to zero
L049	JSR	CHKSC		;advance pointer
	JMP	DSKOPN		;and go open
L050	JSR	CHKCM		;must be comma
	JSR	L0CB9		;get numerical expression
	JSR	L1672		;make sure is 0 to 65535
	LDA	INLNNM+1	;must be >= 2
	BNE	L051		;is ok
	LDA	INLNNM
	CMP	#2
	BCS	L051		;is ok
	LDX	#$40		;else invalid record length error
	JMP	XERR
L051	LDA	INLNNM
	LDY	INLNNM+1
	STA	BLKSZE		;set blocksize
	STY	BLKSZE+1
	JMP	L049		;now finish
OPNEND	PLP			;get eol status
	BNE	XOSNER		;error if more
	STA	DEVSTS,X	;else set
	RTS
;OPEN syntax error
XOSNER	JMP	ERSN		;do syntax error
;duplicate OPEN error
DUOPEN	LDX	#$22
	JMP	XERR
;CLOSE device/file in X
XCLOSE	JSR	GETDEV		;get number
	BNE	XOSNER		;error if more
	JSR	VEROPN		;verify as OPEN
	LDA	DEVSTS,X	;get status
	AND	#128		;clear lsb
	STA	DEVSTS,X	;and save
	BMI	CLSEND		;done if not file structured
	TXA			;make 6 to 9 into 1 to 4
	SEC
	SBC	#5
	JMP	DSKCLS		;then go close
CLSEND	RTS
;disk$close
;close file in A (0 through 4)
DSKCLS	JSR	STFLAD		;first set$file$addr
	JSR	STFLPT		;then set$file$pointers
	JSR	WDIFRQ		;write$disk$if$req
	JSR	CLOSE		;do actual close
	BMI	*+3		;if error
	RTS			;else OK
	LDX	#$2C		;disk CLOSE error
	JMP	XERR
;set$file$addr for file in A (0 through 4)
STFLAD	ASL	A		;make a word index
	TAX
	LDA	FILES,X
	STA	FILADR
	LDA	FILES+1,X
	STA	FILADR+1	;fileaddr:=files(file$number)
	LDA	EOFBRN,X
	STA	EOFADR
	LDA	EOFBRN+1,X
	STA	EOFADR+1	;eofaddr:=eofbranch(file$number)
	RTS
;set$file$pointers
STFLPT	CLC
	LDA	FILADR
	LDY	FILADR+1
	ADC	#37
	STA	BUFFER
	BCC	*+3
	INY
	STY	BUFFER+1	;buffer:=fileaddr+37
	LDY	#17*2		;word addressing
	LDA	(FILADR),Y
	STA	BLKSZE
	INY
	LDA	(FILADR),Y
	STA	BLKSZE+1	;blocksize:=fcbadd(17)
	INY
	LDA	(FILADR),Y
	STA	RCRPNT		;recordpointer=fcb(36)
	JMP	SETDMA
;setup$file$extent
SUFLEX	JSR	OPEN		;if OPEN is ok
	BPL	E22		;then done
	JSR	CREATE		;else create
	BPL	SUFLEX		;loop to open if ok
	LDA	#$38		;else create error
	JMP	XERR
E22	RTS
;set I/O to console
STIOCN	PHA			;save A
	LDA	#1		;device 1
	STA	CURDEV		;set
	PLA			;get A
	RTS
;execute EXIT to DOS/65
XEXIT	JSR	CLSFLS		;first close all open files
	JMP	wrmbte		;and do warm boot
;close all open files
CLSFLS	RTS
;execute USR
XUSR	RTS
;The following routine converts lowercase alpha
;characters to upper case.
LWRUPR	CMP	#'a'		;see if under a
	BCC	NOTLWR
	CMP	#'z'+1		;or over z
	BCS	NOTLWR
	EOR	#$20
NOTLWR	RTS
;Input distributor
INPDST	LDA	CURDEV		;get device
	ASL	A		;make index
	TAX
	LDA	INPTBL,X	;get address
	LDY	INPTBL+1,X
	STA	INPVEC		;and set
	STY	INPVEC+1
	JMP	(INPVEC)	;execute
;Output distributor
OUTDST	PHA			;save byte
	LDA	CURDEV		;get number
	ASL	A		;make index
	TAX
	LDA	OUTTBL,X	;get address
	LDY	OUTTBL+1,X
	STA	OUTVEC		;and set
	STY	OUTVEC+1
	PLA			;get byte
	JMP	(OUTVEC)	;execute
;Input vector table
INPTBL	.word	DSKINP		;default disk
	.word	CNSRDE		;console
	.word	ERSN		;** error
	.word	RDRRDE		;reader
	.word	USERI4		;user defined
	.word	USERI5
	.word	DSKINP		;file I/O
	.word	DSKINP
	.word	DSKINP
	.word	DSKINP
	.word	USERIA		;user defined
	.word	USERIB
;output vector table
OUTTBL	.word	WRABYT		;default disk
	.word	CHROUT		;console
	.word	LSTOUT		;printer
	.word	PNCOUT		;punch
	.word	USERO4		;user defined
	.word	USERO5
	.word	WRABYT		;file I/O
	.word	WRABYT
	.word	WRABYT
	.word	WRABYT
	.word	USEROA		;user defined
	.word	USEROB
;variable storage area
	org	($&$FFFE)+2
;*	=	*/2*2+2		;align on word boundary
INPVEC	.word	0		;input vector
OUTVEC	.word	0		;output vector
CURDEV	.byte	1		;current device number
CURENT	.word	0		;current load address
XBRK	.byte	0		;SYSBRK save locations
YBRK	.byte	0
XOUT	.byte	0		;SYSOUT save locations
YOUT	.byte	0
XIN	.byte	0		;SYSIN save locations
YIN	.byte	0
LECFLG	.byte	0		;printer echo flag
BLKSZE	.word	0		;random file block size
EOFADR	.word	0		;line number for EOF exit
RCRPNT	.byte	0		;record pointer
BYTSWR	.word	0		;bytes written
SX	ds	2		;fixed point accumulators
PX	ds	4
RUT1	ds	2		;temp 1
RUT2	ds	2		;     2
RUT3	ds	2		;     3
RUBC	ds	2		;bytecount
RURC	ds	2		;record
RUEX	ds	1		;extent
EX63BS	.word	0		;blocksize-2 in EX63
NXTFLE	.byte	0		;nextfile
DOI	.byte	0		;i in dskopn
DOIT	.byte	0		;type index
DOJ	.byte	0		;j in dskopn
AUBFPT	.byte	0		;auto command buffer pointer
;RND work area
RNDWRK	ds	5
;TRAP variables
TRPFLG	ds	1		;trap if <> 0
TRPLIN	ds	2		;line to GOTO
;file tables
FILES	.word	FCB0,FCB6,FCB7,FCB8,FCB9
EOFBRN	.word	0,0,0,0,0
;device status table
;If entry is zero, the file/device is not open.  If
;entry is > 127 then file/device need not be OPENed
;or CLOSEd.  If bit zero is one then device is OPEN.
DEVSTS	.byte	0,128,128,128,128,128,0,0,0,0,128,128
;main line input routine
;normal entry is at INPLIN
NEWLIN	JSR	NDCRLF		;send cr and lf
	JMP	INPLIN		;start over
BACKUP	DEX			;dec index
	BPL	INLPE		;jump if ok
INPLIN	LDX	#0		;clear index
INLPE	JSR	INPUT		;get char
	CMP	#CR		;if cr
	BEQ	ENDIN		;then done
	CMP	#CTLX		;if cancel
	BEQ	NEWLIN		;start over
	CMP	#DELETE		;if backspace
	BEQ	BACKUP		;then move back
	CMP	#' '		;if control
	BCC	INLPE		;try again
	CPX	#71		;if index too big
	BCS	TOOBIG		;send bell
	STA	INPBUF,X	;else save
	INX			;bump index
	BNE	INLPE		;and loop
TOOBIG	LDA	#BELL		;get bell
	JSR	SYSOUT		;send
	BNE	INLPE		;and loop
ENDIN	JMP	L0A6D		;end input
;single character input
INPUT	JSR	SYSIN		;get input
	AND	#$7F		;mask parity
	CMP	#CTLO		;if not ctl-O
	BNE	NOTOGL		;skip toggle
	PHA			;else save
	LDA	OUTENB		;get flag
	EOR	#$FF		;toggle
	STA	OUTENB		;save
	PLA			;get char
NOTOGL	RTS
;Break Test
SYSBRK	STX	XBRK		;save X
	STY	YBRK		;and Y
	JSR	CHKCST		;test for key
	LDY	YBRK		;restore Y
	LDX	XBRK		;and X
	AND	#$FF		;set flags
	RTS
;Output to DOS/65
SYSOUT	PHA			;save char
	AND	#$7F		;mask parity
	STX	XOUT		;save X
	STY	YOUT		;and Y
	PHA			;save char
	JSR	OUTDST		;send char
	PLA			;get char
	BIT	LECFLG		;if printer off
	BPL	NOLIST		;skip
	LDX	CURDEV		;get current output
	DEX			;see if console
	BNE	NOLIST		;if not no echo
	JSR	LSTOUT		;else send
NOLIST	LDY	YOUT		;restore Y
	LDX	XOUT		;and X
	PLA			;then char
	RTS
;Input from DOS/65
SYSIN	STX	XIN		;save X
	STY	YIN		;and Y
GETCNS	JSR	INPDST		;get char
	CMP	#CTLI		;if not tab
	BNE	NTCTLI		;then exit
	LDA	#' '		;else get space
NTCTLI	CMP	#DELETE		;if not delete
	BNE	NTDELT		;then exit
	PHA			;save delete
	lda	bs		;send a backspace
	jsr	sysout
	lda	#' '		;then a space
	jsr	sysout
	lda	bs		;and another backspace
	jsr	sysout
;	lda	bs		;do another
;	jsr	sysout
;	lda	#' '		;then another space
;	jsr	sysout
;	lda	bs		;and a final
;	jsr	sysout		;backspace
	PLA			;get delete
NTDELT	CMP	#CTLP		;if not ctl-P
	BNE	NTCTLP		;skip toggle
	LDA	LECFLG		;get flag
	EOR	#$FF		;toggle
	STA	LECFLG		;and save
	JMP	GETCNS		;get another
NTCTLP	LDY	YIN		;restore Y
	LDX	XIN		;and X
	AND	#$7F		;set flags
	RTS
;disk input routine
DSKINP	JSR	GTDSCH		;get char
	CMP	#','		;see if a comma
	BNE	*+4		;use if not
	LDA	#CR		;else make a return
	RTS
;Save program in tokenized form.  End of program
;is recognized by three zeros in a row.
XSAVE	BEQ	LDESNR		;error if eol
	LDA	#0		;set to device zero
	STA	CURDEV
	JSR	SUDDIO		;set pointers
	JSR	PRSNME		;get name
	JSR	MAKE		;delete and create
	BMI	DOPNER		;error if can't
	JSR	OPEN		;open it
	BMI	DOPNER		;error if can't
	LDA	BSCSTR		;set record
	LDY	BSCSTR+1	;pointer
	STA	RECADD		;to start
	STY	RECADD+1	;of text
	LDA	#3		;set zero count
	STA	NULCNT		;to three
WRTLPE	LDY	#0		;point to first
WRMVLP	LDA	(RECADD),Y	;get
	STA	BUF0,Y		;and transfer
	BNE	NTWRNL		;if not zero ok
	DEC	NULCNT		;else count down
	BEQ	ENDSVE		;done if zero
	BNE	WRINDN		;else continue
NTWRNL	LDA	#3		;reset
	STA	NULCNT		;counter
WRINDN	INY			;bump index
	BPL	WRMVLP		;and loop
	JSR	DSKWRT		;else write
	BNE	DWRTER		;error exit
	CLC			;else
	LDA	RECADD		;adjust
	ADC	#128		;record
	STA	RECADD		;address
	BCC	WRTLPE		;by 128
	INC	RECADD+1	;and
	BNE	WRTLPE		;loop
ENDSVE	JSR	DSKWRT		;write last record
	BEQ	*+7		;continue if ok
DWRTER	LDX	#$2E		;else DISK WRITE error
	JMP	XERR
	JSR	CLOSE		;try to close
	BPL	*+7		;continue if OK
	LDX	#$2C		;else DISK CLOSE error
	JMP	XERR
	JMP	STIOCN		;point back to console
;Load program in tokenized form.  File is read
;until three zeros in a row are detected.
XLOAD	BNE	*+5		;ok if not end
LDESNR	JMP	ERSN		;else error
	LDA	CURLNM+1	;now check for immediate
	CMP	#$FF
	BNE	LDESNR		;syntax error if not
	LDA	#0		;set file
	STA	CURDEV
	JSR	SUDDIO		;and set pointers
	JSR	PRSNME		;get name
	JSR	OPEN		;open file
	BPL	LDOPOK		;continue if ok
DOPNER	LDX	#$2A		;else DISK OPEN error
	JMP	XERR
LDOPOK	LDA	BSCSTR		;get start
	LDY	BSCSTR+1	;and set
	STA	RECADD		;record
	STY	RECADD+1	;address
	LDA	#3		;set zero
	STA	NULCNT		;to three
LDELPE	JSR	DSKRDE		;read record
	BEQ	*+7		;continue if ok
	LDX	#$28		;else DISK READ error
	JMP	XERR
	TAY			;clear index
NXTLDE	TYA			;add index
	CLC			;to
	ADC	RECADD		;record start
	STA	CURENT		;to
	LDX	RECADD+1	;make
	BCC	NOLDCY		;current
	INX			;load
NOLDCY	STX	CURENT+1	;address
	CMP	MEMLMT		;if it is
	TXA			;too high
	SBC	MEMLMT+1	;then
	BCS	LOADER		;is wrong
	LDA	BUF0,Y		;else get byte
	STA	(RECADD),Y	;and move
	BNE	NTLDNL		;if zero
	DEC	NULCNT		;drop count
	BEQ	LDEEND		;done if zero
	BNE	LDINUP		;else go to next
NTLDNL	LDA	#3		;reset
	STA	NULCNT		;count
LDINUP	INY			;bump index
	BPL	NXTLDE		;loop if ok
	CLC			;else
	TYA			;add
	ADC	RECADD		;128
	STA	RECADD		;to
	BCC	LDELPE		;record
	INC	RECADD+1	;address
	BNE	LDELPE		;and loop
LDEEND	LDX	CURENT		;get low
	INX			;add one
	STX	VARSTR		;then
	STX	ARYSTR		;set low
	STX	EMPSTR		;pointers
	BNE	NTENCY		;send carry
	INC	CURENT+1	;to high
NTENCY	LDA	CURENT+1	;get
	STA	VARSTR+1	;and set
	STA	ARYSTR+1	;high
	STA	EMPSTR+1	;pointers
	JSR	STIOCN		;set io back to console
	JMP	RECHAN		;rechain memory
LOADER	LDX	#$32		;RECORD TOO LONG error
	JMP	XERR
;console input routine with auto command buffer read
CNSRDE	BIT	AUTOBF		;test for auto command
	BMI	PEMCNS		;done so get normal
	LDX	AUBFPT		;get pointer
	INC	AUBFPT		;then bump for next
	LDA	AUTOBF,X	;get char
	CMP	#CR		;see if eol
	BNE	ENDABF		;done if not
	SEC			;else disable auto read
	ROR	AUTOBF
ENDABF	RTS
;PEM References
WRMBTE	LDX	#0		;warm boot
	BEQ	PEMGO
;get char from pem console input
PEMCNS	LDX	#1
	BNE	PEMGO
CHROUT	LDX	#2		;console output
	BNE	PEMGO
RDRRDE	LDX	#3		;reader input
	BNE	PEMGO
PNCOUT	LDX	#4		;punch output
	BNE	PEMGO
LSTOUT	LDX	#5		;printer output
	BNE	PEMGO
CHKCST	LDX	#11		;check console
PEMGO	JMP	PEMJMP		;execute
;PEM File References
;open a file
OPEN	LDA	FILADR		;point to fcb
	LDY	FILADR+1
	LDX	#15		;open file
	JMP	PEMJMP
;close a file
CLOSE	LDA	FILADR		;point to fcb
	LDY	FILADR+1
	LDX	#16		;close file
	JMP	PEMJMP
;make a file
MAKE	LDA	FILADR		;point to fcb
	LDY	FILADR+1
	LDX	#19		;delete it
	JSR	PEMJMP
;create a file
CREATE	LDA	FILADR		;point to fcb
	LDY	FILADR+1
	LDX	#22
	JMP	PEMJMP
;diskread
DSKRDE	LDA	FILADR		;point to fcb
	LDY	FILADR+1
	LDX	#20		;read record
	JMP	PEMJMP
;diskwrite
DSKWRT	LDA	FILADR		;point to fcb
	LDY	FILADR+1
	LDX	#21		;write record
	JMP	PEMJMP
;setdma
;set dma address for disk i/o
SETDMA	LDA	BUFFER
	LDY	BUFFER+1	;point to buffer
	LDX	#26
	JMP	PEMJMP
;Parse File Name
PRSNME	LDX	#11		;clear
	LDA	#' '		;all
MRESPC	STA	FCB0,X		;of fcb
	DEX			;name
	BNE	MRESPC		;and type
	INX			;set X to 1
	JSR	GTCWOI		;get first char
	CMP	#'"'		;see if "
	BNE	NMEERR		;error if not
	JSR	GETCHR		;get next char
	BEQ	NMEERR		;error if none
	AND	#%00000111	;else convert
	STA	FCB0		;and set automatic
	LDY	#1		;set y to 1
	LDA	(CHRPNT),Y	;next
	CMP	#':'		;if a colon
	BEQ	GETNME		;then continue
	LDA	#0		;clear
	STA	FCB0		;automatic
	JSR	GTCWOI		;get first char
	JMP	NODRVS		;and skip ahead
GETNME	JSR	GETCHR		;skip colon
GTMRNM	JSR	GETCHR		;get next char
NODRVS	BEQ	NMEERR		;error if zero
	CMP	#'"'		;see if "
	BEQ	ENDALL		;done if is
	CMP	#'.'		;if delimiter
	BNE	NTENNM		;continue if not
	LDX	#9		;set index
	BNE	NXTTYP		;try type
NTENNM	JSR	TSTLGL		;if illegal
	BEQ	NMEERR		;then error
	STA	FCB0,X		;else save
	INX			;indexes
	CPX	#9		;if ok
	BNE	GTMRNM		;try next
ENDNME	LDX	#9		;try type
	JSR	GETCHR		;get next char
	BEQ	NMEERR		;error if zero
	CMP	#'"'		;done if
	BEQ	ENDALL		;a quote
	CMP	#'.'		;if not delimiter
	BNE	NMEERR		;then error
NXTTYP	JSR	GETCHR		;get next char
	BEQ	NMEERR		;error if zero
	CMP	#'"'		;done if
	BEQ	ENDALL		;a quote
	JSR	TSTLGL		;error if
	BEQ	NMEERR		;illegal
	STA	FCB0,X		;else save
	INX			;indexes
	CPX	#12		;if more
	BNE	NXTTYP		;then loop
	JSR	GETCHR		;get next char
	CMP	#'"'		;see if quote
	BNE	NMEERR		;error if not
ENDALL	DEX			;if no input
	BEQ	NMEERR		;error
	LDX	#32		;now
	LDA	#0		;clear
CLRLPE	STA	FCB0,X		;rest
	DEX			;of
	CPX	#11		;fcb
	BNE	CLRLPE		;to zero
	JMP	GETCHR		;advance past quote
NMEERR	LDX	#$26		;ILLEGAL NAME error
	JMP	XERR
;Test For Illegal
TSTLGL	CMP	#' '		;if control
	BCC	BADINP		;then bad
	BEQ	EXTLGL
	CMP	#'?'
	BEQ	EXTLGL
	CMP	#'*'
	BEQ	EXTLGL
	CMP	#'='
	BEQ	EXTLGL
	CMP	#'_'
	BEQ	EXTLGL
	CMP	#'.'
	BEQ	EXTLGL
	CMP	#':'
	BEQ	EXTLGL
	CMP	#';'
	BEQ	EXTLGL
	CMP	#'<'
	BEQ	EXTLGL
	CMP	#'>'
EXTLGL	RTS
BADINP	JMP	NMEERR
;DOS/65 Work Area
bs	.byte	0		;user backspace char
;file work areas
FCB0	ds	37
BUF0	ds	128
FCB6	ds	37
BUF6	ds	128
FCB7	ds	37
BUF7	ds	128
FCB8	ds	37
BUF8	ds	128
FCB9	ds	37
BUF9	ds	128
;Initialization
cold	lda	boot+2		;get user backspace
	sta	getbs+2
getbs	lda	$ff00+55
	sta	bs
	LDX	#5		;fix
FIXJMP	LDA	BOOT,X		;move
	STA	SIMJMP,X	;PEM jump
	DEX			;to high
	BPL	FIXJMP		;memory
	LDX	#$FF
	STX	CURLNM+1	;immediate mode
	TXS
;the following lines initialize the first few bytes of page zero
	LDX	#9
IPZLPE	LDA	PGZBLK,X
	STA	0,X
	DEX
	BPL	IPZLPE
	STA	FUNJMP		;set function JMP opcode
;set terminal widths
	LDA	#132
	STA	MAXPSN
	LDA	#112
	STA	LSTTAB
;now we initialize the scanner
	LDY	#32
ISCLPE	LDA	scnblk-1,Y
	STA	getchr-1,Y
	DEY
	BNE	ISCLPE
	TYA
	STA	PC
	STA	L0065
	STA	NULCNT
	STA	OUTENB
	STA	LINPSN		;zero print position
	STA	TRPFLG		;clear TRAP flag
	PHA
	LDA	#3
	STA	L00A0
	LDA	#STRSTK		;string stack
	STA	L0063
	LDA	PEMJMP+1	;set upper
	LDY	PEMJMP+2	;limit
	STA	STRSTR		;to PEM
	STA	MEMLMT		;start
	STY	STRSTR+1	;address
	STY	MEMLMT+1	;location
	JSR	CRLF		;do a cr and lf
	LDA	#<OPENMS	;point to
	LDY	#>OPENMS	;message
	JSR	STROUT		;send it
	LDX	#<COLD		;set start
	LDY	#>COLD		;to cold
	STX	BSCSTR
	STY	BSCSTR+1
	LDY	#0
	TYA			;insert
	STA	(BSCSTR),Y	;zero
	INC	BSCSTR
	BNE	NOBSCY
	INC	BSCSTR+1
NOBSCY	LDA	BSCSTR
	LDY	BSCSTR+1
	JSR	L041F
	JSR	CRLF
	LDA	MEMLMT
	SEC
	SBC	BSCSTR
	TAX
	LDA	MEMLMT+1
	SBC	BSCSTR+1
	JSR	PRAX
	LDA	#<FREEMS	;point to
	LDY	#>FREEMS	;message
	JSR	STROUT		;send it
	JSR	L0664		;do a NEW
	LDA	#<BUF0
	LDY	#>BUF0
	STA	BUFFER
	STY	BUFFER+1
	JSR	SETDMA
	LDA	#<FCB0
	LDY	#>FCB0
	STA	FILADR
	STY	FILADR+1
	JMP	0
;Messages
FREEMS	.byte	" BYTES FREE",CR, LF
	db	"(EXIT command return to DOS/65)",0
OPENMS	.byte	'DOS/65 (MICROSOFT) BASIC'
	.byte	CR,LF
	.byte	'VERSION 2.02',0
;block of data to load at $00
PGZBLK	JMP	L0474
	JMP	STROUT
	.byte	$47,$10,$20,$B2
;block of data to load at GETCHR
;it consists of the scanner and the RND work area
scnblk	inc	chrpnt		;bump pointer
	bne	*+4
	inc	chrpnt+1
	LDA	$2222		;get char
	cmp	#' '		;see if blank
	beq	*-11		;loop if was
	JSR	LWRUPR		;convert to upper
	CMP	#'9'+1		;see if over 9
	BCS	*+8		;exit if is
	SEC
	SBC	#'0'		;subtract '0'
	SEC
	SBC	#255-'0'+1	;subtract twos complement
	RTS
;RND work area
	.byte	$80,$4F,$C7,$52,$58
	.END
