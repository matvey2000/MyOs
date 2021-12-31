use16
org 0x4C00
begin:
	times 0x4800 db 0
header:
	db "file", 0
	times 0x64-$+header db 0
	dw 0x0000
	
headerend:
	times 0x64-$+headerend db 0
	dw 0x0001
	
	times 0x12000-$+begin db 0
start:
	mov ch, 0x1
	mov bx, 16
	mov ax, 0x2A
	int 0x22
	
	int 0x20
mess: db "myfile", 0