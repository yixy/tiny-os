SECTION MBR vstart=0x7c00
    mov ax,cs
    mov dx,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00
    mov ax,0xb800
    mov gs,ax

    ;;;;;;;;;;;;;;;;;;;;;;;0x10 clear display

    ;ah=0x06 rolling up lines
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

    int 10h

    ;;;;;;;;;;;;;;;;;;;;;;;0x10 print 1. MBR
    mov byte [gs:0x00],'1'
    mov byte [gs:0x01],0xA4

    mov byte [gs:0x02],' '
    mov byte [gs:0x03],0xA4

    mov byte [gs:0x04],'M'
    mov byte [gs:0x05],0xA4

    mov byte [gs:0x06],'B'
    mov byte [gs:0x07],0xA4

    mov byte [gs:0x08],'R'
    mov byte [gs:0x09],0xA4

    ;;;;;;;;;;;;;;;;;;;;;;;
    jmp $

    ;;;;;;;;;;;;;;;;;;;;;;;end by 0xaa55
    times 510-($-$$) db 0
    db 0x55,0xaa
