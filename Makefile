
boot_compile:
	nasm -o bin/mbr.bin boot/mbr.s
	nasm -o bin/loader.bin boot/loader.s

#写10MB的img文件，如果img太小，比如只有前两个扇区，BIOS是无法识别其为MBR的。
boot_image:boot_compile
	dd if=bin/mbr.bin \
	of=bin/hd60M.img \
	bs=512 count=1 conv=notrunc

	dd if=bin/loader.bin \
	of=bin/hd60M.img \
	bs=512 count=1 seek=1 conv=notrunc

	dd if=/dev/zero \
	of=bin/hd60M.img \
	bs=512 count=20478 seek=2 conv=notrunc

copy_config:
	cp bochs/bochsrc.txt bin/

build: boot_image copy_config

clean: 
	rm -rf bin/*