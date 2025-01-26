WDC816AS -G -L game-c816.asm -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L1780 -ID100 aaa.bin aaa.s
mot2bin aaa.s GAME-C.B16
copy GAME-C.B16 ..\..\DISKS\GAME-C\.
del aaa.*
