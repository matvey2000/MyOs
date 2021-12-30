use16
org 0x800

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
	mov bx, mess
	call print
	jmp $
print:
	;bx = offset message
	push ax
	push bx
	push cx
	push dx
	lpsprint:
		push bx
		mov ah, 0xe
		mov al, byte [bx]
		
		cmp al, 0
		je endprint
		
		xor bh, bh
		int 0x10
		pop bx
		
		add bx, 1
		
		jmp lpsprint
	endprint:
		pop bx
		pop dx
		pop cx
		pop bx
		pop ax
		ret
mess: db "this is test",0