WDC02AS -G -L PAGE100.ASM -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L0230 -I0200 aaa.bin aaa.s
mot2bin aaa.s PAGE100.COM
copy PAGE100.COM ..\..\DISKS\DOS_DISK\PAGE.COM
del aaa.*
