use16
org 0x4C00
start:
	mov ch, 0x0
	mov bx, mess
	int 0x22
	
	int 0x20
mess: db "hello", 0