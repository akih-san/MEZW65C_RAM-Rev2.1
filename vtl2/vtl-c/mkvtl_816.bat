rem WDC816CC vtl-c.c -A
WDC816AS -G -L vtl2_816.asm -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L0A00 -IDF00 aaa.bin aaa.s
mot2bin aaa.s VTL2.B16
copy VTL2.B16 ..\..\DISKS\VTL2\.
del aaa.*
