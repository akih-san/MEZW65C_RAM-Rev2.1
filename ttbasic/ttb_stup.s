	.setcpu		"65C02"
;	.smart		on
;	.autoimport	on
;	.case		on
;	.debuginfo	off
;	.importzp	sp, sreg, regsave, regbank
;	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
;	.macpack	longbranch
;	.forceimport	__STARTUP__

;;;
;;;	TOYOSHIKI TinyBASIC V1.0
;;;	(C)2015 Tetsuya Suzuki
;;;	https://github.com/vintagechips/ttbasic_lin
;;;
;;; Ported for MEZW65C-RAM by Akihito Honda. 
;;; 2024.10
;;;
;;; Thanks all.
;;;


;;;
;;; File header template (BIOS CALL version)
;;;	

PRG_B	=	$B000
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
	.export		MEZW65_FILE_HEADER
	.import		_warm_start
	.import		_main
	.import		_error
	.import		_err
	.import		_newline

	.import		__FILETOP__
	.import		_startup

.segment	"BSS"

seed:	.res	2, $00


.segment	"RODATA"

MEZW65_FILE_HEADER:
;--------- MEZW65C_RAM file header --------------------------
	.byte	0		; program bank:W65C816, 0:W65C02
;	.word	COLD_START
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
	lda	#0
	sta	_err
	jsr	_error
	jsr	_newline
	jsr	_warm_start
	BRK	PRG_END
end_prg1:
	bra	end_prg1

.endproc

.segment	"CODE"

.proc	COLD_START: near

.segment	"CODE"

	ldx	#USER_SP
	txs
	jsr	_main

; command SYSTEM then ttbasic fin

	BRK	PRG_END
end_prg:
	bra	end_prg

.endproc
