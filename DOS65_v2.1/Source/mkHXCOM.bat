WDC02AS -G -L HXCOM200.ASM -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L0410 -I0200 aaa.bin aaa.s
mot2bin aaa.s HXCOM200.COM
copy HXCOM200.COM ..\..\DISKS\DOS_DISK\HXCOM.COM
del aaa.*
