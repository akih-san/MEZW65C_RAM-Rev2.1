WDC02AS -G -L dos65v21.asm -o aaa.obj
WDCLN -HB -g -t aaa.obj -o aaa.bin
bin2mot -L1E60 -IC8E0 aaa.bin aaa.s
mot2bin aaa.s DOS65V21.SYS
copy DOS65V21.SYS ..\..\DISKS\DOS65.SYS
del aaa.*

