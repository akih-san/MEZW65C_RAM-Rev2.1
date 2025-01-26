WDC02AS -G -L MORE202.ASM -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L0170 -I0200 aaa.bin aaa.s
mot2bin aaa.s MORE202.COM
copy MORE202.COM ..\..\DISKS\DOS_DISK\MORE.COM
del aaa.*
