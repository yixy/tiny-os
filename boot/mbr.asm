;;;;;;;;;;;;;;;;;;;;;;;start from [0:0x7c00], CS=0, IP=0x7c00
mov ax,0x07c0
mov ds,ax
mov es,ax
mov ss,ax
;mov fs,ax
mov ax,0xB800    ;文本显存0xB8000
mov gs,ax
mov sp,0xFF00

;;;;;;;;;;;;;;;;;;;;;;;using 0x10 clear display

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

int 0x10

;;;;;;;;;;;;;;;;;;;;;;;using 0x10 get cursor position
;;;function no.
;mov ah,0x03
;;;display page
;mov bh,0

;int 0x10
;;;output: ch=start_line,cl=end_line,dh=row,dl=column
;;;using dx later

;;;;;;;;;;;;;;;;;;;;;;;直接向文本区显存写数据
mov byte gs:[0],'v'
mov byte gs:[1],0x4 ;0x2绿，0x4红
mov byte gs:[2],'7'
mov byte gs:[3],0x4 ;0x2绿，0x4红

;;;;;;;;;;;;;;;;;;;;;;;set cursor position directly
;dh=row,dl=column
mov dx,0x0100

;;;;;;;;;;;;;;;;;;;;;;;using 0x10 print 1. MBR
mov ax,message
mov bp,ax

;string lenth 12 (Enter MBR...)
mov cx,0x0c

;ah=0x13, function no.
;al=0x01, print char and the cursor followed
mov ax,0x1301

;bh=0, display 0 page
;bl=2, set color
mov bx,0x02

int 0x10

;;;;;;;;;;;;;;;;;;;;;;;using 0x13 load loader to mem
;ah=功能号，读扇区
;al=读取扇区数
mov ax,0x0202   ;根据loader.s的大小，读取2个扇区的内容

;dl=drive0 ,0x80表示第1块硬盘
;dh=head0
mov dx,0x0080

;ch=track0
;cl=sector2
mov cx,0x0002

mov bx,0x0050
mov es,bx
mov bx,0
int 0x13
;output: es:bx

;;;;;;;;;;;;;;;;;;;;;;;jump to loader
jmp 0x0050:0

;;;;;;;;;;;;;;;;;;;;;;;end by 0xaa55
message db "Enter MBR..."
times 510-($-$$) db 0
db 0x55,0xaa
