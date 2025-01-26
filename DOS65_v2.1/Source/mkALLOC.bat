WDC02AS -G -L ALLOC208.asm -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L0260 -I0200 aaa.bin aaa.s
mot2bin aaa.s ALLOC208.COM
copy ALLOC208.COM ..\..\DISKS\DOS_DISK\ALLOC.COM
del aaa.*
