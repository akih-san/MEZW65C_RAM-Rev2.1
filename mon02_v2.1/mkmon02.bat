WDC02AS -G -L mon02_v21.asm -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L1600 -IEA00 aaa.bin aaa.s
mot2bin aaa.s MON02.SYS
copy MON02.SYS ..\DISKS\.
del aaa.*

