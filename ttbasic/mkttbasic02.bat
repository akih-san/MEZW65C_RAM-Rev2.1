rem cc65 .\ttbasic.c -o --cpu 65c02
ca65 .\ttb_stup.s -l ttb_stup.lst
ca65 .\ttbasic_refine.s -l ttbasic.lst -o ttbasic.o
ca65 .\crt0.s
ld65 .\ttb_stup.o .\ttbasic.o crt0.o none.lib -C .\mezw65c_ram.cfg -o TTBASIC.B02 -m ttbasic.map
copy TTBASIC.B02 ..\DISKS\TTBASIC\.
