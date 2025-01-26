WDC02AS -G -L vtl2.asm
WDCLN -HB -g -t vtl2.obj -o aaa.bin
bin2mot -L0500 -ID800 aaa.bin aaa.s
mot2bin aaa.s VTL2.B02
copy VTL2.B02 ..\DISKS\VTL2\.
del aaa.*
