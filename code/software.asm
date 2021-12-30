use16
org 0x800

times 0x4800 db 0
header:
	db "file", 0
	times 0x64-$+header db 0
	dw 0x0000
	
headerend:
	db "end", 0
	times 0x64-$+headerend db 0
	dw 0x0001
start:
	