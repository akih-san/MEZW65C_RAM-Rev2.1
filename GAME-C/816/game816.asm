;:ts=8
R0	equ	1
R1	equ	5
R2	equ	9
R3	equ	13
	code
	xdef	__c_puts
	func
__c_puts:
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
	jsr	__c_putch
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
	ends
	efunc
	data
	xdef	__open_msg
__open_msg:
	dw	L1+0
	ends
	data
L1:
	db	$47,$41,$4D,$45,$2D,$43,$20,$4D,$45,$5A,$57,$36,$35,$43,$5F
	db	$52,$41,$4D,$20,$45,$64,$69,$74,$69,$6F,$6E,$0D,$0A,$00
	ends
	data
	xdef	__rdy_msg
__rdy_msg:
	dw	L6+0
	ends
	data
L6:
	db	$2A,$52,$45,$41,$44,$59,$0D,$0A,$00
	ends
	data
	xdef	__t_lock
__t_lock:
	dw	L7+0
	ends
	data
L7:
	db	$31,$00
	ends
	code
	xdef	__main
	func
__main:
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
	pea	#<$162e
	jsr	__srand
	lda	#<__text_buf
	sta	|__var+122
	lda	#$7fff
	sta	|__var+84
	jsr	__newText1
	lda	|__open_msg
	pha
	jsr	__c_puts
L10003:
	lda	|__rdy_msg
	pha
	jsr	__c_puts
L10004:
	lda	#$ffff
	sta	|__sp
	stz	|__lno
	pea	#<__lin
	jsr	__c_gets
	sta	<L10+cnt_1
	lda	#<__lin
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
	lda	#<__lin
	sta	|__pc
	jsr	__skipBlank
	clc
	tdc
	adc	#<L10+x_1
	pha
	jsr	__getNum
	sta	<L10+n_1
	lda	<L10+x_1
	beq	L12
	brl	L10006
L12:
	jsr	__exqt
	jsr	__newline
	lda	|__rdy_msg
	pha
	jsr	__c_puts
	brl	L10007
L10006:
	pei	<L10+n_1
	jsr	__edit
L10007:
	brl	L10004
L9	equ	14
L10	equ	9
	ends
	efunc
	code
	xdef	__skipLine
	func
__skipLine:
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
	ends
	efunc
	code
	xdef	__searchLine
	func
__searchLine:
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
	lda	|__var+122
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
	and	#$ff
	sta	<R1
	lda	<R1
	xba
	and	#$ff00
	sta	<R0
	ldy	#$1
	lda	(<L18+p_1),Y
	and	#$ff
	sta	<R1
	lda	<R1
	ora	<R0
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
	jsr	__skipLine
	sta	<L18+p_1
	brl	L10010
L10011:
	lda	#$0
	sta	(<L17+f_0)
	lda	<L18+p_1
	brl	L21
L17	equ	12
L18	equ	9
	ends
	efunc
	code
	xdef	__edit
	func
__edit:
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
	lda	|__var+122
	pha
	jsr	__dispList
	pea	#<$0
	jsr	__w_boot
L10014:
	clc
	tdc
	adc	#<L25+f_1
	pha
	pei	<L24+n_0
	jsr	__searchLine
	sta	<L25+p_1
	lda	|__pc
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
	jsr	__dispList
	pea	#<$0
	jsr	__w_boot
	brl	L10016
L10015:
	lda	|__var+76
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
	lda	|__t_lock
	pha
	jsr	__er_boot
L10017:
	lda	<L25+f_1
	bne	L29
	brl	L10018
L29:
	pei	<L25+p_1
	jsr	__deleteLine
L10018:
	lda	|__pc
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
	lda	|__pc
	pha
	pei	<L25+p_1
	pei	<L24+n_0
	jsr	__addLine
L10016:
	lda	#$0
	brl	L31
L24	equ	8
L25	equ	5
	ends
	efunc
	code
	xdef	__addLine
	func
__addLine:
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
	jsr	__strlen
	sta	<R0
	clc
	lda	#$3
	adc	<R0
	sta	<L33+l_1
	sec
	lda	|__var+76
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
	jsr	__memmove
	lda	<L32+n_0
	ldx	#<$8
	xref	__~asr
	jsr	__~asr
	sep	#$20
	longa	off
	sta	(<L32+p_0)
	rep	#$20
	longa	on
	sep	#$20
	longa	off
	lda	<L32+n_0
	ldy	#$1
	sta	(<L32+p_0),Y
	rep	#$20
	longa	on
	pei	<L32+new_0
	clc
	lda	#$2
	adc	<L32+p_0
	sta	<R0
	pei	<R0
	jsr	__strcpy
	clc
	lda	|__var+76
	adc	<L33+l_1
	sta	|__var+76
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
	ends
	efunc
	code
	xdef	__deleteLine
	func
__deleteLine:
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
	jsr	__strlen
	sta	<R1
	clc
	lda	#$3
	adc	<R1
	sta	<L36+l_1
	sec
	lda	|__var+76
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
	jsr	__memmove
	sec
	lda	|__var+76
	sbc	<L36+l_1
	sta	|__var+76
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
	ends
	efunc
	code
	xdef	__g_decStr
	func
__g_decStr:
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
	xref	__~umd
	jsr	__~umd
	ora	#<$30
	sep	#$20
	longa	off
	sta	(<L38+buf_0)
	rep	#$20
	longa	on
	inc	<L38+buf_0
	lda	<L38+num_0
	ldx	#<$a
	xref	__~udv
	jsr	__~udv
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
	ends
	efunc
	code
	xdef	__mk_dStr
	func
__mk_dStr:
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
	jsr	__g_decStr
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
	ends
	efunc
	code
	xdef	__g_hexStr
	func
__g_hexStr:
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
	xref	__~lsr
	jsr	__~lsr
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
	ends
	efunc
	code
	xdef	__dispLine
	func
__dispLine:
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
	and	#$ff
	sta	<R1
	lda	<R1
	xba
	and	#$ff00
	sta	<R0
	ldy	#$1
	lda	(<L57+p_0),Y
	and	#$ff
	sta	<R1
	lda	<R1
	ora	<R0
	sta	<L58+l_1
	inc	<L57+p_0
	inc	<L57+p_0
	pea	#<$5
	pei	<L58+l_1
	clc
	tdc
	adc	#<L58+s_1
	pha
	jsr	__mk_dStr
	clc
	tdc
	adc	#<L58+s_1
	pha
	jsr	__c_puts
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
	jsr	__c_putch
	brl	L10037
L10038:
	jsr	__newline
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
	ends
	efunc
	code
	xdef	__dispList
	func
__dispList:
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
	jsr	__breakCheck
	pei	<L61+p_0
	jsr	__dispLine
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
	ends
	efunc
	code
	xdef	__skipBlank
	func
__skipBlank:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L65
	tcs
	phd
	tcd
L10041:
	lda	|__pc
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
	inc	|__pc
	brl	L10041
L65	equ	4
L66	equ	5
	ends
	efunc
	code
	xdef	__skipAlpha
	func
__skipAlpha:
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
	lda	|__pc
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
	inc	|__pc
	brl	L10044
L69	equ	6
L70	equ	5
	ends
	efunc
	code
	xdef	__exqt
	func
__exqt:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L81
	tcs
	phd
	tcd
L10047:
	jsr	__skipBlank
	jsr	__do_cmd
	brl	L10047
L81	equ	0
L82	equ	1
	ends
	efunc
	code
	xdef	__topOfLine
	func
__topOfLine:
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
	lda	|__pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L84+x_1
	inc	|__pc
	lda	<L84+x_1
	and	#<$80
	bne	L85
	brl	L10050
L85:
	pea	#<$0
	jsr	__w_boot
L10050:
	lda	<L84+x_1
	xba
	and	#$ff00
	sta	<R0
	lda	|__pc
	sta	<R1
	lda	(<R1)
	and	#$ff
	sta	<R1
	lda	<R1
	ora	<R0
	sta	|__lno
	inc	|__pc
	lda	|__pc
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
	lda	|__pc
	pha
	jsr	__skipLine
	sta	|__pc
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
	ends
	efunc
	data
	xdef	__bk_msg
__bk_msg:
	dw	L8+0
	ends
	data
L8:
	db	$0D,$0A,$53,$74,$6F,$70,$21,$00
	ends
	code
	xdef	__breakCheck
	func
__breakCheck:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L89
	tcs
	phd
	tcd
c_1	set	0
	jsr	__c_kbhit
	and	#$ff
	bne	L91
	brl	L10052
L91:
	jsr	__c_getch
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
	lda	|__bk_msg
	pha
	jsr	__w_boot
L10053:
	lda	<L90+c_1
	cmp	#<$13
	beq	L93
	brl	L10054
L93:
	jsr	__c_getch
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
	ends
	efunc
	code
	xdef	__do_cmd
	func
__do_cmd:
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
	jsr	__breakCheck
	lda	|__pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L96+c_1
	inc	|__pc
	lda	|__pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L96+c1_1
	lda	<L96+c_1
	brl	L10055
L10057:
	jsr	__topOfLine
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
	jsr	__pop
	sta	<L96+tp_1
	lda	<L96+tp_1
	sta	|__pc
	lda	#$0
	brl	L97
L10059:
	jsr	__do_pr
	lda	#$0
	brl	L97
L10060:
	jsr	__newline
	lda	#$0
	brl	L97
L10061:
	lda	<L96+c1_1
	cmp	#<$3d
	beq	L98
	brl	L10062
L98:
	lda	|__pc
	sta	<R0
	ldy	#$1
	lda	(<R0),Y
	and	#$ff
	sta	<L96+c2_1
	jsr	__operand
	sta	<L96+e_1
	pei	<L96+c2_1
	pei	<L96+e_1
	jsr	__do_until
	lda	#$0
	brl	L97
L10062:
	jsr	__do_do
	lda	#$0
	brl	L97
L10063:
	pei	<L96+c1_1
	jsr	__do_prNum
	lda	#$0
	brl	L97
L10064:
	jsr	__mach_fin
	brl	L10056
L10055:
	xref	__~swt
	jsr	__~swt
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
	jsr	__operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	__do_goto
	lda	#$0
	brl	L97
L10069:
	jsr	__operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	__do_gosub
	lda	#$0
	brl	L97
L10070:
	jsr	__operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	__c_putch
	lda	#$0
	brl	L97
L10071:
	jsr	__operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	__do_prSpc
	lda	#$0
	brl	L97
L10072:
	jsr	__operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	__do_if
	lda	#$0
	brl	L97
L10073:
	jsr	__operand
	sta	<L96+e_1
	pei	<L96+e_1
	jsr	__srand
	lda	#$0
	brl	L97
L10074:
	jsr	__operand
	sta	<L96+e_1
	lda	<L96+e_1
	beq	L100
	brl	L10075
L100:
	jsr	__newText
L10075:
	lda	#$0
	brl	L97
L10066:
	xref	__~swt
	jsr	__~swt
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
	jsr	__skipAlpha
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
	inc	|__pc
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__expr
	sta	<L96+off_1
	clc
	lda	#$ffff
	adc	|__pc
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
	jsr	__er_boot
L10077:
	jsr	__operand
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
	lda	#<__var
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
	lda	#<__var
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
	jsr	__operand
	sta	<L96+e_1
	lda	<L96+c_1
	asl	A
	sta	<R0
	clc
	lda	#<__var
	adc	<R0
	sta	<R1
	lda	<L96+e_1
	sta	(<R1)
	clc
	lda	#$ffff
	adc	|__pc
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
	lda	|__pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L96+c_1
	inc	|__pc
	pei	<L96+c_1
	jsr	__expr
	sta	<L96+e_1
	lda	|__pc
	pha
	jsr	__push
	pei	<L96+e_1
	jsr	__push
L10081:
	lda	#$0
	brl	L97
L95	equ	26
L96	equ	13
	ends
	efunc
	data
L88:
	db	$32,$00
	ends
	code
	xdef	__do_until
	func
__do_until:
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
	lda	#<__var
	adc	<R0
	sta	<R1
	lda	<L109+e_0
	sta	(<R1)
	lda	|__sp
	asl	A
	sta	<R0
	clc
	lda	#<__stack
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
	dec	|__sp
	dec	|__sp
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
	lda	|__sp
	asl	A
	sta	<R0
	clc
	lda	#$fffe
	adc	#<__stack
	sta	<R1
	clc
	lda	<R1
	adc	<R0
	sta	<R2
	lda	(<R2)
	sta	|__pc
	brl	L113
L109	equ	12
L110	equ	13
	ends
	efunc
	code
	xdef	__do_do
	func
__do_do:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L114
	tcs
	phd
	tcd
	lda	|__pc
	pha
	jsr	__push
	pea	#<$0
	jsr	__push
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
	ends
	efunc
	code
	xdef	__do_if
	func
__do_if:
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
	lda	|__pc
	pha
	jsr	__skipLine
	sta	|__pc
	jsr	__topOfLine
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
	ends
	efunc
	code
	xdef	__do_goto
	func
__do_goto:
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
	jsr	__w_boot
L10084:
	clc
	tdc
	adc	#<L122+f_1
	pha
	pei	<L121+n_0
	jsr	__searchLine
	sta	<L122+p_1
	lda	<L122+p_1
	sta	|__pc
	jsr	__topOfLine
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
	ends
	efunc
	code
	xdef	__do_gosub
	func
__do_gosub:
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
	jsr	__searchLine
	sta	<L126+p_1
	lda	|__pc
	pha
	jsr	__push
	lda	<L126+p_1
	sta	|__pc
	jsr	__topOfLine
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
	ends
	efunc
	code
	xdef	__do_prSpc
	func
__do_prSpc:
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
	jsr	__c_putch
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
	ends
	efunc
	code
	xdef	__do_prNum
	func
__do_prNum:
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
	inc	|__pc
	pei	<L133+c1_0
	jsr	__term
	sta	<L134+digit_1
	jsr	__operand
	sta	<L134+e_1
	pei	<L134+digit_1
	pei	<L134+e_1
	pea	#<__lky_buf
	jsr	__mk_dStr
	pea	#<__lky_buf
	jsr	__c_puts
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
	jsr	__operand
	sta	<L134+e_1
	lda	<L133+c1_0
	brl	L10089
L10091:
	pea	#<$4
	pei	<L134+e_1
	pea	#<__lky_buf
	jsr	__g_hexStr
	brl	L10090
L10092:
	pea	#<$2
	pei	<L134+e_1
	pea	#<__lky_buf
	jsr	__g_hexStr
	brl	L10090
L10093:
	pea	#<$1
	pei	<L134+e_1
	pea	#<__lky_buf
	jsr	__mk_dStr
	brl	L10090
L10094:
	pea	#<L108
	jsr	__er_boot
	brl	L10090
L10089:
	xref	__~swt
	jsr	__~swt
	dw	3
	dw	36
	dw	L10092-1
	dw	61
	dw	L10093-1
	dw	63
	dw	L10091-1
	dw	L10094-1
L10090:
	pea	#<__lky_buf
	jsr	__c_puts
	brl	L136
L133	equ	4
L134	equ	1
	ends
	efunc
	data
L108:
	db	$33,$00
	ends
	code
	xdef	__do_pr
	func
__do_pr:
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
	lda	|__pc
	sta	<R0
	inc	|__pc
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
	dec	|__pc
	brl	L10096
L10097:
	pei	<L139+x_1
	jsr	__c_putch
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
	ends
	efunc
	code
	xdef	__pop
	func
__pop:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L143
	tcs
	phd
	tcd
	lda	|__sp
	bmi	L145
	brl	L10098
L145:
	pea	#<L137
	jsr	__er_boot
L10098:
	lda	|__sp
	sta	<R1
	dec	|__sp
	lda	<R1
	asl	A
	sta	<R0
	clc
	lda	#<__stack
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
	ends
	efunc
	data
L137:
	db	$34,$00
	ends
	code
	xdef	__push
	func
__push:
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
	lda	|__sp
	sbc	#<$63
	bvs	L150
	eor	#$8000
L150:
	bmi	L151
	brl	L10099
L151:
	pea	#<L147
	jsr	__er_boot
L10099:
	inc	|__sp
	lda	|__sp
	asl	A
	sta	<R0
	clc
	lda	#<__stack
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
	ends
	efunc
	data
L147:
	db	$35,$00
	ends
	code
	xdef	__operand
	func
__operand:
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
	lda	|__pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L155+x_1
	inc	|__pc
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
	jsr	__errMsg
L10102:
	brl	L10100
L10101:
	lda	|__pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L155+x_1
	inc	|__pc
	pei	<L155+x_1
	jsr	__expr
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
	ends
	efunc
	data
L153:
	db	$20,$3F,$00
	ends
	code
	xdef	__expr
	func
__expr:
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
	jsr	__term
	sta	<L161+e_1
L10103:
	lda	|__pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L161+o_1
	inc	|__pc
	lda	<L161+o_1
	brl	L10105
L10107:
	dec	|__pc
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
	lda	|__pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L161+o1_1
	inc	|__pc
	lda	<L161+o1_1
	brl	L10112
L10114:
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
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
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
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
	jsr	__term
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
	xref	__~swt
	jsr	__~swt
	dw	2
	dw	61
	dw	L10115-1
	dw	62
	dw	L10114-1
	dw	L10116-1
L10113:
L10117:
	lda	|__pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L161+o1_1
	inc	|__pc
	lda	<L161+o1_1
	brl	L10118
L10120:
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
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
	jsr	__term
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
	xref	__~swt
	jsr	__~swt
	dw	1
	dw	61
	dw	L10120-1
	dw	L10121-1
L10119:
L10122:
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
	sta	<L161+op2_1
	clc
	lda	<L161+e_1
	adc	<L161+op2_1
	sta	<L161+e_1
	brl	L10106
L10123:
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
	sta	<L161+op2_1
	sec
	lda	<L161+e_1
	sbc	<L161+op2_1
	sta	<L161+e_1
	brl	L10106
L10124:
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
	sta	<L161+op2_1
	lda	<L161+e_1
	ldx	<L161+op2_1
	xref	__~mul
	jsr	__~mul
	sta	<L161+e_1
	brl	L10106
L10125:
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
	sta	<L161+op2_1
	lda	<L161+e_1
	ldx	<L161+op2_1
	xref	__~mod
	jsr	__~mod
	sta	|__var+74
	lda	<L161+e_1
	ldx	<L161+op2_1
	xref	__~div
	jsr	__~div
	sta	<L161+e_1
	brl	L10106
L10126:
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
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
	sta	|__mm
	rep	#$20
	longa	on
	sep	#$20
	longa	off
	lda	<L161+o_1
	sta	|__mm+1
	rep	#$20
	longa	on
	sep	#$20
	longa	off
	lda	#$3f
	sta	|__mm+2
	rep	#$20
	longa	on
	sep	#$20
	longa	off
	stz	|__mm+3
	rep	#$20
	longa	on
	pea	#<__mm
	jsr	__errMsg
	brl	L10106
L10105:
	xref	__~swt
	jsr	__~swt
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
	ends
	efunc
	code
	xdef	__term
	func
__term:
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
	jsr	__getHex
	sta	<L180+e_1
	lda	<L180+f_1
	beq	L181
	brl	L10131
L181:
	jsr	__c_getch
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
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__expr
	sta	<L180+e_1
	clc
	lda	#$ffff
	adc	|__pc
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
	jsr	__errMsg
L10133:
	lda	<L180+e_1
	brl	L182
L10134:
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
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
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
	sta	<R0
	sec
	lda	#$0
	sbc	<R0
	brl	L182
L10136:
	stz	<R0
	lda	|__pc
	sta	<R1
	inc	|__pc
	lda	(<R1)
	and	#$ff
	pha
	jsr	__term
	tax
	beq	L188
	brl	L187
L188:
	inc	<R0
L187:
	lda	<R0
	brl	L182
L10137:
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
	sta	<R0
	jsr	__rand
	sta	<R1
	lda	<R1
	ldx	<R0
	xref	__~mod
	jsr	__~mod
	sta	<R0
	lda	<R0
	ina
	brl	L182
L10138:
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__term
	sta	<L180+e_1
	lda	|__var+74
	brl	L182
L10139:
	pea	#<__lky_buf
	jsr	__c_gets
	lda	|__pc
	sta	<L180+ppp_1
	lda	#<__lky_buf
	sta	|__pc
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__expr
	sta	<L180+e_1
	lda	<L180+ppp_1
	sta	|__pc
	lda	<L180+e_1
	brl	L182
L10140:
	lda	|__pc
	sta	<R0
	lda	(<R0)
	and	#$ff
	sta	<L180+e_1
	inc	|__pc
	lda	|__pc
	sta	<R0
	inc	|__pc
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
	jsr	__errMsg
L10141:
	lda	<L180+e_1
	brl	L182
L10128:
	xref	__~swt
	jsr	__~swt
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
	dec	|__pc
	clc
	tdc
	adc	#<L180+f_1
	pha
	jsr	__getNum
	sta	<L180+e_1
	lda	<L180+e_1
	brl	L182
L10142:
	jsr	__skipAlpha
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
	inc	|__pc
	lda	|__pc
	sta	<R0
	inc	|__pc
	lda	(<R0)
	and	#$ff
	pha
	jsr	__expr
	sta	<L180+e_1
	clc
	lda	#$ffff
	adc	|__pc
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
	jsr	__errMsg
L10144:
	lda	<L180+vmode_1
	brl	L10145
L10147:
	lda	<L179+c_0
	asl	A
	sta	<R0
	clc
	lda	#<__var
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
	lda	#<__var
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
	xref	__~swt
	jsr	__~swt
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
	lda	#<__var
	adc	<R0
	sta	<R1
	lda	(<R1)
	brl	L182
L179	equ	20
L180	equ	13
	ends
	efunc
	data
L159:
	db	$20,$29,$3F,$00,$20,$22,$3F,$00,$20,$29,$3F,$00
	ends
	code
	xdef	__errMsg
	func
__errMsg:
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
	jsr	__c_puts
	pei	<L199+s_0
	jsr	__c_puts
	lda	|__lno
	bne	L201
	brl	L10149
L201:
	pea	#<L198+6
	jsr	__c_puts
	pea	#<$1
	lda	|__lno
	pha
	clc
	tdc
	adc	#<L200+a_1
	pha
	jsr	__mk_dStr
	clc
	tdc
	adc	#<L200+a_1
	pha
	jsr	__c_puts
L10149:
	pea	#<$0
	jsr	__w_boot
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
	ends
	efunc
	data
L198:
	db	$0D,$0A,$45,$72,$72,$00,$20,$69,$6E,$20,$00
	ends
	code
	xdef	__w_boot
	func
__w_boot:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L204
	tcs
	phd
	tcd
msg_0	set	3
	jsr	__newline
	lda	<L204+msg_0
	bne	L206
	brl	L10150
L206:
	pei	<L204+msg_0
	jsr	__c_puts
L10150:
	jsr	__warm_boot
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
	ends
	efunc
	code
	xdef	__er_boot
	func
__er_boot:
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
	jsr	__c_puts
	lda	<L208+msg_0
	bne	L210
	brl	L10151
L210:
	pei	<L208+msg_0
	jsr	__c_puts
L10151:
	jsr	__warm_boot
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
	ends
	efunc
	data
L203:
	db	$0D,$0A,$45,$72,$72,$00
	ends
	code
	xdef	__c_isprint
	func
__c_isprint:
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
	ends
	efunc
	code
	xdef	__c_isspace
	func
__c_isspace:
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
	ends
	efunc
	code
	xdef	__newline
	func
__newline:
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
	jsr	__c_puts
L229:
	pld
	tsc
	clc
	adc	#L227
	tcs
	rts
L227	equ	2
L228	equ	1
	ends
	efunc
	data
L212:
	db	$0D,$0A,$00
	ends
	code
	xdef	__c_gets
	func
__c_gets:
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
	jsr	__c_getch
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
	jsr	__c_putch
	pea	#<$20
	jsr	__c_putch
	pea	#<$8
	jsr	__c_putch
	brl	L10156
L10155:
	pei	<L232+c_1
	jsr	__c_isprint
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
	jsr	__c_putch
L10157:
L10156:
	brl	L10152
L10153:
	jsr	__newline
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
	jsr	__c_isspace
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
	ends
	efunc
	code
	xdef	__memmove
	func
__memmove:
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
	ends
	efunc
	code
	xdef	__strcpy
	func
__strcpy:
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
	ends
	efunc
	code
	xdef	__strlen
	func
__strlen:
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
	ends
	efunc
	code
	xdef	__getNum
	func
__getNum:
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
	lda	|__pc
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
	inc	|__pc
	lda	|__pc
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
	ends
	efunc
	code
	xdef	__getHex
	func
__getHex:
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
	lda	|__pc
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
	inc	|__pc
	lda	|__pc
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
	ends
	efunc
	code
	xdef	__newText
	func
__newText:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L293
	tcs
	phd
	tcd
	lda	|__var+76
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
	lda	|__t_lock
	pha
	jsr	__er_boot
L10178:
	jsr	__newText1
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
	ends
	efunc
	code
	xdef	__newText1
	func
__newText1:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L297
	tcs
	phd
	tcd
	lda	|__var+122
	sta	|__var+76
	lda	|__var+76
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
	ends
	efunc
	xref	__mach_fin
	xref	__warm_boot
	xref	__rand
	xref	__srand
	xref	__c_putch
	xref	__c_getch
	xref	__c_kbhit
	udata
	xdef	__mm
__mm
	ds	4
	ends
	udata
	xdef	__var
__var
	ds	256
	ends
	udata
	xdef	__lno
__lno
	ds	2
	ends
	udata
	xdef	__stack
__stack
	ds	200
	ends
	udata
	xdef	__sp
__sp
	ds	2
	ends
	udata
	xdef	__pc
__pc
	ds	2
	ends
	udata
	xdef	__lky_buf
__lky_buf
	ds	160
	ends
	udata
	xdef	__lin
__lin
	ds	160
	ends
	udata
	xdef	__text_buf
__text_buf
	ds	30720
	ends
	end
