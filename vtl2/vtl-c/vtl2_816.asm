;;;
;;; MEZW65C_RAM VTL-C for W65C186
;;;
;;; -- original disassemble sorce code ------------------
;;; https://middleriver.chagasi.com/electronics/vtl.html
;;;
;;;  Very Tiny Language
;;;
;;;  T. Nakagawa
;;;------------------------------------------------------
;;;
;;; Ported for MEZW65C-RAM by Akihito Honda. 
;;; 2024.10
;;;
;;; Thanks all.
;;;

	pl	0
	pw      132
	chip    65816

	include "w65c816.inc"

;;;
;;; File header template (BIOS CALL version)
;;;	

PRG_B	EQU	$DF00
WORK_B	EQU	$400
WORK_END	EQU	$E8FF

USER_PB	equ	0	; program bank = 2
USER_DB	equ	0	; data bank = 0 (Direct Page area)
USER_DP	equ	$300
USER_SP	equ	USER_DP-1

ZERO_B	EQU	$00

;-----------------------------------------------------
;ZERO page
; NOTE
;  Since ZERO page is shared with the monitor program,
;  you must use a free area.
;  See the monitor program.
;-----------------------------------------------------

	.page0
	ORG	ZERO_B

;--------------------------------------
; Data area
;--------------------------------------

	udata
	org	WORK_B

Lct	ds	$8000

valst	equ	$
seed	ds	2
val_a	ds	2
val_x	ds	2
val_y	ds	2
remn	ds	2
div_y	ds	2	; quotient
div_x	ds	2

	CODE

	ORG	PRG_B
;--------- MEZW65C_RAM file header --------------------------
	db	USER_PB		; program bank:W65C816, 0:W65C02
	dw	COLD_START
	db	USER_DB		; data bank:W65C816, 0:W65C02
	dw	warm_boot

	dw	USER_DP		; DP

mezID:	db	"MEZW65C",0	; Unique ID

start_p:	;file load address
	dw	PRG_B		; load address (Low)
	db	USER_PB		; PBR : program bank(W65C816)
	db	0		; reserve

	; define Common memory address
PIC_IF:	dw	0	; reserve
	dw	0	; reserve

SW_816:	db	1	; 0 : W65C02
			; 1 : W65C816 native mode 
			; 2 : works in both modes
irq_sw	db	0	; 0 : no use IRQ console I/O
			; 1 : use IRQ timer interrupt driven console I/O
reg_tp	dw	0	; monitor reserve (register save pointer)
reg_ts	dw	0	; monitor reserve (register table size)
nmi_sw	db	0	; 0 : No NMI support, 1: NMI support
bios_sw	db	1	; 0 : standalone program
			; 1 : program call bios command
			; 2 : monitor program (.SYS)
;--------- MEZW65C_RAM file header --------------------------

L1:
	db	"VTL-C MEZW65C-RAM edition.",0
	db	13, 10,"OK",0

;;;
;;;     Console Driver
;;;
CONIN_NO	equ	1
CONOUT_NO	equ	2
CONST_NO	equ	3
PRG_END		equ	$FF
c_getch
	BRK	CONIN_NO
	rts

c_kbhit
	BRK	CONST_NO
	rts

getchr:
	BRK	CONIN_NO
	BRK	CONOUT_NO
	rts

; SP              -> 0          |
; PC(Low)           +1          v 
; PC(High)          +2   <- SP  0 --> Pull A ( return PC address ) 
; init val(Low)     +3          1    (set return address low )  (lda 1,s)
; init val(Higj)    +4          2    (set return address high)
putchr
	long_a
	lda	3,s	; get init value
	BRK	CONOUT_NO
	pla		; get return address
	sta	1,s	; set return address
	rts

rand
	long_a
	lda	seed
	eor	#$9630
	sbc	#$6553
	rol	a
	sta	seed
	rts

; SP              -> 0          |
; PC(Low)           +1          v 
; PC(High)          +2   <- SP  0 --> Pull A ( return PC address ) 
; init val(Low)     +3          1    (set return address low )  (lda 1,s)
; init val(Higj)    +4          2    (set return address high)
srand
	long_a
	lda	3,s	; get init value
	sta	seed
	pla		; get return address
	sta	1,s	; set return address
	rts

warm_boot
	long_a
	lda	#USER_SP
	tas
	pea	#1
	jsr	main
	
; Terminate VTL
mach_fin
	BRK	PRG_END
end_end	bra	end_end

COLD_START
	long_a
	lda	#USER_SP
	tas
	pea	#0
	jsr	main

mul:
	rep	#$30
	longa on
	longi on
	
	stx	val_x
	stz	val_y

	ldx	#16
	lsr	a
	sta	val_a
	bcs	add_x

add_loop
	asl	val_x
	lsr	val_a
	bcc	skip_add

add_x
	lda	val_y
	clc
	adc	val_x
	sta	val_y
	
skip_add
	dex
	bne	add_loop

end_add
	lda	val_y
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - ;
; 16-bit unsigned division routine
;	div_y /= div_x, {%} = remainder, {>} modified
;	div_y /= 0 produces {%} = div_y, div_y = 65535
;
;	input  A : div_y, X : div_x
;	output A : div_y
div:
	rep	#$30
	longa on
	longi on

	sta	div_y
	stx	div_x

	phy
	lda	#0
	sta	remn		; {%} = 0
	ldy	#16
div1:
	asl	div_y		; div_y is gradually replaced with the quotient

	rol	remn		; {%} is gradually replaced with the remainder

	lda	remn
	cmp	div_x		; partial remainder >= div_x?

	bcc	div2

	sbc	div_x
	sta	remn		; yes: update the partial remainder
				;	and set the low bit in the partial quotient
	
;	sep	#$20
;	longa	off
	inc	div_y
;	rep	#$20
;	longa	on

div2:
	dey
	bne	div1		; loop 16 times

	lda	remn
	sta	Lct+78		; set system valiable %
	lda	div_y		; A = quotient

	ply
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; VTL-C main program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;:ts=8
R0	equ	1
R1	equ	5
R2	equ	9
R3	equ	13
	code

breakCheck:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L2
	tcs
	phd
	tcd
c_1	set	0
	jsr	c_kbhit
	and	#$ff
	bne	L4
	brl	L10001
L4:
	jsr	c_getch
	sep	#$20
	longa	off
	sta	<L3+c_1
	rep	#$20
	longa	on
	sep	#$20
	longa	off
	lda	<L3+c_1
	cmp	#<$3
	rep	#$20
	longa	on
	beq	L5
	brl	L10002
L5:
	jsr	warm_boot
L10002:
L10001:
L6:
	pld
	tsc
	clc
	adc	#L2
	tcs
	rts
L2	equ	1
L3	equ	1

main:
	rep	#$30
	longa	on
	longi	on
	tsc
	sec
	sbc	#L7
	tcs
	phd
	tcd
key_0	set	3
ptr_1	set	0
n_1	set	2
	lda	<L7+key_0
	beq	L9
	brl	L10003
L9:
	lda	#$8000
	sta	Lct+88
	lda	#$108
	sta	Lct+80
	pea	#<$10118
	jsr	srand
	pea	#<L1
	jsr	putstr
L10003:
L10004:
	pea	#<L1+27
	jsr	putstr
L10006:
	lda	#$8a
	sta	<L8+ptr_1
	pei	<L8+ptr_1
	jsr	getln
	clc
	tdc
	adc	#<L8+n_1
	pha
	clc
	tdc
	adc	#<L8+ptr_1
	pha
	jsr	getnm
	tax
	beq	L10
	brl	L10007
L10:
line_2	set	4
	lda	#$88
	sta	<L8+line_2
	lda	#$0
	ldx	<L8+line_2
	sta	Lct,X
	stz	Lct+74
L10008:
	jsr	breakCheck
	pei	<L8+ptr_1
	jsr	ordr
	lda	Lct+74
	bne	L12
	brl	L11
L12:
	lda	Lct+74
	ldx	<L8+line_2
	cmp	Lct,X
	beq	L13
	brl	L10010
L13:
L11:
	lda	<L8+line_2
	cmp	#<$88
	bne	L14
	brl	L10009
L14:
	pei	<L8+line_2
	jsr	nxtln
	sta	<L8+line_2
	lda	<L8+line_2
	cmp	Lct+80
	bne	L15
	brl	L10009
L15:
	brl	L10011
L10010:
	ldx	<L8+line_2
	lda	Lct,X
	ina
	sta	Lct+70
	clc
	tdc
	adc	#<L8+line_2
	pha
	jsr	fndln
	tax
	beq	L16
	brl	L10009
L16:
L10011:
	ldx	<L8+line_2
	lda	Lct,X
	sta	Lct+74
	clc
	lda	#$3
	adc	<L8+line_2
	sta	<L8+ptr_1
	brl	L10008
L10009:
	brl	L10012
L10007:
	lda	<L8+n_1
	beq	L17
	brl	L10013
L17:
	lda	#$108
	sta	<L8+ptr_1
L10014:
	lda	<L8+ptr_1
	cmp	Lct+80
	bne	L18
	brl	L10015
L18:
	jsr	breakCheck
	ldx	<L8+ptr_1
	lda	Lct,X
	pha
	jsr	putnm
	inc	<L8+ptr_1
	inc	<L8+ptr_1
	pea	#<$0
	clc
	tdc
	adc	#<L8+ptr_1
	pha
	jsr	putl
	jsr	crlf
	brl	L10014
L10015:
	brl	L10016
L10013:
cur_3	set	4
src_3	set	6
dst_3	set	8
tmp_3	set	10
m_3	set	12
	lda	<L8+n_1
	sta	Lct+74
	clc
	tdc
	adc	#<L8+cur_3
	pha
	jsr	fndln
	tax
	beq	L19
	brl	L10017
L19:
	ldx	<L8+cur_3
	lda	Lct,X
	cmp	<L8+n_1
	beq	L20
	brl	L10017
L20:
	pei	<L8+cur_3
	jsr	nxtln
	sta	<L8+src_3
	lda	<L8+cur_3
	sta	<L8+dst_3
	brl	L10019
L10018:
	sep	#$20
	longa	off
	ldx	<L8+src_3
	lda	Lct,X
	ldx	<L8+dst_3
	sta	Lct,X
	rep	#$20
	longa	on
	inc	<L8+src_3
	inc	<L8+dst_3
L10019:
	lda	<L8+src_3
	cmp	Lct+80
	bne	L21
	brl	L10020
L21:
	brl	L10018
L10020:
	lda	<L8+dst_3
	sta	Lct+80
L10017:
	ldx	<L8+ptr_1
	lda	Lct,X
	and	#$ff
	bne	L22
	brl	L10006
L22:
	lda	#$3
	sta	<L8+m_3
	lda	<L8+ptr_1
	sta	<L8+tmp_3
	brl	L10022
L10021:
	inc	<L8+tmp_3
	inc	<L8+m_3
L10022:
	ldx	<L8+tmp_3
	lda	Lct,X
	and	#$ff
	bne	L23
	brl	L10023
L23:
	brl	L10021
L10023:
	clc
	lda	Lct+80
	adc	<L8+m_3
	sta	<R0
	lda	<R0
	cmp	Lct+88
	bcc	L24
	brl	L10024
L24:
	lda	Lct+80
	sta	<L8+src_3
	clc
	lda	Lct+80
	adc	<L8+m_3
	sta	Lct+80
	lda	Lct+80
	sta	<L8+dst_3
	brl	L10026
L10025:
	dec	<L8+dst_3
	dec	<L8+src_3
	sep	#$20
	longa	off
	ldx	<L8+src_3
	lda	Lct,X
	ldx	<L8+dst_3
	sta	Lct,X
	rep	#$20
	longa	on
L10026:
	lda	<L8+src_3
	cmp	<L8+cur_3
	bne	L25
	brl	L10027
L25:
	brl	L10025
L10027:
	lda	<L8+n_1
	ldx	<L8+src_3
	sta	Lct,X
	inc	<L8+src_3
	inc	<L8+src_3
L10028:
	lda	<L8+src_3
	sta	<R0
	inc	<L8+src_3
	lda	<L8+ptr_1
	sta	<R1
	inc	<L8+ptr_1
	sep	#$20
	longa	off
	ldx	<R1
	lda	Lct,X
	ldx	<R0
	sta	Lct,X
	rep	#$20
	longa	on
	ldx	<R1
	lda	Lct,X
	and	#$ff
	bne	L26
	brl	L10029
L26:
	brl	L10028
L10029:
	brl	L10006
L10024:
L10016:
L10012:
	brl	L10004
L7	equ	22
L8	equ	9

fndln:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L28
	tcs
	phd
	tcd
ptr_0	set	3
	lda	#$108
	sta	(<L28+ptr_0)
	brl	L10031
L10030:
	lda	(<L28+ptr_0)
	pha
	jsr	nxtln
	sta	(<L28+ptr_0)
L10031:
	lda	(<L28+ptr_0)
	cmp	Lct+80
	bne	L30
	brl	L10032
L30:
	lda	(<L28+ptr_0)
	sta	<R0
	ldx	<R0
	lda	Lct,X
	cmp	Lct+74
	bcs	L31
	brl	L10033
L31:
	lda	#$0
L32:
	tay
	lda	<L28+1
	sta	<L28+1+2
	pld
	tsc
	clc
	adc	#L28+2
	tcs
	tya
	rts
L10033:
	brl	L10030
L10032:
	lda	#$1
	brl	L32
L28	equ	4
L29	equ	5
	
nxtln:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L33
	tcs
	phd
	tcd
ptr_0	set	3
	inc	<L33+ptr_0
	inc	<L33+ptr_0
L10034:
	lda	<L33+ptr_0
	sta	<R0
	inc	<L33+ptr_0
	ldx	<R0
	lda	Lct,X
	and	#$ff
	bne	L35
	brl	L10035
L35:
	brl	L10034
L10035:
	lda	<L33+ptr_0
L36:
	tay
	lda	<L33+1
	sta	<L33+1+2
	pld
	tsc
	clc
	adc	#L33+2
	tcs
	tya
	rts
L33	equ	4
L34	equ	5

getln:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L37
	tcs
	phd
	tcd
lbf_0	set	3
p_1	set	0
c_1	set	2
	stz	<L38+p_1
L10036:
	jsr	getchr
	sep	#$20
	longa	off
	sta	<L38+c_1
	rep	#$20
	longa	on
	sep	#$20
	longa	off
	lda	<L38+c_1
	cmp	#<$8
	rep	#$20
	longa	on
	beq	L39
	brl	L10038
L39:
	sec
	lda	#$0
	sbc	<L38+p_1
	bvs	L40
	eor	#$8000
L40:
	bpl	L41
	brl	L10039
L41:
	dec	<L38+p_1
L10039:
	brl	L10040
L10038:
	sep	#$20
	longa	off
	lda	<L38+c_1
	cmp	#<$d
	rep	#$20
	longa	on
	beq	L42
	brl	L10041
L42:
	clc
	lda	<L37+lbf_0
	adc	<L38+p_1
	sta	<R0
	sep	#$20
	longa	off
	lda	#$0
	ldx	<R0
	sta	Lct,X
	rep	#$20
	longa	on
	pea	#<$a
	jsr	putchr
L43:
	lda	<L37+1
	sta	<L37+1+2
	pld
	tsc
	clc
	adc	#L37+2
	tcs
	rts
L10041:
	sep	#$20
	longa	off
	lda	<L38+c_1
	cmp	#<$15
	rep	#$20
	longa	on
	bne	L45
	brl	L44
L45:
	lda	<L38+p_1
	ina
	sta	<R0
	lda	<R0
	cmp	#<$4a
	beq	L46
	brl	L10042
L46:
L44:
	jsr	crlf
	stz	<L38+p_1
	brl	L10043
L10042:
	sep	#$20
	longa	off
	lda	#$1f
	cmp	<L38+c_1
	rep	#$20
	longa	on
	bcs	L47
	brl	L10044
L47:
	brl	L10045
L10044:
	clc
	lda	<L38+p_1
	adc	<L37+lbf_0
	sta	<R0
	sep	#$20
	longa	off
	lda	<L38+c_1
	ldx	<R0
	sta	Lct,X
	rep	#$20
	longa	on
	inc	<L38+p_1
L10045:
L10043:
L10040:
	brl	L10036
L37	equ	7
L38	equ	5

getnm:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L48
	tcs
	phd
	tcd
ptr_0	set	3
n_0	set	5
	lda	(<L48+ptr_0)
	pha
	jsr	num
	tax
	beq	L50
	brl	L10046
L50:
	lda	#$0
L51:
	tay
	lda	<L48+1
	sta	<L48+1+4
	pld
	tsc
	clc
	adc	#L48+4
	tcs
	tya
	rts
L10046:
	lda	#$0
	sta	(<L48+n_0)
L10049:
	lda	(<L48+n_0)
	asl	A
	asl	A
	adc	(<L48+n_0)
	asl	A
	sta	(<L48+n_0)
	lda	(<L48+ptr_0)
	sta	<R0
	lda	(<L48+ptr_0)
	ina
	sta	(<L48+ptr_0)
	ldx	<R0
	lda	Lct,X
	and	#$ff
	sta	<R1
	clc
	lda	<R1
	adc	(<L48+n_0)
	sta	<R2
	clc
	lda	#$ffd0
	adc	<R2
	sta	(<L48+n_0)
L10047:
	lda	(<L48+ptr_0)
	pha
	jsr	num
	tax
	beq	L52
	brl	L10049
L52:
L10048:
	lda	#$1
	brl	L51
L48	equ	12
L49	equ	13

num:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L53
	tcs
	phd
	tcd
ptr_0	set	3
	stz	<R0
	sep	#$20
	longa	off
	ldx	<L53+ptr_0
	lda	Lct,X
	cmp	#<$30
	rep	#$20
	longa	on
	bcs	L56
	brl	L55
L56:
	sep	#$20
	longa	off
	lda	#$39
	ldx	<L53+ptr_0
	cmp	Lct,X
	rep	#$20
	longa	on
	bcs	L57
	brl	L55
L57:
	inc	<R0
L55:
	lda	<R0
L58:
	tay
	lda	<L53+1
	sta	<L53+1+2
	pld
	tsc
	clc
	adc	#L53+2
	tcs
	tya
	rts
L53	equ	4
L54	equ	5

ordr:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L59
	tcs
	phd
	tcd
ptr_0	set	3
c_1	set	0
adr_1	set	1
	clc
	tdc
	adc	#<L60+adr_1
	pha
	clc
	tdc
	adc	#<L60+c_1
	pha
	clc
	tdc
	adc	#<L59+ptr_0
	pha
	jsr	getvr
	inc	<L59+ptr_0
	sep	#$20
	longa	off
	ldx	<L59+ptr_0
	lda	Lct,X
	cmp	#<$22
	rep	#$20
	longa	on
	beq	L61
	brl	L10050
L61:
	inc	<L59+ptr_0
	pea	#<$22
	clc
	tdc
	adc	#<L59+ptr_0
	pha
	jsr	putl
	sep	#$20
	longa	off
	ldx	<L59+ptr_0
	lda	Lct,X
	cmp	#<$3b
	rep	#$20
	longa	on
	bne	L62
	brl	L10051
L62:
	jsr	crlf
L10051:
	brl	L10052
L10050:
val_2	set	3
	clc
	tdc
	adc	#<L60+val_2
	pha
	clc
	tdc
	adc	#<L59+ptr_0
	pha
	jsr	expr
	sep	#$20
	longa	off
	lda	<L60+c_1
	cmp	#<$24
	rep	#$20
	longa	on
	beq	L63
	brl	L10053
L63:
	lda	<L60+val_2
	and	#<$ff
	pha
	jsr	putchr
	brl	L10054
L10053:
	lda	<L60+c_1
	and	#$ff
	sta	<R0
	clc
	lda	#$ffc1
	adc	<R0
	sep	#$20
	longa	off
	sta	<L60+c_1
	rep	#$20
	longa	on
	lda	<L60+c_1
	and	#$ff
	beq	L64
	brl	L10055
L64:
	pei	<L60+val_2
	jsr	putnm
	brl	L10056
L10055:
r_3	set	5
	lda	<L60+val_2
	ldx	<L60+adr_1
	sta	Lct,X
	jsr	rand
	sta	<L60+r_3
	lda	<L60+r_3
	sta	Lct+82
L10056:
L10054:
L10052:
L65:
	lda	<L59+1
	sta	<L59+1+2
	pld
	tsc
	clc
	adc	#L59+2
	tcs
	rts
L59	equ	11
L60	equ	5

expr:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L66
	tcs
	phd
	tcd
ptr_0	set	3
val_0	set	5
c_1	set	0
	pei	<L66+val_0
	pei	<L66+ptr_0
	jsr	factr
L10057:
	lda	(<L66+ptr_0)
	sta	<R0
	sep	#$20
	longa	off
	ldx	<R0
	lda	Lct,X
	sta	<L67+c_1
	rep	#$20
	longa	on
	lda	<L67+c_1
	and	#$ff
	bne	L68
	brl	L10058
L68:
	sep	#$20
	longa	off
	lda	<L67+c_1
	cmp	#<$29
	rep	#$20
	longa	on
	bne	L69
	brl	L10058
L69:
	pei	<L66+val_0
	pei	<L66+ptr_0
	jsr	term
	brl	L10057
L10058:
	lda	(<L66+ptr_0)
	ina
	sta	(<L66+ptr_0)
L70:
	lda	<L66+1
	sta	<L66+1+4
	pld
	tsc
	clc
	adc	#L66+4
	tcs
	rts
L66	equ	5
L67	equ	5

factr:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L71
	tcs
	phd
	tcd
ptr_0	set	3
val_0	set	5
c_1	set	0
	lda	(<L71+ptr_0)
	sta	<R0
	ldx	<R0
	lda	Lct,X
	and	#$ff
	beq	L73
	brl	L10059
L73:
	lda	#$0
	sta	(<L71+val_0)
L74:
	lda	<L71+1
	sta	<L71+1+4
	pld
	tsc
	clc
	adc	#L71+4
	tcs
	rts
L10059:
	pei	<L71+val_0
	pei	<L71+ptr_0
	jsr	getnm
	tax
	bne	L75
	brl	L10060
L75:
	brl	L74
L10060:
	lda	(<L71+ptr_0)
	sta	<R0
	sep	#$20
	longa	off
	ldx	<R0
	lda	Lct,X
	sta	<L72+c_1
	rep	#$20
	longa	on
	lda	(<L71+ptr_0)
	ina
	sta	(<L71+ptr_0)
	sep	#$20
	longa	off
	lda	<L72+c_1
	cmp	#<$3f
	rep	#$20
	longa	on
	beq	L76
	brl	L10061
L76:
tmp_2	set	1
	lda	#$88
	sta	<L72+tmp_2
	pei	<L72+tmp_2
	jsr	getln
	pei	<L71+val_0
	clc
	tdc
	adc	#<L72+tmp_2
	pha
	jsr	expr
	brl	L10062
L10061:
	sep	#$20
	longa	off
	lda	<L72+c_1
	cmp	#<$24
	rep	#$20
	longa	on
	beq	L77
	brl	L10063
L77:
	jsr	getchr
	sep	#$20
	longa	off
	sta	<R0
	rep	#$20
	longa	on
	lda	<R0
	and	#$ff
	sta	(<L71+val_0)
	brl	L10064
L10063:
	sep	#$20
	longa	off
	lda	<L72+c_1
	cmp	#<$28
	rep	#$20
	longa	on
	beq	L78
	brl	L10065
L78:
	pei	<L71+val_0
	pei	<L71+ptr_0
	jsr	expr
	brl	L10066
L10065:
adr_3	set	1
	clc
	lda	#$ffff
	adc	(<L71+ptr_0)
	sta	(<L71+ptr_0)
	clc
	tdc
	adc	#<L72+adr_3
	pha
	clc
	tdc
	adc	#<L72+c_1
	pha
	pei	<L71+ptr_0
	jsr	getvr
	ldx	<L72+adr_3
	lda	Lct,X
	sta	(<L71+val_0)
L10066:
L10064:
L10062:
	brl	L74
L71	equ	7
L72	equ	5

term:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L79
	tcs
	phd
	tcd
ptr_0	set	3
val_0	set	5
c_1	set	0
val2_1	set	1
	lda	(<L79+ptr_0)
	sta	<R0
	sep	#$20
	longa	off
	ldx	<R0
	lda	Lct,X
	sta	<L80+c_1
	rep	#$20
	longa	on
	lda	(<L79+ptr_0)
	ina
	sta	(<L79+ptr_0)
	clc
	tdc
	adc	#<L80+val2_1
	pha
	pei	<L79+ptr_0
	jsr	factr
	sep	#$20
	longa	off
	lda	<L80+c_1
	cmp	#<$2a
	rep	#$20
	longa	on
	beq	L81
	brl	L10067
L81:
	lda	(<L79+val_0)
	ldx	<L80+val2_1
	jsr	mul
	sta	(<L79+val_0)
	brl	L10068
L10067:
	sep	#$20
	longa	off
	lda	<L80+c_1
	cmp	#<$2b
	rep	#$20
	longa	on
	beq	L82
	brl	L10069
L82:
	clc
	lda	(<L79+val_0)
	adc	<L80+val2_1
	sta	(<L79+val_0)
	brl	L10070
L10069:
	sep	#$20
	longa	off
	lda	<L80+c_1
	cmp	#<$2d
	rep	#$20
	longa	on
	beq	L83
	brl	L10071
L83:
	sec
	lda	(<L79+val_0)
	sbc	<L80+val2_1
	sta	(<L79+val_0)
	brl	L10072
L10071:
	sep	#$20
	longa	off
	lda	<L80+c_1
	cmp	#<$2f		; "/"
	rep	#$20
	longa	on
	beq	L84
	brl	L10073
L84:
;	lda	(<L79+val_0)
;	ldx	<L80+val2_1
;	jsr	umd
;	sta	Lct+78		; system valiable %
	lda	(<L79+val_0)	; *val /= val2
	ldx	<L80+val2_1	; (A = *val, X = val2)
	jsr	div
	sta	(<L79+val_0)
	brl	L10074
L10073:
	sep	#$20
	longa	off
	lda	<L80+c_1
	cmp	#<$3d
	rep	#$20
	longa	on
	beq	L85
	brl	L10075
L85:
	stz	<R0
	lda	(<L79+val_0)
	cmp	<L80+val2_1
	beq	L87
	brl	L86
L87:
	inc	<R0
L86:
	lda	<R0
	sta	(<L79+val_0)
	brl	L10076
L10075:
	sep	#$20
	longa	off
	lda	<L80+c_1
	cmp	#<$3e
	rep	#$20
	longa	on
	beq	L88
	brl	L10077
L88:
	stz	<R0
	lda	(<L79+val_0)
	cmp	<L80+val2_1
	bcs	L90
	brl	L89
L90:
	inc	<R0
L89:
	lda	<R0
	sta	(<L79+val_0)
	brl	L10078
L10077:
	stz	<R0
	lda	(<L79+val_0)
	cmp	<L80+val2_1
	bcc	L92
	brl	L91
L92:
	inc	<R0
L91:
	lda	<R0
	sta	(<L79+val_0)
L10078:
L10076:
L10074:
L10072:
L10070:
L10068:
L93:
	lda	<L79+1
	sta	<L79+1+4
	pld
	tsc
	clc
	adc	#L79+4
	tcs
	rts
L79	equ	7
L80	equ	5

getvr:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L94
	tcs
	phd
	tcd
ptr_0	set	3
c_0	set	5
adr_0	set	7
val_1	set	0
	lda	(<L94+ptr_0)
	sta	<R0
	sep	#$20
	longa	off
	ldx	<R0
	lda	Lct,X
	sta	(<L94+c_0)
	rep	#$20
	longa	on
	lda	(<L94+ptr_0)
	ina
	sta	(<L94+ptr_0)
	sep	#$20
	longa	off
	lda	(<L94+c_0)
	cmp	#<$3a
	rep	#$20
	longa	on
	beq	L96
	brl	L10079
L96:
	clc
	tdc
	adc	#<L95+val_1
	pha
	pei	<L94+ptr_0
	jsr	expr
	lda	<L95+val_1
	asl	A
	sta	<R0
	clc
	lda	<R0
	adc	Lct+80
	sta	(<L94+adr_0)
	brl	L10080
L10079:
	sep	#$20
	longa	off
	lda	(<L94+c_0)
	cmp	#<$7f
	rep	#$20
	longa	on
	beq	L97
	brl	L10081
L97:
	jsr	mach_fin
;	brl	L10082
L10081:
	lda	(<L94+c_0)
	and	#<$3f
	sta	<R1
	lda	<R1
	asl	A
	sta	<R0
	clc
	lda	#$4
	adc	<R0
	sta	(<L94+adr_0)
L10082:
L10080:
L98:
	lda	<L94+1
	sta	<L94+1+6
	pld
	tsc
	clc
	adc	#L94+6
	tcs
	rts
L94	equ	10
L95	equ	9

putl:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L99
	tcs
	phd
	tcd
ptr_0	set	3
d_0	set	5
L10083:
	lda	(<L99+ptr_0)
	sta	<R0
	sep	#$20
	longa	off
	ldx	<R0
	lda	Lct,X
	cmp	<L99+d_0
	rep	#$20
	longa	on
	bne	L101
	brl	L10084
L101:
	lda	(<L99+ptr_0)
	sta	<R0
	lda	(<L99+ptr_0)
	ina
	sta	(<L99+ptr_0)
	ldx	<R0
	lda	Lct,X
	pha
	jsr	putchr
	brl	L10083
L10084:
	lda	(<L99+ptr_0)
	ina
	sta	(<L99+ptr_0)
L102:
	lda	<L99+1
	sta	<L99+1+4
	pld
	tsc
	clc
	adc	#L99+4
	tcs
	rts
L99	equ	4
L100	equ	5

crlf:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L103
	tcs
	phd
	tcd
	pea	#<$d
	jsr	putchr
	pea	#<$a
	jsr	putchr
L105:
	pld
	tsc
	clc
	adc	#L103
	tcs
	rts
L103	equ	0
L104	equ	1

putnm:
	longa	on
	longi	on

	tsc
	sec
	sbc	#L106	; A' = sp-7
	tcs		; sp = A'

	phd
	tcd		; A - > DP
	lda	Lct+78		; %
	pha			; save %
	
x_0	set	3
ptr_1	set	0
y_1	set	2
	lda	#$87
	sta	<L107+ptr_1
	sep	#$20
	longa	off
	lda	#$0
	ldx	<L107+ptr_1
	sta	Lct,X
	rep	#$20
	longa	on

L10087:
	lda	<L106+x_0
	ldx	#<$a
	jsr	div
	sta	<L106+x_0

	lda	Lct+78		; %
	sta	<R0
	sep	#$20
	longa	off
	lda	<R0
	sta	<L107+y_1
	rep	#$20
	longa	on

	dec	<L107+ptr_1
	sep	#$20
	longa	off
	clc
	lda	#$30
	adc	<L107+y_1
	rep	#$20
	longa	on
	sep	#$20
	longa	off
	ldx	<L107+ptr_1
	sta	Lct,X
	rep	#$20
	longa	on
L10085:
	lda	<L106+x_0
	beq	L108
	bra	L10087
L108:
	pea	#<$0
	clc
	tdc
	adc	#<L107+ptr_1
	pha
	jsr	putl
	lda	<L106+1
	sta	<L106+1+2

	pla
	sta	Lct+78		; restore %
	pld

	tsc			; a = sp
	clc
	adc	#L106+2
	tcs
	rts
L106	equ	7
L107	equ	5

putstr:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L110
	tcs
	phd
	tcd
str_0	set	3
L10088:
	lda	(<L110+str_0)
	and	#$ff
	bne	L112
	brl	L10089
L112:
	lda	<L110+str_0
	sta	<R0
	inc	<L110+str_0
	lda	(<R0)
	pha
	jsr	putchr
	brl	L10088
L10089:
	jsr	crlf
L113:
	lda	<L110+1
	sta	<L110+1+2
	pld
	tsc
	clc
	adc	#L110+2
	tcs
	rts
L110	equ	4
L111	equ	5
	
	ds	$10000-$
	end

