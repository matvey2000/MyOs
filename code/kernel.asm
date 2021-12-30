use16
org 0x800

db 0xAA, 0xBB, 0xCC;my start code
start:
	;init
	mov ax, 0
	mov ds, ax
	mov ax, 0x9000
	mov ss, ax
	mov sp, 0xFFFF
	
	mov ax, deletecomand
	mov bx, 7
	mov dx, createcomand
	call writefile
	
	mov bx, hello
	call print
console:
	mov bx, beginconsole;
	call print
	
	call readstringconsole
	handler:
		mov ax, buffer
		mov dx, formatcomand
		call equals
		je format
		
		mov ax, buffer
		mov dx, deletecomand
		call equals
		je delete
		
		mov ax, buffer
		mov dx, treecomand
		call equals
		je tree
		
		mov ax, buffer
		mov dx, createcomand
		call equals
		je create
		
		jmp MyError
		delete:
			mov bx, writenameplease
			call print
			
			call readstringconsole
			mov dx, buffer
			mov cx, 0
			call resizefile
			
			call deletefile
			jmp console
		format:
			call formatdisk
			
			mov bx, ok
			call print
			jmp console
		tree:
			call readservicesector
			
			mov bx, 0x6C00
			sub bx, 102
			;service sector
			lpstree:
				add bx, 102
				cmp bx, 0x7BFF
				ja console
				
				mov al, byte [bx]
		
				cmp al, 0
				je lpstree;this is 0-sector (no name)
				
				push bx
				mov bx, arrow
				call print
				pop bx
				push bx
				call print
				pop bx
				jmp lpstree
		create:
			;create file
			mov bx, writenameplease
			call print
			
			call readstringconsole
			mov ax, buffer
			call createfile
			
			jmp console
		MyError:
			;error
			mov bx, errorcomand
			call print
			
			jmp console
read:
	;dx = filename
	;ax = buffer (offset)
	push ax
	push bx
	push cx
	push dx
	push ax
	
	call readservicesector
	mov ax, 0x6C00
	sub ax, 102
	
	;service sector
	lpsread:
		add ax, 102
		
		cmp ax, 0x7BFF
		ja errorread
		
		push ax
		push dx
		call equals
		pop dx
		pop ax
		je readmain
		
		jmp lpsread
	readmain:
		add ax, 100
		mov bx, ax
		mov ax, word[bx];start
		add bx, 102
		mov cx, word[bx];end
		pop dx;buffer
		
		lpsreadmain:
			;write sector
			push ax
			push bx
			push cx
			push dx
			mov cx, ax
			mov ah, 0x2
			mov dl, 0x80;hdd
			xor dh, dh
			mov al, 0x1;count
			mov bx, 0x6C00;input
			int 0x13
			pop dx
			pop cx
			pop bx
			
			mov ax, 0x6C00
			readsector:
				push ax
				mov bx, ax
				mov al, byte [bx]
				mov bx, dx
				mov byte [bx], al
				pop ax
				
				add ax, 1
				add dx, 1
				cmp ax, 0x6CFF
				jbe readsector
			pop ax
			
			add ax, 1
			cmp ax, cx
			jb lpsreadmain
		
		jmp endreadfile
	errorread:
		mov bx, errorfilemissing
		call print
		jmp endreadfile
	endreadfile:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
writefile:
	;ax = code (offset)
	;bx = lenght code
	;dx = filename
	push ax
	push bx
	push cx
	push dx
	push ax
	
	mov cl, 9
	shr bx, cl
	
	mov cx, bx
	call resizefile
	
	call readservicesector
	mov ax, 0x6C00
	sub ax, 102
	
	;service sector
	lpswrite:
		add ax, 102
		
		cmp ax, 0x7BFF
		ja errorwrite
		
		push ax
		push dx
		call equals
		pop dx
		pop ax
		je writemain
		
		jmp lpswrite
	writemain:
		add ax, 100
		mov bx, ax
		mov ax, word[bx];start file
		add cx, ax;end
		pop dx
		
		add ah, 3
		
		cmp al, 0
		je correctwrite1
		jmp continuewrite1
		correctwrite1:
			add ax, 1
			add cx, 1
	continuewrite1:
		
		writelpsmain:
			mov bx, 0x6C00
			writesector:
				push dx
				push bx
				mov bx, dx
				mov dl, byte[bx]
				pop bx
				mov byte[bx], dl
				pop dx
				
				add bx, 1
				add dx, 1
				cmp bx, 0x6CFF
				jbe writesector
			
			;write sector
			push ax
			push bx
			push cx
			push dx
			mov cx, ax
			mov ah, 0x3
			mov dl, 0x80;hdd
			xor dh, dh
			mov al, 0x1;count
			mov bx, 0x6C00;input
			int 0x13
			pop dx
			pop cx
			pop bx
			pop ax
			
			add ax, 1
			cmp al, 0
			je correctwrite
			jmp continuewrite
			correctwrite:
				add ax, 1
				add cx, 1
			continuewrite:
				cmp ax, cx
				jb writelpsmain
		
		jmp endwrite
	errorwrite:
		pop ax
		mov bx, errorfilemissing
		call print
		jmp endwrite
	endwrite:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
deletefile:
	;dx = filename (offset)
	push ax
	push bx
	push cx
	push dx
	
	call readservicesector
	mov ax, 0x6C00
	sub ax, 102
	
	;service sector
	lpsdelete:
		add ax, 102
		
		cmp ax, 0x7BFF
		ja errordelete
		
		push ax
		push dx
		call equals
		pop dx
		pop ax
		je deletemain
		
		jmp lpsdelete
	deletemain:
		;delete
		mov bx, ax
		mov byte [bx], 0
		call writeservicesector
		jmp enddelete
	errordelete:
		mov bx, errorfilemissing
		call print
		jmp enddelete
	enddelete:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
resizefile:
	push ax
	push bx
	push cx
	push dx
	;dx = filename (offset)
	;cx = new size
	call readservicesector
	mov ax, 0x6C00
	sub ax, 102
	
	;service sector
	lpsresize:
		add ax, 102
		
		cmp ax, 0x7BFF
		ja errorresize
		
		call equals
		je resizemain
		
		jmp lpsresize
	resizemain:
		;rewrite
		mov bx, ax
		add bx, 202
		
		mov dx, word[bx]
		sub bx, 102
		sub dx, word[bx]
		
		mov bx, ax
		add bx, 100
		
		cmp cx, dx
		jae resizeaddcorrect
		sub dx, cx
		mov cl, 0;sub
		
		jmp resizecontinue
		resizeaddcorrect:
			sub cx, dx
			mov dx, cx;correct
			
			mov cl, 1;add
			jmp resizecontinue
	resizecontinue:
		add bx, 102
		cmp bx, 0x7BFF
		ja endresize
		
		cmp cl, 1
		je resizeadd
		sub word[bx], dx
		jmp resizecontinue
		
		resizeadd:
			add word[bx], dx
			jmp resizecontinue
	endresize:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	errorresize:
		mov bx, errorfilemissing
		call print
		jmp endresize
formatdisk:
	push bx
	mov bx, 0x6C00
	;service sector
	lpsformat:
		mov byte[bx], 0
		
		add bx, 1
		
		cmp bx, 0x7BFF
		jb lpsformat
	call writeservicesector
	pop bx
	ret
readstringconsole:
	push ax
	push bx
	push cx
	push dx
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
		je endread
		
		mov bx, cx
		mov buffer[bx], al
		add cx, 1
		
		jmp input
	endread:
		mov al, 0x0
		mov bx, cx
		mov buffer[bx], al
		
		;return buffer
		pop dx
		pop cx
		pop bx
		pop ax
		ret
readservicesector:
	push ax
	push bx
	push cx
	push dx
	
	mov ah, 0x2
	mov dl, 0x80;hdd
	xor dh, dh
	;cilinder, sector
	mov cl, 0x1
	mov ch, 0x1
	mov al, 0x8;count
	
	mov bx, 0x6C00;input
	
	int 0x13
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
writeservicesector:
	push ax
	push bx
	push cx
	push dx
	
	mov ah, 0x3
	mov dl, 0x80;hdd
	xor dh, dh
	;cilinder, sector
	mov cl, 0x1
	mov ch, 0x1
	mov al, 0x8;count
	
	mov bx, 0x6C00;input
	
	int 0x13
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
createfile:
	;ax = name file(offset)
	push ax
	push bx
	push cx
	push dx
	
	push ax
	
	;read
	call readservicesector
	
	;main
	mov bx, 0x6C00
	;service sector
	lps_file:
		mov al, byte [bx]
		
		cmp al, 0
		je createfile_;this is 0-sector (no name)
		jmp begincreate
		createfile_:
			pop ax
			
			writename:
				push bx
				mov bx, ax
				mov cl, byte [bx]
				pop bx
				
				mov byte [bx], cl
				cmp cl, 0
				je endcreate
				
				add bx, 1
				add ax, 1
				jmp writename
	begincreate:
		add bx, 102
		cmp bx, 0x7BFF
		jb lps_file
		jmp err
	err:
		;error size
		mov bx, errorsrevicesector
		call print
		jmp createret
	endcreate:
		;write
		call writeservicesector
		jmp createret
	createret:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
equals:
	;ax - s1
	;dx - s2
	push ax
	push bx
	push cx
	push dx
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
		pop dx
		pop cx
		pop bx
		pop ax
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
hello: db 0xA, 0xD, "hello, this is MyOs", 0
ok: db 0xA, 0xD, "OK", 0
beginconsole: db 0xA, 0xD, ">>", 0
arrow: db 0xA, 0xD, "---->", 0
errorcomand: db 0xA, 0xD, "Error: invalid command", 0
errorsrevicesector: db 0xA, 0xD, "Error: the service sector is crowded", 0
errorfilemissing: db 0xA, 0xD, "Error: this file is missing", 0
writenameplease: db 0xA, 0xD, "please, write name:", 0
;comands
formatcomand: db "format", 0
deletecomand: db "delete", 0
treecomand: db "tree", 0
createcomand: db "create", 0

buffer: db 100 dup(0)