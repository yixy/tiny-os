LOADER_ADDR_SREG_REAL equ 0x50
LOADER_ADDR_BASE equ 0x500

;KERNEL_ADDR_BASE equ 0x900

;这里选取页目录表基址为0x1000，是为了方便最开始时（刚打开分页时），操作系统页目录和页表项的初始化
;因为，PDE或PTE的高20位存储entity的地址信息，低12位为其他标识位
PAGE_DIR_TABEL_BASE equ 0x1000