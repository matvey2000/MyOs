use16
org 0x4C00
start:
	;grafic mode
	mov ah, 0
	mov al, 0x5
	int 0x10
	
	;main
	mov al, 0x3
	mov mycarts[0], al
	mov al, 0x4
	mov mycarts[1], al
	mov al, 0x9
	mov mycarts[2], al
	mov al, 0x2
	mov mycarts[3], al
	call draw
	lps:
		;input
		mov ah, 0x0
		int 0x16
		;ax
		
		cmp ax, 0x4800
		je w
		cmp ax, 0x5000
		je s
		cmp ax, 0x1C0D
		je enter_
		w:
			
			jmp continue
		s:
			
			jmp continue
		enter_:
			
			jmp continue
		continue:
			cmp ax, 0x011B
			jne lps
	
	;text mode
	mov ah, 0
	mov al, 0x2
	int 0x10
	
	int 0x20
draw:
	mov cx, 0
	lpsdraw:
		mov bx, cx
		mov dl, mycarts[bx]
		and dl, 00001111b
		
		mov bl, 10
		call printnominal
		
		push cx
		mov cx, 38
		call forward
		pop cx
		
		add cx, 1
		cmp cx, 24
		jb lpsdraw
	ret
forward:
	;cx forward
	xor bh, bh
	mov bl, 10
	lpsforward:
		mov al, ' '
		int 0x10
		sub cx, 1
		cmp cx, 1
		jae lpsforward
	ret
printnominal:
	;dl
	mov ah, 0xe
	xor bh, bh
	
	cmp dl, 0x0
	je endnominal
	cmp dl, 0x5
	je ten
	mov al, ' '
	int 0x10
	cmp dl, 0x4
	jbe number
	cmp dl, 0x6
	je j
	cmp dl, 0x7
	je q
	cmp dl, 0x8
	je k
	cmp dl, 0x9
	je a
	jmp endnominal
	ten:
		mov al, '1'
		int 0x10
		mov al, '0'
		int 0x10
		ret
	number:
		add dl, '5'
		mov al, dl
		int 0x10
		ret
	j:
		mov al, 'J'
		int 0x10
		ret
	q:
		mov al, 'Q'
		int 0x10
		ret
	k:
		mov al, 'K'
		int 0x10
		ret
	a:
		mov al, 'A'
		int 0x10
		ret
	endnominal:
		mov al, ' '
		int 0x10
		ret

mycarts: db 24 dup(0)
hiscarts: db 24 dup(0)