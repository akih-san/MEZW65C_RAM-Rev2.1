WDC02AS -G -L RUN207.ASM -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L2A90 -I0200 aaa.bin aaa.s
mot2bin aaa.s RUN207.COM
copy RUN207.COM ..\..\DISKS\DOS_DISK\RUN.COM
del aaa.*
