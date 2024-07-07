;;;;;;;;;;;;;;;;;;;;;;;0x10 clear display
;ah=0x06 clear display
;al=lines,0 means all
mov ax,0x0600

;bh=lines properties
mov bx,0x0700

;CL,CH--->(0,0)
mov cx,0

;DL,DH--->(79,24)
;DH=0x18=24
;DL=0x4f=79
;VGA mode 25rows, per row: 80character
mov dx,0x184f

int 0x10

;;;;;;;;;;;;;;;;;;;;;;;0x10 print 2. LOADER
mov byte [gs:0x00],'2'
mov byte [gs:0x01],0xA4

mov byte [gs:0x02],' '
mov byte [gs:0x03],0xA4

mov byte [gs:0x04],'L'
mov byte [gs:0x05],0xA4

mov byte [gs:0x06],'O'
mov byte [gs:0x07],0xA4

mov byte [gs:0x08],'A'
mov byte [gs:0x09],0xA4

mov byte [gs:0x10],'D'
mov byte [gs:0x11],0xA4
;;;;;;;;;;;;;;;;;;;;;;;
jmp $

;;;;;;;;;;;;;;;;;;;;;;;end by 0xaa55
times 510-($-$$) db 0
db 0x55,0xaa
