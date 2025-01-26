	.setcpu		"65C02"
;;;
;;;	GAME Language interpreter ,32bit Takeoka ver.
;;;	by Shozo TAKEOKA (http://www.takeoka.org/~take/ )
;;;
;;;	Modified by Akihito Honda at February 2023.
;;;
;;;	- This source code was inpremented for MEZW65C_RAM
;;;

;;;
;;; File header template (BIOS CALL version)
;;;	

;PRG_B	=	$C400
WORK_B	=	$400
WORK_END	=	$E8FF

USER_SP	=	$BF

ZERO_B	=	$00

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
	.export		_c_kbhit
	.export		_c_getch
	.export		_c_putch
	.export		_srand
	.export		_rand
	.export		COLD_START
	.export		_warm_boot
	.export		_mach_fin
	.export		MEZW65_FILE_HEADER
	.import		_main
	.import		_newline
	.import		_startup
	.import		__FILETOP__

.segment	"BSS"

seed:	.res	2, $00


.segment	"RODATA"

MEZW65_FILE_HEADER:
;--------- MEZW65C_RAM file header --------------------------
	.byte	0		; program bank:W65C816, 0:W65C02
	.word	_startup
	.byte	0		; data bank:W65C816, 0:W65C02
	.word	_warm_boot

	.word	0		; reserve

mezID:	.byte	"MEZW65C",0	; Unique ID

start_p:	;file load address
	.word	__FILETOP__	; load address
	.byte	0		; reserve
	.byte	0		; reserve

	; define Common memory address
PIC_IF:	.word	0	; reserve
	.word	0	; reserve

SW_816:	.byte	0	; 0 : W65C02
			; 1 : W65C816 native mode 
			; 2 : works in both modes
irq_sw:	.byte	0	; 0 : no use IRQ console I/O
			; 1 : use IRQ timer interrupt driven console I/O
reg_tp:	.word	0	; monitor reserve (register save pointer)
reg_ts:	.word	0	; monitor reserve (register table size)
nmi_sw:	.byte	0	; 0 : No NMI support, 1: NMI support
bios_sw:	.byte	1	; 0 : standalone program
			; 1 : program call bios command
			; 2 : monitor program (.SYS)
;--------- MEZW65C_RAM file header --------------------------
;;;     Console Driver
;;;
CONIN_NO	=	1
CONOUT_NO	=	2
CONST_NO	=	3
PRG_END		=	$FF

.segment	"CODE"

.proc	_c_getch: near

.segment	"CODE"

	BRK	CONIN_NO
	rts
.endproc

.segment	"CODE"

.proc	_c_kbhit: near

.segment	"CODE"

	BRK	CONST_NO
	rts
.endproc

;input A : char
.segment	"CODE"

.proc	_c_putch: near

.segment	"CODE"

	BRK	CONOUT_NO
	rts
.endproc

.segment	"CODE"

.proc	_rand: near

.segment	"CODE"

	lda	seed+1
	eor	#$96
	tax
	lda	seed
	eor	#$30
	sbc	$53
	sta	seed
	txa
	sbc	#$65
	sta	seed+1
	asl	seed+1
	lda	seed+1
	rol	seed
	adc	#0
	sta	seed+1
	rts
.endproc

; X:A 16bit
;
.segment	"CODE"

.proc	_srand: near

.segment	"CODE"

	sta	seed
	stx	seed+1
	rts
.endproc

.segment	"CODE"

.proc	_warm_boot: near

.segment	"CODE"

	ldx	#USER_SP
	txs
;	jsr	_newline
	ldx     #$00
	lda	#1
	jsr	_main
	bra	_mach_fin

.endproc

.segment	"CODE"

.proc	COLD_START: near

.segment	"CODE"

	ldx	#USER_SP
	txs
	ldx     #$00
	lda	#0
	jsr	_main

.endproc

; Terminate GAME-C

.segment	"CODE"

.proc	_mach_fin: near

.segment	"CODE"

_mach_fin:
	BRK	PRG_END
end_end:
	bra	end_end

.endproc
