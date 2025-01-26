WDC02AS -G -L DUMP100.ASM -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L0140 -I0200 aaa.bin aaa.s
mot2bin aaa.s DUMP100.COM
copy DUMP100.COM ..\..\DISKS\DOS_DISK\DUMP.COM
del aaa.*
