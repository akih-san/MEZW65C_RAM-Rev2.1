rem cc65 .\game02.c -O --cpu 65c02
ca65 .\gm_stup.s -l gm_stup.lst
ca65 .\game02_refine.s -l game02.lst -o game02.o
ca65 .\crt0.s
ld65 .\gm_stup.o .\game02.o crt0.o none.lib -C .\mezw65c_ram.cfg -o GAME-C.B02 -m game02.map
copy GAME-C.B02 ..\DISKS\GAME-C\.
