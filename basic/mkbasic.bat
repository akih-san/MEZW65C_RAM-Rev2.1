WDC02AS -G -L basic.asm
WDCLN -HB -g -t basic.obj -o aaa.bin
bin2mot -L2900 -IBF00 aaa.bin aaa.s
mot2bin aaa.s BASIC65.B02
copy BASIC65.B02 ..\DISKS\.
del aaa.*
