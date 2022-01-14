use16
org 0x7c00

start:
	mov ah, 0x2
	mov dl, 0x0;disk A
	xor dh, dh
	;cilinder, sector
	mov cl, 0x1
	mov ch, 0x0
	mov al, 0x1;count
	mov bx, 0x800;input
	int 0x13
	
	mov bx, mess2
	call print
	
	mov bx, 0x9FE
	mov cl, byte [bx]
	cmp cl, 0x55
	jne start_
	add bx, 1
	mov cl, byte [bx]
	cmp cl, 0xAA
	jne start_
	
	;download loader
	mov ah, 0x3
	mov dl, 0x80;hdd
	xor dh, dh
	;cilinder, sector
	mov cl, 0x1
	mov ch, 0x0
	mov al, 0x1;count
	mov bx, 0x7c00;input
	int 0x13
	
	mov bx, mess1
	call print
	start_:
		mov ah, 0x2
		mov dl, 0x0;disk A
		xor dh, dh
		;cilinder, sector
		mov cl, 0x2
		mov ch, 0x0
		
		mov al, 0x8;count !!!!!!!change if the os does not work!!!!!!!
		
		mov bx, 0x800;input
		int 0x13
		
		mov cl, byte [bx]
		cmp cl, 0xAA
		jne StartOs
		add bx, 1
		mov cl, byte [bx]
		cmp cl, 0xBB
		jne StartOs
		add bx, 1
		mov cl, byte [bx]
		cmp cl, 0xCC
		jne StartOs
	downloados:
		mov ah, 0x3
		mov dl, 0x80;hdd
		xor dh, dh
		;cilinder, sector
		mov cl, 0x1
		mov ch, 0x3
		mov bx, 0x800;input
		int 0x13
		
		mov bx, mess3
		call print
	StartOs:
		mov al, 0x8;count !!!!!!!change if the os does not work!!!!!!!
		mov ah, 0x2
		mov dl, 0x80;hdd
		xor dh, dh
		;cilinder, sector
		mov cl, 0x1
		mov ch, 0x3
		mov bx, 0x800;input
		int 0x13
		
		mov bx, mess4
		call print
		
		jmp 0x0:0x803
print:
	;bx = offset message
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
		ret
mess1: db 0xA, 0xD, "loader download", 0
mess2: db "start", 0
mess3: db 0xA, 0xD, "os download", 0
mess4: db 0xA, 0xD, "os start", 0
times 510-$+start db 0
db 0x55, 0xAA