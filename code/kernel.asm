use16
org 0x7c00

start:
	;init
	mov ax, 0
	mov ds, ax
	mov ax, 0x9000
	mov ss, ax
	mov sp, 0xFFFF
	
	mov bx, hello;
	call print
	
	jmp console
console:
	mov bx, beginconsole;
	call print
	
	mov ax, 0;lenght buffer
	input:
		;input
		mov ah, 0x0
		int 0x16
		;al
		
		mov ah, 0xe
		xor bh, bh
		int 0x10
		
		cmp al, 13
		je handler
		mov bx, ax
		mov buffer[bx], al
		add ax, 1
		
		jmp input
	handler:
		
		;error
		mov bx, errorcomand
		call print
		
		jmp console
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

printnumber:
	push ax
	push bx
	push cx
	push dx
	
	;print ax
	mov cx, 0
	jmp symball
	symball:
		mov bx, 2;base system
		xor dx, dx
		div bx
		
		push dx
		add cx, 1
		
		cmp ax, 1
		jae symball
		
		mov ah, 02h
		
		jmp prnt
	prnt:
		sub cx, 1
		
		pop ax
		add ax, '0'
		mov ah, 0xe
		xor bh, bh
		int 0x10
		
		
		cmp cx, 0
		ja prnt
		
		pop dx
		pop cx
		pop bx
		pop ax
		ret

hello: db "hello, this is MyOs", 0
beginconsole: db 0xA, 0xD, ">>", 0
buffer: db 100 dup(0)
errorcomand: db 0xA, 0xD, "Error: invalid command", 0