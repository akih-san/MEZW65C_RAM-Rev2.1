WDC02AS -G -L MKCOM204.asm -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L0400 -I0200 aaa.bin aaa.s
mot2bin aaa.s MKCOM204.COM
copy MKCOM204.COM ..\..\DISKS\DOS_DISK\MKCOM.COM
del aaa.*
