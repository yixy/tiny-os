# bochs

## 1 download

```shell
git clone https://github.com/bochs-emu/Bochs.git

export BXROOT=/path_to_bochs
export BXSHARE=$BXROOT/share/bochs
```

## 2 configure & compiling

如果要开启远程调试则需要将`--enable-debugger`调整为`--enable-gdb-stub`。

```shell
./configure --prefix=/opt/bochs \
--enable-debugger \
--enable-disasm \
--enable-iodebug \
--enable-x86-debugger \
--with-x \
--with-x11

make

make install
```

bochs2.7以上`configure: WARNING: unrecognized options: --enable-disasm`这个选项不可用了。

## 3 start

创建空硬盘验证安装是否成功。

```shell
//  ata0-master: type=disk, path="hd60M.img", mode=flats
./bin/bximage
```

指定配置文件并启动。

```shell
./bin/bochs -f bochsrc.txt
```