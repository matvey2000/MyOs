use16
org 0x4C00
start:
	mov ch, 0x1
	mov bx, 16
	mov ax, mess
	int 0x22
	
	int 0x20
mess: db "myfile", 0