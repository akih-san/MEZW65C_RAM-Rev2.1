;;;
;;; Universal Monitor 6502 Copyright (C) 2019 Haruo Asano
;;; https://electrelic.com/electrelic/node/1317
;;;
;;; This program is based on Universal Monitor 6502
;;; Programed by Akihito Honda. 2024.10
;;; It has been modified so that it can be assembled using WDC tools
;;;  (Western Design Center, Inc.).
;;;   https://wdc65xx.com/WDCTools
;;;
;;; -- original disassemble sorce code --
;:; https://github.com/zuiko21/minimOS/blob/master/OS/shell/miniMoDA.s
;;;
;;;    Monitor-debugger-assembler shell for minimOS!
;;;    v0.6rc3
;;;    last modified 20220104-1122
;;;    (c) 2016-2022 Carlos J. Santisteban
;;;
;;; Thanks all.
;;;

	pl	0
	pw      132
	chip    65C02
;                inclist on
;;;
;;; MEZW65C_RAM Monitor for WDC65C02
;;;

;;;
;;; Memory
;;;

PRG_B	EQU	$EA00
WORK_B	equ	PRG_B-$200	; $E800
USER_M	equ	$200
COUT_SIZE	equ $80		; 128byte console output buffer
CIN_SIZE	equ COUT_SIZE

ZERO_B	EQU	$0018		; Must fit in ZERO page

STACK	EQU	$FF
USER_SP	equ	STACK

BUFLEN	EQU	16		; Buffer length ( 16 or above )
cpu_id	equ	$00		; memory address $0000 is written CPU ID by PIC

; PIC function code

CONIN_REQ	EQU	$01
CONOUT_REQ	EQU	$02
CONST_REQ	EQU	$03
STROUT_REQ	equ	$04
REQ_DREAD	equ	$05
REQ_DWRITE	equ	$06
STRIN_REQ	equ	$07
WUP_REQ		equ	$ff

NUM_BCALL	equ	7	;out number of BIOS CALL

;;; Constants
CR	EQU	$0D
LF	EQU	$0A
BS	EQU	$08
TAB	EQU	$09
DEL	EQU	$7F
NULL	EQU	$00

	.data
	org	WORK_B
; PIC18F47QXX I/F
UREQ_COM	rmb	1	; unimon CONIN/CONOUT request command
UNI_CHR		rmb	1	; charcter (CONIN/CONOUT) or number of strings
CREQ_COM	rmb	1	; unimon CONIN/CONOUT request command
CBI_CHR		rmb	1	; charcter (CONIN/CONOUT) or number of strings
;disk_drive	rmb	1	;
;disk_track	rmb	2	;
;disk_sector	rmb	2	;
;data_adr	rmb	2	;
;bank		rmb	1	;
;reserve		rmb	1	;
disk_drive	ds	1	;
; support 24bit LBA
disk_lba0	ds	1	; LBA(Logical Block address) ll
disk_lba1	ds	1	; LBA(Logical Block address) lh
disk_lba2	ds	1	; LBA(Logical Block address) hl
disk_lba3	ds	1	; LBA(Logical Block address) ll (always 0)
data_adr	ds	2	; data buffer addres
reserve		ds	1	; data_adr + reserve : 24bit address(for 65816)
data_cnt	ds	1
DPT_E	equ	$

DPT_size	equ	DPT_E-disk_drive

irq_tgl		rmb	1
ZCIN_BP		rmb	2	; Indirect Index conin buffer pointer
ZCOUT_BP	rmb	2	; Indirect Index conout buffer pointer

PT0	RMB	2		; Generic Pointer 0
PT1	RMB	2		; Generic Pointer 1
CNT	RMB	1		; Generic Counter
bk_no	rmb	2
;Go command variable
sav_adr	rmb	2

oper		RMB	2
scan		RMB	2

SADDR	RMB	2		; Set address
DMPPT	RMB	2

COUT_BUF	rmb	COUT_SIZE	; 128byte console output buffer
CIN_BUF		rmb	CIN_SIZE
CIN_CT		rmb	1		; CIN buffer counter
CIN_RP		rmb	1		; CIN buffer Read pointer
CIN_WP		rmb	1		; CIN buffer Write pointer
COUT_CT		rmb	1		; COUT buffer counter
COUT_RP		rmb	1		; COUT buffer Read pointer
COUT_WP		rmb	1		; COUT buffer Write pointer
CONTMP_BUF	rmb	COUT_SIZE
STRIN_CNT	rmb	1

INBUF	RMB	BUFLEN		; Line input buffer
DSADDR	RMB	2		; Dump start address
DEADDR	RMB	2		; Dump end address
DSTATE	RMB	1		; Dump state
GADDR	RMB	2		; Go address
HEXMOD	RMB	1		; HEX file mode
RECTYP	RMB	1		; Record type

ILL_PC	RMB	2

REGSIZ	RMB	1		; Register size
	
CKSUM	RMB	1		; Checksum
HITMP	RMB	1		; Temporary (used in HEXIN)


; disassemble variable
temp		RMB	1
lines		RMB	1
bytes		RMB	1
s_value		RMB	2
e_value		RMB	2
count		RMB	1
vnim_buf	RMB	16	;virtual console buffer for mnemonic

;Go command variable
stp_flg		rmb	1
sav_dat		rmb	2
hit_reg		rmb	2

;;;
;;; Program area
;;;	
	.code
	ORG	PRG_B

CSTART:
;--------- MEZW65C_RAM file header --------------------------
	jmp	COLD_START
	jmp	WSTART

	; uinimon config data
	;
	db	0,0
	; Unique ID
mezID:	db	"MEZW65C",0
	;start program address
start_p:	dw	PRG_B		; start address (Low)
	dw	0		; (high)

	; define Common memory address
PIC_IF:	dw	UREQ_COM	;  Common memory address for PIC (Low)
	dw	0		; (high)

SW_816:	db	0	; 0 : W65C02
			; 1 : W65C816 native mode 
irq_sw	db	1	; 0 : no use IRQ console I/O
			; 1 : use IRQ timer interrupt driven console I/O
reg_tp	dw	reg_tbls	; register save pointer
reg_ts	dw	reg_size	; register table size
nmi_sw	db	1	; 0 : No NMI support, 1: NMI support
bios_sw	db	2	; 0 : standalone program
			; 1 : program call bios command
			; 2 : monitor program (.SYS)
;--------- MEZW65C_RAM file header --------------------------
; user program infomation pointer

u_sw	equ	mezID+0
u_addr	equ	mezID+1

reg_tbls
REGA	db	0		; Accumulator A
REGX	db	0		; Index register X
REGY	db	0		; Index register Y
REGSP	db	0		; Stack pointer SP
REGPC	dw	0		; Program counter PC
REGPSR	db	1		; Processor status register PSR
reg_tble
reg_size	equ reg_tble-reg_tbls

COLD_START:
	sei			; disable interrupt
	cld
	lda	REGSP
	bne	pass_initsp
	
	lda	#STACK
	sta	REGSP
pass_initsp
	tax
	TXS			; set stack pointer

	JSR	INIT
;	LDA	#$00
	STZ	DSADDR
	STZ	DSADDR+1
	STZ	SADDR
	STZ	SADDR+1
	STZ	GADDR
	STZ	GADDR+1
	LDA	#'S'
	STA	HEXMOD

;	LDA	#$00
	STZ	REGA
	STZ	REGX
	STZ	REGY
	lda	#$20
	STA	REGPSR
	lda	#USER_M
	STA	REGPC
	stz	REGPC+1
	sta	s_value
	stz	s_value+1
	stz	e_value
	stz	e_value+1
	stz	stp_flg

	CLI

	lda	u_sw
	beq	wup_umon
	cmp	#1
	beq	apli_start
;
; sleep moniotr
;
wup
	cli			; enable interrupt
wai_conout
	lda	COUT_CT
	bne	wai_conout	; wait conout buffer empty
	lda	#1
	sta	UNI_CHR		; sleep signal
	jsr	NMI_SIG
	stp

apli_start
	LDX	#USER_SP
	TXS
	jmp	(u_addr)	; application cold start

	;; Opening message
wup_umon
	LDA	#$FF&OPNMSG
	STA	PT0
	LDA	#OPNMSG>>8
	STA	PT0+1
	JSR	STROUT
	bra	prt_prompt

WSTART
	sei			; disable interrupt
	cld
	ldx	REGSP
	txs			; set stack pointer
	cli

prt_prompt
	LDA	#$FF&PROMPT
	STA	PT0
	LDA	#PROMPT>>8
	STA	PT0+1
	JSR	STROUT
	JSR	GETLIN
	LDX	#0
	JSR	SKIPSP
	JSR	UPPER
	CMP	#0
	BEQ	WSTART

	CMP	#'D'
	BNE	M00
	JMP	DUMP
M00
	CMP	#'G'
	BNE	M01
	JMP	GO
M01
	CMP	#'S'
	BNE	M02
	JMP	SETM
M02
	CMP	#'L'
	BNE	M03
	JMP	LOADH
M03
	
	CMP	#'R'
	BNE	M05
	JMP	REG
M05	
	CMP	#'?'
	BNE	M06
	jmp	prt_help

M06
	cmp	#'B'
	bne	ERR
	inx
	LDA	INBUF,X
	JSR	UPPER
	CMP	#'Y'
	bne	ERR
	inx
	LDA	INBUF,X
	JSR	UPPER
	CMP	#'E'
	bne	ERR
	jsr	CRLF


	lda	u_sw
	cmp	#2
	bne	j_wup
	; get DOS/65 cold boot address
	; dos SIM is placed in 256-byte alignment
	lda	#1
	sta	u_sw		; clear DOS/65 Wboot request
	lda	u_addr
	ldy	u_addr+1
	clc
	adc	#3		; get Wboot address
	sta	sim_addr+1
	sty	sim_addr+2
sim_addr
	jmp	$ffff		; DOS/65 Wboot

j_wup
	jmp	wup
ERR
	LDA	#$FF&ERRMSG
	STA	PT0
	LDA	#ERRMSG>>8
	STA	PT0+1
	JSR	STROUT
	JMP	WSTART

;;;
;;; Dump memory
;;;
DUMP
	INX
	JSR	SKIPSP
	JSR	UPPER
	cmp	#'I'
	bne	dmp1
	jmp	disassemble
dmp1
	JSR	RDHEX
	LDA	CNT
	BNE	DP0	; jmp 1st arg.

	; check remain string

	JSR	SKIPSP
	LDA	INBUF,X
	BNE	DP01	; jmp if string exist

	;; No arg.

DP00	; set end address (DSADDR + 128 bytes)

	LDA	DSADDR
	CLC
	ADC	#128
	STA	DEADDR
	LDA	DSADDR+1
	ADC	#0
	STA	DEADDR+1
	JMP	DPM

DP0	;; 1st arg. found

	LDA	PT1
	STA	DSADDR		; set start address(low)
	LDA	PT1+1
	STA	DSADDR+1	; set start address(high)

	JSR	SKIPSP
	LDA	INBUF,X		; get next string
	
DP01	; check exist 2nd arg.

	CMP	#','
	BEQ	DP1		; yes, jmp and chk 2nd arg
	CMP	#0
	BEQ	DP00		; jmp if no 2nd arg.(set end address)
	BRA	ERR

DP1	; chk 2nd arg

	INX
	JSR	SKIPSP
	JSR	RDHEX
	JSR	SKIPSP
	LDA	CNT
	BEQ	ERR

	;; set 2nd arg.

	LDA	PT1
	SEC
	ADC	#0
	STA	DEADDR
	LDA	PT1+1
	ADC	#0
	STA	DEADDR+1

	;; DUMP main
DPM	
	LDA	DSADDR
	AND	#$F0
	STA	PT1
	LDA	DSADDR+1
	STA	PT1+1
;	LDA	#0
	STZ	DSTATE
DPM0
	JSR	DPL
	LDA	PT1
	CLC
	ADC	#16
	STA	PT1
	LDA	PT1+1
	ADC	#0
	STA	PT1+1
	JSR	KEY_CHK
	BNE	DPM1
	LDA	DSTATE
	CMP	#2
	BCC	DPM0
	LDA	DEADDR
	STA	DSADDR
	LDA	DEADDR+1
	STA	DSADDR+1
	JMP	WSTART
DPM1
	LDA	PT1
	STA	DSADDR
	LDA	PT1+1
	STA	DSADDR+1
	JSR	KEY_IN
	JMP	WSTART

	;; Dump line
DPL
	LDA	PT1+1
	JSR	HEXOUT2
	LDA	PT1
	JSR	HEXOUT2
	LDA	#$FF&DSEP0
	STA	PT0
	LDA	#DSEP0>>8
	STA	PT0+1
	JSR	STROUT
	LDX	#0
	LDY	#0
DPL0
	JSR	DPB
	CPX	#16
	BNE	DPL0

	LDA	#$FF&DSEP1
	STA	PT0
	LDA	#DSEP1>>8
	STA	PT0+1
	JSR	STROUT

	;; Print ASCII area
	LDX	#0
DPL1
	LDA	INBUF,X
	CMP	#' '
	BCC	DPL2
	CMP	#$7F
	BCS	DPL2
	JSR	PUT_CH
	JMP	DPL3
DPL2
	LDA	#'.'
	JSR	PUT_CH
DPL3
	INX
	CPX	#16
	BNE	DPL1
	JMP	CRLF

	;; Dump byte
DPB
	LDA	#' '
	JSR	PUT_CH
	LDA	DSTATE
	BNE	DPB2
	;; Dump state 0
	TYA
	SEC
	SBC	DSADDR
	AND	#$0F
	BEQ	DPB1
	;; Still 0 or 2
DPB0
	LDA	#' '
	STA	INBUF,X
	JSR	PUT_CH
	LDA	#' '
	JSR	PUT_CH
	INX
	INY
	RTS
	;; Found start address
DPB1
	LDA	#1
	STA	DSTATE
DPB2
	LDA	DSTATE
	CMP	#1
	BNE	DPB0
	;; Dump state 1
;	LDA	(PT1),Y
	jsr	lda_pt1

	STA	INBUF,X
	JSR	HEXOUT2
	INX
	INY
	TYA
	CLC
	ADC	PT1
	STA	PT0
	LDA	PT1+1
	ADC	#0
	STA	PT0+1
	LDA	PT0
	CMP	DEADDR
	BNE	DPBE
	LDA	PT0+1
	CMP	DEADDR+1
	BNE	DPBE
	;; Found end address
	LDA	#2
	STA	DSTATE
DPBE
	RTS

;++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
; disassemble 
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++
disassemble:
	INX
	JSR	SKIPSP
	JSR	RDHEX
	LDA	CNT

	BNE	PP0	; jmp, if 1st arg. exist

	;; No arg.
	JSR	SKIPSP
	LDA	INBUF,X
	BNE	PP01	; jmp, if remain strings exist

	; no arg.

PP00	; set end parameter
	lda	#16
	sta	lines
	jmp	dis_next

	;; 1st arg. found

PP0	; set start parameter
	LDA	PT1
	sta	s_value		; save start address(low)
	LDA	PT1+1
	STA	s_value+1	; save start address(high)

	; check 2nd parameter exist

	JSR	SKIPSP
	LDA	INBUF,X
PP01
	CMP	#','
	BEQ	PP1		; jmp if 2nd parameter exist
	cmp	#0
	beq	PP00		; jmp if no 2nd parameter

D_ERR
	JMP	ERR

PP1	;; check 2nd arg.

	INX
	JSR	SKIPSP
	JSR	RDHEX
	JSR	SKIPSP
	LDA	CNT
	BEQ	D_ERR
	LDA	INBUF,X
	BNE	D_ERR
	LDA	PT1
	STA	e_value
	LDA	PT1+1
	ADC	#0
	STA	e_value+1
	stz	lines

dis_next:

	LDY	s_value
	LDA	s_value+1
	STY	oper
	STA	oper+1

das_l:

; time to show the opcode and trailing spaces until 20 chars

	JSR	disOpcode	; disassemble one opcode @oper (will print it)
	JSR	KEY_CHK
	BNE	das_end

	lda	lines
	beq	chk_diadr
	dec	lines
	beq	das_end		; continue until done
	bra	das_l

chk_diadr:
	lda	e_value
	cmp	oper
	bcs	das_l

	lda	e_value+1
	cmp	oper+1
	beq	das_end
	bcs	das_l

das_end
	ldy	oper
	lda	oper+1
	sty	s_value
	sta	s_value+1

	JMP	WSTART

; virtual console output for mnemonic characters

vPUT_CH	; input A
	phx
	ldx	count
	sta	vnim_buf,x
	inc	count
	plx
	rts

vHEXOUT2
	PHA
	LSR	A
	LSR	A
	LSR	A
	LSR	A
	JSR	vHEXOUT1
	PLA
vHEXOUT1
	AND	#$0F
	CLC
	ADC	#'0'
	CMP	#'9'+1
	BCC	vHEXOUTE
	CLC
	ADC	#'A'-'9'-1
vHEXOUTE
	bra	vPUT_CH

;------------------------------------------------------
; disassemble one opcode and print it
;------------------------------------------------------
disOpcode:
;	LDA	(oper)		; check pointed opcode
	jsr	lda_d_oper

	STA	count		; keep for comparisons
	LDY	#<da_oclist	; get address of opcode list
	LDA	#>da_oclist
	stz	scan		; indirect-indexed pointer
	STA	scan+1

; proceed normally now

	LDX	#0		; counter of skipped opcodes
do_chkopc:
	CPX	count		; check if desired opcode already pointed
	BEQ	do_found		; no more to skip

do_skip:
;	LDA	(scan),Y		; get char in list
	jsr	lda_scan

	BMI	do_other		; found end-of-opcode mark (bit 7)
	INY
	BNE	do_skip		; next char in list if not crossed
	INC	scan+1		; otherwise correct MSB
	bra	do_skip

do_other:
	INY			; needs to point to actual opcode, not previous end eeeeeek!
	BNE	do_set		; if not crossed
	INC	scan+1		; otherwise correct MSB

do_set:
	INX			; yet another opcode skipped
	BNE	do_chkopc	; until list is done ***should not arrive here***

do_found:
	STY	scan		; restore pointer

;
; decode opcode and print hex dump
;
prnOpcode: ; first goes the current address in label style

	LDA	#' '		; make it self-hosting
	JSR	PUT_CH
	LDA	oper+1		; address MSB
	JSR	HEXOUT2	; print it
	LDA	oper		; same for LSB
	JSR	HEXOUT2

; then extract the opcode string from scan

	LDY	#0		; scan increase, temporarily stored in temp
	STY	bytes		; number of bytes to be dumped (-1)
	STY	count		; printed chars for virtual console buffe

po_loop:
;	LDA	(scan),Y	; get char in opcode list
	jsr	lda_scan

	STY	temp		; keep index as will be destroyed
	AND	#$7F		; filter out possible end mark
	CMP	#'%'		; relative addressing
	BNE	po_nrel		; currently the same as single byte!

; put here specific code for relative arguments!

	LDA	#'$'		; hex radix
	JSR	vPUT_CH

;	lda	(oper)		; check opocde for a moment
	jsr	lda_d_oper

	LDY	#1		; standard branch offset
	LDX	#0		; reset offset sign extention
	AND	#$0F		; watch low-nibble on opcode
	CMP	#$0F		; is it BBR/BBS?
	BNE	po_nobbx		; if not, keep standard offset

	INY			; otherwise needs one more byte!
po_nobbx:
	STY	s_value		; store now as will be added later
	LDY	bytes		; retrieve instruction index
	INY			; point to operand!

;	LDA	(oper),Y	; get offset!
	jsr	lda_oper
	
	STY	bytes		; correct index
	BPL	po_fwd		; forward jump does not extend sign
	DEX			; puts $FF otherwise

po_fwd:
	inc	a		; plus opcode...
	CLC			; (will this and the above instead of SEC fix the error?)
	ADC	s_value		; ...and displacement...
	ADC	oper		; ...from current position
	PHA			; this is the LSB, now check for the MSB
	TXA			; get sign extention
	ADC	oper+1		; add current position MSB plus ocassional carry
	JSR	vHEXOUT2	; show as two ciphers
	PLA			; previously computed LSB
	JSR	vHEXOUT2	; another two
	bra	po_done		; update and continue

po_nrel:
	CMP	#'@'		; single byte operand
	BNE	po_nbyt		; otherwise check word-sized operand

; *** unified 1 and 2-byte operand management ***

	LDY	#1		; number of bytes minus one
	bra	po_disp		; display value

po_nbyt:
	CMP	#'&'		; word operand
	BNE	po_nwd		; otherwise is normal char
	LDY	#2		; number of bytes minus one

po_disp:
; could check HERE for undefined references!!!
	phy			; these are the operand bytes
	STY	bytes		; set counter
	LDA	#'$'		; hex radix
	JSR	vPUT_CH

po_dloop:
	LDY	bytes		; retrieve operand index

;	LDA	(oper),Y		; get whatever byte
	jsr	lda_oper

	JSR	vHEXOUT2	; show in hex
	DEC	bytes		; go back one byte
	BNE	po_dloop
	ply			; restore original operand size
	STY	bytes
	bra	po_adv		; update count (direct from A) and continue

po_nwd:
	JSR	vPUT_CH		; just print it
	bra	po_char

po_done:
po_adv:
po_char:
	LDY	temp		; get scan index

;	LDA	(scan),Y		; get current char again
	jsr	lda_scan

	BMI	po_end		; opcode ended, no more to show
	INY			; go for next char otherwise
	JMP	po_loop		; BNE would work as no opcode string near 256 bytes long, but too far...

po_end: ; output binary code

	ldx	count
	stz	vnim_buf,x	; set mnemonic string termination

; print hex dump as a comment!

po_dump:
	lda	#9		; **
	sta	count		; **
	LDY	#0		; reset index
	STY	temp		; save index (no longer scan)

po_dbyt:
	LDA	#' '		; leading space
	JSR	PUT_CH
	LDY	temp		; retrieve index

;	LDA	(oper),Y	; get current byte in instruction
	jsr	lda_oper

	JSR	HEXOUT2		; show as hex
	lda	count		; **
	sec			; **
	sbc	#3		; **
	sta	count		; **
	INC	temp		; next
	LDX	bytes		; get limit (-1)
	INX			; correct for post-increased
	CPX	temp		; compare current count
	BNE	po_dbyt		; loop until done

; skip all bytes and point to next opcode

post_end:			; **
	LDA	#' '		; **
	JSR	PUT_CH		; **
				; **
	lda	count		; **
	beq	end_prnt	; **
	dec	count		; **
	bra	post_end	; **

end_prnt:			; **
;	LDA	#']'		; **
;	JSR	PUT_CH		; **

	LDA 	oper		; address LSB
	SEC			; skip current opcode...
	ADC	bytes		; ...plus number of operands
	STA	oper
	BCC	po_cr		; in case of page crossing
	INC	oper+1
po_cr:

	LDA	#' '		; **
	JSR	PUT_CH		; **
	LDA	#' '		; **
	JSR	PUT_CH		; **
	LDA	#$FF&vnim_buf
	STA	PT0
	LDA	#vnim_buf>>8
	STA	PT0+1
	jsr	STROUT		; output mnemonic to console
	JMP	CRLF		; print it and return

; minimOS opcode list for (dis)assembler modules
; (c) 2015-2022 Carlos J. Santisteban
; last modified 20200222-1341

; Opcode list as bit-7 terminated strings
; @ expects single byte, & expects word
; NEW % expects RELATIVE addressing
; Rockwell 65C02 version (plus STP & WAI)
; will be used by the assembler module too

da_oclist
	db	"BRK #", $80+'@'	; $00=BRK #zp
	db	"ORA (@, X", $80+')'	; $01=ORA (zp,X)
	db	"?", $80+'@'		; $02=?
	db	$80+'?'			; $03=?
	db	"TSB ", $80+'@'		; $04=TSB zp		CMOS
	db	"ORA ", $80+'@'		; $05=ORA zp
	db	"ASL ", $80+'@'		; $06=ASL zp
	db	"RMB0 ", $80+'@'	; $07=RMB0 zp		CMOS Rockwell
	db	"PH", $80+'P'		; $08=PHP
	db	"ORA #", $80+'@'	; $09=ORA #
	db	"AS", $80+'L'		; $0A=ASL
	db	$80+'?'			; $0B=?
	db	"TSB ", $80+'&'		; $0C=TSB abs		CMOS
	db	"ORA ", $80+'&'		; $0D=ORA abs
	db	"ASL ", $80+'&'		; $0E=ASL abs
	db	"BBR0 @,", $80+'%'	; $0F=BBR0 zp, rel	CMOS Rockwell
	db	"BPL ", $80+'%'		; $10=BPL rel
	db	"ORA (@), ", $80+'Y'	; $11=ORA (zp),Y
	db	"ORA (@", $80+')'	; $12=ORA (zp)		CMOS
	db	$80+'?'			; $13=?
	db	"TRB ", $80+'@'		; $14=TRB zp		CMOS
	db	"ORA @, ", $80+'X'	; $15=ORA zp,X
	db	"ASL @, ", $80+'X'	; $16=ASL zp,X
	db	"RMB1 ", $80+'@'	; $17=RMB1 zp		CMOS Rockwell
	db	"CL", $80+'C'		; $18=CLC
	db	"ORA &, ", $80+'Y'	; $19=ORA abs,Y
	db	"IN", $80+'C'		; $1A=INC		CMOS
	db	$80+'?'			; $1B=?
	db	"TRB ", $80+'&'		; $1C=TRB abs		CMOS
	db	"ORA &, ", $80+'X'	; $1D=ORA abs,X
	db	"ASL &, ", $80+'X'	; $1E=ASL abs,X
	db	"BBR1 @,", $80+'%'	; $1F=BBR1 zp, rel	CMOS Rockwell
	db	"JSR ", $80+'&'		; $20=JSR abs
	db	"AND (@, X", $80+')'	; $21=AND (zp,X)
	db	"?", $80+'@'		; $22=?
	db	$80+'?'			; $23=?
	db	"BIT ", $80+'@'		; $24=BIT zp
	db	"AND ", $80+'@'		; $25=AND zp
	db	"ROL ", $80+'@'		; $26=ROL zp
	db	"RMB2 ", $80+'@'	; $27=RMB2 zp		CMOS Rockwell
	db	"PL", $80+'P'		; $28=PLP
	db	"AND #", $80+'@'	; $29=AND #
	db	"RO", $80+'L'		; $2A=ROL
	db	$80+'?'			; $2B=?
	db	"BIT ", $80+'&'		; $2C=BIT abs
	db	"AND ", $80+'&'		; $2D=AND abs
	db	"ROL ", $80+'&'		; $2E=ROL abs
	db	"BBR2 @,", $80+'%'	; $2F=BBR2 zp, rel	CMOS Rockwell
	db	"BMI ", $80+'%'		; $30=BMI rel
	db	"AND (@), ", $80+'Y'	; $31=AND (zp),Y
	db	"AND (@", $80+')'	; $32=AND (zp)		CMOS
	db	$80+'?'			; $33=?
	db	"BIT @, ", $80+'X'	; $34=BIT zp,X		CMOS
	db	"AND @, ", $80+'X'	; $35=AND zp,X
	db	"ROL @, ", $80+'X'	; $36=ROL zp,X
	db	"RMB3 ", $80+'@'	; $37=RMB3 zp		CMOS Rockwell
	db	"SE", $80+'C'		; $38=SEC
	db	"AND &, ", $80+'Y'	; $39=AND abs,Y
	db	"DE", $80+'C'		; $3A=DEC		CMOS
	db	$80+'?'			; $3B=?
	db	"BIT &, ", $80+'X'	; $3C=BIT abs,X		CMOS
	db	"AND &, ", $80+'X'	; $3D=AND abs,X
	db	"ROL &, ", $80+'X'	; $3E=ROL abs,X
	db	"BBR3 @,", $80+'%'	; $3F=BBR3 zp, rel	CMOS Rockwell
	db	"RT", $80+'I'		; $40=RTI
	db	"EOR (@, X", $80+')'	; $41=EOR (zp,X)
	db	"?", $80+'@'		; $42=?
	db	$80+'?'			; $43=?
	db	"?(3)", $80+'@'		; $44=?
	db	"EOR ", $80+'@'		; $45=EOR zp
	db	"LSR ", $80+'@'		; $46=LSR zp
	db	"RMB4 ", $80+'@'	; $47=RMB4 zp		CMOS Rockwell
	db	"PH", $80+'A'		; $48=PHA
	db	"EOR #", $80+'@'	; $49=EOR #
	db	"LS", $80+'R'		; $4A=LSR
	db	$80+'?'			; $4B=?
	db	"JMP ", $80+'&'		; $4C=JMP abs
	db	"EOR ", $80+'&'		; $4D=EOR abs
	db	"LSR ", $80+'&'		; $4E=LSR abs
	db	"BBR4 @,", $80+'%'	; $4F=BBR4 zp, rel	CMOS Rockwell
	db	"BVC ", $80+'%'		; $50=BVC rel
	db	"EOR (@), ", $80+'Y'	; $51=EOR (zp),Y
	db	"EOR (@", $80+')'	; $52=EOR (zp)		CMOS
	db	$80+'?'			; $53=?
	db	"?(4)", $80+'@'		; $54=?
	db	"EOR @, ", $80+'X'	; $55=EOR zp,X
	db	"LSR @, ", $80+'X'	; $56=LSR zp,X
	db	"RMB5 ", $80+'@'	; $57=RMB5 zp		CMOS Rockwell
	db	"CL", $80+'I'		; $58=CLI
	db	"EOR &, ", $80+'Y'	; $59=EOR abs,Y
	db	"PH", $80+'Y'		; $5A=PHY		CMOS
	db	$80+'?'			; $5B=?
	db	"?(8)", $80+'&'		; $5C=?
	db	"EOR &, ", $80+'X'	; $5D=EOR abs,X
	db	"LSR &, ", $80+'X'	; $5E=LSR abs,X
	db	"BBR5 @,", $80+'%'	; $5F=BBR5 zp, rel	CMOS Rockwell
	db	"RT", $80+'S'		; $60=RTS
	db	"ADC (@, X", $80+')'	; $61=ADC (zp,X)
	db	"?", $80+'@'		; $62=?
	db	$80+'?'			; $63=?
	db	"STZ ", $80+'@'		; $64=STZ zp		CMOS
	db	"ADC ", $80+'@'		; $65=ADC zp
	db	"ROR ", $80+'@'		; $66=ROR zp
	db	"RMB6 ", $80+'@'	; $67=RMB6 zp		CMOS Rockwell
	db	"PL", $80+'A'		; $68=PLA
	db	"ADC #", $80+'@'	; $69=ADC #
	db	"RO", $80+'R'		; $6A=ROR
	db	$80+'?'			; $6B=?
	db	"JMP (&", $80+')'	; $6C=JMP (abs)
	db	"ADC ", $80+'&'		; $6D=ADC abs
	db	"ROR ", $80+'&'		; $6E=ROR abs
	db	"BBR6 @,", $80+'%'	; $6F=BBR6 zp, rel	CMOS Rockwell
	db	"BVS ", $80+'%'		; $70=BVS rel
	db	"ADC (@), ", $80+'Y'	; $71=ADC (zp),Y
	db	"ADC (@", $80+')'	; $72=ADC (zp)		CMOS
	db	$80+'?'			; $73=?
	db	"STZ @, ", $80+'X'	; $74=STZ zp,X		CMOS
	db	"ADC @, ", $80+'X'	; $75=ADC zp,X
	db	"ROR @, ", $80+'X'	; $76=ROR zp,X
	db	"RMB7 ", $80+'@'	; $77=RMB7 zp		CMOS Rockwell
	db	"SE", $80+'I'		; $78=SEI
	db	"ADC &, ", $80+'Y'	; $79=ADC abs, Y
	db	"PL", $80+'Y'		; $7A=PLY		CMOS
	db	$80+'?'			; $7B=?
	db	"JMP (&, X", $80+')'	; $7C=JMP (abs,X)
	db	"ADC &, ", $80+'X'	; $7D=ADC abs, X
	db	"ROR &, ", $80+'X'	; $7E=ROR abs, X
	db	"BBR7 @,", $80+'%'	; $7F=BBR7 zp, rel	CMOS Rockwell
	db	"BRA ", $80+'%'		; $80=BRA rel		CMOS
	db	"STA (@, X", $80+')'	; $81=STA (zp,X)
	db	"?", $80+'@'		; $82=?
	db	$80+'?'			; $83=?
	db	"STY ", $80+'@'		; $84=STY zp
	db	"STA ", $80+'@'		; $85=STA zp
	db	"STX ", $80+'@'		; $86=STX zp		CMOS
	db	"SMB0 ", $80+'@'	; $87=SMB0 zp		CMOS Rockwell
	db	"DE", $80+'Y'		; $88=DEY
	db	"BIT #", $80+'@'	; $89=BIT #
	db	"TX", $80+'A'		; $8A=TXA
	db	$80+'?'			; $8B=?
	db	"STY ", $80+'&'		; $8C=STY abs
	db	"STA ", $80+'&'		; $8D=STA abs
	db	"STX ", $80+'&'		; $8E=STX abs
	db	"BBS0 @, ", $80+'%'	; $8F=BBS0 zp, rel	CMOS Rockwell
	db	"BCC ", $80+'%'		; $90=BCC rel
	db	"STA (@), ", $80+'Y'	; $91=STA (zp),Y
	db	"STA (@", $80+')'	; $92=STA (zp)		CMOS
	db	$80+'?'			; $93=?
	db	"STY @, ", $80+'X'	; $94=STY zp,X
	db	"STA @, ", $80+'X'	; $95=STA zp,X
	db	"STX @, ", $80+'Y'	; $96=STX zp,Y
	db	"SMB1 ", $80+'@'	; $97=SMB1 zp		CMOS Rockwell
	db	"TY", $80+'A'		; $98=TYA
	db	"STA &, ", $80+'Y'	; $99=STA abs, Y
	db	"TX", $80+'S'		; $9A=TXS
	db	$80+'?'			; $9B=?
	db	"STZ ", $80+'&'		; $9C=STZ abs		CMOS
	db	"STA &, ", $80+'X'	; $9D=STA abs,X
	db	"STZ &, ", $80+'X'	; $9E=STZ abs,X		CMOS
	db	"BBS1 @, ", $80+'%'	; $9F=BBS1 zp, rel	CMOS Rockwell
	db	"LDY #", $80+'@'	; $A0=LDY #
	db	"LDA (@, X", $80+')'	; $A1=LDA (zp,X)
	db	"LDX #", $80+'@'	; $A2=LDX #
	db	$80+'?'			; $A3=?
	db	"LDY ", $80+'@'		; $A4=LDY zp
	db	"LDA ", $80+'@'		; $A5=LDA zp
	db	"LDX ", $80+'@'		; $A6=LDX zp
	db	"SMB2 ", $80+'@'	; $A7=SMB2 zp		CMOS Rockwell
	db	"TA", $80+'Y'		; $A8=TAY
	db	"LDA #", $80+'@'	; $A9=LDA #
	db	"TA", $80+'X'		; $AA=TAX
	db	$80+'?'			; $AB=?
	db	"LDY ", $80+'&'		; $AC=LDY abs
	db	"LDA ", $80+'&'		; $AD=LDA abs
	db	"LDX ", $80+'&'		; $AE=LDX abs
	db	"BBS2 @, ", $80+'%'	; $AF=BBS2 zp, rel	CMOS Rockwell
	db	"BCS ", $80+'%'		; $B0=BCS rel
	db	"LDA (@), ", $80+'Y'	; $B1=LDA (zp),Y
	db	"LDA (@", $80+')'	; $B2=LDA (zp)		CMOS
	db	$80+'?'			; $B3=?
	db	"LDY @, ", $80+'X'	; $B4=LDY zp,X
	db	"LDA @, ", $80+'X'	; $B5=LDA zp,X
	db	"LDX @,", $80+'Y'	; $B6=LDX zp,Y
	db	"SMB3 ", $80+'@'	; $B7=SMB3 zp		CMOS Rockwell
	db	"CL", $80+'V'		; $B8=CLV
	db	"LDA &, ", $80+'Y'	; $B9=LDA abs, Y
	db	"TS", $80+'X'		; $BA=TSX
	db	$80+'?'			; $BB=?
	db	"LDY &, ", $80+'X'	; $BC=LDY abs,X
	db	"LDA &, ", $80+'X'	; $BD=LDA abs,X
	db	"LDX &, ", $80+'Y'	; $BE=LDX abs,Y
	db	"BBS3 @, ", $80+'%'	; $BF=BBS3 zp, rel	CMOS Rockwell
	db	"CPY #", $80+'@'	; $C0=CPY #
	db	"CMP (@, X", $80+')'	; $C1=CMP (zp,X)
	db	"?", $80+'@'		; $C2=?
	db	$80+'?'			; $C3=?
	db	"CPY ", $80+'@'		; $C4=CPY zp
	db	"CMP ", $80+'@'		; $C5=CMP zp
	db	"DEC ", $80+'@'		; $C6=DEC zp
	db	"SMB4 ", $80+'@'	; $C7=SMB4 zp		CMOS Rockwell
	db	"IN", $80+'Y'		; $C8=INY
	db	"CMP #", $80+'@'	; $C9=CMP #
	db	"DE", $80+'X'		; $CA=DEX
	db	"WA", $80+'I'		; $CB=WAI		CMOS WDC
	db	"CPY ", $80+'&'		; $CC=CPY abs
	db	"CMP ", $80+'&'		; $CD=CMP abs
	db	"DEC ", $80+'&'		; $CE=DEC abs
	db	"BBS4 @, ", $80+'%'	; $CF=BBS4 zp, rel	CMOS Rockwell
	db	"BNE ", $80+'%'		; $D0=BNE rel
	db	"CMP (@), ", $80+'Y'	; $D1=CMP (zp),Y
	db	"CMP (@", $80+')'	; $D2=CMP (zp)		CMOS
	db	$80+'?'			; $D3=?
	db	"?(4)", $80+'@'		; $D4=?
	db	"CMP @, ", $80+'X'	; $D5=CMP zp,X
	db	"DEC @, ", $80+'X'	; $D6=DEC zp,X
	db	"SMB5 ", $80+'@'	; $D7=SMB5 zp		CMOS Rockwell
	db	"CL", $80+'D'		; $D8=CLD
	db	"CMP &, ", $80+'Y'	; $D9=CMP abs, Y
	db	"PH", $80+'X'		; $DA=PHX		CMOS
	db	"ST", $80+'P'		; $DB=STP		CMOS WDC
	db	"?(4)", $80+'&'		; $DC=?
	db	"CMP &, ", $80+'X'	; $DD=CMP abs,X
	db	"DEC &, ", $80+'X'	; $DE=DEC abs,X
	db	"BBS5 @, ", $80+'%'	; $DF=BBS5 zp, rel	CMOS Rockwell
	db	"CPX #", $80+'@'	; $E0=CPX #
	db	"SBC (@, X", $80+')'	; $E1=SBC (zp,X)
	db	"?", $80+'@'		; $E2=?
	db	$80+'?'			; $E3=?
	db	"CPX ", $80+'@'		; $E4=CPX zp
	db	"SBC ", $80+'@'		; $E5=SBC zp
	db	"INC ", $80+'@'		; $E6=INC zp
	db	"SMB6 ", $80+'@'	; $E7=SMB6 zp		CMOS Rockwell
	db	"IN", $80+'X'		; $E8=INX
	db	"SBC #", $80+'@'	; $E9=SBC #
	db	"NO", $80+'P'		; $EA=NOP
	db	$80+'?'			; $EB=?
	db	"CPX ", $80+'&'		; $EC=CPX abs
	db	"SBC ", $80+'&'		; $ED=SBC abs
	db	"INC ", $80+'&'		; $EE=INC abs
	db	"BBS6 @, ", $80+'%'	; $EF=BBS6 zp, rel	CMOS Rockwell
	db	"BEQ ", $80+'%'		; $F0=BEQ rel
	db	"SBC (@), ", $80+'Y'	; $F1=SBC (zp),Y
	db	"SBC (@", $80+')'	; $F2=SBC (zp)		CMOS
	db	$80+'?'			; $F3=?
	db	"?(4)", $80+'@'		; $F4=?
	db	"SBC @, ", $80+'X'	; $F5=SBC zp,X
	db	"INC @, ", $80+'X'	; $F6=INC zp,X
	db	"SMB7 ", $80+'@'	; $F7=SMB7 zp		CMOS Rockwell
	db	"SE", $80+'D'		; $F8=SED
	db	"SBC &, ", $80+'Y'	; $F9=SBC abs,Y
	db	"PL", $80+'X'		; $FA=PLX		CMOS
	db	$80+'?'			; $FB=?
	db	"?(4)", $80+'&'		; $FC=?
	db	"SBC &, ", $80+'X'	; $FD=SBC abs,X
	db	"INC &, ", $80+'X'	; $FE=INC abs,X
	db	"BBS7 @, ", $80+'%'	; $FF=BBS7 zp, rel	CMOS Rockwell

;;;
;;;  Go address
;;;
GO
	stz	stp_flg		; clear stop flag
	INX
	JSR	SKIPSP
	JSR	RDHEX
	LDA	CNT
	BNE	GP0		; jmp if 1st arg. exist

	JSR	SKIPSP
	LDA	INBUF,X
	bne	GP01		; jmp if remain strings exist

	;; No arg.
	bra	G0

GP0	;; 1st arg. found
	LDA	PT1
	STA	REGPC		; set start address(low)
	LDA	PT1+1
	STA	REGPC+1		; set start address(high)

	; check 2nd arg.
	JSR	SKIPSP
	LDA	INBUF,X
	CMP	#0
	BEQ	G0		; jmp if no 2nd arg.
GP01
	CMP	#','
	BEQ	GP1		; chk 2nd arg

G_ERR
	JMP	ERR

GP1	;; check 2nd arg.
	INX
	JSR	SKIPSP
	JSR	RDHEX
	JSR	SKIPSP
	LDA	CNT
	BEQ	G_ERR

	;; set 2nd arg.

	inc	stp_flg		; set stop flag

	; save original binary at break point
	ldy	#0

;	lda	(PT1),y		; get first binary at stop address
	jsr	lda_pt1

	sta	sav_dat		; save original binary
	iny

;	lda	(PT1),y		; get second binary at stop address
	jsr	lda_pt1

	sta	sav_dat+1	; save original binary

	; set break point
	lda	#0		; BRK 
	tay

;	sta	(PT1),y		; set BRK opecode
	jsr	sta_pt1

	iny
;	sta	(PT1),y		; set BRK operand(#0)
	jsr	sta_pt1
	
	lda	PT1
	sta	sav_adr		; save break point addr(L)
	lda	PT1+1
	sta	sav_adr+1	; save break point addr(H)

G0
	LDX	REGSP
	TXS			; SP
	LDA	REGPC+1
	PHA			; PC(H)
	LDA	REGPC
	PHA			; PC(L)
	LDA	REGPSR
	PHA			; PSR
	LDA	REGA
	LDX	REGX
	LDY	REGY
	RTI

;;;
;;; Set memory
;;;
SETM
	INX
	JSR	SKIPSP
	JSR	RDHEX
	JSR	SKIPSP
	LDA	INBUF,X
	BEQ	SM0
	JMP	ERR
SM0
	LDA	CNT
	BEQ	SM1
	LDA	PT1
	STA	SADDR
	LDA	PT1+1
	STA	SADDR+1
SM1:
	LDA	SADDR+1
	JSR	HEXOUT2
	LDA	SADDR
	JSR	HEXOUT2
	LDA	#$FF&DSEP1
	STA	PT0
	LDA	#DSEP1>>8
	STA	PT0+1
	JSR	STROUT
	LDY	#0

;	LDA	(SADDR),Y
	lda	SADDR
	sta	opr12
	lda	SADDR+1
	sta	opr12+1
	db	$B9		; LDA $xxxx,y
opr12	dw	0		; operand Absolute Indexed Y

	JSR	HEXOUT2
	LDA	#' '
	JSR	PUT_CH
	JSR	GETLIN
	LDX	#0
	JSR	SKIPSP
	LDA	INBUF,X
	BNE	SM2
SM10	
	;; Empty (Increment address)
	LDA	SADDR
	CLC
	ADC	#1
	STA	SADDR
	LDA	SADDR+1
	ADC	#0
	STA	SADDR+1
	JMP	SM1
SM2
	CMP	#'-'
	BNE	SM3
	;; '-' (Decrement address)
	LDA	SADDR
	SEC
	SBC	#1
	STA	SADDR
	LDA	SADDR+1
	SBC	#0
	STA	SADDR+1
	JMP	SM1
SM3
	CMP	#'.'
	BNE	SM4
	;; '.' (Quit)
	JMP	WSTART
SM4
	JSR	RDHEX
	LDA	CNT
	BNE	SM40
SMER
	JMP	ERR
SM40
	; repar original bug -------
	LDA	INBUF,X
	bne	SMER
	; repar original bug -------

;	LDA	PT1
;	LDY	#0
;	STA	(SADDR),Y
	lda	SADDR
	sta	opr13
	lda	SADDR+1
	sta	opr13+1
	LDA	PT1
	LDY	#0
	db	$99		; STA $xxxx,y
opr13	dw	0		; operand Absolute Indexed Y

	JMP	SM10

;;;
;;; LOAD HEX file
;;;
LOADH
	INX
	JSR	SKIPSP
	JSR	RDHEX
	JSR	SKIPSP
	LDA	INBUF,X
	BNE	SMER
LH0
	JSR	KEY_IN
	JSR	UPPER
	CMP	#'S'
	Bne	LH1a
	jmp	LHS0
LH1a
	CMP	#':'
	BEQ	LHI0
LH2
	;; Skip to EOL
	CMP	#CR
	BEQ	LH0
	CMP	#LF
	BEQ	LH0
LH3
	JSR	KEY_IN
	JMP	LH2

LHI0
	JSR	HEXIN
	STA	CKSUM
	STA	CNT		; Length

	JSR	HEXIN
	STA	DMPPT+1		; Address H
	CLC
	ADC	CKSUM
	STA	CKSUM

	JSR	HEXIN
	STA	DMPPT		; Address L
	CLC
	ADC	CKSUM
	STA	CKSUM

	;; Add offset
	LDA	DMPPT
	CLC
	ADC	PT1
	STA	DMPPT
	LDA	DMPPT+1
	ADC	PT1+1
	STA	DMPPT+1
	LDY	#0
	
	JSR	HEXIN
	STA	RECTYP		; Record Type
	CLC
	ADC	CKSUM
	STA	CKSUM

	LDA	CNT
	BEQ	LHI3
LHI1
	JSR	HEXIN
	PHA
	CLC
	ADC	CKSUM
	STA	CKSUM

	LDA	RECTYP
	BNE	LHI2

	PLA
;	STA	(DMPPT),Y
	jsr	sta_dmppt

	INY
	PHA			; Dummy, better than JMP to skip next PLA
LHI2
	PLA
	DEC	CNT
	BNE	LHI1
LHI3
	JSR	HEXIN
	CLC
	ADC	CKSUM
	BNE	LHIE		; Checksum error
	LDA	RECTYP
	BEQ	LH3
	JMP	WSTART
LHIE
	LDA	#$FF&IHEMSG
	STA	PT0
	LDA	#IHEMSG>>8
	STA	PT0+1
	JSR	STROUT
	JMP	WSTART

LHS0
	lda	#'.'
	jsr	PUT_CH

	JSR	KEY_IN
	STA	RECTYP		; Record Type

	JSR	HEXIN
	STA	CNT		; (CNT) = Length+3
	STA	CKSUM

	JSR	HEXIN
	STA	DMPPT+1		; Address H
	CLC
	ADC	CKSUM
	STA	CKSUM
	
	JSR	HEXIN
	STA	DMPPT		; Address L
	CLC
	ADC	CKSUM
	STA	CKSUM

	;; Add offset
	LDA	DMPPT
	CLC
	ADC	PT1
	STA	DMPPT
	LDA	DMPPT+1
	ADC	PT1+1
	STA	DMPPT+1
	LDY	#0

	DEC	CNT
	DEC	CNT
	DEC	CNT
	BEQ	LHS3
LHS1
	JSR	HEXIN
	PHA
	CLC
	ADC	CKSUM
	STA	CKSUM		; Checksum

	LDA	RECTYP
	CMP	#'1'
	BNE	LHS2

	PLA
;	STA	(DMPPT),Y
	jsr	sta_dmppt

	INY
	PHA			; Dummy, better than JMP to skip next PLA
LHS2
	PLA
	DEC	CNT
	BNE	LHS1
LHS3
	JSR	HEXIN
	CLC
	ADC	CKSUM
	CMP	#$FF
	BNE	LHSE		; Checksum error

	LDA	RECTYP
	CMP	#'9'
	BEQ	LHSR
	JMP	LH3
LHSE
	LDA	#$FF&SHEMSG
	STA	PT0
	LDA	#SHEMSG>>8
	STA	PT0+1
	JSR	STROUT
LHSR	
	JMP	WSTART

;;;
;;; Register
;;;
REG
	INX
	JSR	SKIPSP
	JSR	UPPER
	CMP	#0
	BNE	RG0
	JSR	RDUMP
	JMP	WSTART
RG0
	LDY	#$FF&RNTAB
	STY	PT1
	LDY	#RNTAB>>8
	STY	PT1+1
	LDY	#0
RG1
;	CMP	(PT1),Y
	pha
	lda	PT1
	sta	opr16
	lda	PT1+1
	sta	opr16+1
	pla
	db	$D9		; CMP $xxxx,y
opr16	dw	0		; operand Absolute Indexed Y

	BEQ	RG2
	INY
	PHA

;	LDA	(PT1),Y
	jsr	lda_pt1

	BEQ	RGE
	PLA
	INY
	INY
	INY
	INY
	INY
	JMP	RG1
RGE
	PLA
RGE0_0
	JMP	ERR
RG2
	INY
;	LDA	(PT1),Y
	jsr	lda_pt1

	CMP	#$80
	BNE	RG3
	;; Next table
	INY

;	LDA	(PT1),Y
	jsr	lda_pt1

	STA	CNT		; Temporary
	INY

;	LDA	(PT1),Y
	jsr	lda_pt1

	STA	PT1+1
	LDA	CNT
	STA	PT1
	LDY	#0
	INX
	LDA	INBUF,X
	JSR	UPPER
	JMP	RG1
RG3
	CMP	#0
	BEQ	RGE0_0

	INY			; +2

;	LDA	(PT1),Y
	jsr	lda_pt1

;	TAX
	; save hit register address
	sta	hit_reg
	INY
	jsr	lda_pt1
	sta	hit_reg+1

	INY			; +4
;	LDA	(PT1),Y
	jsr	lda_pt1

	STA	PT0
	INY

;	LDA	(PT1),Y
	jsr	lda_pt1

	STA	PT0+1
	STY	CNT		; Save Y (STROUT destroys Y)
	JSR	STROUT
	LDA	#'='
	JSR	PUT_CH
	LDY	CNT		; Restore Y
	DEY
	DEY
	DEY
	DEY

;	LDA	(PT1),Y
	jsr	lda_pt1

	STA	REGSIZ
	CMP	#1
	BNE	RG4
	;; 8 bit register
;	LDA	0,X
	ldx	#0
	jsr	get_hit_r

	JSR	HEXOUT2
	bra	RG5

get_hit_r
	lda	hit_reg
	sta	opr232
	lda	hit_reg+1
	sta	opr232+1
	db	$BD		; lda $xxxx,x
opr232
	dw	0
	rts

RG4
	;; 16 bit register
;	LDA	1,X
	ldx	#1
	jsr	get_hit_r
	JSR	HEXOUT2

;	LDA	0,X
	dex
	jsr	get_hit_r
	JSR	HEXOUT2
RG5
	LDA	#' '
	JSR	PUT_CH
	STX	CKSUM		; Save X (GETLIN destroys X)
	JSR	GETLIN
	LDX	#0
	JSR	RDHEX
	LDA	CNT
	BEQ	RGR
	LDX	CKSUM		; Restore X
	LDA	REGSIZ
	CMP	#1
	BNE	RG6
	;; 8 bit register
	LDA	PT1
;	STA	0,X
	ldx	#0
	jsr	set_hit_r
	bra	RG7

set_hit_r:
	pha
	lda	hit_reg
	sta	opr235
	lda	hit_reg+1
	sta	opr235+1
	pla
	db	$9D		; sta $xxxx,x
opr235:
	dw	0
	rts

RG6
	;; 16 bit address
	LDA	PT1
;	STA	0,X		; (L)
	ldx	#0
	jsr	set_hit_r

	LDA	PT1+1
	inx
;	STA	1,X		; (H)
	jsr	set_hit_r
RG7	
RGR	
	JMP	WSTART
	
RGE0	
	JMP	ERR
	
;
; print all registers
;
RDUMP
	ldy	#34
	lda	#' '
spc_out
	jsr	PUT_CH
	dey
	bne	spc_out

	LDA	#$FF&psr_bm
	STA	PT0
	LDA	#psr_bm>>8
	STA	PT0+1
	jsr	STROUT

	LDA	#$FF&RDSA	; A
	STA	PT0
	LDA	#RDSA>>8
	STA	PT0+1
	JSR	STROUT
	LDA	REGA
	JSR	HEXOUT2

	LDA	#$FF&RDSX	; X
	STA	PT0
	LDA	#RDSX>>8
	STA	PT0+1
	JSR	STROUT
	LDA	REGX
	JSR	HEXOUT2

	LDA	#$FF&RDSY	; Y
	STA	PT0
	LDA	#RDSY>>8
	STA	PT0+1
	JSR	STROUT
	LDA	REGY
	JSR	HEXOUT2

	LDA	#$FF&RDSSP	; SP
	STA	PT0
	LDA	#RDSSP>>8
	STA	PT0+1
	JSR	STROUT
	LDA	REGSP
	JSR	HEXOUT2

	LDA	#$FF&RDSPC	; PC
	STA	PT0
	LDA	#RDSPC>>8
	STA	PT0+1
	JSR	STROUT
	LDA	REGPC+1		; PC(H)
	JSR	HEXOUT2
	LDA	REGPC		; PC(L)
	JSR	HEXOUT2

	LDA	#$FF&RDSPSR	; PSR
	STA	PT0
	LDA	#RDSPSR>>8
	STA	PT0+1
	JSR	STROUT

	LDY	#8
	LDA	REGPSR
	
psr_bloop
	asl	a
	bcc	set_31
	tax			; save
	lda	#'1'
	jsr	PUT_CH
set_30
	txa
	dey
	bne	psr_bloop
	JMP	CRLF

set_31
	tax			; save
	lda	#'0'
	jsr	PUT_CH
	bra	set_30

;
; command help
;
prt_help:
	INX
	JSR	SKIPSP
	LDA	INBUF,X
	BEQ	ph_1	; jmp if string exist
	JMP	ERR
ph_1
	; must strings <= 255 : Y = 8 bit

	LDA	#$FF&hlp_meg1
	STA	PT0
	LDA	#hlp_meg1>>8
	STA	PT0+1
	JSR	STROUT

	LDA	#$FF&hlp_meg2
	STA	PT0
	LDA	#hlp_meg2>>8
	STA	PT0+1
	JSR	STROUT
	JMP	WSTART

hlp_meg1
	db	"--------     Command Summary     --------",CR,LF
	db	"?  : Command Summary", CR, LF
	db	"D  [start adr][,end adr] : Dump Memory", CR, LF
	db	"DI [start adr][,end adr] : Disassembler", CR, LF
	db	"G  [start adr][,end adr] : Go and Stop", CR, LF,0
hlp_meg2
	db	"L  [offset] : Load HexFile", CR, LF
	db	"R  [A|X|Y|PSR|PC] : Show or Set Register", CR, LF
	db	"S  [adr] : Set Memory", CR, LF
	db	"BYE : Terminate",CR,LF,0
;;;
;;; Other support routines
;;;

;-----------------------------------------------------------
; alternative Direct Page Indirect Indexed, Y
;
lda_pt1:
	lda	PT1
	sta	lda_pt2
	lda	PT1+1
	sta	lda_pt2+1
	db	$B9		; LDA $xxxx,y
lda_pt2:
	dw	0		; operand Absolute Indexed Y
	rts

lda_scan:
	lda	scan
	sta	lda_scan1
	lda	scan+1
	sta	lda_scan1+1
	db	$B9		; LDA $xxxx,y
lda_scan1:
	dw	0		; operand Absolute Indexed Y
	rts

lda_oper:
	lda	oper
	sta	lda_oper1
	lda	oper+1
	sta	lda_oper1+1
	db	$B9		; LDA $xxxx,y
lda_oper1:
	dw	0		; operand Absolute Indexed Y
	rts

sta_pt1:
	pha
	lda	PT1
	sta	sta_pt2
	lda	PT1+1
	sta	sta_pt2+1
	pla
	db	$99		; STA $xxxx,y
sta_pt2:
	dw	0		; operand Absolute Indexed Y
	rts

sta_dmppt:
	pha
	lda	DMPPT
	sta	sta_dmppt1
	lda	DMPPT+1
	sta	sta_dmppt1+1
	PLA
	db	$99		; STA $xxxx,y
sta_dmppt1:
	dw	0		; operand Absolute Indexed Y
	rts

sta_sav_adr:
	pha
	lda	sav_adr
	sta	opr25
	lda	sav_adr+1
	sta	opr25+1
	pla
	db	$99		; STA $xxxx,y
opr25	dw	0		; operand Absolute Indexed Y
	rts
;------------------------------------------------------------
; LDA (oper)
; alternative Direct Page Indirect
;------------------------------------------------------------
lda_d_oper:
	lda	oper
	sta	opr2_2
	lda	oper+1
	sta	opr2_2+1
	db	$AD		; LDA $xxxx
opr2_2
	dw	0
	rts
;------------------------------------------------------------

STROUT
	LDY	#0
STRO0
;	LDA	(PT0),Y
	lda	PT0
	sta	opr24
	lda	PT0+1
	sta	opr24+1
	db	$B9		; LDA $xxxx,y
opr24	dw	0		; operand Absolute Indexed Y

	BEQ	STROE
	JSR	PUT_CH
	INY
	JMP	STRO0
STROE
	RTS

HEXOUT2
	PHA
	LSR	A
	LSR	A
	LSR	A
	LSR	A
	JSR	HEXOUT1
	PLA
HEXOUT1
	AND	#$0F
	CLC
	ADC	#'0'
	CMP	#'9'+1
	BCC	HEXOUTE
	CLC
	ADC	#'A'-'9'-1
HEXOUTE
	JMP	PUT_CH

HEXIN
	LDA	#0
	JSR	HI0
	ASL
	ASL
	ASL
	ASL
HI0
	STA	HITMP
	JSR	KEY_IN
	JSR	UPPER
	CMP	#'0'
	BCC	HIR
	CMP	#'9'+1
	BCC	HI1
	CMP	#'A'
	BCC	HIR
	CMP	#'F'+1
	BCS	HIR
	SEC
	SBC	#'A'-'9'-1
HI1
	SEC
	SBC	#'0'
	CLC
	ADC	HITMP
HIR
	RTS
	
CRLF
	LDA	#CR
	JSR	PUT_CH
	LDA	#LF
	JMP	PUT_CH

GETLIN
	LDX	#0
GL0
	JSR	KEY_IN
	CMP	#CR
	BEQ	GLE
	CMP	#LF
	BEQ	GLE
	CMP	#BS
	BEQ	GLB
	CMP	#DEL
	BEQ	GLB
	CMP	#' '
	BCC	GL0
	CMP	#$80
	BCS	GL0
	CPX	#BUFLEN-1
	BCS	GL0		; Too long
	STA	INBUF,X
	INX
	JSR	PUT_CH
	JMP	GL0
GLB
	CPX	#0
	BEQ	GL0
	DEX
	LDA	#BS
	JSR	PUT_CH
	LDA	#' '
	JSR	PUT_CH
	LDA	#BS
	JSR	PUT_CH
	JMP	GL0
GLE
	JSR	CRLF
	LDA	#0
	STA	INBUF,X
	RTS

SKIPSP
	LDA	INBUF,X
	CMP	#' '
	BNE	SSE
	INX
	JMP	SKIPSP
SSE
	RTS

UPPER
	CMP	#'a'
	BCC	UPE
	CMP	#'z'+1
	BCS	UPE
	ADC	#'A'-'a'
UPE
	RTS

RDHEX
;	LDA	#0
	STZ	PT1
	STZ	PT1+1
	STZ	CNT
RH0
	LDA	INBUF,X
	JSR	UPPER
	CMP	#'0'
	BCC	RHE
	CMP	#'9'+1
	BCC	RH1
	CMP	#'A'
	BCC	RHE
	CMP	#'F'+1
	BCS	RHE
	SEC
	SBC	#'A'-'9'-1
RH1
	SEC
	SBC	#'0'
	ASL	PT1
	ROL	PT1+1
	ASL	PT1
	ROL	PT1+1
	ASL	PT1
	ROL	PT1+1
	ASL	PT1
	ROL	PT1+1
	CLC
	ADC	PT1
	STA	PT1
	INC	CNT
	INX
	JMP	RH0
RHE
	RTS

;;;
;;; Interrupt handler
;;;

;----------------------
; NMI
;----------------------
NMI_VEC
	CLD
	STA	REGA
	TXA			; X
	STA	REGX
	TYA			; Y
	STA	REGY
	PLA			; PSR (Pushed by NMI)
	STA	REGPSR		; save status register
	PLA			; PC(L) (Pushed by NMI)
	STA	REGPC
	PLA			; PC(H) (Pushed by NMI)
	STA	REGPC+1
	TSX			; get SP
	STX	REGSP

	lda	#$ff		; NMI signal
	sta	UNI_CHR
	jsr	NMI_SIG

	jmp	G0

;----------------------
; IRQ / BRK
;----------------------
IRQBRK
	pha
	phx

;	    sp->      : sp+0
;	  push x      : sp+1
;	  push a      : sp+2
;	  push P      : sp+3
;	  push PC(L)  : sp+4
;	  push PC(H)  : sp+5
;	which BRK or IRQ?
;	need status condhition check (SP+3)

	tsx
	inx			; ($100 + sp +1) : stacked X register
	inx			; ($100 + sp + 2): stacked A register
	inx			; ($100 + sp + 3): p (status register)
	lda	$100,x		; check status register

	AND	#$10		; Check B flag
	bne	code_brk
	jmp	irq_int

code_brk
	inx			; ($100 + sp + 4): pc (L)
	lda	$100,x		; PC(L)
	SEC
	SBC	#1		; Adjust to #n address (BRK #n)
	sta	bk_no
	inx			; ($100 + sp + 5): pc (H)
	lda	$100,x		; PC(H)
	SBC	#0
	sta	bk_no+1

;	lda	(bk_no)		; get command request #$xx (BRK #$xx)
	lda	bk_no
	sta	bk_00
	lda	bk_no+1
	sta	bk_00+1
	db	$AD		; lda $xxxx
bk_00
	dw	0

	cmp	#$ff		; program end?
	bne	bk_n
	tsx
	inx			; ($100 + sp +1) : stacked X register
	inx			; ($100 + sp + 2): stacked A register
	lda	$100,x		; get A
	cmp	#2		; check for request of invoking monitor
	bne	e_p
	sta	stp_flg		; store 2
	sta	u_sw
	bra	go_brk		; wakeup monitor

e_p
	jmp	wup		; user program terminate
bk_n
	cmp	#0
	beq	go_brk
	cmp	#NUM_BCALL
	bpl	go_brk

	phy
;  sp->        : sp+0
;  push y      : sp+1
;  push x      : sp+2
;  push a      : sp+3
;  push P      : sp+4
;  push PC(L)  : sp+5
;  push PC(H)  : sp+6
	
	tsx
	phx
	ply	; sp -> y
		; A : #n (brk #n)
	jsr	bios_call
	tsx
	inx	; Y
	inx	; x
	inx	; a
	sta	$100, x		; set return code
	ply

	plx
	pla
	rti

creq_p
	dw	KEY_IN
	dw	PUT_CH
	dw	KEY_CHK
	dw	prt_str
	dw	READ_SD
	dw	WRITE_SD
;
; input A : string address Low
;       Y : string address High
;
prt_str
	STA	PT0
	dey
	dey	; Y
	lda	$100, y		; get Y
	sta	PT0+1
	jsr	STROUT
	rts

;  A : #n (brk #n)
;        : -1 return address of bios_call(L)-1
;  y ->  : 0  return address of bios_call(H)
;        : 1 Y
;        : 2 X
;        : 3 A
;        : 4 P
;        : 5 PC(L)
;        : 6 PC(H)

bios_call
	cli
	dec	A
	asl	A		; A = A * 2
	tax
	iny	; Y
	iny	; X
	iny	; A
	lda	$100,y		; get input data to A
	jmp	(creq_p,x)

	; BRK instruction
go_brk
	plx
	CLD
	PLA			; A
	STA	REGA
	TXA			; X
	STA	REGX
	TYA			; Y
	STA	REGY
	PLA			; PSR (Pushed by BRK)
	STA	REGPSR		; save status register
	PLA			; PC(L) (Pushed by BRK)
	sta	ILL_PC
	SEC
	SBC	#2		; Adjust PC to point BRK instruction
	STA	REGPC
	PLA			; PC(H) (Pushed by BRK)
	sta	ILL_PC+1
	SBC	#0
	STA	REGPC+1
	TSX			; get SP
	STX	REGSP

	; check break point
	lda	stp_flg
	cmp	#1		; user break?
	bne	ill_stop

	; restore original code
	ldy	#0
	lda	sav_dat
;	sta	(sav_adr),y
	jsr	sta_sav_adr
	iny
	lda	sav_dat+1
;	sta	(sav_adr),y
	jsr	sta_sav_adr
	
	lda	sav_adr
	cmp	REGPC
	bne	ill_stop
	
	lda	sav_adr+1
	cmp	REGPC+1
	bne	ill_stop

	lda	#$FF&stpmsg
	STA	PT0
	LDA	#stpmsg>>8
	STA	PT0+1
	bra	b_outmsg

ill_stop
	; re-adjust PC
	ldx	ILL_PC
	stx	REGPC
	ldx	ILL_PC+1
	stx	REGPC+1
	cmp	#2		; check wakeup monitor
	beq	b_out1

	LDA	#$FF&BRKMSG
	STA	PT0
	LDA	#BRKMSG>>8
	STA	PT0+1
	lda	ILL_PC
	sta	REGPC
	lda	ILL_PC+1
	sta	REGPC+1
b_outmsg
	cli
	JSR	STROUT
b_out1
	cli
	stz	stp_flg
	JSR	RDUMP
	JMP	WSTART

;--------------------------------------
; IRQ interrupt driver
;--------------------------------------
irq_int
	phy

	lda	#1
	eor	irq_tgl
	sta	irq_tgl
	beq	i_cout_chk

;--------------------------------------
; check CONIN buffer
;--------------------------------------
i_cin_chk
	lda	CIN_CT
	cmp	#CIN_SIZE
	beq	i_cout_chk	; buffer full, then ignore key data

	LDA	#$FF&CONTMP_BUF
	STA	data_adr
	LDA	#CONTMP_BUF>>8
	STA	data_adr+1
	lda	#CIN_SIZE
	sec
	sbc	CIN_CT		; get counter of get btyes
	sta	UNI_CHR
	lda	#STRIN_REQ
	jsr	wup_pic		; string out request to PIC
	beq	irq_end

	; copy data from CONTMP_BUF to CIN_BUF

	sta	STRIN_CNT	; save str count
	ldx	#0		; destinate index
	ldy	CIN_WP		; source index

lop_rdata
;	lda	CONTMP_BUF,x	; get char
;	sta	(ZCIN_BP),y	; save char data
	lda	ZCIN_BP
	sta	sta_zi1
	lda	ZCIN_BP+1
	sta	sta_zi1+1
	lda	CONTMP_BUF,x	; get char
	db	$99		; STA $xxxx,y
sta_zi1:
	dw	0		; operand Absolute Indexed Y

	inc	CIN_CT
	inx
	iny
	tya
	and	#$7f
	tay
	dec	STRIN_CNT
	bne	lop_rdata
	sta	CIN_WP

irq_end
	ply
	plx
	pla
	rti

;--------------------------------------
; check CONUT buffer
;--------------------------------------
i_cout_chk
	lda	COUT_CT
	beq	null_cmd

	sta	UNI_CHR		; set string size

	; copy data from COUT_BUF to CONTMP_BUF
	ldx	#0		; destinate index
	ldy	COUT_RP		; source index

i_cploop
;	lda	(ZCOUT_BP),y	; get a conout data
	lda	ZCOUT_BP
	sta	zo_1
	lda	ZCOUT_BP+1
	sta	zo_1+1
	db	$B9		; LDA $xxxx,y
zo_1:	dw	0

	sta	CONTMP_BUF,x	; set to i_buffer
	inx
	iny
	tya
	and	#$7f
	tay
	dec	COUT_CT
	bne	i_cploop

	sty	COUT_RP		; refresh read pointer

	; set string out request
	
	LDA	#$FF&CONTMP_BUF
	STA	data_adr
	LDA	#CONTMP_BUF>>8
	STA	data_adr+1
	lda	#STROUT_REQ
null_cmd
	jsr	wup_pic		; string out request to PIC
	bra	irq_end

;---------- unimon message data ---------------
OPNMSG
	FCB	CR,LF,"MEZW65C_RAM Monitor W65C02 V2.1",CR,LF,$00
PROMPT
	FCB	"] ",$00
IHEMSG
	FCB	"Error ihex",CR,LF,$00

SHEMSG
	FCB	"Error srec",CR,LF,$00

ERRMSG
	FCB	"Error",CR,LF,$00

DSEP0
	FCB	" :",$00
DSEP1
	FCB	" : ",$00
;IHEXER
;        FCB	":00000001FF",CR,LF,$00
;SRECER
;        FCB	"S9030000FC",CR,LF,$00

BRKMSG	FCB	"BRK!",CR,LF,$00
stpmsg	FCB	"Stop!",CR,LF,$00

RDSA	FCB	"A=",$00
RDSX	FCB	" X=",$00
RDSY	FCB	" Y=",$00
RDSSP	FCB	" SP=01",$00
RDSPC	FCB	" PC=",$00
RDSPSR	FCB	" PSR=",$00
psr_bm	fcb	"(NV1BDIZC)",CR,LF,0

RNTAB
	FCB	'A',1
	FDB	REGA,RNA
	FCB	'X',1
	FDB	REGX,RNX
	FCB	'Y',1
	FDB	REGY,RNY
	FCB	'S',$80
	FDB	RNTABS,0
	FCB	'P',$80
	FDB	RNTABP,0
	
	FCB	$00,0		; End mark
	FDB	0,0

RNTABS
	FCB	'P',1
	FDB	REGSP,RNSP
	
	FCB	$00,0		; End mark
	FDB	0,0

RNTABP
	FCB	'C',2
	FDB	REGPC,RNPC
	FCB	'S',$80
	FDB	RNTABPS,0

	FCB	$00,0		; End mark
	FDB	0,0

RNTABPS
	FCB	'R',1
	FDB	REGPSR,RNPSR

	FCB	$00,0		; End mark
	FDB	0,0
	
RNA	FCB	"A",$00
RNX	FCB	"X",$00
RNY	FCB	"Y",$00
RNSP	FCB	"SP",$00
RNPC	FCB	"PC",$00
RNPSR	FCB	"PSR",$00
	
;-----------------------------------
;	Key Input from CIN_BUF
;	CIN_SIZE $80 = 128bytes
;-----------------------------------
KEY_IN
	phx			; push x
	phy			; push y

	cli
keyin_loop
	lda	CIN_CT		; check key buffer counter
	beq	keyin_loop	; wait key in interrupt if no key data
	; get key from key buffer

	sei			; disable interrupt
	dec	CIN_CT
	ldy	CIN_RP		; key buffer read pointer

;	lda	(ZCIN_BP),y	; get key data
	lda	ZCIN_BP
	sta	zc_1
	lda	ZCIN_BP+1
	sta	zc_1+1
	db	$B9		; LDA $xxxx,y
zc_1:
	dw	0		; operand Absolute Indexed Y

	tax			; save key
	iny
	tya
	and	#$7f
	sta	CIN_RP
	txa
	cli
	ply
	plx
	rts

;-----------------------------------
; check key buffer
;-----------------------------------
KEY_CHK
	lda	CIN_CT		; check key buffer counter
	bne	kchk1
	rts
kchk1
	lda	#1
	rts

;-----------------------------------
; save output character to conout buffer
;-----------------------------------
PUT_CH
	phx
	phy
	pha
	tax
	cli
wai_putch
	lda	COUT_CT
	bmi	wai_putch	; wait buffer readyl if buffer full

	sei			; disable interrupt

	inc	COUT_CT
	ldy	COUT_WP
;	txa
;	sta	(ZCOUT_BP),y	; save character to buffer
	lda	ZCOUT_BP
	sta	zco_1
	lda	ZCOUT_BP+1
	sta	zco_1+1
	txa
	db	$99		; STA $xxxx,y
zco_1:
	dw	0		; operand Absolute Indexed Y
	
	iny
	tya
	and	#$7f
	sta	COUT_WP
	cli

	pla
	ply
	plx
	rts
	
;;;
;;;	Console Driver
;;;

;CONIN_REQ	EQU	0x01
;CONOUT_REQ	EQU	0x02
;CONST_REQ	EQU	0x03
;STROUT_REQ	equ	$04
;REQ_DREAD	equ	$05
;REQ_DWRITE	equ	$06
;STRIN_REQ	equ	$07
;WUP_REQ	equ	$ff
;  ---- request command to PIC
; UREQ_COM = 1   ; CONIN  : return char in UNI_CHR
;          = 2   ; CONOUT : UNI_CHR = output char
;          = 3   ; CONST  : return status in UNI_CHR
;                       : ( 0: no key, 1 : key exist )
;          = 4   ; STROUT : string address = (PTRSAV, PTRSAV_SEG)
;          = $FF ; wakeup firmware ( NMI interrupt )
;
;UREQ_COM	rmb	1	; unimon CONIN/CONOUT request command
;UNI_CHR	rmb	1	; charcter (CONIN/CONOUT) or number of strings

INIT
	; clear Reqest Parameter Block
;	lda	#0
	stz	UREQ_COM
	stz	CREQ_COM
	stz	disk_lba3
	stz	reserve
	stz	CIN_CT
	stz	CIN_RP
	stz	CIN_WP
	stz	COUT_CT
	stz	COUT_RP
	stz	COUT_WP
	stz	irq_tgl
;debug
;	sta	disk_track
;debug


	; save COUT_BUF address to zero page ZCOUT_BP
	LDA	#$FF&COUT_BUF
	STA	ZCOUT_BP
	LDA	#COUT_BUF>>8
	STA	ZCOUT_BP+1

	; save CIN_BUF address to zero page ZCIN_BP
	LDA	#$FF&CIN_BUF
	STA	ZCIN_BP
	LDA	#CIN_BUF>>8
	STA	ZCIN_BP+1

	RTS

;
; request CONIN, CONST CONOUT to PIC18F47QXX
;

CONIN
	lda	#CONIN_REQ

wup_pic
	sta	UREQ_COM
;wait_again
	wai			; RDY = 0, wait /IRQ detect
	
	lda	UNI_CHR
	RTS

CONST
	lda	#CONST_REQ
	jsr	wup_pic
	AND	#$01
	RTS

CONOUT
	pha
	sta	UNI_CHR		; set char
	lda	#CONOUT_REQ
	jsr	wup_pic
	pla
	rts

NMI_SIG
	lda	#WUP_REQ
	bra	wup_pic

DRV_INIT:
	stz	UREQ_COM
	stz	CREQ_COM
	stz	reserve
	stz     disk_lba2
	stz     disk_lba3
	rts

;
; input A:Y : Disk parameter table address
;
set_dpb:
	STA	lda_opr		; save input(A) : DPT low address
	dey
	dey	; Y
	lda	$100, y		; get Y
	sta	lda_opr+1	; save input(Y) : DPT high address

	ldx	#DPT_size-1
lpsetdpb:
	db	$BD		; LDA $nnnn,x
lda_opr:
	dw	0		; operand Absolute Indexed Y
	sta	disk_drive,x	; set disk paratemer
	dex
	bpl	lpsetdpb
	rts

;
; input A:Y : Disk parameter table address
; be only called by [brk 06] (bios call)
; and must disable interrupt
WRITE_SD:
	sei
	jsr	set_dpb
	lda	#REQ_DWRITE;

u_wup_pic
	sta	CREQ_COM
;wait_again
	wai			; RDY = 0, wait /IRQ detect
	
	lda	CBI_CHR
	RTS

;
; input A:Y : Disk parameter table address
; be only called by [brk 05] (bios call)
; and must disable interrupt
READ_SD:
	sei
	jsr	set_dpb
	lda	#REQ_DREAD;
	bra	u_wup_pic

	;;
	;; Vector area
	;; 

	ORG	$FFFA

	FDB	NMI_VEC		; NMI

	FDB	CSTART		; RESET

	FDB	IRQBRK		; IRQ/BRK

	END
