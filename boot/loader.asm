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
    ;cs=0x8  第8个字节， 代码段描述符
    ;ds=0x10 第16个字节，数据段描述符
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov esp,0x7c00
    mov ax,0x18
    ;gs 文本现存段描述符
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

call setup_page

sgdt [LOADER_ADDR_BASE+gdtr]

mov ebx,[LOADER_ADDR_BASE+gdtr+2]
or dword [ebx+0x18+4],0xc0000000
add dword [LOADER_ADDR_BASE+gdtr+2],0xc0000000
add esp,0xc0000000

mov eax,PAGE_DIR_TABEL_BASE
mov cr3,eax

mov eax,cr0
or eax,0x80000000
mov cr0,eax

lgdt [LOADER_ADDR_BASE+gdtr]

mov byte [gs:640],'V'
mov byte [gs:641],0x4
mov byte [gs:642],'i'
mov byte [gs:643],0x4
mov byte [gs:644],'r'
mov byte [gs:645],0x4
mov byte [gs:646],' '
mov byte [gs:647],0x4
mov byte [gs:648],'M'
mov byte [gs:649],0x4
mov byte [gs:650],'e'
mov byte [gs:651],0x4
mov byte [gs:652],'m'
mov byte [gs:653],0x4

;;;;;;;;;;;;;;;;;;;;;;;loader_first_sector end
message  db "Enter LOADER..."

;;;;;;;;;;;;;;;;;;;;;;;
forever:
    jmp $

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

GDTLIMIT equ $-gdt

total_mem_bytes dd 0

gdtr:
    gdt_limit  dw GDTLIMIT            ;by byte
    gdt_start  dd LOADER_ADDR_BASE+gdt

ards_buf times 256 db 0     ;
ards_nr dw 0                ;记录ARDS结构体数量


;;;;;;;;;;;;;;;;;;;;;;;创建页表
PG_P        equ   1b
PG_RW_R     equ  00b
PG_RW_W     equ  10b
PG_US_S     equ 000b
PG_US_U     equ 100b

;页目录空间(4KB)清0
setup_page:
    mov ecx,4096    ;循环次数
    mov esi,0
.clear_page_dir:
    mov byte [PAGE_DIR_TABEL_BASE+esi],0
    inc esi
    loop .clear_page_dir

;1. 创建页目录项(PDE)：第768至第1023个页目录项（共256个页目录），对应操作系统1GB内核空间

;初始化第0个页目录项和第768个页目录项：存储页表基址
mov eax, PAGE_DIR_TABEL_BASE
add eax, 0x1000  ;0x1000=4096,eax=页表基址
or  eax, PG_US_U|PG_RW_W|PG_P
mov [PAGE_DIR_TABEL_BASE + 0x0],eax
;0xc0000000的前20位为 0x1100_0000_0000_0000_0000，其中页目录项为768
mov [PAGE_DIR_TABEL_BASE + 0xc00],eax ;0xc00=3072, 3072/4=768

;初始化第769至1022个页目录项（内核其他页表的PDE）：从第2个页表地址开始顺序存储
mov eax,PAGE_DIR_TABEL_BASE
add eax,0x2000
or  eax,PG_US_U|PG_RW_W|PG_P
mov ebx,PAGE_DIR_TABEL_BASE
mov ecx,254
mov esi,769
.create_kernel_pde:
    mov [ebx+esi*4],eax
    inc esi
    add eax,0x1000
    loop .create_kernel_pde

;初始化第1023个页目录项：存储页目录基址
mov eax, PAGE_DIR_TABEL_BASE
mov [PAGE_DIR_TABEL_BASE + 4092],eax

;2. 创建页表项(PTE)
;初始化前256个PTE，指向低端1MB内存
add ebx,0x1000  ;0x1000=4096,ebx=页表基址
mov ecx,256 ;256*4k=1MB
mov esi,0
mov edx, PG_US_U|PG_RW_W|PG_P
.create_pte:
    mov [ebx+esi*4],edx
    add edx,0x1000
    inc esi
    loop .create_pte

ret

;times 1024-($-$$) db 0
