WDC02AS -GL COMPL205.ASM -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L2630 -I0200 aaa.bin aaa.s
mot2bin aaa.s COMPL205.COM
copy COMPL205.COM ..\..\DISKS\DOS_DISK\BASICCPL.COM
del aaa.*
