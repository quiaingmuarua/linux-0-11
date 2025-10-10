# Linux 0.01 - 增强版本

在 Ubuntu 18.04/20.04 上可编译的 Linux 0.01，支持 GCC 编译器。

## 特性

- 支持在现代 Ubuntu 64/32 位系统上编译
- 可在 QEMU ver. 2.11.1 和 Bochs ver 2.6 上运行
- **新增**: 完整的 GDB 调试支持
- **新增**: 自动化调试配置 (.gdbinit)
- **新增**: 详细的使用文档

## 快速开始

### 编译内核
```bash
make clean
make
```

### 运行系统
```bash
# 解压硬盘镜像（首次运行时需要）
unzip hd_oldlinux.img.zip

# 启动系统
make run
```

### GDB调试（新功能）

#### 方式一：一键调试
```bash
./debug.sh
```

#### 方式二：手动调试
```bash
# 终端1: 启动调试模式
make debug

# 终端2: 连接GDB
make gdb
```

## 详细使用说明

### 文档目录
- [GDB调试指南](docs/GDB_DEBUG.md) - 完整的GDB调试说明
- [CLion调试指南](docs/CLION_DEBUG.md) - CLion图形化调试配置
- [Makefile使用指南](docs/MAKEFILE_USAGE.md) - 所有Make目标的详细说明

### 可用的Make目标

#### 构建目标
- `make` 或 `make all` - 编译整个内核
- `make clean` - 清理编译文件

#### 运行目标  
- `make run` - 启动系统（图形界面）
- `make run-curses` - 启动系统（字符界面）

#### 调试目标
- `make debug` - 启动QEMU调试模式
- `make debug-curses` - 启动QEMU调试模式（字符界面）
- `make gdb` - 启动GDB调试会话
- `./debug.sh` - 一键式调试脚本

#### 分析目标
- `make dump` - 生成反汇编文件
- `make dep` - 更新依赖关系

### GDB调试功能

项目包含预配置的 `.gdbinit` 文件，提供以下便捷命令：

```bash
# 快速断点设置
bp_main      # 在main函数设置断点
bp_syscall   # 在系统调用入口设置断点
bp_schedule  # 在调度器设置断点
bp_fork      # 在fork系统调用设置断点

# 系统状态查看
show_current # 显示当前进程信息
show_memory  # 显示内存布局
show_idt     # 显示中断向量表
status       # 显示CPU状态和调用栈
```

### 环境要求

- Ubuntu 18.04/20.04 (64/32位)
- GCC编译器
- GNU Make
- QEMU (推荐 ver. 2.11.1+)
- GDB (用于调试)

### 原始信息

原始编译说明: https://mapopa.blogspot.com/2022/09/linux-001-compiling-on-ubuntu-64.html

更现代的代码版本 (使用NASM和Clang): https://github.com/isoux/linux-0.01

