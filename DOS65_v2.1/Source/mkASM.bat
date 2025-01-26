WDC02AS -G -L -DUSING_02  ASM212.ASM -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L1990 -I0200 aaa.bin aaa.s
mot2bin aaa.s ASM212.COM
copy ASM212.COM ..\..\DISKS\DOS_DISK\ASM.COM
del aaa.*
