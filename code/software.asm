use16
org 0x4C00
start:
	;grafic mode
	mov ah, 0
	mov al, 0x5
	int 0x10
	
	;main
	mov al, 0x13
	mov mycarts[0], al
	mov al, 0x24
	mov mycarts[1], al
	mov al, 0x39
	mov mycarts[2], al
	mov al, 0x42
	mov mycarts[3], al
	
	mov al, 0x13
	mov hiscarts[0], al
	mov al, 0x24
	mov hiscarts[1], al
	mov al, 0x39
	mov hiscarts[2], al
	lps:
		;cursor
		xor bh, bh
		xor dx, dx
		mov ah, 0x2
		int 0x10
		
		call draw
		
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
			cmp ax, 0x011B;esc
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
		
		push dx
		and dl, 00001111b
		mov bl, 10
		call printnominal
		pop dx
		
		push cx
		mov cl, 4
		shr dl, cl
		mov ch, 1
		pop cx
		
		cmp dl, 0
		je zerodh
		
		onedh:
			mov dh, 1
			sub dl, 1
			
			jmp continuedraw
		zerodh:
			mov dh, 0
	continuedraw:
		call printsuit
		
		push cx
		mov cx, 16
		call forward
		pop cx
		
		;print |
		xor bh, bh
		mov bl, 10
		mov al, '|'
		int 0x10
		
		push cx
		mov cx, 17
		call forward
		pop cx
		
		;print ?
		mov bx, cx
		mov dl, hiscarts[bx]
		
		xor bh, bh
		mov bl, 10
		
		cmp dl, 0
		je noprint
		cart:
			mov al, '?'
			jmp continuedraw2
		noprint:
			mov al, ' '
		continuedraw2:
			int 0x10
			
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
	
	cmp dl, 0x5
	je ten
	mov al, ' '
	int 0x10
	cmp dl, 0x0
	je endnominal
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
printsuit:
	;dl - suits
	;dh - quantity
	mov ah, 0xe
	xor bh, bh
	
	cmp dh, 0
	je no
	
	mov al, '('
	int 0x10
	main:
		push dx
		and dl, 00000011b
		cmp dl, 0x3
		je Ssuit
		cmp dl, 0x2
		je Csuit
		cmp dl, 0x1
		je Hsuit
	Dsuit:
		mov al, 'D'
		jmp continuesuit
	Hsuit:
		mov al, 'H'
		jmp continuesuit
	Csuit:
		mov al, 'C'
		jmp continuesuit
	Ssuit:
		mov al, 'S'
	continuesuit:
		pop dx
		int 0x10
		push cx
		mov cl, 2
		shr dl, cl
		pop cx
		
		sub dh, 1
		cmp dh, 1
		jae comma
		
		mov al, ')'
		int 0x10
		ret
	comma:
		mov al, ','
		int 0x10
		jmp main
	no:
		push cx
		mov cx, 3
		call forward
		pop cx
		ret

mycarts: db 24 dup(0)
hiscarts: db 24 dup(0)