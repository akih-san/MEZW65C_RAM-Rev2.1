	pl	0
	pw      132
	chip    65C02
	inclist on

; 2025.01.24: Rebuilt by Akihito Honda for MEZW65C_RAM.
; It has been modified so that it can be assembled using WDC tools
;  (Western Design Center, Inc.).
;   https://wdc65xx.com/WDCTools

; 

;base addresses and definitions
btejmp	equ	$100		;warm boot jump
pemjmp	equ	$103		;jump to pem
iostat	equ	$106		;i/o status
dflfcb	equ	$107		;default FCB
dflbuf	equ	$128		;default buffer pointer

tea	equ	$200		;tea start

;fixed parameters
lf	equ	$a		;linefeeed
cr	equ	$d		;return
eof	equ	$1a		;end of file
null	equ	0		;null
ctlc	equ	3		;abort
ctle	equ	5		;physical cr lf
bs	equ	8		;back space
ctli	equ	9		;tab character
ctlp	equ	$10		;toggle printer
ctlr	equ	$12		;repeat line
ctls	equ	$13		;freeze
ctlx	equ	$18		;cancel
semico	equ	$3b		;semicolon
delete	equ	$7f		;delete character
ctlt	equ	$14		;terminate DOS65(return to MEZW65 firmware)
wpum	equ	$1C		;invoke universal monitor(for debug)
numcmd	equ	36		;number commands

CCM_SECTION	equ	$c900
PEM_SECTION	equ	pem
SIM_SECTION	equ	sim

	code
	org	CCM_SECTION-20H

;--------- MEZW65C_RAM file header --------------------------
P_LOAD:
	db	0		; 65C02:reserve
	dw	SIM_SECTION
	db	0		; 65C02:reserve
	dw	SIM_SECTION+3

	dw	0		; 65C02:reserve
	; Unique ID
mezID:	db	"MEZW65C",0
	;start program address
start_p:	dw	P_LOAD	; program load address (Low)
		dw	0	; (high)

PIC_IF:	dw	0		;  reserve
	dw	0		;  reserve

SW_816:	db	0	; 0 : W65C02
			; 1 : W65C816 native mode 
irq_sw	db	0	; reserve
reg_tp	dw	0	; reserve
reg_ts	dw	0	; reserve
nmi_sw	db	0	; reserve
bios_sw	db	1	; 1 : mode user program

;--------- End MEZW65C_RAM file header -----------------------

;	org	CCM_SECTION
	
pem
	jmp	pem_body
;-------------------------------
;dos/65 console command module
;-------------------------------
;ccm unique definitions
nbuilt	equ	7		;number built in commands
;main program
ccm
	cld			;set binary mode
	pha			;save drive number
	jsr	rstdsk		;initialize system
	pla			;restore drive num
	jsr	slctds		;select drive
	lda	sysdef+6	;get line length
	lsr	a		;divide
	lsr	a		;by
	lsr	a		;16
	lsr	a		;for dir
	sta	sixten		;and save
	lda	cnslng		;get buffer length
	bne	mrecmd		;if more handle it
ccmlpe	ldx	#$ff		;set
	txs			;stack
	cld			;set binary mode
	jsr	hdrout		;send header
	lda	#'>'		;then print
	jsr	chrout		;prompt
	lda	cnsbvc		;point to start
	ldy	cnsbvc+1	;of buffer
	jsr	rdebuf		;do buffer read
	ldy	#0		;clear index
	ldx	cnslng		;get length
	beq	ccmlpe		;loop if empty
lwrupr	lda	cnstxt,y	;else get char
	cmp	#'a'		;if less than a
	bcc	nxtchg		;skip convert
	cmp	#'z'+1		;if over z
	bcs	nxtchg		;skip convert
	and	#%01011111	;else convert
	sta	cnstxt,y	;put back in buffer
nxtchg	iny			;bump index
	dex			;count down
	bne	lwrupr		;loop if more
	txa			;set a to zero
	sta	cnstxt,y	;insert stopper
	sta	cnbfpt		;initialize pointer
mrecmd	jsr	stdflb		;set default buffer
	jsr	intdsk		;get drive number
	sta	dfldsk		;store as default
	jsr	prslin		;parse command
	bne	cmderr		;error if afn
	lda	tmpdsk		;get temporary
	beq	nodrch		;if zero ok
	lda	#nbuilt*3	;else set and
	bne	dotrns		;do transient
nodrch	lda	#0		;clear
	tax			;table index
	sta	count		;and count
tsnxfn	ldy	#1		;set fcb index
tsnxch	lda	fnctbl,x	;get table entry
	beq	gotcmd		;if zero got it
	cmp	fcbone,y	;else test
	bne	nocmpr		;no good if not =
	inx			;bump
	iny			;pointers
	bne	tsnxch		;and loop
nocmpr	inx			;go to end
	lda	fnctbl,x	;of table
	bne	nocmpr		;entry
	inx			;point to next
	inc	count		;bump count
	lda	count		;and if not
	cmp	#nbuilt		;limit then
	bne	tsnxfn		;try next
gotcmd	lda	count		;get count
	asl	a		;multiply by two
	adc	count		;then add for x3
dotrns	tax			;use as index
	inx			;bump to pass jmp
	lda	xqfntb,x	;to get
	ldy	xqfntb+1,x	;entry address
	sta	vector		;then set
	sty	vector+1	;vector
	lda	extcvc+1	;save
	pha			;return
	lda	extcvc		;address
	pha			;on stack
	jmp	(vector)	;execute
extcmd	jsr	rstddr		;restore default
extwod	jsr	prslin		;parse more
	lda	fcbone+1	;if first
	sec			;character
	sbc	#' '		;not a space
	ora	tmpdsk		;or if temporary
	bne	cmderr		;then an error
	jmp	ccmlpe		;else loop
;command error syntax handler
cmderr	jsr	ccrlf		;do a cr lf
	ldy	curpnt		;get command pointer
cmerlp	lda	cnstxt,y	;get char
	beq	cmerex		;if null then done
	cmp	#' '		;if space
	beq	cmerex		;then done
	jsr	cotsxy		;output with save
	iny			;point to next
	bne	cmerlp		;and loop
cmerex	lda	#'?'		;send a
	jsr	chrout		;question mark
	jmp	ccmlpe		;and start over
;execute dir command
; dir <afn>
dir	jsr	prslin		;find object file
	jsr	clrslt		;clear auto and select
	lda	#' '		;if name
	cmp	fcbone+1	;and
	bne	findfr		;type are
	cmp	fcbone+9	;not empty
	bne	findfr		;then use it
	lda	#'?'		;else
	ldy	#11		;fill
fillqu	sta	fcbone,y	;fcb
	dey			;with
	bne	fillqu		;question marks
findfr	jsr	srchf1		;search for first match
	bmi	notfnd		;error if none
fnddir	lda	sixten		;set across
	sta	across		;to four
	jsr	ccrlf		;do a crlf
dirl	jsr	hdr		;do header
	lda	#':'		;then a
	jsr	chrout		;colon
	lda	diradd		;get number
	asl	a		;and
	asl	a		;multiply
	asl	a		;by
	asl	a		;thirty two
	asl	a		;then
	and	#%01100000	;mask out insignificant
	tay			;make a pointer
	iny			;and bump
	ldx	#1		;set counter
nmelpe	lda	dflbuf,y	;get name
	jsr	cotsxy		;else send to console
noname	iny			;bump index
	inx			;and count
	cpx	#12		;if count is 12
	beq	endnme		;then done
	cpx	#9		;or if not 9
	bne	nmelpe		;then loop
	lda	#'.'		;else send
	jsr	cotsxy		;a period
	jmp	nmelpe		;and loop
endnme	jsr	chkcst		;check console status
	bne	extdir		;if key down quit
	jsr	setone		;else point to fcb
	jsr	srchnx		;else search for next
	sta	diradd		;save number
	bmi	extdir		;quit if not found
	dec	across		;drop count
	beq	fnddir		;new line if 0
	jsr	spcout		;send
	jsr	spcout		;two spaces
	jmp	dirl		;and stay
extdir	rts			;else done
;not found error handler
notfnd	ldy	#ntfnms		;point to message
	jmp	sndmsg		;send and exit
;execute ren command
; ren <ufn> <ufn>
;where first ufn is from name and second is to name
ren	jsr	prslin		;get old name
	bne	renerr		;error if afn
	jsr	tmpold		;save drive
	jsr	clrslt		;clear auto and select
	jsr	srchf1		;if file does not exist
	bmi	fntfnd		;then an error
	jsr	frssec		;move name to second half
	ldy	cnbfpt		;get pointer
	lda	cnstxt,y	;and then char
	cmp	#' '		;if not a space
	bne	rensyn		;then error
	jsr	prslin		;get new name
	bne	rensyn		;error if afn
	lda	tmpdsk		;get new drive
	beq	nonwdr		;if zero ok
	cmp	oldtmp		;compare to old
	beq	nonwdr		;ok if same
	sec			;drop for default check
	sbc	#1
	cmp	dfldsk		;if not default
	bne	rensyn		;is error
	lda	oldtmp		;and then if from not
	bne	rensyn		;default is error
nonwdr	lda	oldtmp		;else get old
	sta	tmpdsk		;and save
	lda	#0		;clear
	sta	fcbone+16
	jsr	clrslt		;reselect
	jsr	srchf1		;search for old
	bpl	filexs		;error if found
	jsr	frssec		;swap names
	jsr	setone		;point to fcb
	jmp	renmfl		;and do it
;ren file exists error handler
filexs	ldy	#flexms		;point to
	bne	remsg		;and send
;ren syntax error handler
rensyn	jsr	rstddr		;restore default
renerr	jmp	cmderr		;do error
;ren source file not found error handler
fntfnd	ldy	#ntfnms		;point to
remsg	jmp	sndmsg		;and send
;execute save command
; save <length> <drive:>ufn (<address>)
save	lda	#<tea		;set start address to tea start
	ldy	#>tea
	sta	sadr
	sty	sadr+1
	jsr	bldnum		;calculate length
	bne	saverr		;error if > 255 pages
	sta	length		;else save low
	ora	length		;test for zero length
	beq	saverr		;error if is
	jsr	prslin		;get file name
	bne	saverr		;error if afn
	jsr	frssec		;move name to second half
	jsr	tmpold		;save drive
	jsr	bldnum		;it is so find value
	ldx	fcbone+1	;see if there
	cpx	#' '
	beq	nosadr		;it is not
	sta	sadr		;and set address
	sty	sadr+1
	cpy	#2		;make sure is high enough
	bcc	saverr		;error if not
nosadr	jsr	secfrs		;move name back
	jsr	clrslt		;clear auto and select
	jsr	dlt1		;delete
	jsr	setone		;then create
	jsr	cratfl		;new file
	bmi	noroom		;say no room if error
	jsr	open1		;open file
	bmi	noopen		;if error
	clc			;now find end page
	lda	sadr+1
	adc	length
	sta	length
	lda	sadr		;get start address
	ldy	sadr+1
wrtmre	sta	dskbuf		;set
	sty	dskbuf+1	;buffer
	jsr	mv128		;move data to buffer
	jsr	setone		;point to fcb
	jsr	wrrcrd		;write record
	bne	wrterr		;exit if error
	clc			;else
	lda	dskbuf		;get old
	ldy	dskbuf+1	;buffer
	adc	#128		;add 128
	bcc	donotc		;if carry
	iny			;bump upper
	beq	clssav		;done if page zero
donotc	cpy	length		;loop if upper
	bne	wrtmre		;not at limit
clssav	jsr	setone		;else point to
	jsr	clsefl		;and close file
	bmi	cantcl		;say so if error
extera	rts
;save error handler
saverr	jmp	cmderr		;do error
;save no room error handler
noroom	ldy	#nospms		;point to
	bne	semsg		;and send
;save can not open error handler
noopen	ldy	#cnnoms		;point to
	bne	semsg		;and send
;save write error handler
wrterr	ldy	#wrerms		;point
	bne	semsg		;to and send
;save can not close error
cantcl	ldy	#ntclms		;point to
semsg	jmp	sndmsg		;and send
;execute era command
; era <afn>
era	jsr	prslin		;get file name
	cmp	#11		;if not all ?
	bne	nteral		;then skip verify
	ldy	#alflms		;else point to
	jsr	sndmsg		;and send all files
	jsr	cnsrde		;get an input
	pha			;and save
	jsr	ccrlf		;do a cr lf
	pla			;restore char
	and	#$5f		;convert to upper case
	cmp	#'Y'		;if not y
	bne	extera		;then quit
nteral	jsr	clrslt		;clear auto and select
	jmp	dlt1		;delete first
;execute type command
; type d:ufn
type	jsr	prslin		;get file
	bne	typafn		;error if afn
	jsr	casdo1		;clear - select - open file 1
	bmi	notype		;error if not found
	jsr	ccrlf		;else do cr lf
typmre	jsr	read1		;read record
	beq	okread		;if ok continue
	bpl	exttyp		;exit if just end
	bmi	typerr		;else error
okread	ldx	#0		;clear index
typlpe	lda	dflbuf,x	;get char
	cmp	#eof		;if eof
	beq	exttyp		;then exit
	jsr	cotsxy		;else send
	jsr	chkcst		;if key down
	bne	exttok		;then exit
	ldx	savx		;else get index
	inx			;bump it
	bpl	typlpe		;and loop if < 128
	bmi	typmre		;else read more
exttok	ldx	#6		;clear console
	jsr	pemjmp		;with no echo
exttyp	rts
;type syntax error handler
typafn	jmp	cmderr		;error return
;type read error handler
typerr	ldy	#rderms		;point to
	bne	temsg		;and send
;type not found error handler
notype	ldy	#ntfnms		;point to
temsg	jmp	sndmsg		;and send
;execute load command
; load <ufn> (<address>)
load	jsr	setddb		;set load start to tea start
	jsr	prslin		;build fcb
	bne	typafn		;error if afn
	jsr	frssec		;save in second half
	jsr	tmpold		;save file
	jsr	bldnum		;find start address
	ldx	fcbone+1	;see if number
	cpx	#' '
	beq	usedfl		;if none use default
	jsr	setdb		;and set
usedfl	jsr	secfrs		;move name back
	jsr	casdo1		;clear - select - open file 1
	bmi	notype		;exit if not found
	lda	dskbuf		;get load start
	ldy	dskbuf+1
lcmdlp	jsr	setbuf		;set as disk buffer
	jsr	read1		;read record
	bne	loadnd		;done if not zero
	jsr	adjdb		;bump address
	jmp	lcmdlp		;and loop
loadnd	bmi	typerr		;if error say so
	jmp	stdflb		;back to default buffer
;execute go command
; go (<address>)
go	jsr	bldnum		;get address
	ldx	fcbone+1	;get first char
	cpx	#' '		;see if nothing
	beq	nolnum		;nothing so use tea
	jmp	godoit		;then execute
nolnum	jmp	gotea
;execute trns (transient) command
; <ufn> (<fn>) (<fn>)
trns	lda	fcbone+1	;get first char
	cmp	#' '		;if not space
	bne	chktyp		;check type
	lda	tmpdsk		;else test temp
	beq	skpdrv		;if none skip
	sec			;else convert
	sbc	#1		;to number
	sta	dfldsk		;set default
	jsr	slctds		;and select
skpdrv	jmp	extwod		;return
chktyp	lda	fcbone+9	;get type
	cmp	#' '		;if space
	beq	typemp		;then ok
	jmp	trnerr		;else error
typemp	ldx	#2		;make
setcom	lda	typcom,x	;type
	sta	fcbone+9,x	;com
	dex			;then
	bpl	setcom		;continue
	jsr	casdo1		;clear - select - open file one
	bpl	gottrn		;jump if ok
	jmp	topner		;else do error
gottrn	jsr	setddb		;set start to tea
nxtrcr	jsr	setbuf		;set address
	jsr	read1		;read fcb 1
	bne	endlde		;branch if error or eof
	jsr	adjdb		;adjust address up by 128
	cmp	ccmvc		;if new low
	bcc	tryhig		;ok try high
	cpy	ccmvc+1		;else if high
	bcc	nxtrcr		;ok do more
	bcs	chklnd		;else check for end
tryhig	cpy	ccmvc+1		;if high less
	bcc	nxtrcr		;then ok
	beq	nxtrcr		;or ok if same
chklnd	jsr	stdflb		;set buffer to default
	jsr	read1		;read (should be eof)
	beq	tlderr		;error if more
endlde	bmi	tlderr		;do error
gotea	lda	#<tea		;set go address to tea start
	ldy	#>tea
godoit	sta	do+1		;set to ay
	sty	do+2
	jsr	rstddr		;else restore default
	jsr	prslin		;parse file
	lda	tmpdsk		;set auto
	sta	fcbone		;select position
	ldx	#16		;do a second
	jsr	prsmre		;fcb if there
	lda	tmpdsk		;set auto select
	sta	fcbone+16	;again
	ldy	#0		;clear record
	sty	fcbone+32	;counter
	ldx	#32		;move
movfcb	lda	fcbone,x	;all
	sta	dflfcb,x	;to
	dex			;default
	bpl	movfcb		;fcb
	inx			;set x to zero
tstbuf	lda	cnstxt,y	;get char
	beq	isnull		;if null jump
	cmp	#' '		;or if space
	beq	isnull		;jump
	iny			;else bump pointer
	bne	tstbuf		;and loop
isnull	lda	#0		;clear 
	sta	dflbuf		;count
movbuf	lda	cnstxt,y	;get char
	sta	dflbuf+1,x	;and move
	beq	fillov		;exit if null
	inx			;increment
	iny			;counters
	inc	dflbuf		;and length
	bne	movbuf		;and loop
fillov	jsr	ccrlf		;do a cr lf
	jsr	stdflb		;set default
do	jsr	tea		;execute
	lda	dfldsk		;get default
	jsr	slctds		;and set
	jmp	ccmlpe		;then loop
;trns syntax error handler
topner	jsr	rstddr		;restore default
trnerr	jmp	cmderr		;do error
;trns load error
tlderr	ldy	#lderms		;point to
	jmp	sndmsg		;and send
;carriage return and linefeed
ccrlf	lda	#cr		;get a cr
	jsr	chrout		;send
	lda	#lf		;get a lf
	bne	chrout		;and send
;pem entry routines
cnsrde	ldx	#1		;console read
	bne	pemgo
spcout	lda	#' '		;output space
chrout	ldx	#2		;console output
	bne	pemgo
rdebuf	ldx	#10		;buffered input
	bne	pemgo
chkcst	ldx	#11		;check console
	bne	pemgo
rstdsk	ldx	#13		;initialize system
	bne	pemgo
slctds	ldx	#14		;select drive
	bne	pemgo
openfl	ldx	#15		;open file
	bne	pemgo
clsefl	ldx	#16		;close file
	bne	pemgo
srchfr	ldx	#17		;first match
	bne	pemgo
srchnx	ldx	#18		;next match
	bne	pemgo
;delete file one
dlt1	jsr	setone		;point to fcb
dltfil	ldx	#19		;delete file
	bne	pemgo
rdrcrd	ldx	#20		;read record
	bne	pemgo
wrrcrd	ldx	#21		;write record
	bne	pemgo
cratfl	ldx	#22		;create file
	bne	pemgo
renmfl	ldx	#23		;rename file
	bne	pemgo
intdsk	ldx	#25		;read drive num
	bne	pemgo
setbuf	ldx	#26		;set buffer add
pemgo	jmp	pemjmp		;go to pem
;restore default drive
rstddr	lda	tmpdsk		;if temp drive
	beq	extddr		;zero then exit
	sec			;else
	sbc	#1		;subtract one
	cmp	dfldsk		;compare to default
	beq	extddr		;exit if same
seldfl	lda	dfldsk		;else get default
	jmp	slctds		;select
;clear auto - select disk - open file at fcbone
casdo1	jsr	clrslt		;clear auto and select
;open file one
; returns:n=1 if not found
open1	lda	#0		;clear
	sta	fcbone+32	;record number
	jsr	setone		;point to fcb
	jsr	openfl		;open it
	sta	diradd		;save number
extddr	rts
;read file one
read1	jsr	setone		;point to fcb
	jmp	rdrcrd		;do read
;search for first file one
; returns:n=1 if not found
srchf1	jsr	setone		;point to fcb
	jsr	srchfr		;search for first
	sta	diradd		;save number
	rts
;header output
hdrout	jsr	ccrlf		;do cr lf
hdr	jsr	intdsk		;get drive number
	clc			;make
	adc	#'A'		;a letter
;output with save of x and y
;this routine calls the pem resident routine
;tstchr to see if a char is a printing char.
;if it is then c=1 upon return from tstchr.
cotsxy	stx	savx		;save x
	sty	savy		;and y
	jsr	tstchr		;see if printing
	bcs	isprnt		;jump if is
	pha			;else save
	lda	sysdef+4	;get invert
	jsr	chrout		;send it
	pla			;get char
	ora	#'@'		;make printing
	jsr	chrout		;send it
	lda	sysdef+3	;get normal
isprnt	jsr	chrout		;do output
	ldy	savy		;get y
	ldx	savx		;and x
	rts
;set up fcb one pointer
setone	lda	fcb1vc		;low
	ldy	fcb1vc+1	;and high
	rts
;save tmpdsk in oldtmp
tmpold	lda	tmpdsk
	sta	oldtmp
	rts
;parse command line
prslin	ldx	#0		;clear index
prsmre	txa			;save
	pha			;index
	lda	#0		;clear temp
	sta	tmpdsk		;drive flag
	ldy	cnbfpt		;get buffer pointer
	jsr	skpspc		;find first non-space
	sty	curpnt		;save index
	beq	nulchr		;jump if null
	and	#%00001111	;else look at 4 lsbs
	pha			;and save
	iny			;point to next char
	lda	cnstxt,y	;and get it
	cmp	#':'		;if a colon
	beq	drvinp		;jump and set drive
	pla			;else clear stack
	dey			;backup index
nulchr	lda	dfldsk		;set automatic
	sta	fcbone,x	;to default
	bpl	trynme		;then parse name
drvinp	pla			;get number
	sta	tmpdsk		;set temp flag
	sta	fcbone,x	;and fcb
	iny			;point past colon
trynme	lda	#8		;set name count
	sta	count		;to eight
tstnme	jsr	tstlgl		;test for illegal
	beq	flnmsp		;if illegal jump
	inx			;bump pointer
	cmp	#'*'		;if not *
	bne	notafn		;skip ? fill
	lda	#'?'		;get a ?
	sta	fcbone,x	;store
	bne	nxtout		;and jump
notafn	sta	fcbone,x	;store char
	iny			;bump source
nxtout	dec	count		;drop counter down
	bne	tstnme		;and loop
skpmre	jsr	tstlgl		;if illegal
	beq	trytyp		;try type
	iny			;else bump index
	bne	skpmre		;and loop
flnmsp	inx			;next position
	lda	#' '		;get a space
	sta	fcbone,x	;store
	dec	count		;count down
	bne	flnmsp		;and loop
	lda	cnstxt,y	;get char again
trytyp	pha			;save char
	lda	#3		;set count
	sta	count		;to three
	pla			;get char
	cmp	#'.'		;if not .
	bne	fltysp		;then fill spaces
	iny			;else bump source
tsttyp	jsr	tstlgl		;if not legal
	beq	fltysp		;then fill spaces
	inx			;else bump index
	cmp	#'*'		;if not *
	bne	notaft		;then skip fill
	lda	#'?'		;else get ?
	sta	fcbone,x	;move to fcb
	bne	mrtyfl		;and loop
notaft	sta	fcbone,x	;move char to fcb
	iny			;bump source
mrtyfl	dec	count		;count down
	bne	tsttyp		;and loop
nttype	jsr	tstlgl		;if illegal
	beq	filnul		;fill out nulls
	iny			;else bump source
	bne	nttype		;and loop
fltysp	inx			;bump fcb pointer
	lda	#' '		;get space
	sta	fcbone,x	;put in fcb
	dec	count		;count down
	bne	fltysp		;and continue
filnul	lda	#3		;clear
	sta	count		;three
mrnlty	inx			;bump fcb pointer
	lda	#0		;get a zero
	sta	fcbone,x	;move to fcb
	dec	count		;count down
	bne	mrnlty		;loop until done
	sty	cnbfpt		;update start pointer
	lda	#0		;clear
	sta	count		;count
	pla			;restore stack
	tay			;move to index
	ldx	#11		;counter to 11
tstqus	iny			;point to
	lda	fcbone,y	;and get char
	cmp	#'?'		;if not a ?
	bne	nxtqus		;then jump
	inc	count		;else bump count
nxtqus	dex			;loop until
	bne	tstqus		;11 tested
	lda	count		;get count
	rts			;and return
;skip space
skpspc	lda	cnstxt,y	;get char
	beq	extskp		;jump if null
	cmp	#' '		;if not space
	bne	extskp		;then exit
	iny			;else go to next
	bne	skpspc		;and test
extskp	rts
;test legal
tstlgl	lda	cnstxt,y	;get char
	beq	extlgl
	cmp	#' '		;if space
	bcc	badinp		;ok - less is error
	beq	extlgl
	cmp	#'='
	beq	extlgl
	cmp	#'.'
	beq	extlgl
	cmp	#':'
	beq	extlgl
	cmp	#semico
	beq	extlgl
	cmp	#'<'
	beq	extlgl
	cmp	#'>'
extlgl	rts
badinp	jmp	cmderr
;set default buffer address
stdflb	lda	#<dflbuf 	;point to
	ldy	#>dflbuf	;location
	jmp	setbuf		;and set
;clear automatic and select
clrslt	lda	#0		;clear auto
	sta	fcbone		;select
slttmp	lda	tmpdsk		;get temp
	beq	extsnd		;if zero exit
	sec			;else subtract
	sbc	#1		;one
	cmp	dfldsk		;if same as default
	beq	extsnd		;then quit
	jmp	slctds		;else set
;send message
sndmsg	sty	savy		;save index
	jsr	ccrlf		;do cr and lf
	ldy	savy		;get index
lpesnd	lda	msgtbl,y	;get char
	beq	extsnd		;if null quit
	jsr	cotsxy		;else send
	iny			;point to next
	bne	lpesnd		;and loop
extsnd	rts
;set load start address
setddb	lda	#<tea		;to tea start
	ldy	#>tea
setdb	sta	dskbuf		;to ay
	sty	dskbuf+1
	rts
;move first part of fcb to second half
;and move second part to first part.
;only ren depends upon this routine to actually
;swap fcb halves.
;alters:a,x,p
;returns:x=$ff
frssec	ldx	#15		;set index to last
frsclp	lda	fcbone,x	;get byte
	ldy	fcbone+16,x
	sta	fcbone+16,x	;move it
	tya
	sta	fcbone,x
	dex
	bpl	frsclp		;until 16 moved
	rts
;move second part of fcb to first half
;restore tmpdsk from save location
;alters:a,x,p
;returns:x=$ff
secfrs	ldx	#15		;set index to last
scfrlp	lda	fcbone+16,x	;get byte
	sta	fcbone,x	;move it
	dex
	bpl	scfrlp		;loop until done
	lda	oldtmp		;get old flag
	sta	tmpdsk		;and set
	rts
;build a number from command line and leave in num
;will handle either decimal (e.g., 578) or hexadecimal (e.g., $3f2)
;move parse index past number
;modifies:all
;returns:a,y set to low and high of number
;	 flags set according to y which is high part of number
bldnum	lda	#9		;preset to decimal
	sta	moduls
	jsr	prslin		;put in fcb
	lda	tmpdsk		;if temp
	bne	numerr		;is error
	sta	num		;else clear num
	sta	num+1
	tay			;and index
	lda	fcbone+1,y	;get first char
	cmp	#'$'		;see if hex signal
	bne	bnumlp		;skip if not
	lda	#15		;set for modulus
	sta	moduls
	iny			;bump past $
bnumlp	iny			;next char
	lda	fcbone,y	;get digit
	cmp	#' '		;see if space
	beq	endnlp		;done if is
	jsr	tstdec		;see if decimal
	bcc	usedig		;use if is
	jsr	tsthex		;see if hex
	bcs	numerr		;error if not
	sbc	#6		;remove offset
	ldx	#15		;test for hex modulus
	cpx	moduls
	bne	numerr		;error if not
usedig	and	#%00001111	;eliminate ascii bias
	pha			;save result
	lda	num		;move number to temp
	sta	tnum
	lda	num+1
	sta	tnum+1
	ldx	moduls		;get modulus
	clc
addlpe	lda	num		;add number to itself
	adc	tnum
	sta	num
	lda	num+1		;modulus times
	adc	tnum+1
	sta	num+1
	bcs	numerr		;error if carry out
	dex
	bne	addlpe		;loop if more
	pla			;get input back
	adc	num		;add in
	sta	num
	bcc	bnumlp		;loop if no carry
	inc	num+1		;else bump high
	bne	bnumlp		;and loop for more
;error in bldnum - handle and quit
numerr	jmp	cmderr		;do general error
;end of use of name part - check type
endnlp	lda	fcbone+9	;get first
	cmp	#' '		;see if space
	bne	numerr		;error if not
	lda	num		;return with result
	ldy	num+1
	rts
;relocatable vectors
	.byte	$4c
cnsbvc	.word	cnsbuf
	.byte	$4c
extcvc	.word	extcmd-1
	.byte	$4c
ccmvc	.word	ccm
	.byte	$4c
fcb1vc	.word	fcbone
;function entry vector
xqfntb	jmp	dir
	jmp	save
	jmp	era
	jmp	type
	jmp	ren
	jmp	go
	jmp	load
	jmp	trns
;terminator for relocation
	.byte	$ff
;messages
msgtbl:
	.byte 0
nospms	equ	$-msgtbl
	.byte	"NO SPACE",0
ntclms	equ	$-msgtbl
	.byte "CAN NOT CLOSE",0
alflms	equ	$-msgtbl
	.byte "ALL FILES (Y/N)?",0
rderms	equ	$-msgtbl
	.byte	"READ ERROR",0
ntfnms	equ	$-msgtbl
	.byte	"NOT FOUND",0
flexms	equ	$-msgtbl
	.byte "FILE EXISTS",0
lderms	equ	$-msgtbl
	.byte "LOAD ERROR",0
cnnoms	equ	$-msgtbl
	.byte "CAN NOT OPEN",0
wrerms	equ	$-msgtbl
	.byte "WRITE ERROR",0
;function name table
fnctbl	.byte	"DIR ",0
	.byte	"SAVE ",0
	.byte	"ERA ",0
	.byte	"TYPE ",0
	.byte	"REN ",0
	.byte	"GO ",0
	.byte	"LOAD ",0
;input buffer
cnsbuf
cnsmax .byte 127
cnslng .byte 0
cnstxt
	BLKB	127,0
;fcb one
fcbone
	BLKB	33,0
;com type field
typcom	.byte	"COM"
;variable storage
cnbfpt	.byte	0		;buffer index
dfldsk	.byte	0		;default drive
tmpdsk	.byte	0		;temporary dvive
;align vector on word boundary

bound1	equ	$/2*2+2
	org	bound1
	
vector	.word	0		;execution vector
count	.byte	0		;counter
curpnt	.byte	0		;input parse start
diradd	.byte	0		;directory number
savx	.byte	0		;save x location
savy	.byte	0		;save y location
length	.byte	0		;number tages to save
oldtmp	.byte	0		;temp drive in ren
dskbuf	.word	tea		;disk buffer start
across	.byte	0		;dir count on line
sixten	.byte	0		;line length div 16
moduls	.byte	9		;modulus-1 for number input
num	.word	0		;input number
tnum	.word	0		;temp in bldnum
sadr	.word	tea		;save start address

ccm_end	equ	$

;------------------------------------------------------------------
;dos/65 primitive execution module (pem)
; PEM_SECTION
;zero page data storage
pzstrt	equ	$2		;start of page zero "free" RAM
addinp	equ	pzstrt		;initialized to a,y
bufadd	equ	addinp+2	;buffer address
alcpnt	equ	bufadd+2	;allocation map pointer
chkpnt	equ	alcpnt+2	;checksum map pointer
numvar	equ	8		;eight bytes
;main program

; input:x=command,a=value,a&y=address
; returns:a=value,a&y=address
; alters:all
;	org	ccm+ccmlng
	org	(ccm_end&$ff00)+$100

pem_body
	cld			;set binary mode
	sta	bytinp		;save input
	sta	lowin		;value and
	sty	bytinp+1	;save high
	sty	lowin+1		;address
	stx	cmdinp		;and command
	cpx	#numcmd		;if invalid
	bcs	extpem		;then exit
	lda	swctbl,x	;if flag zero
	beq	noswin		;skip switch
	lda	#255		;else set
	sta	swcflg		;memory switch flag
	jsr	switch		;move data to page zero
noswin	lda	#0		;clear drive
	sta	tmpdrv		;switch flag
	lda	cmdinp		;get command
	asl	a		;multiply by two
	adc	cmdinp		;then add to get x3
	tax			;and make a pointer
	inx			;bump to pass jmp
	lda	cmdtbl,x	;get command
	ldy	cmdtbl+1,x	;address
	sta	xqtvec		;and put
	sty	xqtvec+1	;in vector
	lda	extevc+1	;get return
	pha			;address
	lda	extevc		;and push
	pha			;as return
	lda	bytinp		;get input value
	ldy	bytinp+1
	jmp	(xqtvec)	;then execute
extexq
	sta	bytout		;save value
	sty	addout+1	;and address
	lda	tmpdrv		;get temp drive
	beq	extpem		;if zero skip switch
	ldy	#0		;else
	sta	(addinp),y	;put back in fcb
	lda	olddrv		;get old drive number
	sta	bytinp		;set input value
	jsr	chgdrv		;then switch back
extpem	bit	swcflg		;test memory switch
	bpl	noswot		;if not set skip
	jsr	switch		;else do memory switch
	lda	#0		;clear
	sta	swcflg		;flag
noswot	ldy	addout+1	;get address
	lda	bytout		;and value (address low)
	rts
;command vector table
cmdtbl	jmp	xwboot		; 0:warm boot
	jmp	xcnsin		; 1:console input with echo
	jmp	sndchr		; 2:console output
	jmp	sim+21		; 3:tape reader
	jmp	sim+18		; 4:tape punch
	jmp	sim+15		; 5:printer output
	jmp	getcon		; 6:console input w/o echo
	jmp	xgtios		; 7:read i/o status
	jmp	xstios		; 8:set i/o status
	jmp	sndstr		; 9:print buffer
	jmp	bufinp		;10:read buffer
	jmp	kbdsts		;11:test console ready
	jmp	sim+45		;12:read list status
	jmp	xintds		;13:initialize system
	jmp	chgdrv		;14:log in drive
	jmp	xopen		;15:open file
	jmp	xclose		;16:close file
	jmp	xfndfr		;17:find first match
	jmp	xfndnx		;18:find next match
	jmp	xdltfl		;19:delete file
	jmp	xread		;20:read record
	jmp	xwrite		;21:write record
	jmp	xmake		;22:create file
	jmp	xrenme		;23:rename file
	jmp	xintlg		;24:interrogate log in status
	jmp	xintdr		;25:interrogate current drive
	jmp	chgdma		;26:set buffer address
	jmp	xrdalv		;27:read allocation map start
	jmp	setron		;28:set r/w status
	jmp	xrdros		;29:read r/w status
	jmp	setlst		;30:set list echo status
	jmp	lststs		;31:read list echo status
	jmp	xrtclo		;32:read low clock
	jmp	xrtchi		;33:read high clock
	jmp	xrddcb		;34:read dcb address
	jmp	sim+51		;35:translate sector
;set list echo status
setlst	sta	lstflg		;set flag
	rts
;read list echo status
lststs	lda	lstflg		;read flag
	rts
;execute warm boot
; ***this command does not return to pem***
; ***instead it jumps to sim, resets	***
; ***system and stack and jumps to ccm. ***
xwboot	bit	swcflg		;test memory switch flag
	bpl	dowmbt		;if clear do not
	jsr	switch		;switch memory
	lda	#0		;clear
	sta	swcflg		;flag
dowmbt	jmp	sim+3		;go to sim
;execute read real time clock
xrtclo	jsr	sim+48		;read clock
	sta	rtclk		;save low
	sty	rtclk+1		;middle
	stx	rtclk+2		;high
	txa
	and	#%10000000	;test for valid
	tay
	lda	rtclk		;get low
	rts
;execute read real time clock high
xrtchi	lda	rtclk+2		;get high
	and	#%01111111	;clear status
	tay
	lda	rtclk+1		;get middle
	rts
;execute read dcb address
xrddcb	lda	cptdcb+1	;get address
	ldy	cptdcb+2
	rts
;execute read i/o status
xgtios	lda	iostat		;get status byte
	rts
;execute read allocation map starting address
xrdalv	lda	alcmap		;get
	ldy	alcmap+1	;starting address
	rts			;then return
;execute set i/o status
xstios	sta	iostat		;set status
	rts
;execute interrogate current drive
xintdr	lda	curdrv		;get number
	rts
;execute read log in status
xintlg	lda	lginvc		;get status
	rts
;execute read read/write status
xrdros	lda	ronlst		;get status
	rts
;execute find next match
xfndnx	jsr	autodr		;auto drive select
	lda	#13		;match including
	jmp	search		;extent
;execute read next record
xread	jsr	autodr		;auto drive select
	jsr	inrcct		;initialize record counters
	lda	nxtrec		;if next record less
	cmp	numrec		;then number records
	bcc	tryrde		;then try to read
	cmp	#128		;but if not and
	beq	tryext		;is max try to extend
rdeeof	lda	#1		;else set eof
	rts			;code and return
tryext	ldx	#1		;try for a read
	jsr	extend		;file extension
	cmp	#0		;if not ok exit eof
	bne	rdeeof		;with jump back
	sta	nxtrec		;clear next record
tryrde	jsr	getblk		;and get block
	lda	blknum		;if block not zero
	ora	blknum+1
	bne	dorde		;do the read
	lda	#2		;else set unwritten
	rts			;code and exit
dorde	jsr	calrcn		;calculate record number
	jsr	sttrsc		;set track and sector
	jsr	rdesec		;do sector read
	jsr	updtrc		;update counters
	lda	#0		;return w/o error
;extrde	
	rts
;execute file rename
xrenme	jsr	autodr		;automatic drive select
	jsr	tstron		;test for r/o
	lda	#12		;match name
	jsr	frstsr		;and type
	bmi	extren		;exit if not found
doren	lda	#0		;clear drive select
	ldy	#16		;in new name
	sta	(addinp),y	;part of fcb
	lda	#12		;then move
	ldx	#16		;new name
	jsr	dirchg		;to directory
	lda	#12		;see if
	jsr	search		;another match
	bpl	doren		;loop if found
extren	rts			;number
;execute delete file
xdltfl	jsr	autodr		;automatic drive select
	jsr	tstron		;test for r/o
	lda	#12		;match name
	jsr	frstsr		;and type
	bmi	extdlt		;done if not found
dodlt	ldx	#0		;else do a
	jsr	mapdir		;delete
	ldy	subrec		;then change
	lda	empty		;byte zero to
	sta	(bufadd),y	;empty code
	jsr	updtck		;then update directory
	lda	#12		;search
	jsr	search		;for next
	bpl	dodlt		;loop if found
extdlt	rts			;exit
;execute write next record
xwrite	jsr	autodr		;automatic drive select
	jsr	tstron		;test for r/o
	jsr	inrcct		;initialize counters
	lda	nxtrec		;get next record
	cmp	#128		;compare to max
	bcc	ntexte		;continue if less
	lda	#1		;else flag as extend
	rts			;error and exit
ntexte	jsr	getblk		;calculate block num
	lda	#0		;say normal write
	sta	wrtype		;for now
	lda	blknum		;get it and if
	ora	blknum+1
	beq	*+5		;zero then get number
	jmp	blkopn		;else go write
	lda	#2		;say unalloc write
	sta	wrtype
	lda	fcbind		;get index from prior
	pha			;and save
	cmp	#16		;if first block
	beq	isfrst		;then don't change
	tay			;else make an index
	dey			;point to last
	bit	blmode		;test mode
	bpl	*+3		;done if byte
	dey			;else drop for word
	lda	(addinp),y	;and get that number
	sta	blknum		;store as starting
	iny			;bump for word
	lda	#0		;preset for byte
	bit	blmode		;test mode
	bpl	*+4		;done if byte
	lda	(addinp),y	;else get high
	sta	blknum+1	;then set high
isfrst	lda	blknum		;get block
	sta	lkdown		;set lower and 
	sta	lookup		;upper pointers
	lda	blknum+1	;now set high part
	sta	lkdown+1
	sta	lookup+1
srblag	lda	lookup		;if upper pointer
	cmp	maxblk		;not at max
	bne	upnemx		;then keep going
	ldy	lookup+1	;now check high
	cpy	maxblk+1
	beq	tstdwn		;go test down
upnemx	inc	lookup		;else bump upper
	bne	*+5
	inc	lookup+1
	lda	lkdown		;then if lower
	ora	lkdown+1
	beq	dotest		;is zero start test
	bne	dcdown		;else drop lower
tstdwn	lda	lkdown		;if upper & lower at
	ora	lkdown+1
	bne	dcdown		;drop if not zero
	tay			;also set y
	beq	extsbl		;then exit
dcdown	lda	lkdown		;drop lower
	bne	*+5
	dec	lkdown+1
	dec	lkdown
dotest	lda	lkdown		;get lower
	ldy	lkdown+1
	jsr	tstblk		;and test
	bne	trylup		;if full try upper
	lda	lkdown		;else use lower
	ldy	lkdown+1
	jmp	extsbl		;as result
trylup	lda	lookup		;get upper
	ldy	lookup+1
	jsr	tstblk		;if full
	bne	srblag		;then loop
	lda	lookup		;else use upper
	ldy	lookup+1
extsbl	sta	blknum		;then save number
	sty	blknum+1
	ora	blknum+1	;see if zero
	bne	gtgood		;then proceed
	pla			;clear stack
	lda	#2		;set end
	rts			;of data return
gtgood	lda	blknum		;get low again
	jsr	setblk		;set allocation map
	pla			;get block
	tay			;pointer back
	lda	blknum		;get number
	sta	(addinp),y	;and put in fcb
	lda	blknum+1	;get high
	iny
	bit	blmode		;test mode
	bpl	*+4		;done if byte
	sta	(addinp),y	;else set high
blkopn	jsr	calrcn		;calculate record num
	jsr	sttrsc		;set track and sector
	jsr	wrtsec		;do write
	ldx	nxtrec		;get next record
	cpx	numrec		;if less than max
	bcc	notful		;then ok
	inx			;else bump count
	stx	numrec		;and save
	dex			;back down
notful	cpx	#127		;if not at max
	bne	noawex		;skip extending
	jsr	updtrc		;update record counters
	ldx	#0		;do write
	jsr	extend		;file extension
	cmp	#0		;if not ok
	bne	extwrt		;exit
	lda	#255		;else start counter
	sta	nxtrec		;at one short
noawex	jsr	updtrc		;then update counters
	lda	#0		;good return
extwrt	rts			;exit
;execute console input
xcnsin	jsr	getcon		;get input
	jsr	tstchr		;test it and
	bcc	extxci		;if control exit
	pha			;else save
	jsr	sndchr		;echo
	pla			;restore
extxci	rts			;return
;switch memory
;page zero block begins at pzstrt and is numvar bytes long.
switch	ldx	#numvar-1	;get number to switch
nxtswh	lda	pzstrt,x	;get zero page
	ldy	varblk,x	;and save area
	sta	varblk,x	;save zero
	sty	0+pzstrt,x	;and high
	dex			;count down
	bpl	nxtswh		;and loop until done
drvsme	rts			;then return
;change dma address
; input:addinp=address
; returns:none
; alters:all
chgdma	lda	addinp		;get low
	ldy	addinp+1	;and high address
	sta	bufadd		;then store
	sty	bufadd+1	;in address
	jmp	sim+36		;then go to sim
;change drive
; input:bytinp
; returns:none
; alters:all
chgdrv	lda	bytinp		;get input
	cmp	curdrv		;if same as current
	beq	drvsme		;do nothing
	sta	curdrv		;else change current
	jmp	mapdrv		;then log it in
;automatic drive select
; input:(addinp) 0=no change
; 1-8 or 'A'-'H' = change
; returns:none
; alters:all
autodr	ldy	#0		;get
	lda	(addinp),y	;first byte of fcb
	beq	qtatdr		;if zero quit
	sec			;set carry for
	sbc	#1		;subtract one
	and	#%00000111	;look at three lsbs
	sta	bytinp		;make parameter
	lda	curdrv		;get current
	sta	olddrv		;and save
	lda	(addinp),y	;get fcb entry
	sta	tmpdrv		;and save as flag
	tya			;set a to 0
	sta	(addinp),y	;clear byte zero in fcb
	jsr	chgdrv		;then select new drive
qtatdr	rts			;and return
;execute initialize system
; input:none
; returns:none
; alters:all,curdrv,lginvc,bufadd
xintds
	lda	#0		;set current
	sta	curdrv		;drive to a
	sta	lginvc		;clear log in status
	lda	#<dflbuf	;get default buffer
	ldy	#>dflbuf	;address
	sta	addinp		;and set up 
	sty	addinp+1	;parameters
	jsr	chgdma		;change address
;log in drive and set pointers and maps
; input:curdrv
; returns:none
; alters:all
mapdrv	lda	curdrv		;if current drive
	cmp	#8		;is 0 to 7
	bcc	vlddrv		;then log it in
drserr	jsr	errout		;send error message
	lda	sltmvc		;point to
	ldy	sltmvc+1	;select message
	jsr	sndstr		;and send it
	jmp	xwboot		;and abort

vlddrv	jsr	sim+27		;go to sim to set
	sta	cptdcb+1	;save
	sty	cptdcb+2
	ora	cptdcb+2	;see if invalid
	beq	drserr		;error if is
;capture dcb
	ldy	#14-1		;do 14 bytes
cptdcb	lda	$ffff,y		;get value from sim
	sta	dcb,y		;store it
	dey
	bpl	cptdcb		;loop for more
	lda	blkscd		;get block size code
	tay			;save in y
	clc
	adc	#3		;convert to sxb
	sta	sxb		;and save
	lda	sabtbl,y	;get sab
	sta	sab		;and set
	lda	maxdir		;get max dir
	sta	maxdrc		;set max dir record
	lda	maxdir+1
	lsr	a		;divide by 4
	ror	maxdrc
	lsr	a
	ror	maxdrc
	sta	maxdrc+1	;then save high
	stz	blmode		;set mode to byte
	lda	maxblk+1	;branch if max block
	beq	ntm255		;not over 255
;if y=0 when the following line is executed it means
;that the user has put an illegal combination into
;the disk definition table. may want to consider
;putting some error checking here in the future if
;there is space in pem.
	dey			;back up index
	sec			;else set mode to word
	ror	blmode
ntm255	lda	exmtbl,y	;get extent mask
	sta	exm
	sec			;now calculate cexm1f
	lda	#31
	sbc	exmtbl,y
	sta	cexm1f
	ldx	curdrv		;get drive as pointer
	lda	bitmap,x	;get bit
	and	lginvc		;if logged in
	bne	extstm		;then exit
	lda	bitmap,x	;get bit back
	ora	lginvc		;set in log-in
	sta	lginvc		;and update
	bra	flinal		;then fill in maps
extstm	
	rts			;and return
;fill in allocation map
flinal	jsr	setrw		;set to read/write
	lda	maxblk		;divide max block by
	sta	gpcnt		;eight to get max
	lda	maxblk+1
	ldx	#3
clcnab	lsr	a		;use a for speed
	ror	gpcnt
	dex
	bne	clcnab		;loop if more
	sta	gpcnt+1		;save high
	inc	gpcnt		;bump by one
	bne	*+5
	inc	gpcnt+1		;with carry
	lda	alcmap		;get map start
	ldy	alcmap+1
	sta	alcpnt		;set pointer to start
	sty	alcpnt+1
clraml	lda	#0		;clear byte
	sta	(alcpnt)	;put in map
	inc	alcpnt		;bump pointer
	bne	*+4
	inc	alcpnt+1	;with carry
	lda	gpcnt		;get low of count
	bne	*+5		;skip if not zero
	dec	gpcnt+1		;else drop high
	dec	gpcnt		;always drop low
	lda	gpcnt		;test for zero
	ora	gpcnt+1
	bne	clraml		;loop if more
;at this point complete map is cleared
	lda	maxdrc		;get low of max dir record
	sta	gpcnt
	lda	maxdrc+1	;high in a
	ldx	sxb		;set x according to block size
clcmdb	lsr	a		;do division
	ror	gpcnt
	dex
	bne	clcmdb		;until x is zero
	sta	gpcnt+1		;set high
	inc	gpcnt		;then bump by one
	bne	*+5
	inc	gpcnt+1
	stx	blknum		;clear block number
	stx	blknum+1
fildal	lda	blknum		;get block number
	ldy	blknum+1
	jsr	setblk		;set bit
	inc	blknum		;bump block number
	bne	*+5
	inc	blknum+1
	lda	gpcnt		;get low of count
	bne	*+5		;skip if not zero
	dec	gpcnt+1		;else drop high
	dec	gpcnt		;always do low
	lda	gpcnt		;test for zero
	ora	gpcnt+1
	bne	fildal		;loop if more
;at this point directory space is mapped
	jsr	intdrv		;initialize drive
	jsr	cldrnm		;clear directory number
fillpe	ldx	#1		;parameter for fill
	jsr	nxtdir		;execute for next directory
	bmi	extfil		;done if invalid
	ldy	subrec		;get offset
	lda	(bufadd),y	;get empty/valid flag
	cmp	#$e5		;if empty
	beq	fillpe		;try next
	ldx	#1		;parameter for fill in
	jsr	mapdir		;do directory map
	bra	fillpe		;then loop
extfil	
	rts			;return
	nop
;initialize drive
; input:nsystr
; returns:none
; alters:all
intdrv	jsr	sim+24		;home then
	lda	nsystr		;get number of system tracks
	ldy	nsystr+1
	jmp	sim+30		;and set in sim
;directory record set up
; input:dirnum
; returns:none
; alters:all,recnum,dirrec
drrcsu	lda	dirnum+1	;move high dir number
	sta	recnum+1	;to record number
	lda	dirnum		;divide
	lsr	recnum+1	;directory by four
	ror	a
	lsr	recnum+1
	ror	a
	sta	dirrec		;and save
	sta	recnum		;set low record number
	lda	recnum+1	;get high
	sta	dirrec+1	;and set
	stz	recnum+2	;clear top byte
;set track and sector
; input:recnum
; returns:none
; alters:all,countr,trkctr
sttrsc	ldx	#0		;clear track counter
	stx	trkctr
	stx	countr		;and record
	stx	countr+1	;counter
	stx	countr+2
trnxtr	lda	recnum		;from
	cmp	countr		;record number
	lda	recnum+1	;and if a
	sbc	countr+1	;borrow then
	lda	recnum+2
	sbc	countr+2
	bcc	higher		;gone too far
	clc			;else
	lda	countr		;get counter
	adc	sectrk		;add sectors per track
	sta	countr		;sectors per track
	lda	countr+1
	adc	sectrk+1
	sta	countr+1
	bcc	bumptr		;done if no carry
	inc	countr+2	;else bump high
bumptr	inx			;increase track count
	bne	trnxtr		;with carry
	inc	trkctr
	bra	trnxtr		;then loop
higher	dex			;back up track
	cpx	#$ff		;see if wrap around
	bne	*+5		;wasn't
	dec	trkctr		;else drop high
	txa			;move to a
	clc			;add starting track
	adc	nsystr
	tax			;save in x
	lda	trkctr
	adc	nsystr+1
	tay			;move to correct registers
	txa
	jsr	sim+30		;then set in sim
	sec			;back
	lda	countr		;counter down
	sbc	sectrk		;by sectors per track
	sta	countr		;and save
	lda	countr+1
	sbc	sectrk+1
	sta	countr+1
	sec			;now 
	lda	recnum		;find difference
	sbc	countr		;as sector
	tax			;save in x
	lda	recnum+1
	sbc	countr+1
	tay			;move to correct registers
	txa
;	jsr	sim+51		;translate
	jmp	sim+33		;and set through sim
;get block bit mask and index
; input:a&y=block number
; returns:a=bit mask and y=0
; alters:all and alcpnt
blkmsk	pha			;save block number
	sty	alcpnt+1	;including high
	lsr	alcpnt+1	;shift high
	ror	a
	lsr	alcpnt+1
	ror	a
	lsr	alcpnt+1
	ror	a
	clc			;now add map start
	adc	alcmap
	sta	alcpnt
	lda	alcpnt+1
	adc	alcmap+1
	sta	alcpnt+1
	pla			;get number back
	and	#%00000111	;look at 3 lsbs
	tax			;get
	lda	bitmsk,x	;mask
	rts			;and return
;test block
; input:a&y=block number
; returns:z=1 if unassigned
; 	   =0 if assigned and bit in a is set
; alters:all
tstblk	jsr	blkmsk		;get mask and index
	and	(alcpnt)	;mask with map entry
	rts			;then return
;alter block status
; input:a&y=block number,x=1 if set
;		   	  =0 if reset
; returns:none
; alters:all and allocation map
altalc	cpx	#1		;if set
	beq	setblk		;go do it
clrblk	jsr	blkmsk		;else get mask
	eor	#$ff		;and complement
	and	(alcpnt)	;preserve others
	sta	(alcpnt)	;and save
	rts			;then return
setblk	jsr	blkmsk		;get mask
	ora	(alcpnt)	;set bit
	sta	(alcpnt)	;and put back
	rts			;then return
;set current drive to read only
; input:curdrv,ronlst,bitmap
; returns:none
; alters:a,x,p and ronlst
setron	ldx	curdrv		;get number
	lda	bitmap,x	;and get mask
	ora	ronlst		;or with status
	sta	ronlst		;and put back
	rts			;then return
;calculate checksum of buffer @ bufadd
; input: buffer@(bufadd)
; returns:a=checksum
; alters:a,y,p
clcchk	lda	#0		;clear accumulator
	ldy	#127		;start at end
chkmre	clc			;no carry
	adc	(bufadd),y	;add byte
	dey			;count down
	bpl	chkmre		;and loop until done
	rts			;then return
;check read/write status
; input:curdrv,ronlst
; returns:z=0 if r/o or z=1 if r/w
; alters:a,x,p
chkron	ldx	curdrv		;get current drive
	lda	bitmap,x	;get mask
	and	ronlst		;and test status
	rts
;initialize record counters from fcb
; input:fcb@(addinp)
; returns:none
; alters:a,y,p,nxtrec,numrec
inrcct	ldy	#32		;next record offset
	lda	(addinp),y	;get next record
	sta	nxtrec		;and save
	ldy	#15		;number records offset
	lda	(addinp),y	;get number
	sta	numrec		;and save
	rts			;and return
;update record counters in fcb
; input:nxtrec,numrec
; returns:none
; alters:all,fcb@(addinp)
updtrc	ldx	nxtrec		;get next record
	inx			;bump it
	txa			;transfer
	ldy	#32		;set offset
	sta	(addinp),y	;and store in fcb
	lda	numrec		;get number
	ldy	#15		;and its offset
	sta	(addinp),y	;and store
	rts			;then return
;execute open file
xopen	jsr	autodr		;auto drive select
;open file
; input:fcb @ (addinp)
; returns:n=1 if not found,a=dirmod (255 if not found)
; alters:all
opnfle	jsr	fndf13		;match all including extent
	bmi	extopn		;done if not found
	lda	#12		;point to first char
	ora	subrec		;add offset
	tay			;make it a pointer
nxopmv	lda	(bufadd),y	;get buffer contents
	tax			;and save
	tya			;save index
	and	#%00011111	;remove offset
	tay			;back to index
	txa			;get byte back
	sta	(addinp),y	;and store in fcb
	tya			;get index
	ora	subrec		;add offset back
	tay			;and make index again
	iny			;next position
	tya			;if index
	and	#%00011111	;not gone past
	bne	nxopmv		;end then loop
;now correct extent and max records
	ldy	#12		;point at extent in fcb
	lda	savext		;get save from search
	cmp	(addinp),y	;compare
	beq	extsme		;jump ahead if same
	sta	(addinp),y	;else change extent
	lda	#128		;assume fcb ext < dir ext
	bcc	fcbxls		;jump ahead if true
	asl	a		;clear a
fcbxls	ldy	#15		;point to max
	sta	(addinp),y	;and set
extsme	lda	dirmod		;else get number
extopn	rts			;and return
;execute close file
xclose	jsr	autodr		;auto drive select
;close file
;if file is r/o then no actual close
;operation is performed.
; input:fcb @ (addinp)
; returns:n=1 if not valid,a=dirmod (255 if invalid)
; alters:all
clsfle	jsr	fndf13		;match including extent
	bmi	extcls		;exit if not found
	jsr	chkron		;see if r/o
	bne	noclse		;branch if is
;now set flag to ensure directory extent and number of
;records fields are only changed if necessary.
;The decision to change is determined by whether or
;not the system is closing an extent less than the
;maximum extent in the directory entry. If that is
;the case, the directory extent and number of record
;fields are not changed.
	ldy	#12		;get extent
	lda	(addinp),y
	pha			;save it
	tya			;now look in directory
	ora	subrec
	tay
	pla			;get extent back
	cmp	(bufadd),y
	ror	skpdir		;save result
;now go do it
	jsr	updtdr		;update directory
noclse	lda	dirmod		;get directory number
extcls	rts			;and return
;execute find first match
xfndfr	jsr	autodr		;auto drive select
fndf13	lda	#13		;match including extent
;search for first match
; input:a=number char to match
; returns:n=1 if invalid,a=dirmod (255 if invalid)
; alters:all
frstsr	pha			;save number to match
	jsr	cldrnm		;clear directory number to -1
	jsr	intdrv		;and drive
	pla			;get number to match
;search for directory match
; input:a=number char to match
; returns:n=1 if not found,a=dirmod (255 if invalid)
; alters:all
search	sta	chrcnt		;save number
newtry	ldx	#0		;set for search
	stx	cmppnt		;clear pointer
	jsr	nxtdir		;get next entry
	bmi	exitsr		;exit if not found
	ldx	chrcnt		;get count
mremch	ldy	cmppnt		;get pointer
	inc	cmppnt		;and bump
	lda	(addinp),y	;get fcb entry
	cpy	#12		;see if at extent
	bne	notaex		;jump if not
	sta	savext		;save for later use
	pha			;save extent
	tya			;change to directory
	ora	subrec		;coordinates
	tay
	pla			;get extent back
	eor	(bufadd),y	;exclusive or with dir
	and	cexm1f		;and with exm complement + 1f
	beq	trynxt		;ok if zero
	bne	newtry		;else get next directory
notaex	cmp	#'?'		;if a ? then
	beq	trynxt		;is a match
	pha			;save char
	tya			;then add
	ora	subrec		;offset to
	tay			;make pointer
	pla			;get char back
	cmp	(bufadd),y	;if not same
	bne	newtry		;try next directory
trynxt	dex			;else count number down
	bne	mremch		;and loop if more
	lda	dirmod		;return with directory
exitsr	rts			;number mod 4
;calculate logical record number
; input:blknum
; returns:none
; alters:a,x,p,recnum
calrcn	ldx	sxb		;set x according to blkscd
mulmre	asl	blknum		;multiply block
	rol	blknum+1	;number
	rol	blknum+2
	dex			;by code
	bne	mulmre	
	lda	sab		;set mask in a
	and	nxtrec		;and with next record
	ora	recnum		;or with number
	sta	recnum		;and save
	rts
;update directory
updtdr	lda	#32		;change all
	ldx	#0		;from start
;change directory entry
; input:a=number char to change,x=starting position,fcb@(addinp)
; returns:none
; alters:all,directory,checksums
dirchg	sta	chrcnt		;save count
	dec	chrcnt		;back up
mrechg	clc			;clear carry
	txa			;get offset
	adc	chrcnt		;compute index
	tay			;and set
	cpy	#12		;see if at extent
	beq	docare		;if so do special
	cpy	#15		;see if at number rec
	bne	dntcar		;if not skip
docare	bit	skpdir		;check flag
	bpl	nochng		;skip if ok
dntcar	lda	(addinp),y	;get char
	pha			;save it
	lda	chrcnt		;get count
	ora	subrec		;add offset
	tay			;make an index
	pla			;get char back
	sta	(bufadd),y	;and put in buffer
nochng	dec	chrcnt		;count down
	bpl	mrechg		;and loop
	jsr	drrcsu		;set it up
	jmp	updtck		;and do change
;execute create file
xmake	jsr	autodr		;auto drive select
;create file
; input:fcb@(addinp)
; returns:n=1 if not valid,a=dirmod (255 if not valid)
; alters:dirnum,dirmod,fcb@(addinp)
mkefle	jsr	tstron		;test for r/o
	lda	addinp		;save fcb
	pha			;address
	lda	addinp+1	;on
	pha			;stack
	lda	empdvc		;then point
	ldy	empdvc+1	;to empty
	sta	addinp		;dummy
	sty	addinp+1	;fcb
	lda	#1		;match only
	jsr	frstsr		;first char
	pla			;restore
	sta	addinp+1	;fcb
	pla			;address
	sta	addinp		;from stack
	lda	dirmod		;get number mod 4
	bmi	extmke		;quit if not found
	ldy	#13		;else set up
	lda	#0		;to clear
mkeagn	sta	(addinp),y	;rest of
	iny			;fcb
	cpy	#33		;including next
	bne	mkeagn		;record
;the next two lines ensure that the extent and
;number of records fields are updated
	sec
	ror	skpdir
	jsr	updtdr		;update directory
	lda	dirmod		;get number
extmke	rts			;and quit
;extend file
; input:fcb@(addinp), x=1 read
;		        0 write
extend	stx	exrwfl		;save parameter
	jsr	clsfle		;close current extent
	bmi	extext		;exit if not found
	ldy	#12		;else
	lda	(addinp),y	;get extent
	clc			;and
	adc	#1		;add one
	and	#%00011111	;see if overflow
	beq	exteof		;eof if so
	sta	(addinp),y	;and save
	jsr	fndf13		;see if next extent exists
	bpl	opnext		;if so open
	lda	exrwfl		;if not and is write then create
	bne	extext		;else return as eof
dwrtex	jsr	mkefle		;create file
	jmp	tstext		;and test
opnext	jsr	opnfle		;open
tstext	bpl	extnok		;continue if ok
exteof	lda	#1		;else set eof
	rts			;and return
extnok	jsr	inrcct		;initialize counters
	lda	#0		;good
extext	rts			;return
;set up next directory block
; input:dirnum,x=1 for update checksum
; returns:a=dirmod (255 if invalid),n=1 if invalid
; alters:alll,dirnum,dirmod
nxtdir
	inc	dirnum		;bump directory
	bne	*+5
	inc	dirnum+1
	lda	maxdir		;if not at limit continue
	cmp	dirnum
	lda	maxdir+1
	sbc	dirnum+1
	bcs	gtnxdr		;then continue
	jmp	cldrnm		;set to invalid
gtnxdr	lda	dirnum		;get low again
	and	#%00000011	;look at 2 lsbs
	sta	dirmod		;save mod 4
	asl	a		;multiply
	asl	a		;by
	asl	a		;32 to
	asl	a		;get pointer
	asl	a		;offset
	sta	subrec		;and save
	bne	gotdir
getdir	phx
	jsr	drrcsu		;set up to read
	jsr	rdesec		;do read
	plx			;get operation code
	jsr	chksop		;do it
gotdir	lda	dirmod		;and return
exnxdr	rts			;with number
;checksum operation
;this routine assumes calling routine has checked for
;valid dirnum and hence valid dirrec
; input:chkflg,dirrec,x (1=update else check)
; returns:none
; alters:map@(chkmap)
chksop	bit	chkflg		;check flag
	bmi	exnxdr		;done if set
	dex			;dec code
	bne	tstchk		;if not zero test
	jsr	clcchk		;else calculate
	jsr	clcckp		;calculate pointer
	sta	(chkpnt),y	;and save
	rts			;then return
tstchk	jsr	clcchk		;do calculation
	jsr	clcckp		;calculate pointer
	cmp	(chkpnt),y	;compare to old
	beq	exnxdr		;if equal ok
	jmp	setron		;else set to r/o
;get block number
; input:nxtrec,blmode,fcb@(addinp),sxb,exm
; returns:none
; alters:all,blknum
getblk	ldx	sxb		;set x according to blkscd
	lda	nxtrec		;get next record
gblp	lsr	a		;divide by 2 x times
	dex
	bne	gblp
	sta	blknum		;save previous as temp
;use extent as offset but first use sxb to create param
	sec
	lda	#8
	sbc	sxb
	tax
;now get extent from fcb
	ldy	#12
	lda	(addinp),y
	and	exm		;and with mask
	lsr	a		;shift with lsb to c
gbxlp	rol	a		;now go other way
	dex
	bne	gbxlp
	clc			;now add saved value
	adc	blknum		;back
	bit	blmode		;test mode
	bpl	*+3		;skip if byte
	asl	a		;else times two
	clc			;then add
	adc	#16		;offset into fcb
	sta	fcbind		;save for later
	tay			;set index
	lda	(addinp),y	;get number
	sta	blknum		;store
	iny
	lda	#0		;clear
	bit	blmode		;test mode
	bpl	*+4		;skip if byte
	lda	(addinp),y	;else get high
	sta	blknum+1	;high byte
	rts			;and return
;calculate chkpnt as function of dirrec and chkmap
; input:dirrec,chkmap
; returns:y=0
; alters:y,p,chkpnt
clcckp	pha			;save a
	clc
	lda	dirrec		;add record number
	adc	chkmap		;to start
	sta	chkpnt
	lda	dirrec+1
	adc	chkmap+1
	sta	chkpnt+1
	ldy	#0
	pla			;get a back
	rts
;clear directory number to $ffff
; input:none
; returns:a=$ff,n=1,z=0
; alters:a,p,dirnum,dirmod
cldrnm	lda	#$ff		;set to $ff
	sta	dirnum
	sta	dirnum+1
	sta	dirmod
	rts
;change allocation map
; input:subrec,directory record @ (bufadd)
; returns:none
; alters:all,allocation map
mapdir	clc			;add 16 to
	lda	subrec		;to subrec to point
	adc	#16		;to block number field
	tay			;make index
lpmpdr	sty	mpdrsy		;save index
	txa			;save x
	pha			;operation
	lda	(bufadd),y	;get block number
	sta	mpdrtm		;save in temp
	iny			;bump index for word
	jsr	gthibn		;get high part of number
mpdrnw	ora	mpdrtm		;see if zero
	beq	skpedr		;skip if zero
	jsr	gthibn		;get high again
	tay			;move to y
	lda	mpdrtm		;get low again
	jsr	altalc		;else alter map
skpedr	pla			;get operation
	tax			;back
	ldy	mpdrsy		;get index back
	iny			;bump it
	tya			;if still
	and	#%00001111	;in field
	bne	lpmpdr		;then loop
	rts			;else quit
;test r/w status
;does warm boot if r/o
; input:curdrv,ronlst
; returns:none
; alters:a,x,p
tstron	jsr	chkron		;test bit
	beq	exttro		;exit if r/w
	jsr	errout		;else send error
	lda	rommvc		;point to r/o
	ldy	rommvc+1	;message
	jsr	sndstr		;send it
	jmp	xwboot		;then abort
;set current drive to r/w
; input:curdrv,ronlst
; returns:ronlst
; alters:a,x,p,ronlst
setrw	ldx	curdrv		;get drive
	lda	bitmap,x	;and mask
	eor	#$ff		;complement
	and	ronlst		;and with status
	sta	ronlst		;save
exttro	rts			;return
;read sector
rdesec	jsr	sim+39		;do read
	bra	chkrwe		;check for error
;update checksum and directory
updtck	ldx	#1		;set for update
	jsr	chksop		;do it
	lda	#1		;say is directory op
	bne	secwrt		;do it
;write sector
wrtsec	lda	wrtype		;get write type
secwrt	jsr	sim+42		;do write
chkrwe	cmp	#0		;if not ok
	beq	exttro		;done if zero
;read/write error
rwerrt	jsr	errout		;send error message
	lda	bdsmvc		;point to
	ldy	bdsmvc+1	;bad sector message
	jsr	sndstr		;and send
	jsr	getcon		;get input
	cmp	#cr		;if a cr
	beq	ignerr		;then continue
	jmp	xwboot		;else abort
ignerr	jmp	pcrlf		;crlf and return
;error output routine
; input:curdrv,pemmvc
; returns:none
; alters:all
errout	lda	pemmvc		;point to
	ldy	pemmvc+1	;error message
	jsr	sndstr		;send it
	lda	curdrv		;get drive number
	clc			;add
	adc	#'A'		;ascii a
	jmp	sndchr		;and send it
;get high part of block number if word (zero if byte)
; input:y=index to high,blmode,directory@(bufadd)+subrec
; returns:a=high part of block number
; alters:a,p,mpdrsy iff word
gthibn	lda	#0		;preset for byte
	bit	blmode		;test mode
	bpl	gthiex		;done if byte
	lda	(bufadd),y	;get high
	sty	mpdrsy		;alter y
gthiex	rts
;get console input
; input:pndkey
; returns:a=character
; alters:all,pndkey
getcon	lda	pndkey		;get pending
	pha			;save it
	lda	#0		;clear
	sta	pndkey		;pending
	pla			;restore
	bne	extget		;exit if not null
	jsr	sim+9		;else get new
extget	rts			;and return
;check keyboard status
;handles <ctl-s> for freeze and <ctl-c> for boot
; input:pndkey
; returns:a=0 if no input or <>0 if input
; alters:all,pndkey
kbdsts	lda	pndkey		;get pending
	bne	extkbd		;if there quit
	jsr	sim+6		;else test
	and	#$ff		;if zero
	beq	extkbd		;exit
	jsr	sim+9		;else get input
	cmp	#ctls		;if not freeze
	bne	newpnd		;save input
	jsr	sim+9		;else wait for more
	cmp	#ctlc		;if not abort
	bne	nowarm		;then jump
	jmp	xwboot		;else do warm boot
nowarm	lda	#0		;clear
	rts			;and return
newpnd	sta	pndkey		;save
	lda	#$ff		;set ready
extkbd	rts			;and return
;test character
; input:a=character
; returns:c=0 if control or c=1 if printing
; alters:p
tstchr	cmp	#cr		;if cr
	beq	chtext		;quit
	cmp	#lf		;if linefeed
	beq	chtext		;quit
	cmp	#ctli		;if tab
	beq	chtext		;quit
	cmp	#' '		;see if control
chtext	rts			;and return
;send string ending in $
; input:ay=string address
; returns:none
; alters:all,index,sndlpe+1 and +2
sndstr	sta	sndlpe+1	;set pointer
	sty	sndlpe+2
	ldy	#0
sndlpe	lda	$ffff,y		;get char
	cmp	#'$'		;if terminator
	beq	sndext		;then exit
	iny			;else bump
	sty	index		;and save
	jsr	sndchr		;send char
	ldy	index		;get index
	bne	sndlpe		;and loop
sndext	rts			;return
;send char to printer if enabled
; input:a=character,lstflg
; returns:a=character
; alters:x,y,p
lstout	bit	lstflg		;test flag
	bpl	extlst		;exit if off
	bit	outflg		;test output flag
	bmi	extlst		;done if set
	pha			;save char
	jsr	sim+15		;send
	pla			;get char
extlst	rts			;and done
;output a character
; input:a=character,console definition block in sim
; returns:none
; alters:all,positn
output	jsr	tstchr		;test it
	bcs	sndchr		;if not control jump
	pha			;else save
	lda	sysdef+4	;get invert
	jsr	nolist		;send to console
	lda	#'^'		;get arrow
	jsr	lstout		;send to printer
	pla			;get character
	ora	#'A'-1		;convert to ascii
	jsr	pchrot		;send to all
	lda	sysdef+3	;get normal
	jmp	nolist		;to console
sndchr	cmp	#ctli		;if not tab
	bne	pchrot		;send
tabspc	lda	#' '		;else get space
	jsr	pchrot		;send
	lda	positn		;get count
	and	#7		;if not mod 8
	bne	tabspc		;loop
	rts			;else exit
pchrot	pha			;save char
	jsr	kbdsts		;test input
	pla			;restore
	jsr	lstout		;to printer if on
nolist	pha			;save again
	bit	outflg		;test flag
	bmi	*+5		;done if set
	jsr	sim+12		;to console
	pla			;restore
	inc	positn		;bump col
	cmp	#' '		;if space or more
	bcs	extchr		;is ok
	cmp	sysdef+2	;also ok
	beq	extchr		;if forward
	dec	positn		;else drop back
	cmp	sysdef+0	;see if bs
	bne	tryotr		;branch if not
	dec	positn		;else drop again
	bmi	zrocol		;zero if <0
	rts			;else ok
tryotr	cmp	#cr		;if a cr
	beq	zrocol		;clear col
	cmp	sysdef+7	;if a formfeed
	beq	zrocol		;also clear
	cmp	sysdef+8	;if not home
	bne	extchr		;then done
zrocol	lda	#0		;clear
	sta	positn		;column
extchr	rts			;and exit
;go to left and space past prompt
; input:frscol,positn
; returns:none
; alters:positn
spcovr	lda	#cr		;get cr
	jsr	pchrot		;send to all
	lda	#lf		;send lf
	jsr	lstout		;only to printer
mreovr	lda	frscol		;get first
	cmp	positn		;see if there
	beq	extchr		;done if is
	lda	sysdef+2	;get forward
	jsr	nolist		;send it
	jmp	mreovr		;and loop
;buffered read
; input:buffer@(addinp)
; returns:none
; alters:all,buffer@(addinp)
bufinp	lda	#0		;clear
	ldy	#1		;length
	sta	(addinp),y	;position in buffer
	sty	bufpsn		;set point to 1
	lda	positn		;get current
	sta	frscol		;and save
nxtinp	jsr	getcon		;get input
	ldy	bufpsn		;get index
	cmp	#cr		;if not a cr
	bne	notcr		;then jump
	jmp	endlin		;else done
notcr	cmp	#delete		;if not delete
	bne	ntdelt		;then jump
	cpy	#1		;else if start
	beq	nxtinp		;then loop
	lda	(addinp),y	;get last
	pha			;save char
	ldy	#1		;point to count
	sec			;set carry
	lda	(addinp),y	;get count
	sbc	#1		;decrement
	sta	(addinp),y	;then save
	pla			;restore char
	dec	bufpsn		;backup pointer
	cmp	#' '		;if space or more
	bcs	nrmbs		;just backspace
	cmp	#ctli		;see if tab
	bne	ctlbs		;if not is control
	sec			;set flag
	ror	outflg
	lda	positn		;get position and save
	sta	lstcol
	jsr	spcovr		;else go back
	jsr	rptlne		;and retype
	lda	positn		;get new last position
	pha			;save on stack
	sec			;subtract to get delta
	lda	lstcol
	sbc	positn
	sta	lstcol		;and save
	asl	outflg		;clear flag
bstab	jsr	dobs		;do one
	dec	lstcol		;drop count
	bne	bstab		;loop if more
	pla			;get position
	sta	positn		;and set
	jmp	nxtinp		;then loop
ctlbs	lda	sysdef+3	;get normal
	jsr	chkbs		;bs if printing
	lda	sysdef+4	;same for invert
	jsr	chkbs		;then delete char itself
nrmbs	jsr	dobs		;do a backspace
	jmp	nxtinp		;and loop
ntdelt	cmp	#ctlp		;if not ctl-p
	bne	ntctlp		;then jump
	lda	lstflg		;else get printer flag
	eor	#$ff		;complement
	sta	lstflg		;save
	jmp	nxtinp		;and loop
ntctlp	cmp	#ctlx		;if not ctl-x
	bne	ntctlx		;then jump
	jsr	spcovr		;restart
	lda	sysdef+1	;get clear to eol
	jsr	nolist		;send it
	jmp	bufinp		;and start over
ntctlx	cmp	#ctlr		;if not ctl-r
	bne	ntctlr		;then jump
	jsr	spcovr		;restart
	jsr	rptlne		;retype line
	jmp	nxtinp		;and start over
ntctlr	iny			;next position
	sta	(addinp),y	;store char
	pha			;and save
	sty	bufpsn		;index
	ldy	#1		;point to count
	tya			;set a to 1
	clc			;then
	adc	(addinp),y	;add count
	sta	(addinp),y	;and save
	pla			;restore char
dontsv	jsr	output		;send char
	ldy	bufpsn		;get index
	lda	(addinp),y	;get char
	cmp	#ctlc		;if not ctl-c
	bne	ignrcc		;ignore
	ldy	#1		;get count
	lda	(addinp),y	;from buffer
	cmp	#1		;if not at start
	bne	ignrcc		;ignore
	jmp	xwboot		;else do warm boot
ignrcc	ldy	#1		;get
	lda	(addinp),y	;count
	dey			;point to max
	cmp	(addinp),y	;if length
	bcs	lineen		;at max jump
	jmp	nxtinp		;else loop
lineen	lda	#cr		;get a cr
endlin	jmp	pchrot		;and send
;cr and lf
pcrlf	lda	#cr		;then a
	jsr	pchrot		;cr
	lda	#lf		;and a
	jmp	pchrot		;lf
;retype line
rptlne	lda	bufpsn		;save point
	sta	numcnt		;as count
	lda	#1		;start position
	pha			;save
mrerpt	pla			;get position
	dec	numcnt		;count down
	bne	*+3		;continue if more
	rts			;else done
	tay			;else make index
	iny			;and bump
	tya			;save
	pha			;on stack
	lda	(addinp),y	;get char
	jsr	output		;send
	jmp	mrerpt		;and loop
;check for printing and backspace if needed
chkbs	cmp	#' '		;compare to space
	bcc	extdec		;not printing so done
;do a backspace
dobs	lda	sysdef+0	;get backspace
	pha			;save it
	jsr	nolist		;send
	lda	#' '		;get space
	jsr	nolist		;send
	pla			;get backspace
	jmp	nolist		;send it
;test for decimal digit
;if decimal then c=0 else c=1
tstdec	cmp	#'0'		;if under 0
	bcc	notdec		;then not decimal
	cmp	#'9'+1		;if 9 or under is ok
	bcc	extdec
notdec	sec			;else not a match
extdec	rts
;test for hexadecimal digit
;if hex then c=0 else c=1
tsthex	jsr	tstdec		;first try decimal
	bcc	extdec		;ok if dec
	cmp	#'A'		;if under A
	bcc	notdec		;then not hex
	cmp	#'F'+1		;set c in F compare
	rts
;bump load address by 128 and return in ay
adjdb	lda	dskbuf		;get old
	ldy	dskbuf+1	;address
	clc			;and bump
	adc	#128		;by 128
	sta	dskbuf		;save low
	bcc	*+6		;then bump
	iny			;and save
	sty	dskbuf+1	;high as needed
	rts
;move record from disk buffer to default buffer
mv128	lda	dskbuf		;get address
	ldy	dskbuf+1
	sta	mvfrom+1	;and set pointer
	sty	mvfrom+2
	ldx	#0		;clear index
mvfrom	lda	$ffff,x		;get byte
	sta	dflbuf,x	;move it
	inx
	bpl	mvfrom		;loop until done
	rts
;relocatable vectors
	.byte	$4c
extevc	.word	extexq-1
	.byte	$4c
sltmvc	.word	sltmsg
	.byte	$4c
empdvc	.word	empty
	.byte	$4c
rommvc	.word	romsg
	.byte	$4c
bdsmvc	.word	bdsmsg
	.byte	$4c
pemmvc	.word	pemmsg
	.byte	$4c
dcbevc	.word	dcb
;relocation stopper
	.byte	$ff
;messages
romsg	.byte	" - R/O$"
bdsmsg	.byte	" - BAD SECTOR"
	.byte	cr,lf,"<RET> TO IGNORE -- <OTHER> "
	.byte	"TO ABORT$"
pemmsg	.byte	cr,lf,"PEM ERROR ON $"
sltmsg	.byte	" - INVALID DRIVE$"
;dummy fcb
empty	.byte	$e5
;zero page switch enable table
swctbl	.byte	0,0,0,0,0,0,0,0
	.byte	0,0,1,0,0,1,1,1
	.byte	1,1,1,1,1,1,1,1
	.byte	0,0,1,0,0,0,0,0
	.byte	0,0,0,0
;bit mask table
bitmsk	.byte	128,64,32,16,8,4,2,1
;bit map table
bitmap	.byte	1,2,4,8,16,32,64,128
;extent mask table (also uses 3 bytes in sabtbl
exmtbl	.byte	0,1,3
;sab table
sabtbl	.byte	7,15,31,63,127
;variable storage
skpdir	.byte	0		;positive if no change
fcbind	.byte	0		;index to block number
savext	.byte	0		;save extent
frscol	.byte	0		;first col
pndkey	.byte	0		;pending input
lstflg	.byte	0		;printer flag
positn	.byte	0		;print position
swcflg	.byte	0		;zero page switch flag
bytinp	.word	0		;input value
cmdinp	.byte	0		;input command
addout	.word	0		;output address
bytout	equ	addout		;output value
bufpsn	.byte	0		;input buffer position
exrwfl	.byte	0		;extend flag
tmpdrv	.byte	0		;temporary drive number
end_strg:

;align xqtvec on word boundary
	org	($&$FFFE)+2
xqtvec	.word	0		;command vector
countr	.word	0		;record counter
	.byte	0		;overflow
lkdown	.word	0		;down pnt. for block search
lookup	.word	0		;up pnt. for block search
olddrv	.byte	0		;old drive number
curdrv	.byte	0		;current drive
lginvc	.byte	0		;log in status
ronlst	.byte	0		;read write status
dirnum	.word	0		;directory number
subrec	.byte	0		;directory offset
recnum	.word	0		;record number
blknum	equ	recnum		;block number
	.byte	0		;overflow
chrcnt	.byte	0		;character count
cmppnt	.byte	0		;comparison pointer
nxtrec	.byte	0		;next record
numrec	.byte	0		;number records
dirrec	.word	0		;directory record
dirmod	.byte	0		;directory mod 4
index	.byte	0		;buffer index
numcnt	.byte	0		;counter
outflg	.byte	0		;output enable flag
lstcol	.byte	0		;last column
mpdrsy	.byte	0		;save for y in mapdir
mpdrtm	.byte	0		;temp in mapdir
blmode	.byte	0		;<128 if byte else word
maxdrc	.word	0		;max directory record
sab	.byte	0		;mask for block
sxb	.byte	0		;shift for block
rtclk	.byte	0,0,0		;real time clock
gpcnt	.word	0		;gp counter
trkctr	.byte	0		;track counter
;following region is used to capture dcb
dcb
maxblk	.word	0		;maximum block number
sectrk	.word	0		;sectors per track
nsystr	.word	0		;number system tracks
blkscd	.byte	0		;block size code
maxdir	.word	0		;maximum directory number
alcmap	.word	0		;address of allocation map
chkflg	.byte	0		;check flag
chkmap	.word	0		;address of checksum map
wrtype	.byte	0		;write type 0=norm,1=dir,2=unalloc
exm	.byte	0		;extent mask
cexm1f	.byte	0		;exm complemented and 1f
;zero page save block
varblk
lowin	.word	0
	.word	0		;save bufadd
	.word	0		;save alcpnt
	.word	0		;save chkpnt

pem_end	equ	$
;------------------------------------------------------------------
;dos/65 sim
;osi - c1p/sbii version
;version 3.00
;released:	18 August 2015 (3.00)
;last revision:

;pem constants on entry to write
wrall	equ	0		;write to allocated
wrdir	equ	1		;write to directory
wrual	equ	2		;write to unallocated

;main program
;	org	SIM_SECTION
	org	(pem_end&$ff00)+$100

;jump vector used by pem
sim	jmp	boot		; 0( 0) from cold start
wboote	jmp	wboot		; 1( 3) from warm boot
	jmp	const		; 2( 6) check for input
	jmp	conin		; 3( 9) get input
	jmp	conout		; 4(12) send to terminal
	rts			; 5(15) printer output
	nop
	nop
	rts			; 6(18) punch output
	nop
	nop
	rts			; 7(21) reader input
	nop
	nop
	jmp	home		; 8(24) home drive
	jmp	seldsk		; 9(27) select disk
	jmp	seltrk		;10(30) set track
	jmp	selsec		;11(33) set sector
	jmp	setdma		;12(36) set buffer address
	jmp	read		;13(39) read sector
	jmp	write		;14(42) write sector
	lda	#1		;15(45) printer always ready
	rts
	ldx	#128		;16(48) clock entry - disable for now
	rts
	jmp	xlate		;17(51)translate

;console definition block
	db	0               ;scratch
sysdef	db	8               ; 0:backspace
	db	1               ; 1:clear to end of line
	db	$0C             ; 2:forward space
	db	0               ; 3:normal video
	db	'^'             ; 4:invert video
	db	24              ; 5:lines per screen
	db	80              ; 6:char per line
	db	$0C             ; 7:form feed
	db	$1E             ; 8:home
	db	2               ; 9:clear to end of screen

B_CONIN		EQU	$01
B_CONOUT	EQU	$02
B_CONST		EQU	$03
B_STOUT		EQU	$04
B_RDSD		EQU	$05
B_WRSD		EQU	$06
B_END_P		equ	$ff

const:
	brk	B_CONST
	and	#$01
conrdx2
	rts
	
conin:
	brk	B_CONIN
	and	#$7f
	cmp	#bs
	bne	conrdx
	lda	#delete
	rts
conrdx
	cmp	#wpum
	beq	conrdx1		; wakeup universal monitor
	cmp	#ctlt
	bne	conrdx2
	; terminate DOS65
	lda	#<term_msg	;point to message
	ldy	#>term_msg
	jsr	outmsg		;send it
	lda	#1
	bra	PRG_END

conrdx1		; wakeup universal monitor
	lda	#<wapu_msg	;point to message
	ldy	#>wapu_msg
	jsr	outmsg		;send it
	lda	#2
	brk	B_END_P
	lda	#cr
	rts

conout
	pha
	brk	B_CONOUT
	pla
	rts

outmsg
	brk	B_STOUT
	rts

rd_sec
	lda	#<DPT
	ldy	#>DPT
	brk	B_RDSD
	rts

wrt_sec
	lda	#<DPT
	ldy	#>DPT
	brk	B_WRSD
	rts

PRG_END
	brk	B_END_P
	stp

;opening id message
opnmsg	.byte	cr,lf,"50K DOS/65 V3.02 MEZW65C_RAM SIM V1.0"
	db	cr,lf,"  (CTL+T : Terminate DOS/65)"
	db	cr,lf,"  (CTL+\ : Invoke Universal Monitor)",0

;terminate message
term_msg	db	cr,lf,"DOS/65 terminated",cr,lf,0
wapu_msg	db	cr,lf,"Wakeup Universal Monitor",cr,lf,0
;cold entry from loader
boot
	lda	#<opnmsg	;point to message
	ldy	#>opnmsg
	jsr	outmsg		;send it

;initialize iostat
	lda	#0
	sta	iostat
	sta	curdrv
	jsr	seldsk

;set up jumps into dos/65 in page one
setup
	ldx	#0		;clear index
setupl	lda	inttbl,x	;get byte
	sta	$100,x		;insert at start
	inx
	cpx	#6
	bne	setupl		;loop until done
; save default baffer pointer & set dma
	lda	#<dflbuf	;get low buffer
	ldy	#>dflbuf	;and high
	jsr	setdma		;and set
;first clear key de-blocking variables
	stz	hstact		;host buffer inactive
	stz	unacnt		;clear unalloc count

;	lda	iostat
	lda	curdrv
	jmp	ccm		;and go to CCM

;initialization table
inttbl	db	$4c
	dw	wboote
	db	$4c
	dw	pem

;warm boot-read DOS/65 back except SIM and then
;jump to CCM. IOSTAT and hence the default drive
;and user are not altered by warm boot.
wboot	ldx	#$ff		;set stack
	txs			;pointer
	cld			;set binary mode
;	lda	iostat		;set default drive
	lda	curdrv
	jsr	seldsk
	jmp	setup		;go set up

;select disk
seldsk	and	#7		;three LSB's only
;	sta	disk_drive	;Save active Drive number
	sta	sekdsk		;save for later
	asl	a		;multiply by two
	tax			;make an index
	lda	dcbtbl,x	;get address
	ldy	dcbtbl+1,x
	rts
;table of dcb addresses - this version retains old assignment
;letters but re-ordered. will fix that in later version.
dcbtbl:
	dw	dcba
	dw	dcbb
	dw	0
	dw	0
	dw	0
	dw	0
	dw	0
	dw	0
;see if de-blocking required for sekdsk
;returns number of dos/65 records per physical
;sector in a and
;returns z=1 if no de-blocking required else z=0
tstdbl	ldx	sekdsk		;get desired disk
;see if de-blocking required for disk x
tstdbx	lda	spttbl,x	;get dos/65 records/host sector
	cmp	#1		;test for no deblock
	rts
;table containing number of dos/65 sectors
;per host physical sector.  if entry is 1
;then de-blocking is skipped.
spttbl	db	4,4,4,4,4,4,4,4
;table of records/block
rbltbl	db	16,16,16,16,16,16,16,16
;home the selected disk
home	lda	hstwrt		;check for pending write
	bne	homed		;there is so skip
	sta	hstact		;clear host active flag
;	sta	disk_drive
homed	rts			;do nothing
;translate record in ay for nxtdrv - translation is only done for 8 in, sssd
;drives - no longer in system. 
xlate	rts			;do nothing
;	tax			;move low to x
;	lda	sekdsk		;get next drive
;	cmp	#2		;see if drive c
;	beq	doxlate		;if so translate
;	cmp	#3		;see if drive d
;	bne	setshd		;if not no translate
;doxlate	lda	xlt8,x		;else get 8 inch value
;	rts
;setshd	txa			;restore low
;	rts
;sector translation tables
;8 inch
;xlt8	.byte	1,7,13,19,25,5,11,17,23,3,9,15,21
;	.byte	2,8,14,20,26,6,12,18,24,4,10,16,22
;the read entry point takes the place of
;the previous sim definition for read.
;read the selected dos/65 record.
read	stz	unacnt		;clear unallocated count
	ldx	#1		;x <-- 1
	stx	readop		;say is read operation
	stx	rsflag		;must read data
	inx			;x <-- wrual
	stx	w_type		;treat as unalloc
	jmp	rwoper		;to perform the read
;The write entry point takes the place of
;the previous sim definition for write.
;write the selected dos/65 record.
write	sta	w_type		;save param from pem
	jsr	tstdbl		;see if one rec/sec
	bne	usewrt		;if not use type passed
	lda	#wrdir		;if is say directory
	sta	w_type		;to force write
usewrt	stz	readop		;say is not a read operation
	lda	w_type		;get write type back
	cmp	#wrual		;write unallocated?
	bne	chkuna		;check for unalloc
;write to unallocated, set parameters
	ldx	sekdsk		;get next disk number
	lda	rbltbl,x	;get records/block
	sta	unacnt
	stx	unadsk		;unadsk <-- sekdsk
	lda	sektrk
	ldy	sektrk+1
	sta	unatrk		;unatrk <-- sectrk
	sty	unatrk+1
	lda	seksec
	ldy	seksec+1
	sta	unasec		;unasec <-- seksec
	sty	unasec+1
;check for write to unallocated record
chkuna	lda	unacnt		;any unalloc remain?
	beq	alloc		;skip if not
;more unallocated records remain
	dec	unacnt		;unacnt <-- unacnt-1
	lda	sekdsk
	cmp	unadsk		;sekdsk = unadsk?
	bne	alloc		;skip if not
;disks are the same
	lda	unatrk		;sektrk = unatrk?
	cmp	sektrk
	bne	alloc		;no so skip
	lda	unatrk+1
	cmp	sektrk+1
	bne	alloc		;skip if not
;tracks are the same
	lda	unasec		;seksec = unasec?
	cmp	seksec
	bne	alloc		;no so skip
	lda	unasec+1
	cmp	seksec+1
	bne	alloc		;skip if not
;match, move to next sector for future ref
	inc	unasec		;unasec = unasec+1
	bne	nounsc
	inc	unasec+1
;calculate dos/65 records/track
nounsc	lda	sekdsk		;get disk number
	asl	a		;mult by two
	tax			;make an index
	lda	dcbtbl,x	;get dcb start
	ldy	dcbtbl+1,x
	sta	getspt+1	;set low operand
	sty	getspt+2	;then high operand
;point has address now get spt at byte 2,3
	ldy	#2		;start at byte 2
	ldx	#0		;start save in low
getspt	lda	$ffff,y		;get value
	sta	d65spt,x	;and save
	iny
	inx
	cpx	#2		;see if done
	bne	getspt		;loop if not
;check for end of track
	lda	unasec		;end of track?
	cmp	d65spt		;count dos/65 sectors
	lda	unasec+1
	sbc	d65spt+1
	bcc	noovf		;skip if no overflow
;overflow to next track
	stz	unasec
	stz	unasec+1
	inc	unatrk		;unatrk <-- unatrk+1
	bne	noovf
	inc	unatrk+1
;match found, mark as unnecessary read
noovf	stz	rsflag		;rsflag <-- 0
	bra	rwoper		;to perform the write
;not an unallocated record, requires pre-read
alloc	stz	unacnt		;unacnt <-- 0
;
;say preread required
	ldx	#1		;x <-- 1
	stx	rsflag		;rsflag <-- 1
;check for single record/sector - and if so
;then say preread not required.
	jsr	tstdbl		;test
	bne	rwoper		;more than one
	stz	rsflag		;say no preread
;common code for read and write follows
;enter here to perform the read/write
rwoper	stz	erflag		;no errors (yet)
	lda	seksec		;compute host sector
	ldy	seksec+1
	sta	sekhst
	sty	sekhst+1
	jsr	tstdbl		;get records/sector
	lsr	a		;divide by two
	tax			;make a counter
	beq	noshif		;done if zero
shflpe	lsr	sekhst+1	;do high
	ror	sekhst		;then low
	dex
	bne	shflpe		;loop if more
;active host sector?
noshif	lda	hstact		;host active flag
	pha			;save
	inx			;x <-- 1
	stx	hstact
	pla			;get flag back
	beq	filhst		;fill host if not active

;host buffer active, same as seek buffer?
	lda	sekdsk
	cmp	hstdsk		;same disk?
	bne	nmatch
;same disk, same track?
	lda	hsttrk		;sektrk = hsttrk?
	cmp	sektrk
	bne	nmatch		;no
	lda	hsttrk+1
	cmp	sektrk+1
	bne	nmatch
;same disk, same track, same sector?
	lda	sekhst		;sekhst = hstsec?
	cmp	hstsec
	bne	nmatch		;no
	lda	sekhst+1
	cmp	hstsec+1
	beq	match		;skip if match
;proper disk, but not correct sector
nmatch	lda	hstwrt		;host written?
	beq	filhst		;skip if was
	jsr	writeh		;else clear host buff
;may have to fill the host buffer
;so set host parameters
filhst	lda	sekdsk
	sta	hstdsk
	lda	sektrk
	ldy	sektrk+1
	sta	hsttrk
	sty	hsttrk+1
	lda	sekhst
	ldy	sekhst+1
	sta	hstsec
	sty	hstsec+1
	lda	rsflag		;need to read?
	beq	noread		;no
;read desired physical sector from host
	jsr	hcom		;set parameters
	jsr	rd_sec		;to rom
	sta	erflag		;save result
noread	stz	hstwrt		;no pending write
;copy data to or from buffer
match				;clear write move pointer
	stz	wmoved+1	;later we'll set read read
	stz	wmoved+2
	jsr	tstdbl		;get records/sector
	beq	endmve		;done if no deblocking
	dec	a
	and	seksec		;mask sector number
	tax			;make a counter
	beq	nooff		;done if zero
clcpnt	clc
	lda	wmoved+1
	adc	#128
	sta	wmoved+1
	lda	wmoved+2
	adc	#0
	sta	wmoved+2
	dex
	bne	clcpnt		;loop if more
;operand has relative host buffer address
nooff	clc			;add hstbuf
	lda	#<hstbuf
	adc	wmoved+1
	sta	wmoved+1
	lda	#>hstbuf
	adc	wmoved+2
	sta	wmoved+2

;at this point wmove operand contains the address of the
;sector of interest in the hstbuf buffer.
;so now set the operands for the possible read move
	lda	wmoved+1
	sta	rmove+1
	lda	wmoved+2
	sta	rmove+2
;now set address of record in associated operands
	lda	dmaadr
	sta	wmove+1
	sta	rmoved+1
	lda	dmaadr+1
	sta	wmove+2
	sta	rmoved+2

;at this point the pointers are all set for read or write
	ldy	#127		;length of move - 1
	ldx	readop		;which way?
	bne	rmove		;skip if read
;write operation so move from dmaadr to mvepnt
	inx			;x <-- 1
	stx	hstwrt		;hstwrt <-- 1
wmove	lda	$ffff,y
wmoved	sta	$ffff,y
	dey
	bpl	wmove		;loop if more
	bmi	endmve		;else done
;read operation so move from mvepnt to dmaadr
rmove	lda	$ffff,y
rmoved	sta	$ffff,y
	dey
	bpl	rmove		;loop if more
;data has been moved to/from host buffer
endmve	lda	w_type		;write type
	cmp	#wrdir		;to directory?
	bne	nodir		;done if not
;clear host buffer for directory write
	lda	erflag		;get error flag
	bne	nodir		;done if errors
	sta	hstwrt		;say buffer written
	jsr	writeh
nodir	lda	erflag
	rts	
;writeh performs the physical write to
;the host disk.
writeh	jsr	hcom		;set-up params

	jsr	wrt_sec		;to rom

	sta	erflag		;save result
	rts
;set parameters for host read/write
hcom	lda	hstdsk		;set disk number
	sta	disk_drive
	lda	hsttrk		;then track
	sta	disk_lba1
	stz	disk_lba2
	stz	disk_lba3
	lda	hstsec		;then sector
	sta	disk_lba0
	ldx	hstdsk		;get host disk
	jsr	tstdbx		;see if de-blocking
	beq	ndblh		;branch if none

	lda	#<hstbuf	;finally address
	ldy	#>hstbuf
ndblh1
	sta	data_adr
	sty	data_adr+1
	rts
ndblh	lda	dmaadr		;send normal address
	ldy	dmaadr+1	;for no de-blocking
	bra	ndblh1

;set sector number
selsec	sta	seksec		;save low and high
	sty	seksec+1
;	sta	disk_lba0	;go to rom also
	rts
;set buffer address
setdma	sta	dmaadr		;store low
	sty	dmaadr+1	;and high
	sta	data_adr
	sty	data_adr+1
	ldx	#1
	stx	data_cnt
	rts
;set track
seltrk	sta	sektrk		;save number
	sty	sektrk+1
;	sta	disk_lba1
;	stz	disk_lba2
;	stz	disk_lba3
	rts
;disk control blocks
;diskdef dos65cf - 8Mb
;  seclen 512
;  tracks 64
;  sectrk 256
;  blocksize 2048
;  maxdir 1024
;  skew 0
;  boottrk 0
;drive a (CF 8MB)
dcba	.word	4095		;max block number
	.word	1024		;records per track
	.word	0		;number system tracks
	.byte	1		;block size = 2048
	.word	1023		;max directory
	.word	almpa		;address of allocation map
	.byte	128		;do not do checksums
	.word	0		;phony address
;drive b (CF 8MB)
dcbb	.word	4095		;max block number
	.word	1024		;records per track
	.word	0		;number system tracks
	.byte	1		;block size = 2048
	.word	1023		;max directory
	.word	almpb		;address of allocation map
	.byte	128		;do not do checksums
	.word	0		;phony address

;data area
sekdsk	db	0		;seek disk number
hstwrt	db	0		;0=written,1=pending host write
;allocate the following data areas to unused ram space
savsec	ds	1		;save sector for warm boot
;count	ds	1		;counter in warm boot
temp	ds	1		;save hstdsk for warm boot
hstact	ds	1		;host active flag
unacnt	ds	1		;unalloc rec cnt

sektrk	ds	2		;seek track number
seksec	ds	2		;seek sector number

hstdsk	ds	1		;host disk number
hsttrk	ds	2		;host track number
hstsec	ds	2		;host sector number

sekhst	ds	2		;seek shr secshf
unadsk	ds	1		;last unalloc disk
unatrk	ds	2		;last unalloc track
unasec	ds	2		;last unalloc sector
erflag	ds	1		;error reporting
rsflag	ds	1		;read sector flag
readop	ds	1		;1 if read operation
w_type	ds	1		;write operation type
d65spt	ds	2		;dos/65 records/track
dmaadr	ds	2		;record address

mov_rvec
	ds	6		; save RESET, IRQ/BRK, NMI vector

; LBA3    |LBA2    |LBA1    |LBA0      look like:
; 00000000|00000000|0ttttttt|ssssssss
DPT:
disk_drive	db	0
disk_lba0	db	0	; sector
disk_lba1	db	0	; track
disk_lba2	db	0
disk_lba3	db	0
data_adr	dw	0
reserve		db	0
data_cnt	db	1	; init count 1

;drive a
almpa	ds	512
;drive b
almpb	ds	512

hstbuf	ds	512

sim_end	equ	$

	end
