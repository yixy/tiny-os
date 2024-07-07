# boot

## 1 compile

```shell
nasm -o mbr.bin mbr.s
nasm -o loader.bin loader.s
```

## 2 write into hd

```shell
dd if=./mbr.bin \
of=/path_to_dir/hd60M.img \
bs=512 count=1 conv=notrunc
```