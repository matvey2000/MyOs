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
	
	mov cx, 0;lenght buffer
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
		
		mov bx, cx
		mov buffer[bx], al
		add cx, 1
		
		jmp input
	handler:
		mov al, 0x0
		mov bx, cx
		mov buffer[bx], al
		
		mov ax, buffer
		mov dx, createcomand
		
		call equals
		je create
		
		jmp MyError
		create:
			;create file
			mov bx, ok
			call print
			call createfile
			
			jmp console
		MyError:
			;error
			mov bx, errorcomand
			call print
			
			jmp console
createfile:
	;read
	mov ah, 0x2
	mov dl, 0x80;hdd
	xor dh, dh
	;cilinder, sector
	mov cl, 0x1
	mov ch, 0x1
	mov al, 0x1;count
	
	mov bx, 0x1000;input
	
	int 0x13
	
	;main
	
	;write
	mov ah, 0x3
	mov dl, 0x80;hdd
	xor dh, dh
	;cilinder, sector
	mov cl, 0x1
	mov ch, 0x1
	mov al, 0x1;count
	
	mov bx, 0x1000;input
	
	int 0x13
	
	ret
equals:
	;ax - s1
	;dx - s2
	lpsequal:
		mov bx, ax
		mov cl, byte [bx]
		mov bx, dx
		mov bl, byte [bx]
		
		cmp cl, bl
		jne return;false
		
		cmp cl, 0
		je return;  true
		
		add ax, 1
		add dx, 1
		jmp lpsequal
	return:
		ret
	;return flag (read je, jne)
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
temp: dw 0 
hello: db "hello, this is MyOs", 0
beginconsole: db 0xA, 0xD, ">>", 0
errorcomand: db 0xA, 0xD, "Error: invalid command", 0
ok: db 0xA, 0xD, "OK", 0
;comands
createcomand: db "create", 0

buffer: db 100 dup(0)