rem WDC816CC ttbasic.c -A
WDC816AS -G -L ttbasic816.asm -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L24F0 -IC400 aaa.bin aaa.s
mot2bin aaa.s TTBASIC.B16
copy TTBASIC.B16 ..\..\DISKS\TTBASIC\.
del aaa.*
