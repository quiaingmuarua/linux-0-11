# Linux 0.01 Makefile使用指南

本文档介绍Linux 0.01项目中Makefile的所有目标和使用方法。

## 基本构建目标

### `make` 或 `make all`
编译整个Linux 0.01内核，生成可启动的Image文件。

**依赖关系:**
```
Image ← boot/boot + tools/system + tools/build
tools/system ← boot/head.o + init/main.o + kernel/kernel.o + mm/mm.o + fs/fs.o + lib/lib.a
```

**编译过程:**
1. 编译各子系统（kernel、mm、fs、lib）
2. 链接生成tools/system
3. 构建引导扇区boot/boot
4. 使用tools/build合并生成最终Image

### `make clean`
清理所有编译生成的文件。

**清理内容:**
- 主目录: Image, System.map, tmp_make, boot/boot, core
- init目录: *.o文件
- boot目录: *.o文件  
- tools目录: system, build, system.bin
- 各子目录: 调用子目录的make clean

## 运行目标

### `make run`
使用QEMU启动Linux 0.01（图形界面模式）。

**QEMU参数:**
- `-drive format=raw,file=Image,index=0,if=floppy`: 软盘镜像
- `-boot a`: 从软盘启动
- `-hdb hd_oldlinux.img`: 硬盘镜像
- `-m 8`: 8MB内存
- `-machine pc-i440fx-2.5`: 机器类型

### `make run-curses`
使用QEMU启动Linux 0.01（字符界面模式，适合无GUI环境）。

**额外参数:**
- `-display curses`: 使用curses字符界面

## 调试目标

### `make debug`
启动QEMU调试模式（图形界面），暂停等待GDB连接。

**调试参数:**
- `-s`: 在TCP端口1234启用GDB服务器
- `-S`: CPU启动时暂停

**使用方法:**
```bash
# 终端1: 启动调试模式
make debug

# 终端2: 连接GDB
gdb tools/system
(gdb) target remote localhost:1234
```

### `make debug-curses`
启动QEMU调试模式（字符界面）。

## 分析目标

### `make dump`
生成系统的反汇编文件System.dum。

**生成内容:**
- 完整的tools/system反汇编代码
- 使用Intel汇编语法
- 包含所有段的详细信息

**用途:**
- 分析编译后的代码
- 调试汇编级别问题
- 学习系统调用实现

## 维护目标

### `make dep`
生成和更新依赖关系。

**处理范围:**
- 主目录的init/*.c文件
- fs子目录
- kernel子目录
- mm子目录

**依赖信息位置:**
- 主Makefile底部的"### Dependencies"部分
- 各子目录的Makefile中

### `make backup`
创建项目备份。

**备份过程:**
1. 执行make clean清理临时文件
2. 打包整个linux目录
3. 使用compress16压缩
4. 生成backup.Z文件（位于上级目录）

## 子系统构建

### `make kernel/kernel.o`
只编译内核子系统。

**包含模块:**
- 进程调度 (sched.c)
- 系统调用 (sys.c, system_call.s)
- 中断处理 (traps.c)
- 控制台 (console.c)
- 等等

### `make mm/mm.o`
只编译内存管理子系统。

**包含模块:**
- 内存分配 (memory.c)
- 页面管理 (page.s)

### `make fs/fs.o`
只编译文件系统子系统。

**包含模块:**
- 文件操作 (open.c, read_write.c)
- 目录操作 (namei.c)
- 缓冲区管理 (buffer.c)
- 等等

### `make lib/lib.a`
编译C库。

**包含模块:**
- 标准库函数 (string.c, ctype.c)
- 系统调用包装 (open.c, close.c, write.c等)

## 工具构建

### `make tools/build`
编译构建工具。

**功能:**
- 合并引导扇区和系统镜像
- 设置正确的系统大小信息
- 生成最终的可启动Image

### `make boot/boot`
构建引导扇区。

**构建过程:**
1. 计算tools/system的大小
2. 生成SYSSIZE宏定义
3. 与boot.s合并编译
4. 生成16位引导代码

## 编译选项说明

### C编译器选项 (CFLAGS)
```
-Wall                    # 启用所有警告
-O                      # 优化代码
-std=gnu89              # 使用GNU C89标准
-fstrength-reduce       # 强度削减优化
-fomit-frame-pointer    # 省略帧指针
-fno-stack-protector    # 禁用栈保护
-fno-builtin           # 禁用内建函数
-g                     # 包含调试信息
-m32                   # 生成32位代码
```

### 链接器选项 (LDFLAGS)
```
-M                     # 生成链接映射
-Ttext 0              # 代码段起始地址为0
-e startup_32         # 入口点为startup_32
```

## 使用示例

### 完整构建和运行
```bash
make clean          # 清理旧文件
make               # 编译内核
make run           # 运行系统
```

### 调试会话
```bash
make clean          # 清理
make               # 编译（包含调试信息）
make debug         # 启动调试模式

# 在另一个终端
gdb tools/system
(gdb) target remote localhost:1234
(gdb) break main
(gdb) continue
```

### 代码分析
```bash
make dump          # 生成反汇编
less System.dum    # 查看反汇编代码
make dep           # 更新依赖关系
```

### 只编译特定子系统
```bash
make kernel/kernel.o    # 只编译内核
make mm/mm.o           # 只编译内存管理
make fs/fs.o           # 只编译文件系统
```

## 故障排除

### 编译错误
1. 检查工具链是否正确安装（gcc, as, ld等）
2. 确保使用32位编译环境
3. 检查头文件路径

### 链接错误
1. 确保所有子系统都已编译
2. 检查Symbol.map是否生成
3. 验证链接脚本参数

### 运行错误
1. 确保QEMU已安装
2. 检查Image文件是否正确生成
3. 验证硬盘镜像hd_oldlinux.img是否存在

### 调试连接失败
1. 确保使用了-s -S参数
2. 检查端口1234是否被占用
3. 验证tools/system包含调试信息

## 目标依赖图

```
Image
├── boot/boot
│   ├── boot/boot.s
│   └── tools/system
├── tools/system.bin (由tools/system生成)
└── tools/build

tools/system
├── boot/head.o (boot/head.s)
├── init/main.o (init/main.c)
├── kernel/kernel.o
│   └── kernel/*.c, kernel/*.s
├── mm/mm.o
│   └── mm/*.c, mm/*.s  
├── fs/fs.o
│   └── fs/*.c
└── lib/lib.a
    └── lib/*.c
```

## 性能优化

### 并行编译
虽然原始Makefile不支持并行编译，但可以手动并行编译子系统：
```bash
# 在不同终端中同时执行
make kernel/kernel.o &
make mm/mm.o &
make fs/fs.o &
make lib/lib.a &
wait
make tools/system
```

### 增量编译
只重新编译修改过的部分：
```bash
# 只修改了内核文件
make kernel/kernel.o
make tools/system
make Image
```
