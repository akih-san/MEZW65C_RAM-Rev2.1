WDC02AS -G -L EDIT205.ASM -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L1af0 -I0200 aaa.bin aaa.s
mot2bin aaa.s EDIT205.COM
copy EDIT205.COM ..\..\DISKS\DOS_DISK\EDIT.COM
del aaa.*
