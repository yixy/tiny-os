;;;;;;;;;;;;;;;;;;;;;;;start from [0x0500:0], CS=0x0500, IP=0
;不需要再设置CS,因为CS已经是0x0500
mov ax,0x0050
mov ds,ax
mov es,ax
mov ss,ax
;mov fs,ax
;mov gs,ax
mov sp,0xFF00

;;;;;;;;;;;;;;;;;;;;;;;set cursor position directly
;dh=row,dl=column
mov dx,0x0200

;;;;;;;;;;;;;;;;;;;;;;;using 0x10 print 2. LOADER
mov ax,message
mov bp,ax

;string lenth 15 (Enter LOADER...)
mov cx,0x0E

;ah=0x13, function no.
;al=0x01, print char and the cursor followed
mov ax,0x1301

;bh=0, display 0 page
;bl=2, set color
mov bx,0x02

int 0x10

;;;;;;;;;;;;;;;;;;;;;;;
jmp $

;;;;;;;;;;;;;;;;;;;;;;;end by 0xaa55
message db "Enter LOADER..."
times 512-($-$$) db 0
