;;;
;;;	GAME Language interpreter ,Takeoka ver.
;;;	by Shozo TAKEOKA (http://www.takeoka.org/~take/ )
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

PRG_B	EQU	$D100
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

;	.page0
;	ORG	ZERO_B

;--------------------------------------
; Data area
;--------------------------------------

	udata
	org	WORK_B

text_buf	ds	$7800
mm		ds	4
var		ds	256
lno		ds	2
stack		ds	200
sp		ds	2
pc		ds	2
lky_buf	ds	160
lin		ds	160

seed1	ds	2
seed2	ds	2
rand_v1	ds	2
rand_v2	ds	2

val_a	ds	2
val_x	ds	2
val_y	ds	2
remn	ds	2
div_y	ds	2	; quotient
div_x	ds	2
negf	ds	2

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

; SP              -> 0          |
; PC(Low)           +1          v 
; PC(High)          +2   <- SP  0 --> Pull A ( return PC address ) 
; init val(Low)     +3          1    (set return address low )  (lda 1,s)
; init val(Higj)    +4          2    (set return address high)
c_putch
	long_a
	lda	3,s	; get init value
	BRK	CONOUT_NO
	pla		; get return address
	sta	1,s	; set return address
	rts

rand
	long_a
	lda	seed1
	sta	rand_v2
	asl	a
	lda	seed2
	rol	a
	sta	rand_v1
	lda	seed1+1
	eor	rand_v1
	sta	seed1
	lda	rand_v2
	sta	seed2
	lda	seed1
	rts

; SP              -> 0          |
; PC(Low)           +1          v 
; PC(High)          +2   <- SP  0 --> Pull A ( return PC address ) 
; init val(Low)     +3          1    (set return address low )  (lda 1,s)
; init val(Higj)    +4          2    (set return address high)
srand
	long_a
	lda	3,s	; get init value
	sta	seed1
	sta	seed2

	pla		; get return address
	sta	1,s	; set return address
	rts

warm_boot
	long_ai
	lda	#USER_SP
	tas
	pea	#1
	jsr	main
	
; Terminate VTL
mach_fin
	BRK	PRG_END
end_end	bra	end_end

COLD_START
	long_ai
	lda	#USER_SP
	tas
	pea	#0
	jsr	main

mul:
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
; 16-bit signed division routine
;	div_y /= div_x, {%} = remainder, {>} modified
;	div_y /= 0 produces {%} = div_y, div_y = -32768 - 32767
;
;	input  A : div_y, X : div_x
;	output A : div_y
div:
	longa on
	longi on

	stz	negf
	sta	div_y
	stx	div_x

	bit	#$8000
	beq	neg_div1
	inc	negf
	eor	#$FFFF
	inc	a
	sta	div_y
	
neg_div1
	txa
	bit	#$8000
	beq	neg_div2
	inc	negf
	eor	#$FFFF
	inc	a
	sta	div_x

neg_div2
	lda	div_y
	ldx	div_x
	jsr	u_div

	lda	negf
	bit	#$0001
	bne	neg_div3
	lda	div_y
	rts
	
neg_div3
	lda	div_y
	eor	#$FFFF
	inc	a
	sta	div_y
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - ;
; 16-bit unsigned division routine
;	div_y /= div_x, {%} = remainder, {>} modified
;	div_y /= 0 produces {%} = div_y, div_y = 65535
;
;	input  A : div_y, X : div_x
;	output A : div_y
u_div:
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
	
	inc	div_y

div2:
	dey
	bne	div1		; loop 16 times

	lda	remn
	sta	var+74	; set system valiable %
	lda	div_y		; A = quotient

	ply
	rts
	
mod:
	longa on
	longi on

	sta	div_y
	stx	div_x

	phy
	lda	#0
	sta	remn		; {%} = 0
	ldy	#16
mod1:
	asl	div_y		; div_y is gradually replaced with the quotient

	rol	remn		; {%} is gradually replaced with the remainder

	lda	remn
	cmp	div_x		; partial remainder >= div_x?

	bcc	mod2

	sbc	div_x
	sta	remn		; yes: update the partial remainder
				;	and set the low bit in the partial quotient
	
	inc	div_y

mod2:
	dey
	bne	mod1		; loop 16 times

	lda	remn

	ply
	rts
;
;switch - case: jump function
;ex)
;pppp
;	db	01
;	db	00
;	db	00
;	db	00
;	db	label1(L)-1
;	db	label1(H)
;	db	label2(L)-1
;	db	label2(H)
;
; input A : switch( A )

	longa	on
	longi	on
swt:
	plx
;SP->
;  |	PC(L)-1 : pppp(L) -1
;  v
;SP->	PC(H)   : pppp(H)

	inx	; get table address

	ldy	0,x	; Y : get no of tables ($0007)

	inx
	inx		; compare value address
loop_sw:
	cmp	0,x
	beq	go_jmp
	inx		;+1
	inx		;+2
	inx		;+3
	inx		;+4 : next address of compare value
	dey
	bne	loop_sw
	; no much
psh_ret:
	lda	0,x	; escape switch 
	pha		; push jump address
	rts
	
go_jmp:
	inx
	inx
	bra	psh_ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GAME-C main program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;:ts=8

R0	equ	1
R1	equ	5
R2	equ	9
R3	equ	13

c_puts:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L2
	tcs
	phd
	tcd
s_0	set	3
L10001:
	lda	(<L2+s_0)
	and	#$ff
	bne	L4
	brl	L10002
L4:
	lda	<L2+s_0
	sta	<R0
	inc	<L2+s_0
	lda	(<R0)
	and	#$ff
	pha
	jsr	c_putch
	brl	L10001
L10002:
L5:
	lda	<L2+1
	sta	<L2+1+2
	pld
	tsc
	clc
	adc	#L2+2
	tcs
	rts
L2	equ	4
L3	equ	5

open_msg:	dw	L1+0
L1:		db	"GAME-C MEZW65C_RAM Edition",13,10,0

rdy_msg:	dw	L6+0
L6:		db	"*READY",13,10,0

t_lock:	dw	L7+0
L7:		db	'1',0

main:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L9
	tcs
	phd
	tcd
st_flg_0	set	3
n_1	set	0
x_1	set	2
cnt_1	set	4
	lda	<L9+st_flg_0
	and	#$ff
	beq	L11
	brl	L10003
L11:
	pea	#<$1966
	jsr	srand
	lda	#<text_buf
	sta	var+122
	lda	#$7fff
	sta	var+84
	jsr	newText1
	lda	open_msg
	pha
	jsr	c_puts
L10003:
	lda	rdy_msg
	pha
	jsr	c_puts
L10004:
	lda	#$ffff
	sta	sp
	stz	lno
	pea	#<lin
	jsr	c_gets
	sta	<L10+cnt_1
	lda	#<lin
	ina
	sta	<R0
	clc
	lda	<R0
	adc	<L10+cnt_1
	sta	<R1
	sep	#$20
	longa	off
	lda	#$80
	sta	(<R1)
	rep	#$20
	longa	on
	lda	#<lin
	sta	pc
	jsr	skipBlank
	clc
	tdc
	adc	#<L10+x_1
	pha
	jsr	getNum
	sta	<L10+n_1
	lda	<L10+x_1
	beq	L12
	brl	L10006
L12:
	jsr	exqt
	jsr	newline
	lda	rdy_msg
	pha
	jsr	c_puts
	brl	L10007
L10006:
	pei	<L10+n_1
	jsr	edit
L10007:
	brl	L10004
L9	equ	14
L10	equ	9

skipLine:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L13
	tcs
	phd
	tcd
p_0	set	3
L10008:
	lda	(<L13+p_0)
	and	#$ff
	bne	L15
	brl	L10009
L15:
	inc	<L13+p_0
	brl	L10008
L10009:
	lda	<L13+p_0
	ina
	sta	<R0
	lda	<R0
L16:
	tay
	lda	<L13+1
	sta	<L13+1+2
	pld
	tsc
	clc
	adc	#L13+2
	tcs
	tya
	rts
L13	equ	4
L14	equ	5

searchLine:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L17
	tcs
	phd
	tcd
n_0	set	3
f_0	set	5
p_1	set	0
l_1	set	2
	lda	var+122
	sta	<L18+p_1
L10010:
	sep	#$20
	longa	off
	lda	(<L18+p_1)
	and	#<$80
	rep	#$20
	longa	on
	beq	L19
	brl	L10011
L19:
	lda	(<L18+p_1)
	xba			; A(low) <-> A(high)
	sta	<L18+l_1
	lda	<L17+n_0
	cmp	<L18+l_1
	beq	L20
	brl	L10012
L20:
	lda	#$1
	sta	(<L17+f_0)
	lda	<L18+p_1
L21:
	tay
	lda	<L17+1
	sta	<L17+1+4
	pld
	tsc
	clc
	adc	#L17+4
	tcs
	tya
	rts
L10012:
	sec
	lda	<L17+n_0
	sbc	<L18+l_1
	bvs	L22
	eor	#$8000
L22:
	bpl	L23
	brl	L10013
L23:
	lda	#$0
	sta	(<L17+f_0)
	lda	<L18+p_1
	brl	L21
L10013:
	clc
	lda	#$2
	adc	<L18+p_1
	sta	<R0
	pei	<R0
	jsr	skipLine
	sta	<L18+p_1
	brl	L10010
L10011:
	lda	#$0
	sta	(<L17+f_0)
	lda	<L18+p_1
	brl	L21
L17	equ	12
L18	equ	9

edit:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L24
	tcs
	phd
	tcd
n_0	set	3
p_1	set	0
f_1	set	2
	lda	<L24+n_0
	beq	L26
	brl	L10014
L26:
	lda	var+122
	pha
	jsr	dispList
	pea	#<$0
	jsr	w_boot
L10014:
	clc
	tdc
	adc	#<L25+f_1
	pha
	pei	<L24+n_0
	jsr	searchLine
	sta	<L25+p_1
	lda	pc
	sta	<R0
	sep	#$20
	longa	off
	lda	(<R0)
	cmp	#<$2f
	rep	#$20
	longa	on
	beq	L27
	brl	L10015
L27:
	pei	<L25+p_1
	jsr	dispList
	pea	#<$0
	jsr	w_boot
	brl	L10016
L10015:
	lda	var+76
	sta	<R0
	sep	#$20
	longa	off
	lda	(<R0)
	cmp	#<$ff
	rep	#$20
	longa	on
	bne	L28
	brl	L10017
L28:
	lda	t_lock
	pha
	jsr	er_boot
L10017:
	lda	<L25+f_1
	bne	L29
	brl	L10018
L29:
	pei	<L25+p_1
	jsr	deleteLine
L10018:
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	beq	L30
	brl	L10019
L30:
	lda	#$0
L31:
	tay
	lda	<L24+1
	sta	<L24+1+2
	pld
	tsc
	clc
	adc	#L24+2
	tcs
	tya
	rts
L10019:
	lda	pc
	pha
	pei	<L25+p_1
	pei	<L24+n_0
	jsr	addLine
L10016:
	lda	#$0
	brl	L31
L24	equ	8
L25	equ	5

addLine:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L32
	tcs
	phd
	tcd
n_0	set	3
p_0	set	5
new_0	set	7
l_1	set	0
	pei	<L32+new_0
	jsr	strlen
	sta	<R0
	clc
	lda	#$3
	adc	<R0
	sta	<L33+l_1
	sec
	lda	var+76
	sbc	<L32+p_0
	sta	<R0
	lda	<R0
	ina
	pha
	pei	<L32+p_0
	clc
	lda	<L32+p_0
	adc	<L33+l_1
	sta	<R0
	pei	<R0
	jsr	memmove
	lda	<L32+n_0
	xba			; A(low) <-> A(high)
	sta	(<L32+p_0)
	pei	<L32+new_0
	clc
	lda	#$2
	adc	<L32+p_0
	sta	<R0
	pei	<R0
	jsr	strcpy
	clc
	lda	var+76
	adc	<L33+l_1
	sta	var+76
L34:
	tay
	lda	<L32+1
	sta	<L32+1+6
	pld
	tsc
	clc
	adc	#L32+6
	tcs
	tya
	rts
L32	equ	6
L33	equ	5

deleteLine:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L35
	tcs
	phd
	tcd
p_0	set	3
l_1	set	0
	clc
	lda	#$2
	adc	<L35+p_0
	sta	<R0
	pei	<R0
	jsr	strlen
	sta	<R1
	clc
	lda	#$3
	adc	<R1
	sta	<L36+l_1
	sec
	lda	var+76
	sbc	<L35+p_0
	sta	<R0
	sec
	lda	<R0
	sbc	<L36+l_1
	sta	<R1
	lda	<R1
	ina
	pha
	clc
	lda	<L35+p_0
	adc	<L36+l_1
	sta	<R0
	pei	<R0
	pei	<L35+p_0
	jsr	memmove
	sec
	lda	var+76
	sbc	<L36+l_1
	sta	var+76
L37:
	tay
	lda	<L35+1
	sta	<L35+1+2
	pld
	tsc
	clc
	adc	#L35+2
	tcs
	tya
	rts
L35	equ	10
L36	equ	9

g_decStr:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L38
	tcs
	phd
	tcd
buf_0	set	3
num_0	set	5
cnt_1	set	0
b_1	set	2
	stz	<L39+cnt_1
L10022:
	lda	<L38+num_0
	ldx	#<$a
;	jsr	~umd
	jsr	mod
	
	ora	#<$30
	sep	#$20
	longa	off
	sta	(<L38+buf_0)
	rep	#$20
	longa	on
	inc	<L38+buf_0
	lda	<L38+num_0
	ldx	#<$a
;	jsr	~udv
	jsr	mod
	lda	div_y
	sta	<L38+num_0
	inc	<L39+cnt_1
L10020:
	lda	#$0
	cmp	<L38+num_0
	bcs	L40
	brl	L10022
L40:
L10021:
	sep	#$20
	longa	off
	lda	#$0
	sta	(<L38+buf_0)
	rep	#$20
	longa	on
	lda	<L39+cnt_1
L41:
	tay
	lda	<L38+1
	sta	<L38+1+4
	pld
	tsc
	clc
	adc	#L38+4
	tcs
	tya
	rts
L38	equ	4
L39	equ	1

mk_dStr:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L42
	tcs
	phd
	tcd
d_buf_0	set	3
num_0	set	5
digit_0	set	7
s_buf_1	set	0
i_1	set	8
j_1	set	10
cnt_1	set	12
sign_1	set	14
	stz	<L43+sign_1
	lda	<L42+num_0
	and	#<$8000
	bne	L44
	brl	L10023
L44:
	lda	#$1
	sta	<L43+sign_1
	lda	<L42+num_0
	eor	#<$ffffffff
	sta	<R0
	lda	<R0
	ina
	sta	<L42+num_0
L10023:
	pei	<L42+num_0
	clc
	tdc
	adc	#<L43+s_buf_1
	pha
	jsr	g_decStr
	sta	<L43+cnt_1
	lda	<L43+cnt_1
	sta	<L43+j_1
	lda	<L43+sign_1
	bne	L45
	brl	L10024
L45:
	inc	<L43+cnt_1
L10024:
	stz	<L43+i_1
L10025:
	sec
	lda	<L43+cnt_1
	sbc	<L42+digit_0
	bvs	L46
	eor	#$8000
L46:
	bpl	L47
	brl	L10026
L47:
	clc
	lda	<L42+d_buf_0
	adc	<L43+i_1
	sta	<R0
	sep	#$20
	longa	off
	lda	#$20
	sta	(<R0)
	rep	#$20
	longa	on
	inc	<L43+i_1
	dec	<L42+digit_0
	brl	L10025
L10026:
	lda	<L43+sign_1
	bne	L48
	brl	L10027
L48:
	clc
	lda	<L42+d_buf_0
	adc	<L43+i_1
	sta	<R0
	sep	#$20
	longa	off
	lda	#$2d
	sta	(<R0)
	rep	#$20
	longa	on
	inc	<L43+i_1
L10027:
L10028:
	lda	<L43+j_1
	bne	L49
	brl	L10029
L49:
	clc
	lda	<L42+d_buf_0
	adc	<L43+i_1
	sta	<R0
	clc
	tdc
	adc	#<L43+s_buf_1
	sta	<R1
	clc
	lda	#$ffff
	adc	<R1
	sta	<R2
	clc
	lda	<R2
	adc	<L43+j_1
	sta	<R1
	sep	#$20
	longa	off
	lda	(<R1)
	sta	(<R0)
	rep	#$20
	longa	on
	inc	<L43+i_1
	dec	<L43+j_1
	brl	L10028
L10029:
	clc
	lda	<L42+d_buf_0
	adc	<L43+i_1
	sta	<R0
	sep	#$20
	longa	off
	lda	#$0
	sta	(<R0)
	rep	#$20
	longa	on
L50:
	lda	<L42+1
	sta	<L42+1+6
	pld
	tsc
	clc
	adc	#L42+6
	tcs
	rts
L42	equ	28
L43	equ	13

g_hexStr:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L51
	tcs
	phd
	tcd
buf_0	set	3
num_0	set	5
cnt_0	set	7
i_1	set	0
n_1	set	2
msk_1	set	3
	lda	<L51+cnt_0
	cmp	#<$4
	beq	L53
	brl	L10030
L53:
	lda	#$f000
	sta	<L52+msk_1
	brl	L10031
L10030:
	lda	#$f0
	sta	<L52+msk_1
L10031:
	lda	<L51+cnt_0
	asl	A
	asl	A
	sta	<R0
	clc
	lda	#$fffc
	adc	<R0
	sta	<L52+i_1
L10034:
	lda	<L52+msk_1
	and	<L51+num_0
	ldx	<L52+i_1
;	jsr	lsr
; input A, X
;
; A = A << X

shift_left:
	lsr	A
	dex
	bne	shift_left

	sta	<R0
	sep	#$20
	longa	off
	lda	<R0
	sta	<L52+n_1
	rep	#$20
	longa	on
	lda	<L52+msk_1
	lsr	A
	lsr	A
	lsr	A
	lsr	A
	sta	<L52+msk_1
	sep	#$20
	longa	off
	lda	#$9
	cmp	<L52+n_1
	rep	#$20
	longa	on
	bcc	L54
	brl	L10035
L54:
	sep	#$20
	longa	off
	clc
	lda	#$37
	adc	<L52+n_1
	sta	<L52+n_1
	rep	#$20
	longa	on
	brl	L10036
L10035:
	sep	#$20
	longa	off
	clc
	lda	#$30
	adc	<L52+n_1
	sta	<L52+n_1
	rep	#$20
	longa	on
L10036:
	sep	#$20
	longa	off
	lda	<L52+n_1
	sta	(<L51+buf_0)
	rep	#$20
	longa	on
	inc	<L51+buf_0
	clc
	lda	#$fffc
	adc	<L52+i_1
	sta	<L52+i_1
L10032:
	lda	<L52+i_1
	bmi	L55
	brl	L10034
L55:
L10033:
	sep	#$20
	longa	off
	lda	#$0
	sta	(<L51+buf_0)
	rep	#$20
	longa	on
L56:
	lda	<L51+1
	sta	<L51+1+6
	pld
	tsc
	clc
	adc	#L51+6
	tcs
	rts
L51	equ	9
L52	equ	5

dispLine:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L57
	tcs
	phd
	tcd
p_0	set	3
l_1	set	0
s_1	set	2
	lda	(<L57+p_0)
	xba			; A(low) <-> A(high)
	sta	<L58+l_1
	inc	<L57+p_0
	inc	<L57+p_0
	pea	#<$5
	pei	<L58+l_1
	clc
	tdc
	adc	#<L58+s_1
	pha
	jsr	mk_dStr
	clc
	tdc
	adc	#<L58+s_1
	pha
	jsr	c_puts
L10037:
	lda	(<L57+p_0)
	and	#$ff
	bne	L59
	brl	L10038
L59:
	lda	<L57+p_0
	sta	<R0
	inc	<L57+p_0
	lda	(<R0)
	and	#$ff
	pha
	jsr	c_putch
	brl	L10037
L10038:
	jsr	newline
	lda	<L57+p_0
	ina
	sta	<R0
	lda	<R0
L60:
	tay
	lda	<L57+1
	sta	<L57+1+2
	pld
	tsc
	clc
	adc	#L57+2
	tcs
	tya
	rts
L57	equ	18
L58	equ	9

dispList:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L61
	tcs
	phd
	tcd
p_0	set	3
L10039:
	sep	#$20
	longa	off
	lda	(<L61+p_0)
	and	#<$80
	rep	#$20
	longa	on
	beq	L63
	brl	L10040
L63:
	jsr	breakCheck
	pei	<L61+p_0
	jsr	dispLine
	sta	<L61+p_0
	brl	L10039
L10040:
L64:
	tay
	lda	<L61+1
	sta	<L61+1+2
	pld
	tsc
	clc
	adc	#L61+2
	tcs
	tya
	rts
L61	equ	0
L62	equ	1

skipBlank:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L65
	tcs
	phd
	tcd
L10041:
	lda	pc
	sta	<R0
	sep	#$20
	longa	off
	lda	(<R0)
	cmp	#<$20
	rep	#$20
	longa	on
	bne	L67
	brl	L10043
L67:
L68:
	tay
	pld
	tsc
	clc
	adc	#L65
	tcs
	tya
	rts
L10043:
	inc	pc
	brl	L10041
L65	equ	4
L66	equ	5

skipAlpha:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L69
	tcs
	phd
	tcd
x_1	set	0
L10044:
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L70+x_1
	sec
	lda	<L70+x_1
	sbc	#<$41
	bvs	L72
	eor	#$8000
L72:
	bmi	L73
	brl	L71
L73:
	sec
	lda	#$7a
	sbc	<L70+x_1
	bvs	L74
	eor	#$8000
L74:
	bmi	L75
	brl	L71
L75:
	sec
	lda	#$5a
	sbc	<L70+x_1
	bvs	L76
	eor	#$8000
L76:
	bpl	L77
	brl	L10046
L77:
	sec
	lda	<L70+x_1
	sbc	#<$61
	bvs	L78
	eor	#$8000
L78:
	bpl	L79
	brl	L10046
L79:
L71:
	lda	<L70+x_1
L80:
	tay
	pld
	tsc
	clc
	adc	#L69
	tcs
	tya
	rts
L10046:
	inc	pc
	brl	L10044
L69	equ	6
L70	equ	5

exqt:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L81
	tcs
	phd
	tcd
L10047:
	jsr	skipBlank
	jsr	do_cmd
	brl	L10047
L81	equ	0
L82	equ	1

topOfLine:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L83
	tcs
	phd
	tcd
x_1	set	0
c_1	set	2
L10049:
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L84+x_1
;	lda	<L84+x_1
	and	#<$80
	bne	L85
	brl	L10050
L85:
	pea	#<$0
	jsr	w_boot
L10050:
	lda	pc
	sta	<R0
	lda	(<R0)
	xba			; A(low) <-> A(high)
	sta	lno
	inc	pc
	inc	pc
	lda	pc
	sta	<R0
	sep	#$20
	longa	off
	lda	(<R0)
	cmp	#<$20
	rep	#$20
	longa	on
	bne	L86
	brl	L10051
L86:
	lda	pc
	pha
	jsr	skipLine
	sta	pc
	brl	L10049
L10051:
L87:
	tay
	pld
	tsc
	clc
	adc	#L83
	tcs
	tya
	rts
L83	equ	12
L84	equ	9

bk_msg:
	dw	L8+0

L8:
	db	$0D,$0A,$53,$74,$6F,$70,$21,$00

breakCheck:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L89
	tcs
	phd
	tcd
c_1	set	0
	jsr	c_kbhit
	and	#$ff
	bne	L91
	brl	L10052
L91:
	jsr	c_getch
	sep	#$20
	longa	off
	sta	<R0
	rep	#$20
	longa	on
	lda	<R0
	and	#$ff
	sta	<L90+c_1
	lda	<L90+c_1
	cmp	#<$3
	beq	L92
	brl	L10053
L92:
	lda	bk_msg
	pha
	jsr	w_boot
L10053:
	lda	<L90+c_1
	cmp	#<$13
	beq	L93
	brl	L10054
L93:
	jsr	c_getch
L10054:
L10052:
L94:
	tay
	pld
	tsc
	clc
	adc	#L89
	tcs
	tya
	rts
L89	equ	6
L90	equ	5

do_cmd:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L95
	tcs
	phd
	tcd
c_1	set	0
c1_1	set	2
c2_1	set	4
e_1	set	6
vmode_1	set	8
off_1	set	10
tp_1	set	12
	jsr	breakCheck
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L96+c_1
	inc	pc
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L96+c1_1
	lda	<L96+c_1
	brl	L10055
L10057:
	jsr	topOfLine
	lda	#$1
L97:
	tay
	pld
	tsc
	clc
	adc	#L95
	tcs
	tya
	rts
L10058:
	jsr	pop
	sta	<L96+tp_1
	lda	<L96+tp_1
	sta	pc
	lda	#$0
	brl	L97
L10059:
	jsr	do_pr
	lda	#$0
	brl	L97
L10060:
	jsr	newline
	lda	#$0
	brl	L97
L10061:
	lda	<L96+c1_1
	cmp	#<$3d
	beq	L98
	brl	L10062
L98:
	lda	pc
	sta	<R0
	ldy	#$1
	lda	(<R0),Y
	and	#$ff
	sta	<L96+c2_1
	jsr	operand
	sta	<L96+e_1
	pei	<L96+c2_1
	pei	<L96+e_1
	jsr	do_until
	lda	#$0
	brl	L97
L10062:
	jsr	do_do
	lda	#$0
	brl	L97
L10063:
	pei	<L96+c1_1
	jsr	do_prNum
	lda	#$0
	brl	L97
L10064:
	jsr	mach_fin
	brl	L10056
L10055:
	jsr	swt
	dw	7
	dw	0
	dw	L10057-1
	dw	34
	dw	L10059-1
	dw	47
	dw	L10060-1
	dw	63
	dw	L10063-1
	dw	64
	dw	L10061-1
	dw	92
	dw	L10064-1
	dw	93
	dw	L10058-1
	dw	L10056-1
L10056:
	lda	<L96+c1_1
	cmp	#<$3d
	beq	L99
	brl	L10065
L99:
	lda	<L96+c_1
	brl	L10066
L10068:
	jsr	operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	do_goto
	lda	#$0
	brl	L97
L10069:
	jsr	operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	do_gosub
	lda	#$0
	brl	L97
L10070:
	jsr	operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	c_putch
	lda	#$0
	brl	L97
L10071:
	jsr	operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	do_prSpc
	lda	#$0
	brl	L97
L10072:
	jsr	operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	do_if
	lda	#$0
	brl	L97
L10073:
	jsr	operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	srand
	lda	#$0
	brl	L97
L10074:
	jsr	operand
	sta	<L96+e_1
	lda	<L96+e_1
	beq	L100
	brl	L10075
L100:
	jsr	newText
L10075:
	lda	#$0
	brl	L97
L10066:
	jsr	swt
	dw	7
	dw	33
	dw	L10069-1
	dw	35
	dw	L10068-1
	dw	36
	dw	L10070-1
	dw	38
	dw	L10074-1
	dw	39
	dw	L10073-1
	dw	46
	dw	L10071-1
	dw	59
	dw	L10072-1
	dw	L10067-1
L10067:
L10065:
	jsr	skipAlpha
	sta	<L96+vmode_1
	lda	<L96+vmode_1
	cmp	#<$3a
	bne	L102
	brl	L101
L102:
	lda	<L96+vmode_1
	cmp	#<$28
	beq	L103
	brl	L10076
L103:
L101:
	inc	pc
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	expr
	sta	<L96+off_1
	clc
	lda	#$ffff
	adc	pc
	sta	<R0
	sep	#$20
	longa	off
	lda	(<R0)
	cmp	#<$29
	rep	#$20
	longa	on
	bne	L104
	brl	L10077
L104:
	pea	#<L88
	jsr	er_boot
L10077:
	jsr	operand
	sta	<L96+e_1
	lda	<L96+vmode_1
	cmp	#<$3a
	beq	L105
	brl	L10078
L105:
	lda	<L96+c_1
	asl	A
	sta	<R0
	clc
	lda	#<var
	adc	<R0
	sta	<R1
	clc
	lda	(<R1)
	adc	<L96+off_1
	sta	<R0
	sep	#$20
	longa	off
	lda	<L96+e_1
	sta	(<R0)
	rep	#$20
	longa	on
	brl	L10079
L10078:
	lda	<L96+vmode_1
	cmp	#<$28
	beq	L106
	brl	L10080
L106:
	lda	<L96+c_1
	asl	A
	sta	<R0
	clc
	lda	#<var
	adc	<R0
	sta	<R1
	lda	<L96+off_1
	asl	A
	sta	<R0
	clc
	lda	(<R1)
	adc	<R0
	sta	<R2
	lda	<L96+e_1
	sta	(<R2)
L10080:
L10079:
	lda	#$0
	brl	L97
L10076:
	jsr	operand
	sta	<L96+e_1
	lda	<L96+c_1
	asl	A
	sta	<R0
	clc
	lda	#<var
	adc	<R0
	sta	<R1
	lda	<L96+e_1
	sta	(<R1)
	clc
	lda	#$ffff
	adc	pc
	sta	<R0
	sep	#$20
	longa	off
	lda	(<R0)
	cmp	#<$2c
	rep	#$20
	longa	on
	beq	L107
	brl	L10081
L107:
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L96+c_1
	inc	pc
	pei	<L96+c_1
	jsr	expr
	sta	<L96+e_1
	lda	pc
	pha
	jsr	push
	pei	<L96+e_1
	jsr	push
L10081:
	lda	#$0
	brl	L97
L95	equ	26
L96	equ	13

L88:
	db	$32,$00

do_until:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L109
	tcs
	phd
	tcd
e_0	set	3
val_0	set	5
	lda	<L109+val_0
	asl	A
	sta	<R0
	clc
	lda	#<var
	adc	<R0
	sta	<R1
	lda	<L109+e_0
	sta	(<R1)
	lda	sp
	asl	A
	sta	<R0
	clc
	lda	#<stack
	adc	<R0
	sta	<R1
	sec
	lda	(<R1)
	sbc	<L109+e_0
	bvs	L111
	eor	#$8000
L111:
	bpl	L112
	brl	L10082
L112:
	dec	sp
	dec	sp
L113:
	tay
	lda	<L109+1
	sta	<L109+1+4
	pld
	tsc
	clc
	adc	#L109+4
	tcs
	tya
	rts
L10082:
	lda	sp
	asl	A
	sta	<R0
	clc
	lda	#$fffe
	adc	#<stack
	sta	<R1
	clc
	lda	<R1
	adc	<R0
	sta	<R2
	lda	(<R2)
	sta	pc
	brl	L113
L109	equ	12
L110	equ	13

do_do:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L114
	tcs
	phd
	tcd
	lda	pc
	pha
	jsr	push
	pea	#<$0
	jsr	push
L116:
	tay
	pld
	tsc
	clc
	adc	#L114
	tcs
	tya
	rts
L114	equ	0
L115	equ	1

do_if:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L117
	tcs
	phd
	tcd
e_0	set	3
	lda	<L117+e_0
	beq	L119
	brl	L10083
L119:
	lda	pc
	pha
	jsr	skipLine
	sta	pc
	jsr	topOfLine
L10083:
L120:
	tay
	lda	<L117+1
	sta	<L117+1+2
	pld
	tsc
	clc
	adc	#L117+2
	tcs
	tya
	rts
L117	equ	0
L118	equ	1

do_goto:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L121
	tcs
	phd
	tcd
n_0	set	3
f_1	set	0
p_1	set	2
	lda	<L121+n_0
	cmp	#<$ffffffff
	beq	L123
	brl	L10084
L123:
	pea	#<$0
	jsr	w_boot
L10084:
	clc
	tdc
	adc	#<L122+f_1
	pha
	pei	<L121+n_0
	jsr	searchLine
	sta	<L122+p_1
;	lda	<L122+p_1
	sta	pc
	jsr	topOfLine
L124:
	tay
	lda	<L121+1
	sta	<L121+1+2
	pld
	tsc
	clc
	adc	#L121+2
	tcs
	tya
	rts
L121	equ	4
L122	equ	1

do_gosub:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L125
	tcs
	phd
	tcd
n_0	set	3
f_1	set	0
p_1	set	2
	clc
	tdc
	adc	#<L126+f_1
	pha
	pei	<L125+n_0
	jsr	searchLine
	sta	<L126+p_1
	lda	pc
	pha
	jsr	push
	lda	<L126+p_1
	sta	pc
	jsr	topOfLine
L127:
	tay
	lda	<L125+1
	sta	<L125+1+2
	pld
	tsc
	clc
	adc	#L125+2
	tcs
	tya
	rts
L125	equ	4
L126	equ	1

do_prSpc:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L128
	tcs
	phd
	tcd
e_0	set	3
i_1	set	0
	stz	<L129+i_1
	brl	L10086
L10085:
	inc	<L129+i_1
L10086:
	sec
	lda	<L129+i_1
	sbc	<L128+e_0
	bvs	L130
	eor	#$8000
L130:
	bpl	L131
	brl	L10087
L131:
	pea	#<$20
	jsr	c_putch
	brl	L10085
L10087:
L132:
	tay
	lda	<L128+1
	sta	<L128+1+2
	pld
	tsc
	clc
	adc	#L128+2
	tcs
	tya
	rts
L128	equ	2
L129	equ	1

do_prNum:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L133
	tcs
	phd
	tcd
c1_0	set	3
e_1	set	0
digit_1	set	2
	lda	<L133+c1_0
	cmp	#<$28
	beq	L135
	brl	L10088
L135:
	inc	pc
	pei	<L133+c1_0
	jsr	term
	sta	<L134+digit_1
	jsr	operand
	sta	<L134+e_1
	pei	<L134+digit_1
	pei	<L134+e_1
	pea	#<lky_buf
	jsr	mk_dStr
	pea	#<lky_buf
	jsr	c_puts
L136:
	tay
	lda	<L133+1
	sta	<L133+1+2
	pld
	tsc
	clc
	adc	#L133+2
	tcs
	tya
	rts
L10088:
	jsr	operand
	sta	<L134+e_1
	lda	<L133+c1_0
	brl	L10089
L10091:
	pea	#<$4
	pei	<L134+e_1
	pea	#<lky_buf
	jsr	g_hexStr
	brl	L10090
L10092:
	pea	#<$2
	pei	<L134+e_1
	pea	#<lky_buf
	jsr	g_hexStr
	brl	L10090
L10093:
	pea	#<$1
	pei	<L134+e_1
	pea	#<lky_buf
	jsr	mk_dStr
	brl	L10090
L10094:
	pea	#<L108
	jsr	er_boot
	brl	L10090
L10089:
	jsr	swt
	dw	3
	dw	36
	dw	L10092-1
	dw	61
	dw	L10093-1
	dw	63
	dw	L10091-1
	dw	L10094-1
L10090:
	pea	#<lky_buf
	jsr	c_puts
	brl	L136
L133	equ	4
L134	equ	1

L108:
	db	$33,$00

do_pr:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L138
	tcs
	phd
	tcd
x_1	set	0
L10095:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	sta	<L139+x_1
	lda	<L139+x_1
	cmp	#<$22
	bne	L140
	brl	L10096
L140:
	lda	<L139+x_1
	beq	L141
	brl	L10097
L141:
	dec	pc
	brl	L10096
L10097:
	pei	<L139+x_1
	jsr	c_putch
	brl	L10095
L10096:
L142:
	tay
	pld
	tsc
	clc
	adc	#L138
	tcs
	tya
	rts
L138	equ	6
L139	equ	5

pop:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L143
	tcs
	phd
	tcd
	lda	sp
	bmi	L145
	brl	L10098
L145:
	pea	#<L137
	jsr	er_boot
L10098:
	lda	sp
	sta	<R1
	dec	sp
	lda	<R1
	asl	A
	sta	<R0
	clc
	lda	#<stack
	adc	<R0
	sta	<R1
	lda	(<R1)
L146:
	tay
	pld
	tsc
	clc
	adc	#L143
	tcs
	tya
	rts
L143	equ	8
L144	equ	9

L137:
	db	$34,$00

push:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L148
	tcs
	phd
	tcd
x_0	set	3
	sec
	lda	sp
	sbc	#<$63
	bvs	L150
	eor	#$8000
L150:
	bmi	L151
	brl	L10099
L151:
	pea	#<L147
	jsr	er_boot
L10099:
	inc	sp
	lda	sp
	asl	A
	sta	<R0
	clc
	lda	#<stack
	adc	<R0
	sta	<R1
	lda	<L148+x_0
	sta	(<R1)
	lda	<L148+x_0
L152:
	tay
	lda	<L148+1
	sta	<L148+1+2
	pld
	tsc
	clc
	adc	#L148+2
	tcs
	tya
	rts
L148	equ	8
L149	equ	9

L147:
	db	$35,$00

operand:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L154
	tcs
	phd
	tcd
x_1	set	0
e_1	set	2
L10100:
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L155+x_1
	inc	pc
	lda	<L155+x_1
	cmp	#<$3d
	bne	L156
	brl	L10101
L156:
	lda	<L155+x_1
	and	#<$df
	beq	L157
	brl	L10102
L157:
	pea	#<L153
	jsr	errMsg
L10102:
	brl	L10100
L10101:
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L155+x_1
	inc	pc
	pei	<L155+x_1
	jsr	expr
	sta	<L155+e_1
	lda	<L155+e_1
L158:
	tay
	pld
	tsc
	clc
	adc	#L154
	tcs
	tya
	rts
L154	equ	8
L155	equ	5

L153:
	db	$20,$3F,$00

expr:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L160
	tcs
	phd
	tcd
c_0	set	3
o_1	set	0
o1_1	set	2
op2_1	set	4
e_1	set	6
	pei	<L160+c_0
	jsr	term
	sta	<L161+e_1
L10103:
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L161+o_1
	inc	pc
	lda	<L161+o_1
	brl	L10105
L10107:
	dec	pc
L10108:
L10109:
L10110:
	lda	<L161+e_1
L162:
	tay
	lda	<L160+1
	sta	<L160+1+2
	pld
	tsc
	clc
	adc	#L160+2
	tcs
	tya
	rts
L10111:
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L161+o1_1
	inc	pc
	lda	<L161+o1_1
	brl	L10112
L10114:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<L161+op2_1
	stz	<R0
	lda	<L161+e_1
	cmp	<L161+op2_1
	bne	L164
	brl	L163
L164:
	inc	<R0
L163:
	lda	<R0
	sta	<L161+e_1
	brl	L10103
L10115:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<L161+op2_1
	stz	<R0
	sec
	lda	<L161+op2_1
	sbc	<L161+e_1
	bvs	L166
	eor	#$8000
L166:
	bmi	L167
	brl	L165
L167:
	inc	<R0
L165:
	lda	<R0
	sta	<L161+e_1
	brl	L10103
L10116:
	pei	<L161+o1_1
	jsr	term
	sta	<L161+op2_1
	stz	<R0
	sec
	lda	<L161+e_1
	sbc	<L161+op2_1
	bvs	L169
	eor	#$8000
L169:
	bpl	L170
	brl	L168
L170:
	inc	<R0
L168:
	lda	<R0
	sta	<L161+e_1
	brl	L10103
L10112:
	jsr	swt
	dw	2
	dw	61
	dw	L10115-1
	dw	62
	dw	L10114-1
	dw	L10116-1
L10113:
L10117:
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L161+o1_1
	inc	pc
	lda	<L161+o1_1
	brl	L10118
L10120:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<L161+op2_1
	stz	<R0
	sec
	lda	<L161+e_1
	sbc	<L161+op2_1
	bvs	L172
	eor	#$8000
L172:
	bmi	L173
	brl	L171
L173:
	inc	<R0
L171:
	lda	<R0
	sta	<L161+e_1
	brl	L10103
L10121:
	pei	<L161+o1_1
	jsr	term
	sta	<L161+op2_1
	stz	<R0
	sec
	lda	<L161+op2_1
	sbc	<L161+e_1
	bvs	L175
	eor	#$8000
L175:
	bpl	L176
	brl	L174
L176:
	inc	<R0
L174:
	lda	<R0
	sta	<L161+e_1
	brl	L10103
L10118:
	jsr	swt
	dw	1
	dw	61
	dw	L10120-1
	dw	L10121-1
L10119:
L10122:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<L161+op2_1
	clc
	lda	<L161+e_1
	adc	<L161+op2_1
	sta	<L161+e_1
	brl	L10106
L10123:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<L161+op2_1
	sec
	lda	<L161+e_1
	sbc	<L161+op2_1
	sta	<L161+e_1
	brl	L10106
L10124:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<L161+op2_1
	lda	<L161+e_1
	ldx	<L161+op2_1
	jsr	mul
	sta	<L161+e_1
	brl	L10106
L10125:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<L161+op2_1
	lda	<L161+e_1
	ldx	<L161+op2_1

;	jsr	mod
;	sta	var+74

	lda	<L161+e_1
	ldx	<L161+op2_1
	jsr	div
	sta	<L161+e_1
	brl	L10106
L10126:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<L161+op2_1
	stz	<R0
	lda	<L161+e_1
	cmp	<L161+op2_1
	beq	L178
	brl	L177
L178:
	inc	<R0
L177:
	lda	<R0
	sta	<L161+e_1
	brl	L10106
L10127:
	sep	#$20
	longa	off
	lda	#$20
	sta	mm
	rep	#$20
	longa	on
	sep	#$20
	longa	off
	lda	<L161+o_1
	sta	mm+1
	rep	#$20
	longa	on
	sep	#$20
	longa	off
	lda	#$3f
	sta	mm+2
	rep	#$20
	longa	on
	sep	#$20
	longa	off
	stz	mm+3
	rep	#$20
	longa	on
	pea	#<mm
	jsr	errMsg
	brl	L10106
L10105:
	jsr	swt
	dw	11
	dw	0
	dw	L10107-1
	dw	32
	dw	L10108-1
	dw	41
	dw	L10109-1
	dw	42
	dw	L10124-1
	dw	43
	dw	L10122-1
	dw	44
	dw	L10110-1
	dw	45
	dw	L10123-1
	dw	47
	dw	L10125-1
	dw	60
	dw	L10111-1
	dw	61
	dw	L10126-1
	dw	62
	dw	L10117-1
	dw	L10127-1
L10106:
	brl	L10103
L160	equ	12
L161	equ	5

term:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L179
	tcs
	phd
	tcd
c_0	set	3
e_1	set	0
f_1	set	2
vmode_1	set	4
ppp_1	set	6
	stz	<L180+f_1
	lda	<L179+c_0
	brl	L10128
L10130:
	clc
	tdc
	adc	#<L180+f_1
	pha
	jsr	getHex
	sta	<L180+e_1
	lda	<L180+f_1
	beq	L181
	brl	L10131
L181:
	jsr	c_getch
	sep	#$20
	longa	off
	sta	<R0
	rep	#$20
	longa	on
	lda	<R0
	and	#$ff
L182:
	tay
	lda	<L179+1
	sta	<L179+1+2
	pld
	tsc
	clc
	adc	#L179+2
	tcs
	tya
	rts
L10131:
	lda	<L180+e_1
	brl	L182
L10132:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	expr
	sta	<L180+e_1
	clc
	lda	#$ffff
	adc	pc
	sta	<R0
	sep	#$20
	longa	off
	lda	(<R0)
	cmp	#<$29
	rep	#$20
	longa	on
	bne	L183
	brl	L10133
L183:
	pea	#<L159
	jsr	errMsg
L10133:
	lda	<L180+e_1
	brl	L182
L10134:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<L180+e_1
	lda	<L180+e_1
	bmi	L185
	brl	L184
L185:
	sec
	lda	#$0
	sbc	<L180+e_1
	bra	L186
L184:
	lda	<L180+e_1
L186:
	brl	L182
L10135:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<R0
	sec
	lda	#$0
	sbc	<R0
	brl	L182
L10136:
	stz	<R0
	lda	pc
	sta	<R1
	inc	pc
	lda	(<R1)
	and	#$ff
	pha
	jsr	term
	tax
	beq	L188
	brl	L187
L188:
	inc	<R0
L187:
	lda	<R0
	brl	L182
L10137:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<R0
	jsr	rand
	sta	<R1
	lda	<R1
	ldx	<R0
	jsr	mod
	sta	<R0
	lda	<R0
	ina
	brl	L182
L10138:
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	term
	sta	<L180+e_1
	lda	var+74
	brl	L182
L10139:
	pea	#<lky_buf
	jsr	c_gets
	lda	pc
	sta	<L180+ppp_1
	lda	#<lky_buf
	sta	pc
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	expr
	sta	<L180+e_1
	lda	<L180+ppp_1
	sta	pc
	lda	<L180+e_1
	brl	L182
L10140:
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L180+e_1
	inc	pc
	lda	pc
	sta	<R0
	inc	pc
	sep	#$20
	longa	off
	lda	(<R0)
	cmp	#<$22
	rep	#$20
	longa	on
	bne	L189
	brl	L10141
L189:
	pea	#<L159+4
	jsr	errMsg
L10141:
	lda	<L180+e_1
	brl	L182
L10128:
	jsr	swt
	dw	9
	dw	34
	dw	L10140-1
	dw	35
	dw	L10136-1
	dw	36
	dw	L10130-1
	dw	37
	dw	L10138-1
	dw	39
	dw	L10137-1
	dw	40
	dw	L10132-1
	dw	43
	dw	L10134-1
	dw	45
	dw	L10135-1
	dw	63
	dw	L10139-1
	dw	L10129-1
L10129:
	sec
	lda	<L179+c_0
	sbc	#<$30
	bvs	L190
	eor	#$8000
L190:
	bmi	L191
	brl	L10142
L191:
	sec
	lda	#$39
	sbc	<L179+c_0
	bvs	L192
	eor	#$8000
L192:
	bmi	L193
	brl	L10142
L193:
	dec	pc
	clc
	tdc
	adc	#<L180+f_1
	pha
	jsr	getNum
	sta	<L180+e_1
	lda	<L180+e_1
	brl	L182
L10142:
	jsr	skipAlpha
	sta	<L180+vmode_1
	lda	<L180+vmode_1
	cmp	#<$3a
	bne	L195
	brl	L194
L195:
	lda	<L180+vmode_1
	cmp	#<$28
	beq	L196
	brl	L10143
L196:
L194:
	inc	pc
	lda	pc
	sta	<R0
	inc	pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	expr
	sta	<L180+e_1
	clc
	lda	#$ffff
	adc	pc
	sta	<R0
	sep	#$20
	longa	off
	lda	(<R0)
	cmp	#<$29
	rep	#$20
	longa	on
	bne	L197
	brl	L10144
L197:
	pea	#<L159+8
	jsr	errMsg
L10144:
	lda	<L180+vmode_1
	brl	L10145
L10147:
	lda	<L179+c_0
	asl	A
	sta	<R0
	clc
	lda	#<var
	adc	<R0
	sta	<R1
	clc
	lda	(<R1)
	adc	<L180+e_1
	sta	<R0
	lda	(<R0)
	and	#$ff
	brl	L182
L10148:
	lda	<L179+c_0
	asl	A
	sta	<R0
	clc
	lda	#<var
	adc	<R0
	sta	<R1
	lda	<L180+e_1
	asl	A
	sta	<R0
	clc
	lda	(<R1)
	adc	<R0
	sta	<R2
	lda	(<R2)
	brl	L182
L10145:
	jsr	swt
	dw	2
	dw	40
	dw	L10148-1
	dw	58
	dw	L10147-1
	dw	L10146-1
L10146:
L10143:
	lda	<L179+c_0
	asl	A
	sta	<R0
	clc
	lda	#<var
	adc	<R0
	sta	<R1
	lda	(<R1)
	brl	L182
L179	equ	20
L180	equ	13

L159:
	db	" )?",0
	db	' ','"','?',0
	db	" )?",0

errMsg:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L199
	tcs
	phd
	tcd
s_0	set	3
a_1	set	0
	pea	#<L198
	jsr	c_puts
	pei	<L199+s_0
	jsr	c_puts
	lda	lno
	bne	L201
	brl	L10149
L201:
	pea	#<L198+6
	jsr	c_puts
	pea	#<$1
	lda	lno
	pha
	clc
	tdc
	adc	#<L200+a_1
	pha
	jsr	mk_dStr
	clc
	tdc
	adc	#<L200+a_1
	pha
	jsr	c_puts
L10149:
	pea	#<$0
	jsr	w_boot
L202:
	tay
	lda	<L199+1
	sta	<L199+1+2
	pld
	tsc
	clc
	adc	#L199+2
	tcs
	tya
	rts
L199	equ	8
L200	equ	1

L198:
	db	$0D,$0A,$45,$72,$72,$00,$20,$69,$6E,$20,$00

w_boot:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L204
	tcs
	phd
	tcd
msg_0	set	3
	jsr	newline
	lda	<L204+msg_0
	bne	L206
	brl	L10150
L206:
	pei	<L204+msg_0
	jsr	c_puts
L10150:
	jsr	warm_boot
L207:
	tay
	lda	<L204+1
	sta	<L204+1+2
	pld
	tsc
	clc
	adc	#L204+2
	tcs
	tya
	rts
L204	equ	0
L205	equ	1

er_boot:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L208
	tcs
	phd
	tcd
msg_0	set	3
	pea	#<L203
	jsr	c_puts
	lda	<L208+msg_0
	bne	L210
	brl	L10151
L210:
	pei	<L208+msg_0
	jsr	c_puts
L10151:
	jsr	warm_boot
L211:
	tay
	lda	<L208+1
	sta	<L208+1+2
	pld
	tsc
	clc
	adc	#L208+2
	tcs
	tya
	rts
L208	equ	0
L209	equ	1

L203:
	db	$0D,$0A,$45,$72,$72,$00

c_isprint:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L213
	tcs
	phd
	tcd
c_0	set	3
	stz	<R0
	sep	#$20
	longa	off
	lda	<L213+c_0
	cmp	#<$20
	rep	#$20
	longa	on
	bcs	L216
	brl	L215
L216:
	sep	#$20
	longa	off
	lda	#$7e
	cmp	<L213+c_0
	rep	#$20
	longa	on
	bcs	L217
	brl	L215
L217:
	inc	<R0
L215:
	lda	<R0
	and	#$ff
L218:
	tay
	lda	<L213+1
	sta	<L213+1+2
	pld
	tsc
	clc
	adc	#L213+2
	tcs
	tya
	rts
L213	equ	4
L214	equ	5

c_isspace:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L219
	tcs
	phd
	tcd
c_0	set	3
	stz	<R0
	sep	#$20
	longa	off
	lda	<L219+c_0
	cmp	#<$20
	rep	#$20
	longa	on
	bne	L223
	brl	L222
L223:
	sep	#$20
	longa	off
	lda	#$d
	cmp	<L219+c_0
	rep	#$20
	longa	on
	bcs	L224
	brl	L221
L224:
	sep	#$20
	longa	off
	lda	<L219+c_0
	cmp	#<$9
	rep	#$20
	longa	on
	bcs	L225
	brl	L221
L225:
L222:
	inc	<R0
L221:
	lda	<R0
	and	#$ff
L226:
	tay
	lda	<L219+1
	sta	<L219+1+2
	pld
	tsc
	clc
	adc	#L219+2
	tcs
	tya
	rts
L219	equ	4
L220	equ	5

newline:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L227
	tcs
	phd
	tcd
crlf_1	set	0
	lda	#<L212
	sta	<L228+crlf_1
	pei	<L228+crlf_1
	jsr	c_puts
L229:
	pld
	tsc
	clc
	adc	#L227
	tcs
	rts
L227	equ	2
L228	equ	1

L212:
	db	$0D,$0A,$00

c_gets:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L231
	tcs
	phd
	tcd
lbuf_0	set	3
c_1	set	0
len_1	set	1
	stz	<L232+len_1
L10152:
	jsr	c_getch
	sep	#$20
	longa	off
	sta	<L232+c_1
	rep	#$20
	longa	on
	sep	#$20
	longa	off
	lda	<L232+c_1
	cmp	#<$d
	rep	#$20
	longa	on
	bne	L233
	brl	L10153
L233:
	sep	#$20
	longa	off
	lda	<L232+c_1
	cmp	#<$9
	rep	#$20
	longa	on
	beq	L234
	brl	L10154
L234:
	sep	#$20
	longa	off
	lda	#$20
	sta	<L232+c_1
	rep	#$20
	longa	on
L10154:
	sep	#$20
	longa	off
	lda	<L232+c_1
	cmp	#<$8
	rep	#$20
	longa	on
	bne	L236
	brl	L235
L236:
	sep	#$20
	longa	off
	lda	<L232+c_1
	cmp	#<$7f
	rep	#$20
	longa	on
	beq	L237
	brl	L10155
L237:
L235:
	lda	#$0
	cmp	<L232+len_1
	bcc	L238
	brl	L10155
L238:
	dec	<L232+len_1
	pea	#<$8
	jsr	c_putch
	pea	#<$20
	jsr	c_putch
	pea	#<$8
	jsr	c_putch
	brl	L10156
L10155:
	pei	<L232+c_1
	jsr	c_isprint
	and	#$ff
	bne	L239
	brl	L10157
L239:
	lda	<L232+len_1
	cmp	#<$9f
	bcc	L240
	brl	L10157
L240:
	sep	#$20
	longa	off
	lda	<L232+c_1
	ldy	<L232+len_1
	sta	(<L231+lbuf_0),Y
	rep	#$20
	longa	on
	inc	<L232+len_1
	lda	<L232+c_1
	and	#$ff
	pha
	jsr	c_putch
L10157:
L10156:
	brl	L10152
L10153:
	jsr	newline
	sep	#$20
	longa	off
	lda	#$0
	ldy	<L232+len_1
	sta	(<L231+lbuf_0),Y
	rep	#$20
	longa	on
	lda	#$0
	cmp	<L232+len_1
	bcc	L241
	brl	L10158
L241:
L10161:
	dec	<L232+len_1
L10159:
	ldy	<L232+len_1
	lda	(<L231+lbuf_0),Y
	pha
	jsr	c_isspace
	and	#$ff
	beq	L242
	brl	L10161
L242:
L10160:
	inc	<L232+len_1
	sep	#$20
	longa	off
	lda	#$0
	ldy	<L232+len_1
	sta	(<L231+lbuf_0),Y
	rep	#$20
	longa	on
L10158:
	lda	<L232+len_1
L243:
	tay
	lda	<L231+1
	sta	<L231+1+2
	pld
	tsc
	clc
	adc	#L231+2
	tcs
	tya
	rts
L231	equ	3
L232	equ	1

memmove:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L244
	tcs
	phd
	tcd
dest_0	set	3
src_0	set	5
n_0	set	7
tmp_1	set	0
s_1	set	2
	lda	<L244+src_0
	cmp	<L244+dest_0
	bcs	L246
	brl	L10162
L246:
	lda	<L244+dest_0
	sta	<L245+tmp_1
	lda	<L244+src_0
	sta	<L245+s_1
L10163:
	lda	<L244+n_0
	sta	<R0
	dec	<L244+n_0
	lda	<R0
	bne	L247
	brl	L10164
L247:
	sep	#$20
	longa	off
	lda	(<L245+s_1)
	sta	(<L245+tmp_1)
	rep	#$20
	longa	on
	inc	<L245+s_1
	inc	<L245+tmp_1
	brl	L10163
L10164:
	brl	L10165
L10162:
	lda	<L244+dest_0
	sta	<L245+tmp_1
	clc
	lda	<L245+tmp_1
	adc	<L244+n_0
	sta	<L245+tmp_1
	lda	<L244+src_0
	sta	<L245+s_1
	clc
	lda	<L245+s_1
	adc	<L244+n_0
	sta	<L245+s_1
L10166:
	lda	<L244+n_0
	sta	<R0
	dec	<L244+n_0
	lda	<R0
	bne	L248
	brl	L10167
L248:
	dec	<L245+tmp_1
	dec	<L245+s_1
	sep	#$20
	longa	off
	lda	(<L245+s_1)
	sta	(<L245+tmp_1)
	rep	#$20
	longa	on
	brl	L10166
L10167:
L10165:
L249:
	lda	<L244+1
	sta	<L244+1+6
	pld
	tsc
	clc
	adc	#L244+6
	tcs
	rts
L244	equ	8
L245	equ	5

strcpy:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L250
	tcs
	phd
	tcd
p1_0	set	3
p2_0	set	5
c_1	set	0
flg_1	set	1
	sep	#$20
	longa	off
	stz	<L251+flg_1
	rep	#$20
	longa	on
L10168:
	lda	<L250+p2_0
	sta	<R0
	inc	<L250+p2_0
	sep	#$20
	longa	off
	lda	(<R0)
	sta	<L251+c_1
	rep	#$20
	longa	on
	lda	<L251+c_1
	and	#$ff
	bne	L252
	brl	L10169
L252:
	sep	#$20
	longa	off
	lda	<L251+c_1
	cmp	#<$22
	rep	#$20
	longa	on
	beq	L253
	brl	L10170
L253:
	sep	#$20
	longa	off
	lda	<L251+flg_1
	eor	#<$1
	sta	<L251+flg_1
	rep	#$20
	longa	on
L10170:
	sep	#$20
	longa	off
	lda	<L251+c_1
	cmp	#<$61
	rep	#$20
	longa	on
	bcs	L254
	brl	L10171
L254:
	sep	#$20
	longa	off
	lda	#$7a
	cmp	<L251+c_1
	rep	#$20
	longa	on
	bcs	L255
	brl	L10171
L255:
	lda	<L251+flg_1
	and	#$ff
	beq	L256
	brl	L10171
L256:
	sep	#$20
	longa	off
	lda	#$20
	trb	<L251+c_1
	rep	#$20
	longa	on
L10171:
	sep	#$20
	longa	off
	lda	<L251+c_1
	sta	(<L250+p1_0)
	rep	#$20
	longa	on
	inc	<L250+p1_0
	brl	L10168
L10169:
	sep	#$20
	longa	off
	lda	#$0
	sta	(<L250+p1_0)
	rep	#$20
	longa	on
L257:
	lda	<L250+1
	sta	<L250+1+4
	pld
	tsc
	clc
	adc	#L250+4
	tcs
	rts
L250	equ	6
L251	equ	5

strlen:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L258
	tcs
	phd
	tcd
s_0	set	3
num_1	set	0
	stz	<L259+num_1
L10172:
	lda	<L258+s_0
	sta	<R0
	inc	<L258+s_0
	lda	(<R0)
	and	#$ff
	bne	L260
	brl	L10173
L260:
	inc	<L259+num_1
	brl	L10172
L10173:
	lda	<L259+num_1
L261:
	tay
	lda	<L258+1
	sta	<L258+1+2
	pld
	tsc
	clc
	adc	#L258+2
	tcs
	tya
	rts
L258	equ	6
L259	equ	5

getNum:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L262
	tcs
	phd
	tcd
f_0	set	3
c_1	set	0
n_1	set	1
	stz	<L263+n_1
	lda	#$0
	sta	(<L262+f_0)
	lda	pc
	sta	<R0
	sep	#$20
	longa	off
	lda	(<R0)
	sta	<L263+c_1
	rep	#$20
	longa	on
L10174:
	sep	#$20
	longa	off
	lda	<L263+c_1
	cmp	#<$30
	rep	#$20
	longa	on
	bcs	L264
	brl	L10175
L264:
	sep	#$20
	longa	off
	lda	#$39
	cmp	<L263+c_1
	rep	#$20
	longa	on
	bcs	L265
	brl	L10175
L265:
	lda	<L263+c_1
	and	#$ff
	sta	<R0
	lda	<L263+n_1
	asl	A
	asl	A
	adc	<L263+n_1
	asl	A
	sta	<R1
	clc
	lda	<R1
	adc	<R0
	sta	<R2
	clc
	lda	#$ffd0
	adc	<R2
	sta	<L263+n_1
	inc	pc
	lda	pc
	sta	<R0
	sep	#$20
	longa	off
	lda	(<R0)
	sta	<L263+c_1
	rep	#$20
	longa	on
	lda	#$1
	sta	(<L262+f_0)
	brl	L10174
L10175:
	lda	<L263+n_1
L266:
	tay
	lda	<L262+1
	sta	<L262+1+2
	pld
	tsc
	clc
	adc	#L262+2
	tcs
	tya
	rts
L262	equ	15
L263	equ	13

getHex:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L267
	tcs
	phd
	tcd
f_0	set	3
c_1	set	0
n_1	set	2
	stz	<L268+n_1
	lda	#$0
	sta	(<L267+f_0)
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L268+c_1
L10176:
	sec
	lda	<L268+c_1
	sbc	#<$30
	bvs	L271
	eor	#$8000
L271:
	bmi	L272
	brl	L270
L272:
	sec
	lda	#$39
	sbc	<L268+c_1
	bvs	L273
	eor	#$8000
L273:
	bpl	L274
	brl	L269
L274:
L270:
	sec
	lda	<L268+c_1
	sbc	#<$41
	bvs	L276
	eor	#$8000
L276:
	bmi	L277
	brl	L275
L277:
	sec
	lda	#$46
	sbc	<L268+c_1
	bvs	L278
	eor	#$8000
L278:
	bpl	L279
	brl	L269
L279:
L275:
	sec
	lda	<L268+c_1
	sbc	#<$61
	bvs	L280
	eor	#$8000
L280:
	bmi	L281
	brl	L10177
L281:
	sec
	lda	#$66
	sbc	<L268+c_1
	bvs	L282
	eor	#$8000
L282:
	bmi	L283
	brl	L10177
L283:
L269:
	lda	<L268+n_1
	asl	A
	asl	A
	asl	A
	asl	A
	sta	<R0
	sec
	lda	<L268+c_1
	sbc	#<$41
	bvs	L285
	eor	#$8000
L285:
	bpl	L286
	brl	L284
L286:
	clc
	lda	#$ffd0
	adc	<L268+c_1
	sta	<R1
	lda	<R1
	bra	L287
L284:
	sec
	lda	<L268+c_1
	sbc	#<$61
	bvs	L289
	eor	#$8000
L289:
	bpl	L290
	brl	L288
L290:
	clc
	lda	#$ffbf
	adc	<L268+c_1
	sta	<R1
	lda	<R1
	bra	L291
L288:
	clc
	lda	#$ff9f
	adc	<L268+c_1
	sta	<R1
	lda	<R1
L291:
	sta	<R1
	clc
	lda	#$a
	adc	<R1
	sta	<R2
	lda	<R2
L287:
	sta	<R1
	clc
	lda	<R1
	adc	<R0
	sta	<L268+n_1
	inc	pc
	lda	pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L268+c_1
	lda	#$1
	sta	(<L267+f_0)
	brl	L10176
L10177:
	lda	<L268+n_1
L292:
	tay
	lda	<L267+1
	sta	<L267+1+2
	pld
	tsc
	clc
	adc	#L267+2
	tcs
	tya
	rts
L267	equ	16
L268	equ	13

newText:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L293
	tcs
	phd
	tcd
	lda	var+76
	sta	<R0
	sep	#$20
	longa	off
	lda	(<R0)
	cmp	#<$ff
	rep	#$20
	longa	on
	bne	L295
	brl	L10178
L295:
	lda	t_lock
	pha
	jsr	er_boot
L10178:
	jsr	newText1
L296:
	tay
	pld
	tsc
	clc
	adc	#L293
	tcs
	tya
	rts
L293	equ	4
L294	equ	5

newText1:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L297
	tcs
	phd
	tcd
	lda	var+122
	sta	var+76
	lda	var+76
	sta	<R0
	sep	#$20
	longa	off
	lda	#$ff
	sta	(<R0)
	rep	#$20
	longa	on
L299:
	tay
	pld
	tsc
	clc
	adc	#L297
	tcs
	tya
	rts
L297	equ	4
L298	equ	5

	ds	$10000-$
	end
