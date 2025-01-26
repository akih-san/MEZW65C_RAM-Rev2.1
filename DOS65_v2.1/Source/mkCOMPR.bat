WDC02AS -G -L COMPR204.ASM -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L0350 -I0200 aaa.bin aaa.s
mot2bin aaa.s COMPR204.COM
copy COMPR204.COM ..\..\DISKS\DOS_DISK\COMPR.COM
del aaa.*
