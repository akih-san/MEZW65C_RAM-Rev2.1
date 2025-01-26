       .export         _exit
       .export         __STARTUP__ : absolute = 1      ; Mark as startup
		.export		_startup
       .import         zerobss, _main
       .import         initlib, donelib
       .import         __STACKSTART__                  ; Linker generated
       .import         COLD_START
       
       .include "zeropage.inc"

       .segment "STARTUP"

_startup:
       lda #<__STACKSTART__
       ldx #>__STACKSTART__
       sta sp
       stx sp+1
       jsr zerobss
       jsr initlib
       jsr COLD_START
_exit: pha
       jsr donelib
       pla
       rts
