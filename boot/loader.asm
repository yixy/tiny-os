%include "boot.inc"

;;;;;;;;;;;;;;;;;;;;;;;start from [0x0500:0], CS=0x0050, IP=0
;不需要再设置CS,因为CS已经是0x0500
mov ax,LOADER_ADDR_SREG_REAL
mov ds,ax
mov es,ax
mov ss,ax
;mov fs,ax
;mov gs,ax
mov sp,0x7c00

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

;;;;;;;;;;;;;;;;;;;;;;;获取内存信息
;以句点.开头的标签被视为局部标签，这意味着它和它前面的非局部标签相关联。
;下面也可以不使用局部标签。不过如果有多种获取内存的方法，则局部标签就可以派上用场了。

load_start:
    xor ebx,ebx         ;清零
    mov edx,0x534d4150  ;循环体中不改变
    mov di,ards_buf     ;

.e820_mem_get_loop:
    mov eax,0x0000e820  ;循环中会改变，每次需要重设功能号
    mov ecx,20
    int 0x15
    jc forever
    add di,cx
    inc word [ards_nr]
    cmp ebx,0
    jnz .e820_mem_get_loop

    mov cx,[ards_nr]
    mov ebx,ards_buf
    xor edx,edx

.find_max_mem_area:
    mov eax,[ebx]
    add eax,[ebx+8]
    add ebx,20
    cmp edx,eax
    jge .next_ards
    mov edx,eax     ;edx为总内存大小

.next_ards:
    loop .find_max_mem_area
    jmp .mem_get_ok

.mem_get_ok:
    mov [total_mem_bytes],edx

;;;;;;;;;;;;;;;;;;;;;;;计算GDT所在的地址 
	 
lgdt [gdtr]

in al,0x92                         ;南桥芯片内的端口 
or al,0000_0010B
out 0x92,al                        ;打开A20

cli                                ;保护模式下中断机制尚未建立，应禁止中断 

mov eax,cr0                         ;PSW(cr0)是32位
or eax,1
mov cr0,eax                        ;设置PE位

;刷新流水线跳转进入保护模式
;0x8是代码段描述符（gdt中第8个字节开始）
jmp dword 0x8:LOADER_ADDR_BASE+protect_start   ;xprotect_start只是相对偏移量，所以还要加上基址0x500

;;;;;;;;;;;;;;;;;;;;;;;32bit protect mode
;[BITS 32] 是用于在 NASM (Netwide Assembler) 汇编器中的一个伪指令，用来指示汇编器按照 32 位指令集进行汇编。这在编写保护模式代码时非常重要，因为它明确了代码是针对 32 位 CPU 模式的。
[bits 32]
protect_start:
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov esp,0x7c00
    mov ax,0x18
    mov gs,ax

    mov byte gs:[480],'P'   ;在第4行打印。一行80个字符，每个字符占2个字节
    mov byte gs:[481],0x4   ;0x2绿，0x4红
    mov byte gs:[482],'r'
    mov byte gs:[483],0x4
    mov byte gs:[484],'o'
    mov byte gs:[485],0x4
    mov byte gs:[486],'t'
    mov byte gs:[487],0x4
    mov byte gs:[488],'e'
    mov byte gs:[489],0x4
    mov byte gs:[490],'c'
    mov byte gs:[491],0x4
    mov byte gs:[492],'t'
    mov byte gs:[493],0x4
    mov byte gs:[494],'M'
    mov byte gs:[495],0x4
    mov byte gs:[496],'o'
    mov byte gs:[497],0x4
    mov byte gs:[498],'d'
    mov byte gs:[499],0x4
    mov byte gs:[500],'e'
    mov byte gs:[501],0x4

;;;;;;;;;;;;;;;;;;;;;;;
forever:
    jmp $

;;;;;;;;;;;;;;;;;;;;;;;创建页表
PG_P        equ   1b
PG_RW_R     equ  00b
PG_RW_W     equ  10b
PG_US_S     equ 000b
PG_US_U     equ 100b

;页目录空间清0
setup_page:
    mov ecx,4096
    mov esi,0
.clear_page_dir:
    move byte [PAGE_DIR_TABEL_BASE+esi],0
    inc esi
    loop .clear_page_dir

;创建页目录项
.create_pde:
    mov eax, PAGE_DIR_TABEL_BASE
    add eax,0x1000  ;0x1000=4096
    mov ebx,eax     ;ebx=页表基址

    or eax, PG_US_U|PG_RW_W|PG_P

    mov [PAGE_DIR_TABEL_BASE + ],eax

    mov [PAGE_DIR_TABEL_BASE + ],eax

    sub eax,0x1000
    mov [PAGE_DIR_TABEL_BASE + ],eax

;;;;;;;;;;;;;;;;;;;;;;;loader_first_sector end
message  db "Enter LOADER..."

;times 512-($-$$) db 0
;;;;;;;;;;;;;;;;;;;;;;;loader_first_sector end

;;;;;;;;;;;;;;;;;;;;;;;0x900
gdt:
    ;8bytes per gdt item

    first_sd_1 dw 0x0000
    first_sd_2 dw 0x0000
    first_sd_3 dw 0x0000
    first_sd_4 dw 0x0000

    code_sd_1  dw 0xFFFF
    code_sd_2  dw 0x0000
    code_sd_3  dw 0x9A00    ;type=1010b
    code_sd_4  dw 0x00CF

    data_sd_1  dw 0xFFFF
    data_sd_2  dw 0x0000
    data_sd_3  dw 0x9200    ;type=0010b
    data_sd_4  dw 0x00CF

    video_sd_1  dw 0x0007
    video_sd_2  dw 0x8000   ;0xB8000 文本显存开始地址（低16位）
    video_sd_3  dw 0x920b   ;type=0010b
    video_sd_4  dw 0x00C0

total_mem_bytes dd 0

gdtr:
    gdt_limit  dw 0x0800            ;by byte, 256 gdt items, 256*8byte=2048byte
    gdt_start  dd LOADER_ADDR_BASE+gdt

ards_buf times 256 db 0     ;
ards_nr dw 0                ;记录ARDS结构体数量


;times 1024-($-$$) db 0
