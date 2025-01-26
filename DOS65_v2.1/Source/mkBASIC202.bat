WDC02AS -GL BASIC202.ASM -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L2EE0 -I0200 aaa.bin aaa.s
mot2bin aaa.s BASIC202.COM
copy BASIC202.COM ..\..\DISKS\DOS_DISK\BASIC.COM
del aaa.*
