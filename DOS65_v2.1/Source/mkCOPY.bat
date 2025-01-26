WDC02AS -G -L COPY203.ASM -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L01F0 -I0200 aaa.bin aaa.s
mot2bin aaa.s COPY203.COM
copy COPY203.COM ..\..\DISKS\DOS_DISK\COPY.COM
del aaa.*
